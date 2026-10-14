import {test} from 'node:test';
import assert from 'node:assert/strict';
import {MAX_BYTES, parseReference, requireOwner, requireFirebaseClaims,
  validateImage, readLimited} from './security.mjs';
const id = '12345678-1234-1234-1234-123456789abc';
const ref = `supabase://event-images/member/${id}.jpg`;

test('private references accept only known buckets and canonical generated paths', () => {
  assert.deepEqual(parseReference(ref), {bucket:'event-images', path:`member/${id}.jpg`});
  for (const value of [ref+'?x=1', ref+'#x', 'https://example.com/photo.jpg',
    ref.replace('event-images','unknown'), ref.replace('member/','member/../other/'),
    ref.replace('member/','member%2fother/'), ref.replace(id,'not-a-uuid')]) {
    assert.throws(() => parseReference(value));
  }
});
test('deletion requires the verified Firebase owner, never a caller-supplied owner', () => {
  requireOwner(`member/${id}.jpg`, 'member');
  assert.throws(() => requireOwner(`another/${id}.jpg`, 'member'), {status:403});
});
test('verified JWT claims must still contain a valid user and past authentication time', () => {
  const claims = {sub:'member',iat:90,auth_time:80,exp:120};
  assert.equal(requireFirebaseClaims(claims,100),'member');
  for (const changed of [{sub:''},{sub:'../owner'},{sub:'x'.repeat(129)},
    {exp:100},{iat:110},{auth_time:110},{auth_time:-1},{iat:'90'}]) {
    assert.throws(() => requireFirebaseClaims({...claims,...changed},100),{status:401});
  }
});
test('JPEG, PNG, and WebP magic bytes must match the declared content type', () => {
  assert.equal(validateImage(new Uint8Array([255,216,255]),'image/jpeg'),'jpg');
  assert.equal(validateImage(new Uint8Array([137,80,78,71,13,10,26,10]),'image/png'),'png');
  assert.equal(validateImage(new TextEncoder().encode('RIFF0000WEBP'),'image/webp'),'webp');
  assert.throws(() => validateImage(new TextEncoder().encode('<svg></svg>'),'image/jpeg'));
  assert.throws(() => validateImage(new Uint8Array([255,216,255]),'image/png'));
});
test('empty or oversized uploads are rejected before storage', () => {
  assert.throws(() => validateImage(new Uint8Array(),'image/jpeg'),{status:413});
  assert.throws(() => validateImage(new Uint8Array(MAX_BYTES+1),'image/jpeg'),{status:413});
});
test('a streamed body cannot bypass the limit by omitting Content-Length', async () => {
  const request = new Request('https://example.com',{method:'POST',body:'too-long'});
  await assert.rejects(readLimited(request,3),{status:413});
  const small = new Request('https://example.com',{method:'POST',body:'ok'});
  assert.equal(new TextDecoder().decode(await readLimited(small,3)),'ok');
});
