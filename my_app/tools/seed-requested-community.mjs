import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {createRequire} from 'node:module';
import {randomBytes} from 'node:crypto';
import assert from 'node:assert/strict';
import {initializeApp, applicationDefault} from 'firebase-admin/app';
import {getAuth} from 'firebase-admin/auth';
import {getFirestore, Timestamp, FieldValue} from 'firebase-admin/firestore';

const args=process.argv.slice(2);
const option=name=>args.find(value=>value.startsWith(name+'='))?.slice(name.length+1);
const dataPath=option('--data')??path.join(path.dirname(fileURLToPath(import.meta.url)), 'requested-community-data.json');
const plan=JSON.parse(fs.readFileSync(dataPath,'utf8'));
const projectId=option('--project')??plan.projectId;
assert.equal(projectId,plan.projectId,'The project must match the reviewed dataset.');
const asOf=new Date(plan.asOf+'T10:00:00Z');
const categories=['Social','Outdoors','Animals','Housework','Education','Culture','Sports','Other'];
const people=new Map(plan.accounts.map(person=>[person.uid,person]));
const events=new Map(plan.events.map(event=>[event.id,event]));
const pairs=new Set();
assert.equal(people.size,46);
assert.equal(new Set(plan.accounts.map(person=>person.email)).size,46);
assert.equal(new Set(plan.accounts.map(person=>person.name)).size,46);
assert.equal(events.size,plan.events.length);
assert.equal(new Set(plan.events.map(event=>event.title)).size,events.size);
assert.equal(new Set(plan.events.map(event=>`${event.latitude},${event.longitude}`)).size,events.size);
assert.deepEqual(new Set(plan.events.map(event=>event.category)),new Set(categories));
for(const person of people.values()){
  const posted=plan.events.filter(event=>event.ownerId===person.uid);
  assert(posted.length>=1&&posted.length<=3,person.name+' post count');
  const joined=plan.joins.filter(join=>join.uid===person.uid).map(join=>events.get(join.eventId));
  const past=joined.filter(event=>new Date(event.endsAt)<asOf).length;
  const future=joined.length-past;
  assert(past>=0&&past<=2&&future>=0&&future<=3,person.name+' participation');
  assert.equal(past,person.pastParticipation);
  assert.equal(future,person.futureSignups);
  const commitments=[...posted,...joined];
  for(let i=0;i<joined.length;i++)for(const other of commitments){
    if(other.id===joined[i].id)continue;
    assert(!(joined[i].startsAt<other.endsAt&&other.startsAt<joined[i].endsAt),person.name+' overlapping commitments');
  }
}
for(const event of events.values()){
  assert(people.has(event.ownerId));
  assert(event.spots>=1&&event.spots<=8&&Number.isInteger(event.spots));
  assert(event.latitude>=57.4&&event.latitude<=58&&event.longitude>=11.5&&event.longitude<=12.3);
  assert(new Date(event.startsAt)<new Date(event.endsAt));
  assert(event.startsAt>='2026-10-11T22:00:00Z'&&event.endsAt<'2026-12-25T23:00:00Z');
  assert.equal(event.attendeeCount,plan.joins.filter(join=>join.eventId===event.id).length);
  assert(event.attendeeCount<=event.spots);
  assert.equal(event.attendanceRevision,event.attendeeCount);
  assert.equal(event.organization,people.get(event.ownerId).name);
}
for(const join of plan.joins){
  assert(people.has(join.uid)&&events.has(join.eventId));
  assert.notEqual(events.get(join.eventId).ownerId,join.uid);
  assert(!pairs.has(join.uid+'/'+join.eventId));
  assert(new Date(join.joinedAt)<new Date(events.get(join.eventId).startsAt));
  assert(new Date(join.joinedAt)<=asOf);
  pairs.add(join.uid+'/'+join.eventId);
}
const summary={projectId,accounts:people.size,individuals:plan.accounts.filter(p=>!p.organization).length,
  organizations:plan.accounts.filter(p=>p.organization).length,opportunities:events.size,
  past:plan.events.filter(event=>new Date(event.endsAt)<asOf).length,
  upcoming:plan.events.filter(event=>new Date(event.endsAt)>=asOf).length,
  participationRecords:plan.joins.length,
  categories:Object.fromEntries(categories.map(category=>[category,plan.events.filter(e=>e.category===category).length])),
  dateRange:plan.dateRange,validated:true};
