export const MAX_BYTES = 5 * 1024 * 1024;
export const BUCKETS = new Set(['profile-images', 'event-images']);
export class RequestError extends Error {
  constructor(status, message) { super(message); this.status = status; }
}
export function parseReference(reference) {
  if (typeof reference !== 'string' || reference.length > 300) throw new RequestError(400, 'Invalid photo reference.');
  let url;
  try { url = new URL(reference); } catch { throw new RequestError(400, 'Invalid photo reference.'); }
  if (url.protocol !== 'supabase:' || !BUCKETS.has(url.host) || url.search || url.hash || url.username || url.password || reference !== `supabase://${url.host}${url.pathname}` ||
      !/^\/[A-Za-z0-9_-]{1,128}\/[0-9a-f]{8}-(?:[0-9a-f]{4}-){3}[0-9a-f]{12}\.(jpg|png|webp)$/.test(url.pathname)) {
    throw new RequestError(400, 'Invalid photo reference.');
  }
  return {bucket: url.host, path: url.pathname.slice(1)};
}
export function requireOwner(path, uid) {
  if (path.split('/')[0] !== uid) throw new RequestError(403, 'You can only remove your own photos.');
}
export function requireFirebaseClaims(payload, now = Math.floor(Date.now() / 1000)) {
  if (typeof payload.sub !== 'string' || !/^[A-Za-z0-9_-]{1,128}$/.test(payload.sub) ||
      typeof payload.iat !== 'number' || payload.iat < 0 || payload.iat > now + 5 ||
      typeof payload.auth_time !== 'number' || payload.auth_time < 0 || payload.auth_time > now + 5 ||
      typeof payload.exp !== 'number' || payload.exp <= now) {
    throw new RequestError(401, 'Please sign in again.');
  }
  return payload.sub;
}
export function validateImage(bytes, mime) {
  if (!bytes.length || bytes.length > MAX_BYTES) throw new RequestError(413, 'Choose an image no larger than 5 MB.');
  const jpeg = bytes.length >= 3 && bytes[0] === 255 && bytes[1] === 216 && bytes[2] === 255;
  const png = bytes.length >= 8 && [137,80,78,71,13,10,26,10].every((b,i) => bytes[i] === b);
  const text = (from, to) => new TextDecoder().decode(bytes.slice(from, to));
  const webp = bytes.length >= 12 && text(0,4) === 'RIFF' && text(8,12) === 'WEBP';
  if (mime === 'image/jpeg' && jpeg) return 'jpg';
  if (mime === 'image/png' && png) return 'png';
  if (mime === 'image/webp' && webp) return 'webp';
  throw new RequestError(400, 'Choose a JPEG, PNG or WebP image.');
}
export async function readLimited(request, limit = MAX_BYTES) {
  const declared = Number(request.headers.get('content-length'));
  if (declared > limit) throw new RequestError(413, 'File is too large.');
  const reader = request.body?.getReader();
  if (!reader) return new Uint8Array();
  const chunks = []; let size = 0;
  try {
    while (true) {
      const {done, value} = await reader.read();
      if (done) break;
      size += value.length;
      if (size > limit) { await reader.cancel(); throw new RequestError(413, 'File is too large.'); }
      chunks.push(value);
    }
  } finally { reader.releaseLock(); }
  const bytes = new Uint8Array(size); let offset = 0;
  for (const chunk of chunks) { bytes.set(chunk, offset); offset += chunk.length; }
  return bytes;
}
