import fs from 'node:fs';
import assert from 'node:assert/strict';
import {initializeTestEnvironment,assertSucceeds,assertFails} from '@firebase/rules-unit-testing';
import {doc,setDoc,getDoc,getDocs,collection,updateDoc,deleteDoc,runTransaction,increment,serverTimestamp,Timestamp,writeBatch} from 'firebase/firestore';
const env=await initializeTestEnvironment({projectId:'demo-good-together',firestore:{host:'127.0.0.1',port:8088,rules:fs.readFileSync(new URL('../../firestore.rules',import.meta.url),'utf8')}});
const dbFor=id=>env.authenticatedContext(id).firestore();
const host=dbFor('host');const users=['a','b','c'];
const eventData={ownerId:'host',organization:'Host',title:'Park cleanup',date:'7 Oct',time:'10:00',place:'Park',distance:'',category:'Community',description:'Help',spots:2,latitude:57.7,longitude:11.9,startsAt:Timestamp.fromDate(new Date('2027-10-07T10:00:00Z')),endsAt:Timestamp.fromDate(new Date('2027-10-07T12:00:00Z')),coverImageUrl:null,imageUrls:[],createdAt:Timestamp.now(),updatedAt:Timestamp.now(),attendeeCount:0,attendanceRevision:0,cancelled:false};
async function attendance(id,joining=true,{omitHostNotice=false}={}) {
 const db=dbFor(id), event=doc(db,'opportunities/event'), person=doc(db,`opportunities/event/attendees/${id}`), mirror=doc(db,`users/${id}/joined/event`);
 return runTransaction(db,async tx=>{
  const [es,ps,ms,profile]=await Promise.all([tx.get(event),tx.get(person),tx.get(mirror),tx.get(doc(db,`users/${id}`))]);
  const e=es.data();if(e.cancelled)throw Error('cancelled');if(ps.exists()===joining)return false;
  if(joining && e.attendeeCount>=e.spots)throw Error('full');
  const revision=e.attendanceRevision+1;
  tx.update(event,{attendeeCount:e.attendeeCount+(joining?1:-1),attendanceRevision:revision,lastActorId:id,lastAction:joining?'joined':'left',updatedAt:serverTimestamp()});
  if(joining){tx.set(person,{username:profile.data().username,joinedAt:serverTimestamp()});tx.set(mirror,{createdAt:serverTimestamp()});}else{tx.delete(person);tx.delete(mirror);}
  const notice=kind=>({eventId:'event',title:e.title,actorId:id,actorName:profile.data().username,kind,revision,createdAt:serverTimestamp()});
  tx.set(doc(db,`users/${id}/notifications/event_${revision}`),notice(joining?'joined':'left'));
  if(!omitHostNotice)tx.set(doc(db,`users/host/notifications/event_${revision}`),notice(joining?'signup':'withdrawal'));
  return true;
 });
}
async function registerMemberOnce(id) {
 const db=dbFor(id), marker=doc(db,`members/${id}`), stats=doc(db,'communityStats/members');
 return runTransaction(db,async tx=>{
  const existing=await tx.get(marker), counter=await tx.get(stats);
  if(existing.exists())return;
  tx.set(marker,{createdAt:serverTimestamp()});
  tx.set(stats,{accounts:(counter.data()?.accounts??0)+1,updatedAt:serverTimestamp()});
 });
}
async function registerMember(id) {
 for(let attempt=0;attempt<5;attempt++) {
  try {return await registerMemberOnce(id);}
  catch(e) {if(attempt===4 || !['permission-denied','aborted','unavailable'].includes(e.code))throw e;await new Promise(resolve=>setTimeout(resolve,150*(attempt+1)));}
 }
}
let checks=0;const check=(name,fn)=>Promise.resolve().then(fn).then(()=>{checks++;console.log('PASS '+name);});
try {
 await env.withSecurityRulesDisabled(async c=>{const db=c.firestore();await setDoc(doc(db,'opportunities/event'),eventData);for(const id of ['host',...users])await setDoc(doc(db,`users/${id}`),{username:id,name:id,location:'Sweden',profileImageUrl:null});});
 await check('first member initializes the counter atomically',async()=>{
  await registerMember('a');assert.equal((await getDoc(doc(host,'communityStats/members'))).data().accounts,1);
 });
 await check('returning member does not increment the counter',async()=>{
  await registerMember('a');assert.equal((await getDoc(doc(host,'communityStats/members'))).data().accounts,1);
 });
 await check('concurrent registrations do not lose or double count members',async()=>{
  await Promise.all([registerMember('b'),registerMember('c')]);
  assert.equal((await getDoc(doc(host,'communityStats/members'))).data().accounts,3);
 });
 await check('member cannot forge, reset or delete totals',async()=>{
  await assertFails(setDoc(doc(dbFor('a'),'communityStats/members'),{accounts:999,updatedAt:serverTimestamp()}));
  await assertFails(deleteDoc(doc(dbFor('a'),'communityStats/members')));
 });
 await check('member directory cannot be listed',()=>assertFails(getDocs(collection(host,'members'))));
 await check('member markers cannot be changed or removed',async()=>{
  await assertFails(updateDoc(doc(dbFor('a'),'members/a'),{createdAt:serverTimestamp()}));
  await assertFails(deleteDoc(doc(dbFor('a'),'members/a')));
 });
 await check('marker without counter increment cannot be created',()=>assertFails(setDoc(doc(host,'members/host'),{createdAt:serverTimestamp()})));
 await check('counter increment without marker cannot be created',()=>assertFails(updateDoc(doc(host,'communityStats/members'),{accounts:4,updatedAt:serverTimestamp()})));
 await check('cannot register another account marker',()=>assertFails(setDoc(doc(host,'members/stranger'),{createdAt:serverTimestamp()})));
 await check('guest can read member totals',()=>assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(),'communityStats/members'))));
 await check('guest can read events',()=>assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(),'opportunities/event'))));
 await check('guest cannot create events or sign up or favorite',async()=>{
  const guest=env.unauthenticatedContext().firestore();
  await assertFails(setDoc(doc(guest,'opportunities/guest'),eventData));
  await assertFails(setDoc(doc(guest,'users/a/favorites/event'),{createdAt:serverTimestamp()}));
  await assertFails(setDoc(doc(guest,'users/a/joined/event'),{createdAt:serverTimestamp()}));
  await assertFails(getDoc(doc(guest,'users/a')));
  await assertFails(getDocs(collection(guest,'opportunities/event/attendees')));
 });
 await check('all new posting categories are accepted',async()=>{
  for(const category of ['Social','Outdoors','Animals','Housework','Education','Culture','Sports','Other'])
   await assertSucceeds(setDoc(doc(host,'opportunities/category-'+category),{...eventData,category,createdAt:serverTimestamp(),updatedAt:serverTimestamp()}));
 });
 await check('host can create event with zero attendance',()=>assertSucceeds(setDoc(doc(host,'opportunities/new'),{...eventData,createdAt:serverTimestamp(),updatedAt:serverTimestamp()})));
 await check('end time is required by backend rules',()=>assertFails(setDoc(doc(host,'opportunities/missing-end'),{...eventData,endsAt:null,createdAt:serverTimestamp(),updatedAt:serverTimestamp()})));
 await check('end time must be later than start',()=>assertFails(setDoc(doc(host,'opportunities/invalid-end'),{...eventData,endsAt:eventData.startsAt,createdAt:serverTimestamp(),updatedAt:serverTimestamp()})));
 await check('clients cannot write community totals',()=>assertFails(setDoc(doc(host,'communityStats/members'),{hours:999,accounts:999})));
 await check('creator cannot impersonate another host',()=>assertFails(setDoc(doc(dbFor('a'),'opportunities/forged'),{...eventData,createdAt:serverTimestamp(),updatedAt:serverTimestamp()})));
 await check('missing host notification rejects the entire sign-up',()=>assertFails(attendance('a',true,{omitHostNotice:true})));
 await check('two simultaneous last-place sign-ups succeed and third cannot overbook',async()=>{
  const results=await Promise.allSettled(users.map(id=>attendance(id)));assert.equal(results.filter(r=>r.status==='fulfilled').length,2);
  assert.equal((await getDoc(doc(host,'opportunities/event'))).data().attendeeCount,2);
 });
 const list=await getDocs(collection(host,'opportunities/event/attendees'));const first=list.docs[0].id;
 await check('host sees both participant identities',()=>assert.equal(list.size,2));
 await check('attendee cannot list other participants',()=>assertFails(getDocs(collection(dbFor(first),'opportunities/event/attendees'))));
 await check('duplicate sign-up is a no-op',async()=>{assert.equal(await attendance(first),false);assert.equal((await getDoc(doc(host,'opportunities/event'))).data().attendeeCount,2);});
 await check('counter cannot be edited outside a membership transaction',()=>assertFails(updateDoc(doc(dbFor(first),'opportunities/event'),{attendeeCount:0})));
 await check('participant cannot be deleted without releasing capacity atomically',()=>assertFails(deleteDoc(doc(dbFor(first),`opportunities/event/attendees/${first}`))));
 await check('sign-ups created two host notifications',async()=>assert.equal((await getDocs(collection(host,'users/host/notifications'))).size,2));
 const myNotices=await getDocs(collection(dbFor(first),`users/${first}/notifications`));const ownNotice=myNotices.docs[0].id;
 await check('recipient can mark notification read',()=>assertSucceeds(updateDoc(doc(dbFor(first),`users/${first}/notifications/${ownNotice}`),{read:true})));
 await check('other user cannot read or mark someone else notification',()=>assertFails(updateDoc(doc(dbFor('host'),`users/${first}/notifications/${ownNotice}`),{read:true})));
 await check('host cannot reduce capacity below attendance',()=>assertFails(updateDoc(doc(host,'opportunities/event'),{spots:1,updatedAt:serverTimestamp()})));
 await check('withdrawal releases a place and writes host withdrawal notification',async()=>{await attendance(first,false);const e=(await getDoc(doc(host,'opportunities/event'))).data();assert.equal(e.attendeeCount,1);assert.equal((await getDoc(doc(host,`users/host/notifications/event_${e.attendanceRevision}`))).data().kind,'withdrawal');});
 await check('released place can be filled again',async()=>{await attendance(first);assert.equal((await getDoc(doc(host,'opportunities/event'))).data().attendeeCount,2);});
 await check('unrelated users cannot edit event metadata',()=>assertFails(updateDoc(doc(dbFor(first),'opportunities/event'),{title:'Forged',updatedAt:serverTimestamp()})));
 await check('host edits metadata without changing attendance',()=>assertSucceeds(updateDoc(doc(host,'opportunities/event'),{description:'Updated details',updatedAt:serverTimestamp()})));
 await check('host cancels event and attendees receive cancellation notices',async()=>{
  await updateDoc(doc(host,'opportunities/event'),{cancelled:true,updatedAt:serverTimestamp()});
  for(const participant of list.docs)await assertSucceeds(setDoc(doc(host,`users/${participant.id}/notifications/event_cancelled`),{eventId:'event',title:eventData.title,actorId:'host',actorName:'host',kind:'cancelled',revision:0,createdAt:serverTimestamp()}));
 });
 await check('cancelled event rejects new sign-ups',()=>assert.rejects(attendance('c'),/cancelled/));
 await check('stranger cannot spoof cancellation notice',()=>assertFails(setDoc(doc(dbFor(first),'users/host/notifications/event_cancelled'),{eventId:'event',title:eventData.title,actorId:first,actorName:first,kind:'cancelled',revision:0,createdAt:serverTimestamp()})));
 await check('cancellation notification retry preserves recipient read status',async()=>{
  await updateDoc(doc(dbFor(first),`users/${first}/notifications/event_cancelled`),{read:true});
  await assertSucceeds(setDoc(doc(host,`users/${first}/notifications/event_cancelled`),{eventId:'event',title:eventData.title,actorId:'host',actorName:'host',kind:'cancelled',revision:0,createdAt:serverTimestamp()},{merge:true}));
  assert.equal((await getDoc(doc(dbFor(first),`users/${first}/notifications/event_cancelled`))).data().read,true);
 });
 console.log(`ALL ${checks} FIREBASE RULE/TRANSACTION CHECKS PASSED`);
} finally {await env.cleanup();}