console.log(JSON.stringify(summary,null,2));
if(!args.includes('--apply')){
  console.log('Validation only. No accounts or documents were created.');
  process.exit(0);
}
const credentialsFile=option('--credentials');
const reportFile=option('--report');
assert(credentialsFile&&reportFile,'Supply --credentials=FILE.json and --report=FILE.json.');
// Existing Firebase CLI authentication can be used without exporting or printing its tokens.
let credential=applicationDefault();
if(option('--firebase-cli-lib')){
  const require=createRequire(import.meta.url),base=option('--firebase-cli-lib')+'/';
  const {configstore}=require(base+'configstore.js');
  await require(base+'requireAuth.js').requireAuth({project:projectId,user:configstore.get('user'),tokens:configstore.get('tokens')});
  credential={getAccessToken:async()=>({access_token:await require(base+'apiv2.js').getAccessToken(),expires_in:3500})};
}
initializeApp({projectId,credential});
const auth=getAuth();
let db;
if(option('--firebase-cli-lib')){
  const {Firestore}=await import('@google-cloud/firestore');
  const {OAuth2Client}=await import('google-auth-library');
  const client=new OAuth2Client();
  client.setCredentials({access_token:(await credential.getAccessToken()).access_token,expiry_date:Date.now()+3500000});
  db=new Firestore({projectId,authClient:client});
}else db=getFirestore();

const records=new Map();
const now=Timestamp.now();
const timestamp=value=>Timestamp.fromDate(new Date(value));
for(const person of people.values())records.set('users/'+person.uid,{
  name:person.name,username:person.username,location:person.location,profileImageUrl:person.profileImageUrl??null,
});
const eventGroups=new Map();
for(const event of events.values()){
  const eventPath='opportunities/'+event.id;
  const data={...event};delete data.id;
  data.startsAt=timestamp(data.startsAt);data.endsAt=timestamp(data.endsAt);
  data.createdAt=timestamp(new Date(Math.min(+asOf,+new Date(event.startsAt)-2*86400000)).toISOString());
  data.updatedAt=now;
  records.set(eventPath,data);
  const group=[eventPath];
  let revision=0;
  for(const join of plan.joins.filter(join=>join.eventId===event.id)){
    revision++;
    const stamp=timestamp(join.joinedAt);
    const membership=`users/${join.uid}/joined/${event.id}`;
    const attendee=`${eventPath}/attendees/${join.uid}`;
    records.set(membership,{createdAt:stamp});
    records.set(attendee,{username:join.username,joinedAt:stamp});
    group.push(membership,attendee);
    for(const [receiver,kind] of [[join.uid,'joined'],[event.ownerId,'signup']]){
      const notice=`users/${receiver}/notifications/${event.id}_${revision}`;
      records.set(notice,{eventId:event.id,title:event.title,actorId:join.uid,
        actorName:join.username,kind,revision,createdAt:stamp,read:false});
      group.push(notice);
    }
  }
  eventGroups.set(event.id,group);
}

