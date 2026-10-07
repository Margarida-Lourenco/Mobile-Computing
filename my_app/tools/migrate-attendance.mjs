import fs from 'node:fs';
import {initializeApp,applicationDefault} from 'firebase-admin/app';
import {getFirestore,Timestamp} from 'firebase-admin/firestore';
import {pathToFileURL} from 'node:url';
function encode(value) {
 if(value && typeof value.toDate==='function' && typeof value.seconds==='number')return {__timestamp:[value.seconds,value.nanoseconds]};
 if(Array.isArray(value))return value.map(encode);
 if(value && typeof value==='object')return Object.fromEntries(Object.entries(value).map(([k,v])=>[k,encode(v)]));
 return value;
}
function decode(value){
 if(value?.__timestamp)return new Timestamp(...value.__timestamp);
 if(Array.isArray(value))return value.map(decode);
 if(value && typeof value==='object')return Object.fromEntries(Object.entries(value).map(([k,v])=>[k,decode(v)]));
 return value;
}
export async function migrate(db,{apply=false,backupPath,projectId}) {
 const [events,mirrors,profiles]=await Promise.all([db.collection('opportunities').get(),db.collectionGroup('joined').get(),db.collection('users').get()]);
 const names=new Map(profiles.docs.map(d=>[d.id,d.data().username||d.data().name||'Member']));
 const joinedByEvent=new Map();
 for(const d of mirrors.docs){
  const parts=d.ref.path.split('/');if(parts.length!==4 || parts[0]!=='users')continue;
  if(!joinedByEvent.has(d.id))joinedByEvent.set(d.id,new Map());
  joinedByEvent.get(d.id).set(parts[1],{username:names.get(parts[1])||'Member',joinedAt:d.data().createdAt||Timestamp.now()});
 }
 const backup={projectId,createdAt:new Date().toISOString(),documents:[]};const changes=[];
 for(const event of events.docs){
  const existing=await event.ref.collection('attendees').get();
  const members=new Map(existing.docs.map(d=>[d.id,d.data()]));
  for(const [uid,data] of joinedByEvent.get(event.id)||[])if(!members.has(uid))members.set(uid,data);
  const count=members.size;const before=event.data();const capacity=Math.max(before.spots||1,count);
  backup.documents.push({path:event.ref.path,data:encode(before)});
  changes.push({ref:event.ref,data:{attendeeCount:count,attendanceRevision:before.attendanceRevision||0,cancelled:before.cancelled===true,spots:capacity,...(!('endsAt'in before)?{endsAt:null}:{})}});
  for(const [uid,data] of members){
   if(existing.docs.some(d=>d.id===uid))continue;
   const ref=event.ref.collection('attendees').doc(uid);backup.documents.push({path:ref.path,data:null});changes.push({ref,data});
  }
 }
 const summary={events:events.size,legacySignups:mirrors.size,writes:changes.length,apply};
 if(apply){
  if(!backupPath)throw Error('An explicit backupPath is required.');
  fs.writeFileSync(backupPath,JSON.stringify(backup,null,2),{flag:'wx'});
  const writer=db.bulkWriter();const pending=changes.map(c=>writer.set(c.ref,c.data,{merge:true}));await writer.close();await Promise.all(pending);
 }
 return summary;
}
export async function restore(db,file,projectId){
 const backup=JSON.parse(fs.readFileSync(file,'utf8'));if(backup.projectId!==projectId)throw Error('Backup project does not match the selected project.');
 const writer=db.bulkWriter();const pending=backup.documents.map(d=>d.data===null?writer.delete(db.doc(d.path)):writer.set(db.doc(d.path),decode(d.data)));await writer.close();await Promise.all(pending);
}
if(process.argv[1] && import.meta.url===pathToFileURL(process.argv[1]).href){
 const args=process.argv.slice(2);const value=flag=>args[args.indexOf(flag)+1];
 if(!args.includes('--project'))throw Error('Pass --project YOUR_PROJECT_ID.');const projectId=value('--project');
 initializeApp({projectId,...(!process.env.FIRESTORE_EMULATOR_HOST?{credential:applicationDefault()}:{})});const db=getFirestore();
 if(args.includes('--restore')){if(!args.includes('--apply'))throw Error('Restore needs --apply.');await restore(db,value('--restore'),projectId);console.log('Backup restored.');}
 else console.log(await migrate(db,{projectId,apply:args.includes('--apply'),backupPath:args.includes('--backup')?value('--backup'):undefined}));
}
