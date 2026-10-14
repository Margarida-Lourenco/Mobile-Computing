import fs from 'node:fs';
import {initializeApp, applicationDefault} from 'firebase-admin/app';
import {getAuth} from 'firebase-admin/auth';
import {getFirestore, FieldValue} from 'firebase-admin/firestore';

// Run locally with administrator credentials. No deployed service is needed.
const args = process.argv.slice(2);
const option = name => args.find(arg => arg.startsWith(`${name}=`))?.slice(name.length + 1);
const projectId = option('--project');
if (!projectId) throw new Error('Specify --project=YOUR_PROJECT_ID.');
const apply = args.includes('--apply');
const backupPath = option('--backup');
if (apply && (!args.includes('--maintenance-confirmed') || !backupPath)) {
  throw new Error('Pause registrations first, then supply --maintenance-confirmed and --backup=FILE with --apply.');
}
initializeApp({credential: applicationDefault(), projectId});
const db = getFirestore();
const ids = new Set();
let pageToken;
do {
  const page = await getAuth().listUsers(1000, pageToken);
  for (const user of page.users) ids.add(user.uid);
  pageToken = page.pageToken;
} while (pageToken);
const markers = await db.collection('members').get();
const statsRef = db.doc('communityStats/members');
const previousStats = await statsRef.get();
const existing = new Set(markers.docs.map(doc => doc.id));
const additions = [...ids].filter(id => !existing.has(id));
const removals = markers.docs.filter(doc => !ids.has(doc.id));
console.log(JSON.stringify({projectId, authenticationAccounts: ids.size,
  currentCount: previousStats.data()?.accounts ?? null,
  markersToAdd: additions.length, markersToRemove: removals.length, apply}, null, 2));
if (apply) {
  const encode = data => JSON.parse(JSON.stringify(data));
  fs.writeFileSync(backupPath, JSON.stringify({projectId,
    stats: previousStats.exists ? encode(previousStats.data()) : null,
    markers: markers.docs.map(doc => ({id: doc.id, data: encode(doc.data())})),
  }, null, 2), {flag: 'wx'});
  const changes = [
    ...additions.map(id => ({ref: db.doc(`members/${id}`), remove: false})),
    ...removals.map(doc => ({ref: doc.ref, remove: true})),
  ];
  for (let i = 0; i < changes.length; i += 400) {
    const batch = db.batch();
    for (const change of changes.slice(i, i + 400)) {
      if (change.remove) batch.delete(change.ref);
      else batch.set(change.ref, {createdAt: FieldValue.serverTimestamp()});
    }
    await batch.commit();
  }
  await statsRef.set({accounts: ids.size, updatedAt: FieldValue.serverTimestamp()});
  console.log('Member counter reconciled. Registrations can resume.');
}