// Read and check every target before mutating anything. Existing unrelated accounts are untouched.
const existingAuth=await auth.getUsers(plan.accounts.map(person=>({uid:person.uid})));
const byUid=new Map(existingAuth.users.map(user=>[user.uid,user]));
const existingEmails=await auth.getUsers(plan.accounts.map(person=>({email:person.email})));
for(const user of existingEmails.users)assert(people.has(user.uid)&&people.get(user.uid).email===user.email,'Email collision: '+user.email);
for(const user of existingAuth.users){
  assert.equal(user.email,people.get(user.uid).email,'UID collision: '+user.uid);
  assert.equal(user.displayName,people.get(user.uid).username,'This seeded account was edited: '+user.uid);
}
const existingDocs=new Map();
const paths=[...records.keys()];
for(let i=0;i<paths.length;i+=100){
  const snapshots=await db.getAll(...paths.slice(i,i+100).map(value=>db.doc(value)));
  for(const doc of snapshots)if(doc.exists)existingDocs.set(doc.ref.path,doc.data());
}
const canonical=value=>{
  if(value&&typeof value.toMillis==='function')return value.toMillis();
  if(Array.isArray(value))return value.map(canonical);
  if(value&&typeof value==='object')return Object.fromEntries(Object.keys(value).sort().map(key=>[key,canonical(value[key])]));
  return value;
};
for(const [document,data] of existingDocs){
  const expected={...records.get(document)};
  const actual={...data};
  // updatedAt is the only nondeterministic seed value. User changes must be reviewed, never overwritten.
  delete expected.updatedAt;delete actual.updatedAt;
  assert.deepEqual(canonical(actual),canonical(expected),'Refusing to replace an edited record: '+document);
}
for(const group of eventGroups.values()){
  const existing=group.filter(document=>existingDocs.has(document)).length;
  assert(existing===0||existing===group.length,'Incomplete existing event group; review before retrying.');
}
let credentials;
if(fs.existsSync(credentialsFile)){
  credentials=JSON.parse(fs.readFileSync(credentialsFile,'utf8'));
  assert.equal(credentials.projectId,projectId);
  assert.equal(credentials.seedId,plan.seedId);
  for(const person of people.values()){
    const entry=credentials.accounts.find(account=>account.uid===person.uid);
    assert(entry&&entry.email===person.email&&entry.password,'Missing saved credentials for '+person.name);
  }
}else{
  assert.equal(existingAuth.users.length,0,'Credentials for existing demo accounts are required; passwords will not be reset.');
  credentials={projectId,seedId:plan.seedId,accounts:plan.accounts.map(person=>({
    uid:person.uid,name:person.name,email:person.email,password:'GT!'+randomBytes(18).toString('base64url'),
  }))};
  fs.mkdirSync(path.dirname(path.resolve(credentialsFile)),{recursive:true});
  fs.writeFileSync(credentialsFile,JSON.stringify(credentials,null,2),{flag:'wx',mode:0o600});
}
console.log('Preflight passed. Creating the requested namespaced records.');
for(const person of people.values()){
  if(!byUid.has(person.uid)){
    const login=credentials.accounts.find(account=>account.uid===person.uid);
    await auth.createUser({uid:person.uid,email:person.email,password:login.password,
      displayName:person.username,emailVerified:false,disabled:false});
  }
  const profilePath='users/'+person.uid;
  if(!existingDocs.has(profilePath))await db.doc(profilePath).create(records.get(profilePath));
  // A transaction increments the count once, preserving concurrent registrations.
  await db.runTransaction(async tx=>{
    const marker=db.doc('members/'+person.uid),stats=db.doc('communityStats/members');
    const snapshot=await tx.get(marker);
    if(!snapshot.exists){
      tx.create(marker,{createdAt:FieldValue.serverTimestamp()});
      tx.set(stats,{accounts:FieldValue.increment(1),updatedAt:FieldValue.serverTimestamp()},{merge:true});
    }
  });
}
// Each event and all its attendance/notification documents are committed together.
let batch=db.batch(),writes=0;
for(const group of eventGroups.values()){
  if(existingDocs.has(group[0]))continue;
  if(writes+group.length>400){await batch.commit();batch=db.batch();writes=0;}
  for(const document of group){batch.create(db.doc(document),records.get(document));writes++;}
}
if(writes)await batch.commit();
const verifiedAuth=await auth.getUsers(plan.accounts.map(person=>({uid:person.uid})));
assert.equal(verifiedAuth.users.length,people.size);
let verifiedDocuments=0;
for(let i=0;i<paths.length;i+=100){
  const snapshots=await db.getAll(...paths.slice(i,i+100).map(value=>db.doc(value)));
  for(const doc of snapshots){
    assert(doc.exists,'Missing document after import: '+doc.ref.path);
    const expected={...records.get(doc.ref.path)},actual={...doc.data()};
    delete expected.updatedAt;delete actual.updatedAt;
    assert.deepEqual(canonical(actual),canonical(expected),'Verification failed: '+doc.ref.path);
    verifiedDocuments++;
  }
}
const report={...summary,status:'created-and-verified',verifiedAt:new Date().toISOString(),
  authenticationAccountsVerified:verifiedAuth.users.length,documentsVerified:verifiedDocuments,
  accounts:plan.accounts.map(person=>({name:person.name,uid:person.uid,email:person.email,
    posts:person.posts,pastParticipation:person.pastParticipation,futureSignups:person.futureSignups}))};
fs.mkdirSync(path.dirname(path.resolve(reportFile)),{recursive:true});
fs.writeFileSync(reportFile,JSON.stringify(report,null,2));
console.log(JSON.stringify({...summary,status:report.status,documentsVerified:verifiedDocuments},null,2));
