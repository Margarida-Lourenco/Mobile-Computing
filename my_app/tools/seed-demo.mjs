import {createRequire} from 'node:module';
import fs from 'node:fs';
import {randomBytes} from 'node:crypto';
import {initializeApp, applicationDefault} from 'firebase-admin/app';
import {getAuth} from 'firebase-admin/auth';
import {getFirestore, Timestamp, FieldValue} from 'firebase-admin/firestore';

const args=process.argv.slice(2);
const option=name=>args.find(a=>a.startsWith(name+'='))?.slice(name.length+1);
const projectId=option('--project');
if(!projectId) throw Error('Pass --project=YOUR_PROJECT_ID.');
const apply=args.includes('--apply');
let credential=applicationDefault();
// Optional adapter for a locally installed, already authenticated Firebase CLI.
// No credentials are copied to the deliverable or printed.
if(option('--firebase-cli-lib')) {
 const require=createRequire(import.meta.url),base=option('--firebase-cli-lib')+'/';
 const {configstore}=require(base+'configstore.js');
 await require(base+'requireAuth.js').requireAuth({project:projectId,user:configstore.get('user'),tokens:configstore.get('tokens')});
 credential={getAccessToken:async()=>({access_token:await require(base+'apiv2.js').getAccessToken(),expires_in:3500})};
}
initializeApp({projectId,credential});
let db;
if(option('--firebase-cli-lib')) {
 const {Firestore}=await import('@google-cloud/firestore');
 const {OAuth2Client}=await import('google-auth-library');
 const client=new OAuth2Client();
 client.setCredentials({access_token:(await credential.getAccessToken()).access_token,expiry_date:Date.now()+3500000});
 db=new Firestore({projectId,authClient:client});
} else db=getFirestore();
const auth=getAuth();
const names=['Alma','Erik','Maja','Oscar','Elsa','Hugo','Alice','Noah','Selma','Elias','Vera','William','Astrid','Liam','Freja','Nils','Signe','Leo','Ebba','Adam','Ines','Axel','Saga','Oliver','Ida','Arvid','Clara','Isak','Agnes','Theo','Julia','August','Nora','Malte','Wilma'];
const categories=['Social','Outdoors','Animals','Housework','Education','Culture','Sports'];
const activities=['Coffee and conversation','Keep our parks green','Help at the animal shelter','Lend a hand with household tasks','Homework club','Community arts workshop','Inclusive sports afternoon'];
const places=[['Majorna',57.6952,11.9187],['Centrum',57.7007,11.9680],['Hisingen',57.721,11.9432],['Linné',57.6969,11.9528],['Haga',57.6987,11.9555],['Kvillebäcken',57.7225,11.9465]];
const now=new Date();
const people=names.map((name,i)=>({uid:`gt-demo-2026-${String(i+1).padStart(2,'0')}`,email:`gt.demo.${String(i+1).padStart(2,'0')}@example.com`,name,username:`demo_${name.toLowerCase()}_${i+1}`,host:i<15}));
const events=[];
for(let i=0;i<15;i++)for(let j=0;j<1+i%5;j++){
 const index=events.length,cat=index%categories.length,place=places[index%places.length];
 const past=j>0 && j===i%5;
 const start=new Date(now);start.setUTCDate(start.getUTCDate()+(past?-(1+i%10):index%21));start.setUTCHours(past?8:16,0,0,0);
 if(!past && start<=now)start.setUTCDate(start.getUTCDate()+1);
 const end=new Date(+start+(1+index%4)*3600000);
 const clock=d=>new Intl.DateTimeFormat('en-GB',{timeZone:'Europe/Stockholm',hour:'2-digit',minute:'2-digit',hour12:false}).format(d);
 events.push({id:`gt-demo-2026-event-${String(index+1).padStart(2,'0')}`,past,data:{ownerId:people[i].uid,organization:`${names[i]}'s neighborhood group`,title:`${activities[cat]} · ${place[0]}`,date:new Intl.DateTimeFormat('en-GB',{timeZone:'Europe/Stockholm',day:'numeric',month:'short'}).format(start),time:`${clock(start)} – ${clock(end)}`,place:place[0]+', Gothenburg',distance:'',category:categories[cat],description:'Demo opportunity: '+activities[cat]+'. Meet neighbors in '+place[0]+'. Everyone is welcome; no previous experience needed.',spots:50,latitude:place[1]+(index%3)*0.001,longitude:place[2]+Math.floor(index/6)*0.001,startsAt:Timestamp.fromDate(start),endsAt:Timestamp.fromDate(end),coverImageUrl:null,imageUrls:[],attendeeCount:0,attendanceRevision:0,cancelled:false,createdAt:Timestamp.now(),updatedAt:Timestamp.now()}});
}
const joins=[];
for(let i=0;i<people.length;i++){
 const person=people[i];
 const past=events.filter(e=>e.past&&e.data.ownerId!==person.uid);
 const future=events.filter(e=>!e.past&&e.data.ownerId!==person.uid);
 for(const event of [...past.slice(0,i%12),future[i%future.length],future[(i+7)%future.length]]){
  joins.push({person,event});event.data.attendeeCount++;
 }
}
const manifest=people.map(person=>{const history=joins.filter(j=>j.person===person&&j.event.past);const completed=history.length;return {...person,listings:events.filter(e=>e.data.ownerId===person.uid).length,completed,hours:history.reduce((s,j)=>s+(j.event.data.endsAt.toMillis()-j.event.data.startsAt.toMillis())/3600000,0),level:completed===0?1:completed<3?2:completed<5?3:3+Math.floor(completed/5),joined:joins.filter(j=>j.person===person).length};});
console.log(JSON.stringify({projectId,apply,accounts:people.length,hosts:15,participants:20,listings:events.length,upcoming:events.filter(e=>!e.past).length,past:events.filter(e=>e.past).length,signups:joins.length},null,2));
if(!apply)process.exit(0);
const credentialsFile=option('--credentials');
if(!credentialsFile)throw Error('Pass --credentials=LOCAL_FILE.json to save demo sign-in details.');
const credentials=fs.existsSync(credentialsFile)?JSON.parse(fs.readFileSync(credentialsFile,'utf8')):[];
for(const person of people){
 try {const existing=await auth.getUser(person.uid);if(existing.email!==person.email)throw Error('Demo UID collision.');}
 catch(e){if(e.code!=='auth/user-not-found')throw e;const password='Demo!'+randomBytes(12).toString('base64url');await auth.createUser({uid:person.uid,email:person.email,password,displayName:person.username,emailVerified:false});credentials.push({email:person.email,password,uid:person.uid});fs.writeFileSync(credentialsFile,JSON.stringify(credentials,null,2));}
 const profile=db.doc('users/'+person.uid);if(!(await profile.get()).exists)await profile.set({name:person.name,username:person.username,location:'Gothenburg, Sweden',profileImageUrl:null});
}
// Only namespaced demo events are written. A rerun stops if users have edited them.
for(const event of events){const existing=await db.doc('opportunities/'+event.id).get();if(existing.exists && ((existing.data().attendanceRevision??0)>0 || existing.data().cancelled))throw Error('Demo event has live activity; refusing to replace '+event.id);}
let batch=db.batch(),writes=0;
async function put(ref,data){batch.set(ref,data);if(++writes===350){await batch.commit();batch=db.batch();writes=0;}}
for(const event of events)await put(db.doc('opportunities/'+event.id),event.data);
if(writes)await batch.commit();batch=db.batch();writes=0;
for(const {person,event} of joins){
 await put(db.doc(`users/${person.uid}/joined/${event.id}`),{createdAt:Timestamp.now()});
 await put(db.doc(`opportunities/${event.id}/attendees/${person.uid}`),{username:person.username,joinedAt:Timestamp.now()});
}
if(writes)await batch.commit();
// Reconcile existing accounts as well, preserving concurrent client registrations:
// only missing markers increment the aggregate, in the same transaction.
let pageToken;do{const page=await auth.listUsers(1000,pageToken);for(const person of page.users){await db.runTransaction(async tx=>{const marker=db.doc('members/'+person.uid),stats=db.doc('communityStats/members');const m=await tx.get(marker),s=await tx.get(stats);if(!m.exists){tx.set(marker,{createdAt:FieldValue.serverTimestamp()});tx.set(stats,{accounts:(s.data()?.accounts??0)+1,updatedAt:FieldValue.serverTimestamp()});}});}pageToken=page.pageToken;}while(pageToken);
fs.writeFileSync(option('--manifest')??'demo-manifest.json',JSON.stringify({projectId,createdAt:now.toISOString(),accounts:manifest},null,2));
console.log('Demo accounts, events, participation history and member registry saved.');
