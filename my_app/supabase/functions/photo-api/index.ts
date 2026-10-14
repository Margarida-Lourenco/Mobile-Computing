import { createClient } from 'npm:@supabase/supabase-js@2';
import { createRemoteJWKSet, jwtVerify } from 'npm:jose@6';
import { BUCKETS, RequestError, parseReference, requireOwner, requireFirebaseClaims,
  validateImage, readLimited } from './security.mjs';

const firebaseProject = Deno.env.get('FIREBASE_PROJECT_ID') ?? 'cls055-26-project';
const keys = createRemoteJWKSet(new URL(
  'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com'));
const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-image-bucket, x-client-info',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Cache-Control': 'no-store',
};
const json = (body: unknown, status = 200) => Response.json(body, {status, headers: cors});

Deno.serve(async (request: Request) => {
  if (request.method === 'OPTIONS') return new Response(null, {status: 204, headers: cors});
  if (request.method !== 'POST') return json({error: 'Use POST.'}, 405);
  try {
    const token = /^Bearer (.+)$/.exec(request.headers.get('authorization') ?? '')?.[1];
    if (!token) throw new RequestError(401, 'Please sign in first.');
    let uid: string;
    try {
      const {payload} = await jwtVerify(token, keys, {
        issuer: `https://securetoken.google.com/${firebaseProject}`,
        audience: firebaseProject,
        algorithms: ['RS256'],
        requiredClaims: ['exp', 'iat', 'sub', 'auth_time', 'aud', 'iss'],
        clockTolerance: 5,
      });
      uid = requireFirebaseClaims(payload);
    } catch { throw new RequestError(401, 'Please sign in again.'); }

    // These keys remain inside the Supabase function and are never returned.
    const secretKeys = JSON.parse(Deno.env.get('SUPABASE_SECRET_KEYS') ?? '{}');
    const secret = secretKeys.default ?? Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    const url = Deno.env.get('SUPABASE_URL');
    if (!secret || !url) throw new RequestError(503, 'Photo service is not configured.');
    const storage = createClient(url, secret, {
      auth: {persistSession: false, autoRefreshToken: false},
    }).storage;
    const action = new URL(request.url).searchParams.get('action');
    if (action === 'upload') {
      const bucket = request.headers.get('x-image-bucket') ?? '';
      if (!BUCKETS.has(bucket)) throw new RequestError(400, 'Invalid image bucket.');
      const mime = (request.headers.get('content-type') ?? '').split(';')[0];
      const bytes = await readLimited(request);
      const extension = validateImage(bytes, mime);
      const path = `${uid}/${crypto.randomUUID()}.${extension}`;
      const {error} = await storage.from(bucket).upload(path, bytes, {
        contentType: mime, upsert: false, cacheControl: '3600',
      });
      if (error) { console.error('Storage upload failed:', error.message); throw new RequestError(502, 'Could not upload photo. Please try again.'); }
      return json({reference: `supabase://${bucket}/${path}`});
    }
    if (action !== 'read' && action !== 'delete') throw new RequestError(400, 'Unknown action.');
    const bytes = await readLimited(request, 4096);
    let body;
    try { body = JSON.parse(new TextDecoder().decode(bytes)); }
    catch { throw new RequestError(400, 'Invalid request.'); }
    const {bucket, path} = parseReference(body?.reference);
    if (action === 'delete') {
      requireOwner(path, uid);
      const {error} = await storage.from(bucket).remove([path]);
      if (error) throw new RequestError(502, 'Could not remove photo.');
      return json({ok: true});
    }
    // Photos are visible to signed-in members, but the buckets remain private.
    const {data, error} = await storage.from(bucket).createSignedUrl(path, 3600);
    if (error) throw new RequestError(404, 'Photo is unavailable.');
    return json({url: data.signedUrl});
  } catch (error) {
    if (error instanceof RequestError) return json({error: error.message}, error.status);
    console.error('Photo request failed:', error instanceof Error ? error.message : 'unknown error');
    return json({error: 'Photo service is temporarily unavailable.'}, 503);
  }
});
