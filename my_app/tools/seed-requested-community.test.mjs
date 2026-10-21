import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';

const directory=path.dirname(fileURLToPath(import.meta.url));
const script=path.join(directory,'seed-requested-community.mjs');
const data=JSON.parse(fs.readFileSync(path.join(directory,'requested-community-data.json'),'utf8'));
const scratch=path.join(directory,'.seed-validation');
fs.mkdirSync(scratch,{recursive:true});
function run(name,mutate){
  const plan=structuredClone(data);
  mutate?.(plan);
  const file=path.join(scratch,name+'.json');
  fs.writeFileSync(file,JSON.stringify(plan));
  return spawnSync(process.execPath,[script,'--data='+file],{encoding:'utf8',timeout:30000});
}
test('the reviewed dataset passes a dry run without Firebase credentials',()=>{
  const result=run('baseline');
  assert.equal(result.status,0,result.stderr);
  assert.match(result.stdout,/"accounts": 46/);
  assert.match(result.stdout,/"opportunities": 94/);
  assert.match(result.stdout,/No accounts or documents were created/);
});
for(const [name,mutate] of [
  ['capacity-over-eight',plan=>{plan.events[0].spots=9;}],
  ['duplicate-pin',plan=>{plan.events[1].latitude=plan.events[0].latitude;plan.events[1].longitude=plan.events[0].longitude;}],
  ['duplicate-title',plan=>{plan.events[1].title=plan.events[0].title;}],
  ['missing-category',plan=>{for(const event of plan.events)if(event.category==='Other')event.category='Housework';}],
  ['overbooked-event',plan=>{plan.events[0].attendeeCount=plan.events[0].spots+1;}],
  ['self-signup',plan=>{plan.joins[0].uid=plan.events.find(e=>e.id===plan.joins[0].eventId).ownerId;}],
])test('rejects '+name+' before external access',()=>{
  const result=run(name,mutate);
  assert.notEqual(result.status,0,result.stdout);
  assert.match(result.stderr,/AssertionError/);
});
test('the supplied examples keep their exact volunteer counts',()=>{
  for(const [title,spots] of [
    ['Help run a neighbourhood football tournament',4],
    ['Help my daughter with her maths homework',1],
    ['Help run a community volleyball event',3],
    ['Help plant trees in our neighbourhood',6],
    ['Help me run a neighbourhood bingo event',2],
    ['Help mow my garden lawn',1],
  ])assert.equal(data.events.find(event=>event.title===title)?.spots,spots);
  assert(data.accounts.some(person=>person.name==='Astrid'));
  assert(data.accounts.some(person=>person.name==='Astrid Berg'));
});
