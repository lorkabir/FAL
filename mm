<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>Football analysis</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<style>
:root{color-scheme:dark;--bg:#000;--pn:rgba(0,10,0,.88);--g:#00ff41;--g2:#00b32c;--dim:#0b5d1e;--tx:#b9ffc9;--wa:#ffd23f;--er:#ff4d4d;box-sizing:border-box;padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}
html{scroll-padding-top:env(safe-area-inset-top,0px)}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--tx);font:14px/1.55 "Courier New",ui-monospace,Menlo,monospace}
#rain{position:fixed;inset:0;z-index:-1;opacity:.4}
main{max-width:1100px;margin:auto;padding:14px}
h1{color:var(--g);text-shadow:0 0 8px var(--g);margin:6px 0}
h2,h3,h4{color:var(--g);margin:.4em 0}
nav{display:flex;gap:8px;flex-wrap:wrap;margin:10px 0}
nav a{color:var(--g);border:1px solid var(--dim);padding:6px 12px;text-decoration:none;background:var(--pn)}
nav a.on{background:var(--g);color:#000}
.card{background:var(--pn);border:1px solid var(--dim);padding:12px;margin:10px 0;box-shadow:0 0 12px #00ff4122}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:14px}
label{display:block;font-size:12px;margin:6px 0;color:#7dff98}
input,select,textarea{width:100%;background:#000;color:var(--g);border:1px solid var(--g2);padding:6px;font:inherit;border-radius:0}
input:focus,textarea:focus,select:focus{outline:2px solid var(--g)}
input:disabled{opacity:.7}
button{background:#000;color:var(--g);border:1px solid var(--g);padding:7px 12px;font:inherit;cursor:pointer;margin:6px 6px 0 0}
button:hover{background:var(--g);color:#000}
.hint{color:#6fbf80;font-size:12px}
.t{font-size:10px;padding:1px 5px;border:1px solid;margin-right:4px}.d{color:var(--g)}.m{color:#7df9ff}.a{color:var(--wa)}
.bad,.neg{color:var(--er)}.pos{color:var(--g)}.warn{color:var(--wa)}
.tw{overflow-x:auto}table{border-collapse:collapse;width:100%;font-size:12px}th,td{border:1px solid var(--dim);padding:4px 6px;text-align:left}th{color:var(--g)}
.sel{display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));gap:8px;border:1px solid var(--dim);padding:8px;margin:8px 0;align-items:end}
.ch{height:220px}
details{margin-top:8px}summary{cursor:pointer;color:var(--g)}
</style></head><body>
<canvas id="rain"></canvas>
<main>

<style>@keyframes b{50%{opacity:0}}@media(prefers-reduced-motion:reduce){span{animation:none!important}}</style>
<p class="hint">Football statistics and probability lab. It runs only in your browser. No live data, no made-up numbers. Tags: <span class="t d">DATA</span> you entered, <span class="t m">MODEL</span> calculated, <span class="t a">ASSUMPTION</span> your choice.</p>
<nav><a id="n_analyzer" href="#analyzer">Match Analyzer</a><a id="n_bets" href="#bets">Bet Calculator</a><a id="n_data" href="#data">Data &amp; Validation</a><a id="n_combo" href="#combo" dir="rtl">محاسبه احتمال فرم ترکیبی</a></nav>

<section id="p_analyzer">
<div class="card"><h2>1. Enter what you know</h2>
<p class="hint">Leave a field empty if you do not know the value. Empty means MISSING. 0 means zero. Missing values are never filled in for you, and events that need them are skipped.</p>
<div class="grid"><div id="fh"></div><div id="fa"></div>
<div><h3>Referee</h3>
<label>Average yellow cards per match<input id="r_y" type="number" min="0" step="any"></label>
<label>Matches officiated<input id="r_n" type="number" min="0" step="1"></label>
<h3>Your assumptions</h3>
<label>Home goals multiplier (1 = no change)<input id="x_hm" type="number" min="0" step="any"></label>
<label>Away goals multiplier (1 = no change)<input id="x_am" type="number" min="0" step="any"></label>
<label>Number of simulations<input id="x_sims" type="number" min="1000" max="300000" step="1000" value="10000"></label></div></div>
<button id="go">Run analysis</button><div id="msg"></div></div>
<div id="res" hidden></div>
</section>

<section id="p_bets" hidden>
<div class="card"><h2>Bet Calculator</h2>
<p class="hint">Add picks from the Analyzer (they are counted together in the same simulated matches, so dependence is handled) or add your own manual picks. Manual picks are treated as independent, and the result says so.</p>
<button id="addm">+ Add manual selection</button>
<div id="sel"></div>
<label>Stake for the combined bet (optional)<input id="b_st" type="number" min="0" step="any" oninput="calc()"></label>
<div id="sum"></div></div>
</section>

<section id="p_combo" hidden>
<div class="card"><h2><span dir="rtl">محاسبه احتمال فرم ترکیبی</span> <span class="hint">(Combined Bet Form)</span></h2>
<p class="hint">Add every pick of one form. Picks from different matches are treated as independent, so their probabilities are multiplied. Picks from the same match are usually related, so they get a dependency setting below. Everything updates as you type.</p>
<button id="cadd">+ Add selection</button><button id="cex">Load example from your brief</button><button id="cclr">Remove all</button>
<div id="crows"></div><div id="cdep"></div>
<label>Stake (units)<input id="cstake" type="number" min="0" step="any" value="1" oninput="calcCombo()"></label>
<div id="cres"></div><details><summary>Numerical self-tests (copula maths)</summary><button id="ctest">Run self-tests</button><div id="ctres"></div></details></div>
</section>

<section id="p_data" hidden>
<div class="card"><h2>Saved matches (stored only in this browser)</h2>
<p class="hint">CSV columns: date,home,away,hg,ag,hy,ay,hr,ar,hf,af,hc,ac,hst,ast (goals, yellow cards, red cards, fouls, corners, shots on target for home and away). All columns except home and away are optional. Dates as YYYY-MM-DD. An empty cell means missing. Commas inside names are not supported. Format example: 2025-08-16,Team A,Team B,2,1,3,2,0,0,11,13,5,4,4,3</p>
<input type="file" id="file" accept=".csv,text/csv">
<textarea id="csv" rows="6" placeholder="date,home,away,hg,ag,hy,ay,hr,ar,hf,af,hc,ac,hst,ast"></textarea>
<button id="imp">Import (replaces saved matches)</button><button id="exp">Show saved matches as CSV</button><button id="clr">Delete all saved matches</button>
<div id="dmsg"></div><div id="dsum"></div></div>
<div class="card"><h2>Model check (backtest)</h2>
<p class="hint">Time split: the first 70% of matches (oldest) train the model, the newest 30% test it. Team averages come from the training part only, so there is no data leakage. Event tested: Over 2.5 goals.</p>
<button id="bt_go">Run backtest</button><div id="bt"></div></div>
</section>
</main>
<script>
const $=id=>document.getElementById(id);
const esc=s=>String(s).replace(/[&<>"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const num=id=>{const v=$(id).value.trim();if(v==='')return null;const x=Number(v);return isFinite(x)&&x>=0?x:NaN};
const f2=(x,d=2)=>x==null||!isFinite(x)?'-':x.toFixed(d),pc=x=>f2(x*100,1)+'%';
const say=(m,c='')=>{$('msg').innerHTML=`<p class="${c}">${m}</p>`};
/* ---------- statistics ---------- */
const sum=a=>a.reduce((s,x)=>s+x,0),mean=a=>sum(a)/a.length;
const vr=a=>{const m=mean(a);return sum(a.map(x=>(x-m)**2))/(a.length-1)};
const med=a=>{const s=[...a].sort((x,y)=>x-y),n=s.length;return n%2?s[(n-1)/2]:(s[n/2-1]+s[n/2])/2};
const rank=a=>{const o=a.map((v,i)=>[v,i]).sort((x,y)=>x[0]-y[0]),r=[];for(let i=0;i<o.length;){let j=i;while(j+1<o.length&&o[j+1][0]===o[i][0])j++;for(let k=i;k<=j;k++)r[o[k][1]]=(i+j)/2+1;i=j+1}return r};
const pear=(x,y)=>{const mx=mean(x),my=mean(y);let a=0,b=0,c=0;x.forEach((v,i)=>{a+=(v-mx)*(y[i]-my);b+=(v-mx)**2;c+=(y[i]-my)**2});return a/Math.sqrt(b*c)};
const spear=(x,y)=>pear(rank(x),rank(y));
const wil=(p,n)=>{const z=1.96,d=1+z*z/n,c=p+z*z/(2*n),h=z*Math.sqrt(p*(1-p)/n+z*z/(4*n*n));return[(c-h)/d,(c+h)/d]};
const t2=(a,b)=>a==null||b==null?null:a+b;
/* ---------- random counts: Poisson and Negative Binomial (gamma-Poisson mixture) ---------- */
function norm(){return Math.sqrt(-2*Math.log(1-Math.random()))*Math.cos(2*Math.PI*Math.random())}
function pois(l){if(!(l>0))return 0;if(l>30)return Math.max(0,Math.round(l+Math.sqrt(l)*norm()));const L=Math.exp(-l);let k=0,p=1;do{k++;p*=Math.random()}while(p>L);return k-1}
function gam(a){if(a<1)return gam(a+1)*Math.pow(Math.random(),1/a);const d=a-1/3,c=1/Math.sqrt(9*d);for(;;){let x,v;do{x=norm();v=1+c*x}while(v<=0);v=v*v*v;const u=Math.random();if(Math.log(u)<.5*x*x+d-d*v+d*Math.log(v))return d*v}}
const cnt=(mu,r)=>mu<=0?0:(isFinite(r)&&r>0?pois(gam(r)*mu/r):pois(mu));
/* ---------- saved matches ---------- */
let H=[];try{H=JSON.parse(localStorage.getItem('mfl_h')||'[]')}catch(e){}
const save=()=>{try{localStorage.setItem('mfl_h',JSON.stringify(H))}catch(e){}};
const COLS=['date','home','away','hg','ag','hy','ay','hr','ar','hf','af','hc','ac','hst','ast'];
const NUMCOLS=['hg','ag','hy','ay','hr','ar','hf','af','hc','ac','hst','ast'];
function parseCSV(t){const L=t.trim().split(/\r?\n/).map(l=>l.split(',').map(s=>s.trim()));const h=L.shift().map(s=>s.toLowerCase()),rows=[];
 L.forEach(r=>{const o={};h.forEach((k,i)=>{o[k]=r[i]===undefined||r[i]===''?null:r[i]});if(!o.home||!o.away)return;
  NUMCOLS.forEach(k=>{const x=o[k]===null||o[k]===undefined?null:Number(o[k]);o[k]=x!==null&&isFinite(x)&&x>=0?x:null});rows.push(o)});return rows}
function teamAvg(name,N){const g=H.filter(r=>r.home===name||r.away===name).slice(-N);
 const f=sel=>{const v=g.map(sel).filter(x=>x!=null);return v.length?{m:mean(v),n:v.length}:null};
 return{gf:f(r=>r.home===name?r.hg:r.ag),ga:f(r=>r.home===name?r.ag:r.hg),y:f(r=>r.home===name?r.hy:r.ay),r:f(r=>r.home===name?r.hr:r.ar),fo:f(r=>r.home===name?r.hf:r.af),c:f(r=>r.home===name?r.hc:r.ac),sot:f(r=>r.home===name?r.hst:r.ast),n:g.length}}
function disp(fn){const v=H.map(fn).filter(x=>x!=null);
 if(v.length<20)return{r:Infinity,note:`Poisson assumed. Testing for overdispersion needs 20 or more saved matches (you have ${v.length}).`};
 const m=mean(v),s=vr(v);return s>1.15*m?{r:m*m/(s-m),note:`Negative Binomial used: variance ${f2(s)} is above mean ${f2(m)} (n=${v.length}).`}:{r:Infinity,note:`Poisson used: variance ${f2(s)} is close to mean ${f2(m)} (n=${v.length}).`}}
/* ---------- analyzer ---------- */
const F=[['n','Matches in sample'],['gf','Avg goals scored'],['ga','Avg goals conceded'],['y','Avg yellow cards'],['r','Avg red cards'],['f','Avg fouls committed'],['c','Avg corners'],['sot','Avg shots on target']];
const teamForm=(s,t)=>`<h3>${t}</h3><label>Team name<input id="${s}_name"></label>`+F.map(([k,l])=>`<label>${l}<input id="${s}_${k}" type="number" min="0" step="any"></label>`).join('')+`<select id="${s}_N">${Array.from({length:20},(_,i)=>`<option value="${i+1}"${i===4?' selected':''}>Last ${i+1}`).join('')}<option value="999">All saved</option></select><button onclick="fill('${s}')">Load from saved matches</button>`;
$('fh').innerHTML=teamForm('h','Home team');$('fa').innerHTML=teamForm('a','Away team');
function fill(s){const n=$(s+'_name').value.trim(),t=teamAvg(n,+$(s+'_N').value);
 if(!t.n){say(`No saved matches for “${esc(n)}”. The name must match the CSV exactly.`,'warn');return}
 const set=(k,o)=>{$(s+'_'+k).value=o?+o.m.toFixed(2):''};set('gf',t.gf);set('ga',t.ga);set('y',t.y);set('r',t.r);set('f',t.fo);set('c',t.c);set('sot',t.sot);$(s+'_n').value=t.n;
 say(`Loaded ${t.n} saved matches for ${esc(n)} (home and away together). Stats missing in the file stay empty.`)}
const DG='Goals scored and conceded by both teams, your multipliers',DC='Team card averages, referee average, foul count',DR='Red card averages (rarity handled by dispersion / Poisson)',DF='Foul averages of both teams',DCor='Corner averages of both teams';
const E=[
 // ---- Match goals: Over/Under total ----
 ['g05','Over 0.5 total goals',s=>s.hg+s.ag>0.5,c=>c.goals,DG],
 ['g15','Over 1.5 total goals',s=>s.hg+s.ag>1.5,c=>c.goals,DG],
 ['g25','Over 2.5 total goals',s=>s.hg+s.ag>2.5,c=>c.goals,DG],
 ['g35','Over 3.5 total goals',s=>s.hg+s.ag>3.5,c=>c.goals,DG],
 ['g45','Over 4.5 total goals',s=>s.hg+s.ag>4.5,c=>c.goals,DG],
 // ---- Teams that score + BTTS ----
 ['hsc','Home team scores',s=>s.hg>0,c=>c.goals,DG],
 ['asc','Away team scores',s=>s.ag>0,c=>c.goals,DG],
 ['bt','Both teams score',s=>s.hg>0&&s.ag>0,c=>c.goals,DG],
 // ---- 1X2 ----
 ['hw','Home team wins',s=>s.hg>s.ag,c=>c.goals,DG],
 ['dr','Draw',s=>s.hg===s.ag,c=>c.goals,DG],
 ['aw','Away team wins',s=>s.ag>s.hg,c=>c.goals,DG],
 // ---- Yellow cards ----
 ['y25','Over 2.5 total yellow cards',s=>s.y>2.5,c=>c.cards,DC],
 ['y35','Over 3.5 total yellow cards',s=>s.y>3.5,c=>c.cards,DC],
 ['y45','Over 4.5 total yellow cards',s=>s.y>4.5,c=>c.cards,DC],
 ['y55','Over 5.5 total yellow cards',s=>s.y>5.5,c=>c.cards,DC],
 // ---- Red cards ----
 ['rr1','At least one red card',s=>s.r>=1,c=>c.reds,DR],
 ['rr2','Two or more red cards',s=>s.r>=2,c=>c.reds,DR],
 // ---- Fouls ----
 ['f205','Over 20.5 total fouls',s=>s.f>20.5,c=>c.fouls,DF],
 ['f225','Over 22.5 total fouls',s=>s.f>22.5,c=>c.fouls,DF],
 ['f245','Over 24.5 total fouls',s=>s.f>24.5,c=>c.fouls,DF],
 ['hf','Home team over 10.5 fouls',s=>s.hf>10.5,c=>c.fouls,'Home foul average'],
 ['af','Away team over 10.5 fouls',s=>s.af>10.5,c=>c.fouls,'Away foul average'],
 // ---- Corners ----
 ['c85','Over 8.5 total corners',s=>s.c>8.5,c=>c.corners,DCor],
 ['c95','Over 9.5 total corners',s=>s.c>9.5,c=>c.corners,DCor],
 ['c105','Over 10.5 total corners',s=>s.c>10.5,c=>c.corners,DCor],
 ['c115','Over 11.5 total corners',s=>s.c>11.5,c=>c.corners,DCor],
 // ---- Shots on target ----
 ['hs35','Home team over 3.5 shots on target',s=>s.hsot>3.5,c=>c.sot_home,'Home shots-on-target average'],
 ['hs45','Home team over 4.5 shots on target',s=>s.hsot>4.5,c=>c.sot_home,'Home shots-on-target average'],
 ['as','Away team over 3.5 shots on target',s=>s.as>3.5,c=>c.sot_away,'Away shots-on-target average'],
 ['as45','Away team over 4.5 shots on target',s=>s.as>4.5,c=>c.sot_away,'Away shots-on-target average'],
];
let LAST=null,CH={};
const CO={responsive:true,maintainAspectRatio:false,plugins:{legend:{labels:{color:'#00ff41'}}},scales:{x:{ticks:{color:'#7dff98'},grid:{color:'#06300f'}},y:{ticks:{color:'#7dff98'},grid:{color:'#06300f'}}}};
const chart=(id,cfg)=>{if(!window.Chart||!$(id))return;CH[id]&&CH[id].destroy();CH[id]=new Chart($(id),cfg)};
const hist=(id,d,N,lab)=>{const mx=Math.max(0,...Object.keys(d).map(Number));const L=[...Array(mx+1).keys()];chart(id,{type:'bar',data:{labels:L,datasets:[{label:lab+' (% of simulations)',data:L.map(k=>(d[k]||0)/N*100),backgroundColor:'#00ff41aa'}]},options:CO})};
const ids=['h_n','h_gf','h_ga','h_y','h_r','h_f','h_c','h_sot','a_n','a_gf','a_ga','a_y','a_r','a_f','a_c','a_sot','r_y','r_n','x_hm','x_am','x_sims'];
function run(){
 const g={};for(const i of ids){g[i]=num(i);if(Number.isNaN(g[i]))return say(`Every value must be a number, 0 or more. Check: ${esc($(i).parentNode.firstChild.textContent)}`,'bad')}
 const N=Math.round(g.x_sims??10000);if(N<1000||N>300000)return say('Simulations must be between 1,000 and 300,000.','bad');
 const hm=g.x_hm??1,am=g.x_am??1;
 const c={
   goals:[g.h_gf,g.h_ga,g.a_gf,g.a_ga].every(x=>x!==null),
   cards:g.h_y!==null&&g.a_y!==null,
   reds:g.h_r!==null&&g.a_r!==null,
   fouls:g.h_f!==null&&g.a_f!==null,
   corners:g.h_c!==null&&g.a_c!==null,
   sot_home:g.h_sot!==null,
   sot_away:g.a_sot!==null,
 };
 if(!c.goals&&!c.cards&&!c.reds&&!c.fouls&&!c.corners&&!c.sot_home&&!c.sot_away)return say('Enter at least one full group: goals (all 4 values), yellow cards (both teams), red cards (both teams), fouls (both teams), corners (both teams) or shots on target (at least one team).','bad');
 say('');
 /* ----- Expected values ----- */
 const lh=c.goals?(g.h_gf+g.a_ga)/2*hm:0,la=c.goals?(g.a_gf+g.h_ga)/2*am:0;
 const tot=c.cards?g.h_y+g.a_y:0,Ey=c.cards?(g.r_y!==null?(tot+g.r_y)/2:tot):0;
 const Er=c.reds?g.h_r+g.a_r:0;
 const Ec=c.corners?g.h_c+g.a_c:0;
 const Ef=c.fouls?g.h_f+g.a_f:0;
 /* ----- Dispersion checks against saved matches ----- */
 const dG=disp(r=>t2(r.hg,r.ag)),dY=disp(r=>t2(r.hy,r.ay)),dR=disp(r=>t2(r.hr,r.ar)),
       dF=disp(r=>t2(r.hf,r.af)),dC=disp(r=>t2(r.hc,r.ac)),
       dSotH=disp(r=>r.hst),dSotA=disp(r=>r.ast);
 /* Variance-preserving split (same identity as existing fouls code):
    rH = d*.h/Ef  =>  h^2/rH + a^2/rA = Ef^2/d, so the total keeps the observed dispersion. */
 const rGh=isFinite(dG.r)&&(lh+la)>0?dG.r*lh/(lh+la):Infinity;
 const rGa=isFinite(dG.r)&&(lh+la)>0?dG.r*la/(lh+la):Infinity;
 const rH =isFinite(dF.r)&&Ef>0?dF.r*g.h_f/Ef:Infinity;
 const rA =isFinite(dF.r)&&Ef>0?dF.r*g.a_f/Ef:Infinity;
 /* ----- Simulation ----- */
 const act=E.filter(e=>e[3](c)),O={},D={g:{},y:{},r:{},f:{},c:{},hg:{},ag:{},hf:{},af:{},hsot:{},as:{}},CS_MAT={};
 act.forEach(e=>O[e[0]]=new Uint8Array(N));
 let mg=0,my=0,mr=0,mf=0,mc=0,mhs=0,mas=0;
 for(let i=0;i<N;i++){
   const s={hg:0,ag:0,y:0,r:0,f:0,hf:0,af:0,c:0,hsot:0,as:0};let k=1;
   if(c.goals){s.hg=cnt(lh,rGh);s.ag=cnt(la,rGa)}
   if(c.fouls){s.hf=cnt(g.h_f,rH);s.af=cnt(g.a_f,rA);s.f=s.hf+s.af;k=Ef>0?s.f/Ef:1}
   if(c.cards)s.y=c.fouls?pois(Ey*k):cnt(Ey,dY.r);
   if(c.reds)s.r=cnt(Er,dR.r);
   if(c.corners)s.c=cnt(Ec,dC.r);
   if(c.sot_home)s.hsot=cnt(g.h_sot,dSotH.r);
   if(c.sot_away)s.as=cnt(g.a_sot,dSotA.r);
   act.forEach(e=>{O[e[0]][i]=e[2](s)?1:0});
   const tg=s.hg+s.ag;D.g[tg]=(D.g[tg]||0)+1;D.y[s.y]=(D.y[s.y]||0)+1;
   if(c.goals){D.hg[s.hg]=(D.hg[s.hg]||0)+1;D.ag[s.ag]=(D.ag[s.ag]||0)+1;CS_MAT[s.hg+'-'+s.ag]=(CS_MAT[s.hg+'-'+s.ag]||0)+1;mg+=tg}
   if(c.reds)D.r[s.r]=(D.r[s.r]||0)+1;
   if(c.fouls){D.f[s.f]=(D.f[s.f]||0)+1;D.hf[s.hf]=(D.hf[s.hf]||0)+1;D.af[s.af]=(D.af[s.af]||0)+1;mf+=s.f}
   if(c.corners){D.c[s.c]=(D.c[s.c]||0)+1;mc+=s.c}
   if(c.sot_home){D.hsot[s.hsot]=(D.hsot[s.hsot]||0)+1;mhs+=s.hsot}
   if(c.sot_away){D.as[s.as]=(D.as[s.as]||0)+1;mas+=s.as}
   my+=s.y;mr+=s.r;
 }
 const p={};act.forEach(e=>p[e[0]]=sum(Array.from(O[e[0]]))/N);LAST={N,O,p,names:Object.fromEntries(E.map(e=>[e[0],e[1]]))};
 /* ----- Quality ----- */
 const n0=Math.min(g.h_n??0,g.a_n??0),q=g.h_n===null||g.a_n===null?['UNKNOWN','warn']:n0<10?['LOW','bad']:n0<30?['MEDIUM','warn']:['OK','pos'];
 const se=n0>0?x=>` &plusmn; ${f2(Math.sqrt(x/n0))}`:()=>'';
 /* ----- Expected values summary ----- */
 const ex=[];
 if(c.goals)ex.push(`Total goals: <b>${f2(mg/N)}</b> (home ${f2(lh)}, away ${f2(la)})${se(lh+la)}`);
 if(c.cards)ex.push(`Total yellow cards: <b>${f2(my/N)}</b>${se(Ey)}`);
 if(c.reds)ex.push(`Total red cards: <b>${f2(mr/N)}</b>`);
 if(c.fouls)ex.push(`Total fouls: <b>${f2(mf/N)}</b>${se(Ef)}`);
 if(c.corners)ex.push(`Total corners: <b>${f2(mc/N)}</b>${se(Ec)}`);
 if(c.sot_home)ex.push(`Home shots on target: <b>${f2(mhs/N)}</b>`);
 if(c.sot_away)ex.push(`Away shots on target: <b>${f2(mas/N)}</b>`);
 /* ----- Dispersion notes ----- */
 const dnotes=[];
 if(c.goals)dnotes.push(`Goals: ${dG.note}`);
 if(c.fouls)dnotes.push(`Fouls: ${dF.note}`);
 if(c.cards)dnotes.push(`Cards: ${c.fouls?'driven by the simulated fouls (cards and fouls move together)':dY.note}`);
 if(c.reds)dnotes.push(`Red cards: ${dR.note}`);
 if(c.corners)dnotes.push(`Corners: ${dC.note}`);
 if(c.sot_home)dnotes.push(`Home shots on target: ${dSotH.note}`);
 if(c.sot_away)dnotes.push(`Away shots on target: ${dSotA.note}`);
 /* ----- O/U and distribution helpers ----- */
 const ouRender=(title,d,lines)=>{const ks=Object.keys(d).map(Number);const t=lines.map(line=>{let o=0;ks.forEach(k=>{if(k>line)o+=d[k]||0});const pp=o/N;return{line,o:Math.max(0,Math.min(1,pp)),u:Math.max(0,Math.min(1,1-pp))}});
   return `<h4>${title}</h4><div class="tw"><table><tr><th>Line</th>${t.map(x=>`<th>${x.line}</th>`).join('')}</tr><tr><td>Over</td>${t.map(x=>`<td>${pc(x.o)}</td>`).join('')}</tr><tr><td>Under</td>${t.map(x=>`<td>${pc(x.u)}</td>`).join('')}</tr></table></div>`};
 const distTable=(title,d,maxK)=>{const vals=[];for(let k=0;k<maxK;k++)vals.push((d[k]||0)/N);const tail=Object.keys(d).filter(k=>+k>=maxK).reduce((a,k)=>a+d[k],0)/N;
   return `<h4>${title}</h4><div class="tw"><table><tr><th>Value</th>${vals.map((_,k)=>`<th>${k}</th>`).join('')}<th>&ge;${maxK}</th></tr><tr><td>P</td>${vals.map(c=>`<td>${pc(Math.max(0,Math.min(1,c)))}</td>`).join('')}<td>${pc(Math.max(0,Math.min(1,tail)))}</td></tr></table></div>`};
 const scoreTable=()=>{const items=Object.entries(CS_MAT).map(([k,v])=>({sc:k.split('-').map(Number),p:v/N})).sort((a,b)=>b.p-a.p).slice(0,15);
   return `<table><tr><th>Score (home-away)</th><th>Probability</th><th>Fair odds</th></tr>${items.map(x=>`<tr><td>${x.sc[0]}-${x.sc[1]}</td><td>${pc(x.p)}</td><td>${x.p>0?f2(1/x.p):'-'}</td></tr>`).join('')}</table>`};
 /* ----- Build results ----- */
 let html=`<div class="card"><h2>2. Results <span class="t m">MODEL</span></h2>
 <p>Data quality: <b class="${q[1]}">${q[0]}</b> (smallest team sample: ${n0||'unknown'} matches). ${H.length<30?'<span class="warn">You have fewer than 30 saved matches, so no fitted model is possible. This is a simplified estimate, not a fitted model.</span>':''}</p>
 <p>${ex.join('<br>')}</p>
 <p class="hint">Dispersion: ${dnotes.join('<br>')}</p></div>`;

 if(c.goals){
   html+=`<div class="card"><h3>Match Goals</h3>
   <p>Expected goals: home <b>${f2(lh)}</b>, away <b>${f2(la)}</b>, total <b>${f2(lh+la)}</b>. Distribution: ${isFinite(dG.r)?'Negative Binomial per team':'Poisson per team'}.</p>
   <p>P(home scores) <b>${pc(p.hsc)}</b> &middot; P(away scores) <b>${pc(p.asc)}</b> &middot; P(both teams score) <b>${pc(p.bt)}</b> &middot; P(draw) <b>${pc(p.dr)}</b></p>
   ${ouRender('Total goals — Over/Under',D.g,[0.5,1.5,2.5,3.5,4.5])}
   <div class="grid"><div class="ch"><canvas id="c_g"></canvas></div></div>
   ${distTable('Home goals distribution',D.hg,6)}
   ${distTable('Away goals distribution',D.ag,6)}
   <h4>Most likely correct scores</h4><div class="tw">${scoreTable()}</div>
   <p class="hint">Home and away goals are simulated independently (standard Poisson-based assumption; not bivariate). Correct score probabilities are empirical from the simulation and carry Monte Carlo noise of roughly &plusmn;${f2(100*Math.sqrt(0.5*(1-0.5)/N),2)}% on a single scoreline.</p></div>`;
 }
 if(c.cards){
   html+=`<div class="card"><h3>Yellow Cards</h3>
   <p>Expected total yellow cards: <b>${f2(my/N)}</b>. ${c.fouls?'In each simulated match the card rate scales with the simulated fouls, so fouls and cards move together.':'No fouls input, so cards were simulated independently with the chosen dispersion.'}</p>
   ${ouRender('Total yellow cards — Over/Under',D.y,[2.5,3.5,4.5,5.5])}
   <div class="grid"><div class="ch"><canvas id="c_y"></canvas></div></div></div>`;
 }
 if(c.reds){
   html+=`<div class="card"><h3>Red Cards</h3>
   <p>Expected total red cards: <b>${f2(mr/N)}</b>. P(at least one) <b>${pc(p.rr1)}</b> &middot; P(two or more) <b>${pc(p.rr2)}</b>.</p>
   <p class="hint warn">Red cards are rare. ${isFinite(dR.r)?'Negative Binomial used.':'Poisson used (either no saved data, or data did not show overdispersion).'} ${g.h_r===0&&g.a_r===0?'Both teams entered as 0 — the model will output 0 for every red-card market.':'If the averages were entered manually without saved-match data, this is an ASSUMPTION, not a measured rate. With means below about 0.3, Poisson and NB are both approximations: treat the numbers as rough.'}</p></div>`;
 }
 if(c.fouls){
   html+=`<div class="card"><h3>Fouls</h3>
   <p>Expected total fouls: <b>${f2(mf/N)}</b>. Per team, home <b>${f2(g.h_f)}</b>, away <b>${f2(g.a_f)}</b>.</p>
   ${ouRender('Total fouls — Over/Under',D.f,[20.5,22.5,24.5])}
   ${ouRender('Home team fouls — Over/Under',D.hf,[8.5,10.5,12.5])}
   ${ouRender('Away team fouls — Over/Under',D.af,[8.5,10.5,12.5])}
   <div class="grid"><div class="ch"><canvas id="c_f"></canvas></div></div></div>`;
 }
 if(c.corners){
   html+=`<div class="card"><h3>Corners</h3>
   <p>Expected total corners: <b>${f2(mc/N)}</b>. Per team, home <b>${f2(g.h_c)}</b>, away <b>${f2(g.a_c)}</b>.</p>
   ${ouRender('Total corners — Over/Under',D.c,[8.5,9.5,10.5,11.5])}
   <div class="grid"><div class="ch"><canvas id="c_c"></canvas></div></div></div>`;
 }
 if(c.sot_home||c.sot_away){
   html+=`<div class="card"><h3>Shots on Target</h3>`;
   if(c.sot_home){
     html+=`<p>Home: expected <b>${f2(mhs/N)}</b>.</p>${ouRender('Home team shots on target — Over/Under',D.hsot,[2.5,3.5,4.5])}`;
   }
   if(c.sot_away){
     html+=`<p>Away: expected <b>${f2(mas/N)}</b>.</p>${ouRender('Away team shots on target — Over/Under',D.as,[2.5,3.5,4.5])}`;
   }
   html+=`</div>`;
 }
 /* ----- All events table (for the Bet Calculator) ----- */
 const rows=act.map(e=>{const w=wil(p[e[0]],N);return `<tr><td>${e[1]}</td><td><b>${pc(p[e[0]])}</b></td><td>${pc(w[0])} to ${pc(w[1])}</td><td>${p[e[0]]>0?f2(1/p[e[0]]):'-'}</td><td>${N.toLocaleString()} sims / n=${n0||'?'}</td><td>${e[4]}</td><td><button onclick="addSel('${e[0]}')">+ Bets</button></td></tr>`}).join('');
 const skipped=E.filter(e=>!e[3](c)).map(e=>e[1]);
 html+=`<div class="card"><h3>All events for the Bet Calculator</h3>
 <p class="hint">Every event that was actually simulated. Empty rows mean the required inputs were not entered.</p>
 <div class="tw"><table><tr><th>Event</th><th>Probability</th><th>95% interval</th><th>Fair odds</th><th>Sample</th><th>Main inputs</th><th></th></tr>${rows}</table></div>
 ${skipped.length?`<p class="hint warn">Skipped because data is missing: ${skipped.join('; ')}.</p>`:''}
 <details><summary>How these numbers are made</summary><p class="hint">1) Expected goals: home = (home goals scored + away goals conceded) / 2 times your multiplier. Away is the mirror. Goals are Poisson when the data does not show overdispersion; when it does, a Negative Binomial with the same total dispersion is used, split by the expected-goal share so the total variance matches the observed one (same identity used for fouls). Home and away goals are assumed independent. Correct scores are empirical from the simulation (not analytic).<br>2) Fouls, corners and shots on target: Poisson, or Negative Binomial when saved matches show variance above the mean. Home and away counts are summed for totals and simulated separately for per-team markets.<br>3) Yellow cards: expected total = average of the two teams’ card sum and the referee average (equal weights, an ASSUMPTION, not fitted). In each simulated match the card rate scales with that match’s simulated fouls, so cards and fouls are linked instead of multiplied as separate probabilities.<br>4) Red cards: NB / Poisson on the total per match. Because the mean is usually small, the tail (two or more) is sensitive to the choice of dispersion, so treat it as a range, not a point.<br>5) Cards and goals are assumed independent of each other.<br>6) Probability = share of simulated matches where the event happened. The 95% interval (Wilson) shows simulation noise only. Real uncertainty is larger when samples are small, because the inputs themselves are averages.<br>7) Correlation is not causation. A strict referee or an intense match could raise both fouls and cards.</p></details></div>`;
 $('res').hidden=false;$('res').innerHTML=html;
 if(c.goals)hist('c_g',D.g,N,'Total goals');
 if(c.cards)hist('c_y',D.y,N,'Total yellow cards');
 if(c.fouls)hist('c_f',D.f,N,'Total fouls');
 if(c.corners)hist('c_c',D.c,N,'Total corners');
 if(S.length)renderBets();
}
$('go').onclick=run;
/* ---------- bets ---------- */
let S=[];
function addSel(k){S.push({k,d:k?LAST.names[k]:'',p:'',o:'',opp:'',st:''});location.hash='#bets';renderBets()}
$('addm').onclick=()=>{S.push({k:null,d:'',p:'',o:'',opp:'',st:''});renderBets()};
function renderBets(){$('sel').innerHTML=S.length?S.map((s,i)=>{const lp=s.k&&LAST&&LAST.p[s.k]!=null?(LAST.p[s.k]*100).toFixed(1):'';
 const I=(f,l,x='')=>`<label>${l}<input data-i="${i}" data-f="${f}" ${x}></label>`;
 return `<div class="sel"><div>${s.k?'<span class="t m">MODEL</span>':'<span class="t a">ASSUMPTION</span>'}</div>`+I('d','Event',`value="${esc(s.d)}"`)+I('p','Probability %',s.k?`disabled value="${lp}"`:`type="number" step="any" min="0" max="100" value="${esc(s.p)}"`)+I('o','Decimal odds',`type="number" step="any" min="1" value="${esc(s.o)}"`)+I('opp','Opposite-side odds (optional)',`type="number" step="any" min="1" value="${esc(s.opp)}"`)+I('st','Stake (optional)',`type="number" step="any" min="0" value="${esc(s.st)}"`)+`<button data-rm="${i}">Remove</button></div>`}).join(''):'<p class="hint">No selections yet. Run the Analyzer and press “+ Bets”, or add a manual one.</p>';calc()}
$('sel').addEventListener('input',e=>{const t=e.target;if(t.dataset.i!==undefined){S[+t.dataset.i][t.dataset.f]=t.value;calc()}});
$('sel').addEventListener('click',e=>{if(e.target.dataset.rm!==undefined){S.splice(+e.target.dataset.rm,1);renderBets()}});
function calc(){const el=$('sum');if(!S.length){el.innerHTML='';return}
 const R=S.map(s=>({s,p:s.k?(LAST&&LAST.p[s.k]!=null?LAST.p[s.k]:null):(s.p===''?null:+s.p/100),o:+s.o,opp:+s.opp,st:s.st===''?null:+s.st}));
 if(R.some(r=>r.p==null||!(r.p>0&&r.p<=1)||!(r.o>1)||(r.s.opp!==''&&!(r.opp>1))||(r.st!==null&&!(r.st>=0)))){el.innerHTML='<p class="warn">Fill every selection: probability above 0 and up to 100, decimal odds above 1. Model picks need an Analyzer run that includes that event. Optional fields can stay empty.</p>';return}
 const rows=R.map(r=>{const imp=1/r.o;let fair='-',mg='-';if(r.s.opp!==''){const m=imp+1/r.opp;fair=pc(imp/m);mg=pc(m-1)}const ev=r.p*r.o-1;
  return `<tr><td>${esc(r.s.d)||'-'}</td><td>${pc(r.p)}</td><td>${pc(imp)}</td><td>${fair}</td><td>${mg}</td><td class="${ev>=0?'pos':'neg'}">${f2(ev*100,1)}%</td><td>${r.st==null?'-':f2(r.st*ev)}</td></tr>`}).join('');
 const K=R.filter(r=>r.s.k),M=R.filter(r=>!r.s.k);let pj=1,ci='';
 if(K.length){let cn=0;for(let i=0;i<LAST.N;i++)if(K.every(r=>LAST.O[r.s.k][i]))cn++;pj=cn/LAST.N;const w=wil(pj,LAST.N);ci=` (95% interval ${pc(w[0])} to ${pc(w[1])}, simulation noise only)`}
 const P=pj*M.reduce((a,r)=>a*r.p,1),naive=R.reduce((a,r)=>a*r.p,1),Od=R.reduce((a,r)=>a*r.o,1),st=+$('b_st').value||0,ev=P*Od-1;
 const lab=!K.length?'INDEPENDENCE APPROXIMATION: the probabilities were multiplied. Real dependence between the picks is unknown.':!M.length?'JOINT (Monte Carlo): all picks were counted inside the same simulated matches, so the dependence built into the model is included.':'PARTLY JOINT: model picks were counted together. Manual picks were multiplied in as independent.';
 el.innerHTML=`<div class="tw"><table><tr><th>Selection</th><th>Your P</th><th>Implied P (1/odds)</th><th>Fair P (margin removed)</th><th>Bookmaker margin</th><th>EV</th><th>Single-bet expected profit</th></tr>${rows}</table></div>
 <h3>Combined bet</h3><p class="warn">${lab}</p>
 <p>Combined probability: <b>${pc(P)}</b>${ci}<br>Plain multiplication of all probabilities: ${pc(naive)}${Math.abs(P-naive)>.005?' (differs, because the picks are dependent)':''}<br>Combined decimal odds: <b>${f2(Od)}</b> (implied ${pc(1/Od)})<br>Expected value per 1 unit: <b class="${ev>=0?'pos':'neg'}">${f2(ev,3)}</b> &middot; Expected ROI: <b class="${ev>=0?'pos':'neg'}">${f2(ev*100,1)}%</b>
 ${st>0?`<br>Stake ${f2(st)}: return if all win ${f2(st*Od)}, profit if all win ${f2(st*(Od-1))}, expected profit ${f2(st*ev)}`:''}</p>
 <p class="hint">EV is a theoretical average over many repeats of the same bet. It is not guaranteed profit. It is only as good as the probability you put in, and small samples can make the model wrong. Never raise stakes to win back losses.</p>`}
/* ---------- data page ---------- */
$('file').onchange=e=>{const f=e.target.files[0];if(!f)return;const r=new FileReader();r.onload=()=>{$('csv').value=r.result};r.readAsText(f)};
$('imp').onclick=()=>{try{const rows=parseCSV($('csv').value);if(!rows.length)throw 0;if(rows.every(r=>r.date))rows.sort((a,b)=>String(a.date).localeCompare(String(b.date)));H=rows;save();$('dmsg').innerHTML=`<p class="pos">Imported ${rows.length} matches.</p>`;renderData()}catch(e){$('dmsg').innerHTML='<p class="bad">Could not read the CSV. It needs a header row with at least “home” and “away”.</p>'}};
$('exp').onclick=()=>{$('csv').value=[COLS.join(','),...H.map(r=>COLS.map(k=>r[k]??'').join(','))].join('\n');$('csv').select();$('dmsg').innerHTML='<p class="hint">Copy the text above to save it as a file.</p>'};
$('clr').onclick=()=>{if(confirm('Delete all saved matches?')){H=[];save();renderData()}};
function renderData(){if(!H.length){$('dsum').innerHTML='<p class="hint">No saved matches yet.</p>';return}
 const C=[['hg','Home goals'],['ag','Away goals'],['hy','Home yellow cards'],['ay','Away yellow cards'],['hr','Home red cards'],['ar','Away red cards'],['hf','Home fouls'],['af','Away fouls'],['hc','Home corners'],['ac','Away corners'],['hst','Home shots on target'],['ast','Away shots on target']];
 const ds=C.map(([k,l])=>{const v=H.map(r=>r[k]).filter(x=>x!=null),n=v.length;if(!n)return `<tr><td>${l}</td><td>0</td><td>${H.length}</td><td colspan="4">no data</td></tr>`;const m=mean(v),sd=n>1?Math.sqrt(vr(v)):null;
  return `<tr><td>${l}</td><td>${n}${n<30?' <span class="warn">(small)</span>':''}</td><td>${H.length-n}</td><td>${f2(m)}</td><td>${f2(med(v))}</td><td>${f2(sd)}</td><td>${m>0&&sd!=null?f2(sd/m):'-'}</td></tr>`}).join('');
 const P=[['Total fouls','Total yellow cards',r=>t2(r.hf,r.af),r=>t2(r.hy,r.ay)],['Home fouls','Home yellow cards',r=>r.hf,r=>r.hy],['Away fouls','Away yellow cards',r=>r.af,r=>r.ay],['Home goals','Away goals',r=>r.hg,r=>r.ag],['Total goals','Total yellow cards',r=>t2(r.hg,r.ag),r=>t2(r.hy,r.ay)]];
 const cr=P.map(([a,b,fa,fb])=>{const x=[],y=[];H.forEach(r=>{const u=fa(r),v=fb(r);if(u!=null&&v!=null){x.push(u);y.push(v)}});
  return x.length<8?`<tr><td>${a} vs ${b}</td><td>${x.length}</td><td colspan="2" class="warn">needs 8 or more complete rows</td></tr>`:`<tr><td>${a} vs ${b}</td><td>${x.length}</td><td>${f2(pear(x,y))}</td><td>${f2(spear(x,y))}</td></tr>`}).join('');
 $('dsum').innerHTML=`<p>${H.length} saved matches <span class="t d">DATA</span></p><div class="tw"><table><tr><th>Column</th><th>Known values</th><th>Missing</th><th>Mean</th><th>Median</th><th>Std dev</th><th>CV (sd/mean)</th></tr>${ds}</table></div>
 <h3>Relationships</h3><div class="tw"><table><tr><th>Pair</th><th>Rows</th><th>Pearson</th><th>Spearman</th></tr>${cr}</table></div><p class="hint">Correlation shows that two things move together. It does not show that one causes the other. Hidden factors such as referee style or match intensity can drive both.</p>`}
function backtest(){const R=H.filter(r=>r.hg!=null&&r.ag!=null),b=$('bt');
 if(R.length<30){b.innerHTML=`<p class="warn">Not enough data. A fair test needs at least 30 saved matches with goals. You have ${R.length}.</p>`;return}
 const cut=Math.floor(R.length*.7),tr=R.slice(0,cut),te=R.slice(cut),T={};
 tr.forEach(r=>[[r.home,r.hg,r.ag],[r.away,r.ag,r.hg]].forEach(([t,f,a])=>{const o=T[t]=T[t]||{f:[],a:[]};o.f.push(f);o.a.push(a)}));
 const P=[],Y=[],L=[],A=[],rows=[];
 te.forEach(r=>{const a=T[r.home],c=T[r.away];if(!a||!c||a.f.length<3||c.f.length<3)return;
  const l=(mean(a.f)+mean(c.a))/2+(mean(c.f)+mean(a.a))/2,p=1-Math.exp(-l)*(1+l+l*l/2),y=r.hg+r.ag>2.5?1:0;
  P.push(p);Y.push(y);L.push(l);A.push(r.hg+r.ag);if(rows.length<10)rows.push(`<tr><td>${esc(r.home)} vs ${esc(r.away)}</td><td>${pc(p)}</td><td>${f2(l)}</td><td>${r.hg+r.ag}</td><td>${y?'Over':'Under'}</td></tr>`)});
 const n=P.length;if(n<10){b.innerHTML=`<p class="warn">Only ${n} test matches have teams with 3 or more training matches. Too few for reliable scores. Add more matches.</p>`;return}
 const base=mean(tr.map(r=>r.hg+r.ag>2.5?1:0)),br=mean(P.map((p,i)=>(p-Y[i])**2)),bb=mean(Y.map(y=>(base-y)**2)),cl=p=>Math.min(1-1e-6,Math.max(1e-6,p));
 const ll=-mean(P.map((p,i)=>Y[i]*Math.log(cl(p))+(1-Y[i])*Math.log(1-cl(p)))),mae=mean(L.map((l,i)=>Math.abs(l-A[i]))),rmse=Math.sqrt(mean(L.map((l,i)=>(l-A[i])**2)));
 let tp=0,fp=0,fn=0,tn=0;P.forEach((p,i)=>{const h=p>=.5;if(h&&Y[i])tp++;else if(h)fp++;else if(Y[i])fn++;else tn++});
 const cal=[0,1,2,3,4].map(k=>{const ix=P.map((p,i)=>i).filter(i=>Math.min(4,Math.floor(P[i]*5))===k);return{n:ix.length,p:ix.length?mean(ix.map(i=>P[i])):null,o:ix.length?mean(ix.map(i=>Y[i])):null}});
 b.innerHTML=`<p>Train: ${tr.length} oldest matches. Test: ${n} newest usable matches (${te.length-n} skipped because a team had fewer than 3 training matches).</p>
 <div class="tw"><table><tr><th>Brier score (model)</th><th>Brier (naive baseline)</th><th>Log loss</th><th>MAE (goals)</th><th>RMSE (goals)</th></tr><tr><td>${f2(br,4)}</td><td>${f2(bb,4)}</td><td>${f2(ll,4)}</td><td>${f2(mae)}</td><td>${f2(rmse)}</td></tr></table></div>
 <p class="${br<bb?'pos':'bad'}">${br<bb?'The model beat the naive baseline (always predicting the training over rate) on this test set.':'The model did NOT beat the naive baseline here. Do not trust its probabilities yet.'}</p>
 <p class="hint">Lower Brier and log loss are better. A calibrated model has observed rates close to predicted rates.</p>
 <h3>Confusion matrix (predict Over when P &ge; 50%)</h3><div class="tw"><table><tr><th></th><th>Actual Over</th><th>Actual Under</th></tr><tr><th>Predicted Over</th><td>${tp}</td><td>${fp}</td></tr><tr><th>Predicted Under</th><td>${fn}</td><td>${tn}</td></tr></table></div>
 <h3>Calibration</h3><div class="ch"><canvas id="c_cal"></canvas></div>
 <h3>Predictions vs actual results (first 10 test matches)</h3><div class="tw"><table><tr><th>Match</th><th>P(Over 2.5)</th><th>Predicted goals</th><th>Actual goals</th><th>Result</th></tr>${rows.join('')}</table></div>`;
 chart('c_cal',{type:'line',data:{labels:cal.map((c,k)=>`${k*20}-${k*20+20}% (n=${c.n})`),datasets:[{label:'Mean predicted',data:cal.map(c=>c.p),borderColor:'#7df9ff'},{label:'Observed rate',data:cal.map(c=>c.o),borderColor:'#00ff41'}]},options:{...CO,scales:{...CO.scales,y:{...CO.scales.y,min:0,max:1}}}})}
$('bt_go').onclick=backtest;
/* ---------- combined form calculator (unchanged mathematics) ---------- */
const MK=['Yellow cards','Red cards','Fouls','Corners','Goals','Match result','Both teams score','Shots on target','Player market','Other'];
const REL=[['Yellow cards','Fouls'],['Yellow cards','Red cards'],['Goals','Match result'],['Goals','Both teams score'],['Match result','Both teams score'],['Goals','Shots on target'],['Corners','Shots on target'],['Match result','Shots on target'],['Corners','Goals']];
let CS=[{m:'',t:'',d:'',p:'',o:'',n:''}],RHO={},SIG='';
/*MATH-BEGIN*/
/* Normal CDF: Hart/West double-precision algorithm (about 1e-15 absolute error) */
const cdf=x=>{const a=Math.abs(x);let c;if(a>37)c=0;else{const e=Math.exp(-a*a/2);if(a<7.07106781186547){let b=3.52624965998911e-02*a+.700383064443688;b=b*a+6.37396220353165;b=b*a+33.912866078383;b=b*a+112.079291497871;b=b*a+221.213596169931;b=b*a+220.206867912376;c=e*b;b=8.83883476483184e-02*a+1.75566716318264;b=b*a+16.064177579207;b=b*a+86.7807322029461;b=b*a+296.564248779674;b=b*a+637.333633378831;b=b*a+793.826512519948;b=b*a+440.413735824752;c/=b}else{let b=a+.65;b=a+4/b;b=a+3/b;b=a+2/b;b=a+1/b;c=e/b/2.506628274631}}return x>0?1-c:c};
/* Inverse normal CDF: Acklam rational start + two Halley refinement steps against the accurate cdf */
const icdf=p=>{if(!(p>0))return-Infinity;if(!(p<1))return Infinity;if(p>.5)return-icdf(1-p);
 const A=[-39.69683028665376,220.9460984245205,-275.9285104469687,138.357751867269,-30.66479806614716,2.506628277459239],B=[-54.47609879822406,161.5858368580409,-155.6989798598866,66.80131188771972,-13.28068155288572],C=[-.007784894002430293,-.3223964580411365,-2.400758277161838,-2.549732539343734,4.374664141464968,2.938163982698783],D=[.007784695709041462,.3224671290700398,2.445134137142996,3.754408661907416];
 let x;if(p<.02425){const q=Math.sqrt(-2*Math.log(p));x=(((((C[0]*q+C[1])*q+C[2])*q+C[3])*q+C[4])*q+C[5])/((((D[0]*q+D[1])*q+D[2])*q+D[3])*q+1)}else{const q=p-.5,r=q*q;x=(((((A[0]*r+A[1])*r+A[2])*r+A[3])*r+A[4])*r+A[5])*q/(((((B[0]*r+B[1])*r+B[2])*r+B[3])*r+B[4])*r+1)}
 for(let i=0;i<2;i++){const u=(cdf(x)-p)*2.5066282746310002*Math.exp(x*x/2);x-=u/(1+x*u/2)}return x};
const frechet=ps=>[Math.max(0,sum(ps)-(ps.length-1)),Math.min(...ps)];
const clamp01=x=>Math.min(1,Math.max(0,x));
const eqR=(k,r)=>Array.from({length:k},(_,i)=>Array.from({length:k},(_,j)=>i===j?1:r));
const rhoMin=k=>k<2?0:-1/(k-1); /* equicorrelation matrix is positive semidefinite only for rho in [-1/(k-1), 1] */
/* Cholesky with a strict PSD test. Pivot below -1e-9: not PSD. Pivot up to 1e-13: zero pivot (singular PSD); every residual under a zero pivot must then be zero within the Cauchy-Schwarz bound 1e-9+sqrt(pivot*remaining diagonal), otherwise the matrix is NOT PSD and is rejected (the old code silently dropped such residuals). Nothing is repaired. */
const chol=R=>{if(!R.every(r=>r.every(Number.isFinite)))return null;const k=R.length,L=[],P=[];for(let i=0;i<k;i++){L[i]=Array(k).fill(0);for(let j=0;j<=i;j++){let s=R[i][j];for(let m=0;m<j;m++)s-=L[i][m]*L[j][m];
 if(i===j){if(s<-1e-9)return null;P[i]=s;L[i][i]=s>1e-13?Math.sqrt(s):0}
 else if(L[j][j]>0)L[i][j]=s/L[j][j];
 else{let d=R[i][i];for(let m=0;m<j;m++)d-=L[i][m]*L[i][m];if(Math.abs(s)>1e-9+Math.sqrt(Math.max(P[j],0)*Math.max(d,0)))return null}}}return L};
const rng=s=>()=>{s=s+0x6D2B79F5|0;let t=Math.imul(s^s>>>15,1|s);t=t+Math.imul(t^t>>>7,61|t)^t;return((t^t>>>14)>>>0)/4294967296};
/* Genz separation-of-variables Monte Carlo for P(X_i<=z_i for all i), X ~ N(0,R). Works for any PSD matrix; returns estimate and standard error */
function genz(L,z,M,seed){const k=z.length,rnd=rng(seed),y=[];let s=0,s2=0;for(let t=0;t<M;t++){let f=1;for(let i=0;i<k&&f>0;i++){let a=0;for(let j=0;j<i;j++)a+=L[i][j]*y[j];const d=L[i][i],e=d>0?cdf((z[i]-a)/d):(z[i]-a>=0?1:0);f*=e;if(i<k-1)y[i]=icdf(Math.min(1-1e-15,Math.max(1e-15,rnd()*e)))}s+=f;s2+=f*f}const m=s/M;return{p:m,se:Math.sqrt(Math.max(0,s2/M-m*m)/M)}}
/* Joint probability that ALL events happen, Gaussian copula with latent correlation matrix R.
   equal non-negative correlation: deterministic one-factor integral over [-9,9] (truncation error below 1e-18)
   everything else (negative or pairwise): Genz Monte Carlo, doubled until the standard error is small or 640000 draws are used */
function jointR(ps,R,seed=12345){const idx=[];for(let i=0;i<ps.length;i++){if(!(ps[i]>0))return{p:0,se:0,m:'exact (a probability is 0)'};if(ps[i]<1)idx.push(i)}
 const q=idx.map(i=>ps[i]),k=q.length;if(k===0)return{p:1,se:0,m:'exact'};if(k===1)return{p:q[0],se:0,m:'exact'};
 const RR=idx.map(i=>idx.map(j=>R[i][j])),z=q.map(icdf),fr=frechet(q),off=RR[0][1],eq=RR.every((r,i)=>r.every((v,j)=>i===j||Math.abs(v-off)<1e-12)),fin=o=>({...o,p:Math.min(fr[1],Math.max(fr[0],clamp01(o.p)))});
 const L=chol(RR);if(!L)return{p:NaN,se:NaN,m:'invalid (not positive semidefinite)'};
 if(eq&&off>=0){if(off>=1-1e-12)return{p:fr[1],se:0,m:'exact (perfect latent dependence = Fréchet upper bound)'};if(off===0)return{p:q.reduce((a,x)=>a*x,1),se:0,m:'exact (independence)'};
  const sr=Math.sqrt(off),sq=Math.sqrt(1-off),n=3600,h=18/n;let t=0;for(let i=0;i<=n;i++){const f=-9+i*h;let w=Math.exp(-f*f/2)/2.5066282746310002;for(const zi of z)w*=cdf((zi-sr*f)/sq);t+=w*(i===0||i===n?.5:1)}return fin({p:t*h,se:0,m:'deterministic one-factor integral'})}
 let M=20000,r=genz(L,z,M,seed);while(r.se>Math.max(2e-5,.005*r.p)&&M<640000){M*=2;r=genz(L,z,M,seed)}return fin({...r,m:`Genz Monte Carlo, ${M.toLocaleString()} draws, seed ${seed}`})}
const phi=(p,q,j)=>{const d=Math.sqrt(p*(1-p)*q*(1-q));return d>0?(j-p*q)/d:NaN}; /* correlation between two yes/no outcomes */
/*MATH-END*/
/* ---------- numerical self-tests (analytic references) ---------- */
function selfTests(){const T=[],t=(n,ok,d)=>T.push([n,!!ok,d||'']),ae=(a,b,e)=>Math.abs(a-b)<=e,fr=(ps,j)=>j>=frechet(ps)[0]-1e-9&&j<=frechet(ps)[1]+1e-9&&j>=0&&j<=1;
 const eqJ=(ps,r)=>jointR(ps,eqR(ps.length,r)),tri=r=>1/8+3/(4*Math.PI)*Math.asin(r);
 t('Φ(1.96) vs 0.9750021048517795',ae(cdf(1.96),.9750021048517795,1e-13));t('Φ(-3) vs 0.0013498980316301',ae(cdf(-3),.0013498980316301,1e-13));t('Φ(-5) vs 2.866515718791939e-7',ae(cdf(-5),2.866515718791939e-7,1e-13));
 t('Φ⁻¹(0.975) vs 1.959963984540054',ae(icdf(.975),1.959963984540054,1e-10));t('Φ⁻¹(1e-6) vs -4.753424308822899',ae(icdf(1e-6),-4.753424308822899,1e-9));t('Φ⁻¹(0.999) vs 3.090232306167813',ae(icdf(.999),3.090232306167813,1e-9));
 t('Φ(Φ⁻¹(p)) round trip, 7 values',[1e-8,.001,.1,.5,.7,.99,1-1e-9].every(p=>ae(cdf(icdf(p)),p,1e-12)));
 let r=eqJ([.3,.6],0);t('2 independent events: 0.3×0.6',ae(r.p,.18,1e-12),f2(r.p,6));
 r=eqJ([.3,.6],1);t('2 perfectly positive (ρ=1): min(p,q)',ae(r.p,.3,1e-12),f2(r.p,6));
 r=eqJ([.5,.5],.7);t('2 positive, p=q=½, ρ=0.7: ¼+asin(ρ)/2π',ae(r.p,.25+Math.asin(.7)/(2*Math.PI),1e-9),f2(r.p,8));
 r=eqJ([.5,.5],-.7);t('2 negative, p=q=½, ρ=-0.7: ¼+asin(ρ)/2π',ae(r.p,.25+Math.asin(-.7)/(2*Math.PI),Math.max(4*r.se,1e-3)),`${f2(r.p,6)} ± ${f2(r.se,6)} SE`);
 r=eqJ([.7,.6],-1);t('2 perfectly negative (ρ=-1): max(0,p+q-1)=0.3',ae(r.p,.3,Math.max(4*r.se,2e-3)),`${f2(r.p,5)} ± ${f2(r.se,5)}`);
 r=eqJ([.5,.5,.5],.5);t('3 positive equicorrelation ρ=0.5, p=½: exactly ¼',ae(r.p,.25,1e-9),f2(r.p,8));
 r=eqJ([.5,.5,.5],.3);t('3 positive ρ=0.3: ⅛+3·asin(ρ)/4π',ae(r.p,tri(.3),1e-9),f2(r.p,8));
 r=eqJ([.5,.5,.5],-.4);t('3 negative ρ=-0.4: ⅛+3·asin(ρ)/4π',ae(r.p,tri(-.4),Math.max(4*r.se,5e-4)),`${f2(r.p,6)} vs ${f2(tri(-.4),6)}, SE ${f2(r.se,6)}`);
 r=eqJ([.5,.5,.5],-.5);t('3 negative at the boundary ρ=-½: probability 0',r.p<2e-3,f2(r.p,6));
 t('ρ=-0.6 is outside the valid range for 3 picks (min -0.5), matrix rejected',chol(eqR(3,-.6))===null&&ae(rhoMin(3),-.5,1e-12));t('ρ=-0.5 for 3 picks accepted (PSD boundary)',chol(eqR(3,-.5))!==null);
 t('4 picks: valid minimum -1/3',ae(rhoMin(4),-1/3,1e-12)&&chol(eqR(4,-.34))===null&&chol(eqR(4,-1/3))!==null);
 r=eqJ([1e-6,1-1e-6],.7);t('p=1e-6 and 1-1e-6, ρ=0.7: finite, within Fréchet',isFinite(r.p)&&fr([1e-6,1-1e-6],r.p),r.p.toExponential(3));
 r=eqJ([1,.4],.7);t('an event with p=1 does not change the joint (0.4)',ae(r.p,.4,1e-12));
 r=jointR([.2,.5,.9],[[1,.6,-.2],[.6,1,.1],[-.2,.1,1]]);t('3 picks, mixed pairwise matrix: valid, within bounds',isFinite(r.p)&&fr([.2,.5,.9],r.p),`${f2(r.p,5)} ± ${f2(r.se,5)}`);
 t('invalid pairwise matrix (ρ12=ρ23=0.9, ρ13=-0.9) rejected',chol([[1,.9,-.9],[.9,1,.9],[-.9,.9,1]])===null);
 let bad=0,cnt=0;for(const p of[.01,.3,.5,.9,.99])for(const k of[2,3])for(const rho of[rhoMin(k),-.3,0,.3,.9,1]){if(rho<rhoMin(k))continue;const ps=Array(k).fill(p),j=eqJ(ps,rho).p;cnt++;if(!fr(ps,j))bad++}t(`Fréchet bounds and [0,1] hold in ${cnt} grid cases`,bad===0,bad+' violations');
 const a=genz(chol(eqR(3,-.4)),Array(3).fill(0),20000,7),b=genz(chol(eqR(3,-.4)),Array(3).fill(0),80000,7);t('Monte Carlo standard error shrinks ≈½ when draws ×4',b.se<a.se*.7,`${f2(a.se,6)} → ${f2(b.se,6)}`);
 let mx=0;for(const rho of[.1,.5,.9,.99])mx=Math.max(mx,Math.abs(eqJ([.5,.5,.5],rho).p-tri(rho)));t('one-factor integral, ρ up to 0.99, 3 picks: max error vs analytic',mx<1e-8,mx.toExponential(2));
 const gram=v=>v.map(a=>v.map(b=>sum(a.map((x,i)=>x*b[i])))),rec=R=>{const L=chol(R);if(!L)return NaN;let m=0;R.forEach((r,i)=>r.forEach((x,j)=>{m=Math.max(m,Math.abs(sum(L[i].map((l,q)=>l*L[j][q]))-x))}));return m};
 [['[[1,1],[1,1]] (ρ=1)',[[1,1],[1,1]]],['3×3 all ones (rank 1)',eqR(3,1)],['block [[1,1,0],[1,1,0],[0,0,1]]',[[1,1,0],[1,1,0],[0,0,1]]],['zero pivot, zero residual [[1,1,.5],[1,1,.5],[.5,.5,1]]',[[1,1,.5],[1,1,.5],[.5,.5,1]]],['equicorrelation ρ=-1/(k-1), k=3',eqR(3,-.5)],['equicorrelation ρ=-1/(k-1), k=6',eqR(6,-.2)],['2×2 ρ=-1',[[1,-1],[-1,1]]]].forEach(([n,R])=>{const e=rec(R);t('singular PSD accepted, L·Lᵀ reproduces R: '+n,e<1e-8,e.toExponential(1))});
 [['zero pivot + nonzero residual [[1,1,.5],[1,1,.4],[.5,.4,1]] (old code accepted it)',[[1,1,.5],[1,1,.4],[.5,.4,1]]],['zero pivot, residual -0.6',[[1,1,.3],[1,1,-.3],[.3,-.3,1]]],['entry above 1',[[1,1.2],[1.2,1]]],['NaN entry',[[1,NaN],[NaN,1]]],['equicorrelation ρ=-0.5-1e-6, k=3',eqR(3,-.5-1e-6)],['ρ12=ρ23=.9, ρ13=-.9',[[1,.9,-.9],[.9,1,.9],[-.9,.9,1]]]].forEach(([n,R])=>t('invalid matrix rejected, not repaired: '+n,chol(R)===null));
 const e7=1e-7,gm=gram([[1,0,0],[Math.cos(e7),Math.sin(e7),0],[.6,.5,Math.sqrt(.39)]]);t('near-singular PSD (pivot 1e-14, consistent residual 5e-8) accepted',rec(gm)<1e-6,rec(gm).toExponential(1));
 const bd=gm.map(r=>[...r]);bd[2][1]=bd[1][2]=bd[2][1]+1e-6;t('same matrix with residual 1e-6 (beyond the PSD bound) rejected',chol(bd)===null);
 t('near-singular ρ=-0.5+1e-9, k=3, accepted',rec(eqR(3,-.5+1e-9))<1e-8);t('near-singular ρ=1-1e-9, k=2, accepted',rec(eqR(2,1-1e-9))<1e-8);
 r=jointR([.3,.6,.5],[[1,1,0],[1,1,0],[0,0,1]]);t('singular PSD joint, X1=X2, X3 independent: 0.3×0.5=0.15',ae(r.p,.15,Math.max(4*r.se,1e-9)),`${f2(r.p,6)} ± ${f2(r.se,6)}`);
 r=jointR([.7,.6,.5],[[1,-1,0],[-1,1,0],[0,0,1]]);t('singular PSD joint, X1=-X2, X3 independent: (0.7+0.6-1)×0.5=0.15',ae(r.p,.15,Math.max(4*r.se,2e-3)),`${f2(r.p,5)} ± ${f2(r.se,5)}`);
 r=jointR([.5,.5,.5],[[1,1,.5],[1,1,.5],[.5,.5,1]]);t('zero pivot in the middle: ¼+asin(.5)/2π = ⅓',ae(r.p,1/3,Math.max(4*r.se,1e-3)),`${f2(r.p,5)} ± ${f2(r.se,5)}`);
 r=jointR([.5,.5,.5],[[1,.9,-.9],[.9,1,.9],[-.9,.9,1]]);t('jointR returns NaN for an invalid matrix (not a repaired number)',Number.isNaN(r.p));r=jointR([.5,.5],[[1,1.5],[1.5,1]]);t('jointR rejects off-diagonal 1.5',Number.isNaN(r.p));
 let g=groupR(3,-.6,{});t('groupR: latent -0.6 for 3 picks rejected, message shows valid range -0.500',!!g.err&&g.err.includes('-0.500'));g=groupR(3,-.5,{});t('groupR: latent -0.5 for 3 picks accepted and unchanged',!g.err&&g.R[0][1]===-.5);
 g=groupR(3,null,{'0,1':'.9','1,2':'.9','0,2':'-.9'});t('groupR: invalid pairwise matrix rejected and left unrepaired',g.err.includes('positive semidefinite')&&g.R[0][2]===-.9);g=groupR(2,null,{'0,1':'1.5'});t('groupR: pair value 1.5 rejected',g.err.includes('between -1 and 1'));g=groupR(3,null,{});t('groupR: no setting means no dependency model used',g.used===false&&!g.err);
 t('shifted matrix check: ρ=-0.45 shifted by -0.2 (k=3) is invalid, +0.2 on ρ=0.3 valid',chol(shiftR(eqR(3,-.45),-.2))===null&&chol(shiftR(eqR(3,.3),.2))!==null);
 t('outcome correlation φ for p=q=½, latent 0.7 equals (2/π)·asin(0.7)',ae(phi(.5,.5,.25+Math.asin(.7)/(2*Math.PI)),2/Math.PI*Math.asin(.7),1e-12));t('φ is 0 for independent outcomes',ae(phi(.3,.6,.18),0,1e-12));
 const w=wil(.5,100);t('Wilson interval p=.5, n=100 vs reference 0.4038 to 0.5962',ae(w[0],.40382,2e-5)&&ae(w[1],.59618,2e-5));t('Fréchet bounds [0.3, 0.6] for p=0.7, 0.6',JSON.stringify(frechet([.7,.6]).map(x=>+x.toFixed(10)))==='[0.3,0.6]');
 return T}
const RO=[['','I do not know'],['-0.7','Strongly work against each other'],['-0.35','Somewhat work against each other'],['0','No link (independent)'],['0.35','Somewhat go together'],['0.7','Strongly go together']];
function relHint(rs){const o=[];for(let i=0;i<rs.length;i++)for(let j=i+1;j<rs.length;j++){const a=rs[i].s.t,b=rs[j].s.t;if(!a||!b)continue;if(a===b)o.push(`two ${a} picks`);else if(REL.some(x=>(x[0]===a&&x[1]===b)||(x[0]===b&&x[1]===a)))o.push(`${a} and ${b}`)}return o.length?'Likely related: '+[...new Set(o)].join('; ')+'.':''}
function renderCombo(){$('crows').innerHTML=CS.map((s,i)=>{const I=(f,l,x='')=>`<label>${l}<input data-ci="${i}" data-f="${f}" ${x}></label>`;
 return `<div class="sel"><b>#${i+1}</b>`+I('m','Match name',`value="${esc(s.m)}" placeholder="Team A vs Team B"`)+`<label>Market type<select data-ci="${i}" data-f="t"><option value="">Choose...</option>${MK.map(m=>`<option${m===s.t?' selected':''}>${m}</option>`).join('')}</select></label>`+I('d','Selection description',`value="${esc(s.d)}" placeholder="Over 3.5 yellow cards"`)+I('p','Probability %',`type="number" step="any" min="0" max="100" value="${esc(s.p)}"`)+I('o','Decimal odds',`type="number" step="any" min="1" value="${esc(s.o)}"`)+I('n','Sample size n (optional)',`type="number" step="1" min="1" value="${esc(s.n)}"`)+`<button data-crm="${i}">Remove</button></div>`}).join('');calcCombo()}
let PW={};
/* latent correlation matrix for one match: group value first, then optional pair overrides. Never altered silently: invalid input returns an error. */
function groupR(n,rho,ov){const R=eqR(n,rho==null?0:rho);let used=rho!=null,err='',pairs=false;
 for(const key in ov){const[i,j]=key.split(',').map(Number),v=ov[key];if(v===''||v==null||i>=n||j>=n)continue;const x=+v;if(!(x>=-1&&x<=1)){err=`Pair ${i+1} and ${j+1}: latent correlation must be between -1 and 1.`;continue}R[i][j]=R[j][i]=x;used=pairs=true}
 if(!err&&used&&!chol(R))err=`This correlation matrix is not positive semidefinite, so it cannot exist for ${n} picks.${pairs?'':` With one shared value the valid range is ${f2(rhoMin(n),3)} to 1.`} Nothing was adjusted: the picks are shown with their Fréchet range instead.`;
 return{R,used,err}}
const shiftR=(R,d)=>R.map((r,i)=>r.map((v,j)=>i===j?1:Math.max(-1,Math.min(1,v+d))));
function calcCombo(){
 const out=$('cres'),dep=$('cdep');
 if(!CS.length){out.innerHTML='<p class="hint">No selections yet. Press “+ Add selection”.</p>';dep.innerHTML='';SIG='';return}
 const R=CS.map(s=>({s,p:+s.p/100,o:+s.o,n:s.n===''?null:+s.n,k:s.m.trim().toLowerCase()}));
 const G={};R.filter(r=>r.k).forEach(r=>(G[r.k]=G[r.k]||[]).push(r));
 const multi=Object.keys(G).filter(k=>G[k].length>1),sig=multi.map(k=>k+':'+G[k].map(r=>r.s.t+'/'+r.s.d).join(',')).join('|');
 if(sig!==SIG){SIG=sig;dep.innerHTML=multi.length?'<h3>Dependency settings (same-match picks)</h3><p class="hint">The setting below is a <b>latent Gaussian correlation</b> (a parameter of the copula). It is NOT the correlation between the yes/no outcomes: the outcome correlation is smaller in size and depends on the probabilities of the picks (it is shown in the results). Your choice is an ASSUMPTION, not a measured fact. “I do not know” gives a warning, plain multiplication, and the widest range that is mathematically possible (Fréchet bounds). Invalid values are rejected, never adjusted: for n equally linked picks the latent value must be between -1/(n-1) and 1.</p>'+multi.map(k=>{const h=relHint(G[k]),n=G[k].length,pw=[];for(let i=0;i<n;i++)for(let j=i+1;j<n;j++)pw.push(`<label>Pick ${i+1} and ${j+1}<input type="number" min="-1" max="1" step="any" data-pwg="${esc(k)}" data-pwk="${i},${j}" value="${esc(PW[k]?.[i+','+j]??'')}" placeholder="group value"></label>`);
  return `<div class="sel"><div><b>${esc(G[k][0].s.m)}</b><br><span class="hint">${G[k].map((r,i)=>`${i+1}: ${esc(r.s.d||r.s.t||'?')}`).join('<br>')}</span>${h?`<br><span class="warn">${h}</span>`:''}</div><label>Latent correlation for all pairs<select data-rho="${esc(k)}">${RO.map(o=>`<option value="${o[0]}"${String(RHO[k]??'')===o[0]?' selected':''}>${o[1]}</option>`).join('')}</select></label><details style="grid-column:1/-1"><summary>Set pairs separately (optional, -1 to 1, empty = group value)</summary><div class="sel">${pw.join('')}</div><p class="hint">The full matrix must be positive semidefinite. If it is not, it is rejected and the Fréchet range is used. Different markets are rarely equally dependent, so separate values are more realistic, but they are still guesses unless you estimated them from data.</p></details></div>`}).join(''):''}
 if(R.some(r=>!r.k||!r.s.t||!r.s.d.trim()||!(r.p>0&&r.p<=1)||!(r.o>1)||(r.n!==null&&!(r.n>=1)))){out.innerHTML='<p class="warn">Fill every selection: match name, market type, description, probability above 0 up to 100, and decimal odds above 1. Sample size is optional but must be 1 or more.</p>';return}
 const keys=Object.keys(G);
 const grp=keys.map(k=>{const ps=G[k].map(r=>r.p),n=ps.length;if(n<2)return{k,est:ps[0],lo:ps[0],hi:ps[0],single:true,has:true,se:0,n};
  const ind=ps.reduce((a,p)=>a*p,1),[fl,fh]=frechet(ps),gm=groupR(n,RHO[k]??null,PW[k]||{});
  if(!gm.used||gm.err)return{k,ind,fl,fh,has:false,err:gm.err,est:ind,lo:fl,hi:fh,se:0,n};
  const e=jointR(ps,gm.R),side=d=>{const S=shiftR(gm.R,d);return chol(S)?jointR(ps,S).p:(d<0?fl:fh)},a=side(-.2),b=side(.2);
  return{k,ind,fl,fh,has:true,est:e.p,lo:Math.min(e.p,a,b),hi:Math.max(e.p,a,b),se:e.se,m:e.m,R:gm.R,ps,n}});
 const P=grp.reduce((a,g)=>a*g.est,1),Dlo=grp.reduce((a,g)=>a*g.lo,1),Dhi=grp.reduce((a,g)=>a*g.hi,1),ind=R.reduce((a,r)=>a*r.p,1);
 const mcse=P*Math.sqrt(sum(grp.map(g=>g.se&&g.est>0?(g.se/g.est)**2:0)));
 const unk=grp.filter(g=>!g.single&&!g.has),O=R.reduce((a,r)=>a*r.o,1),ev=P*O-1,evl=Dlo*O-1,evh=Dhi*O-1,sv=$('cstake').value.trim(),st=sv===''?null:+sv;
 const nk=R.every(r=>r.n!==null),sg=nk?R.map(r=>Math.sqrt((1-r.p)/(r.n*r.p))):null,si=nk?Math.sqrt(sum(sg.map(x=>x*x))):0,sc=nk?sum(sg):0;
 const rows=R.map(r=>{const w=r.n?wil(r.p,r.n):null,e1=r.p*r.o-1;return `<tr><td>${esc(r.s.m)}</td><td>${esc(r.s.t)}</td><td>${esc(r.s.d)}</td><td><b>${pc(r.p)}</b>${w?`<br><span class="hint">${pc(w[0])} to ${pc(w[1])} (Wilson, only valid if p is an observed rate from n matches)</span>`:''}</td><td>${f2(r.o)}</td><td>${pc(1/r.o)}</td><td class="${e1>=0?'pos':'neg'}">${f2(e1*100,1)}%</td></tr>`}).join('');
 const gl=grp.filter(g=>!g.single).map(g=>{let s=`<li>${esc(G[g.k][0].s.m)}: independence ${pc(g.ind)}; Fréchet range (any dependence) ${pc(g.fl)} to ${pc(g.fh)}`;
  if(g.err)s+=`<br><span class="bad">REJECTED: ${g.err}</span>`;else if(g.has){s+=`<br>with your latent correlation: <b>${pc(g.est)}</b> (${g.m}${g.se?`; Monte Carlo standard error ±${pc(g.se)}`:''}); sensitivity to latent correlation ±0.2: ${pc(g.lo)} to ${pc(g.hi)}`;
   const o=[];for(let i=0;i<g.n&&o.length<12;i++)for(let j=i+1;j<g.n&&o.length<12;j++){const r=g.R[i][j],j2=jointR([g.ps[i],g.ps[j]],[[1,r],[r,1]]).p;o.push(`picks ${i+1} and ${j+1}: latent ρ=${f2(r)} gives outcome correlation φ=${f2(phi(g.ps[i],g.ps[j],j2),3)}`)}s+=`<br><span class="hint">Latent ρ is not outcome correlation: ${o.join('; ')}.</span>`}return s+'</li>'}).join('');
 const cut=(x)=>Math.min(1,x);
 out.innerHTML=`<div class="tw"><table><tr><th>Match</th><th>Market</th><th>Selection</th><th>Probability <span class="t a">YOURS</span></th><th>Odds</th><th>Implied P (1/odds)</th><th>EV of this pick</th></tr>${rows}</table></div>
 <h3>Combined form <span class="t m">MODEL</span></h3>
 ${unk.length?`<p class="bad">WARNING, INDEPENDENCE APPROXIMATION: no valid dependency was set for ${unk.map(g=>esc(G[g.k][0].s.m)).join(', ')}. Those same-match picks were multiplied as if unrelated. The Fréchet range below covers every possible dependence.</p>`:''}
 ${grp.some(g=>g.has&&!g.single)?'<p class="warn">JOINT MODEL: Gaussian copula with the latent correlation YOU entered (an ASSUMPTION, not estimated from data). Marginal probabilities are your inputs.</p>':''}
 ${keys.length>1?'<p class="hint">Picks from different matches are multiplied, which ASSUMES they are independent. A shared referee, league, weather or situation can still link them. No correlation is modelled between matches.</p>':''}
 ${gl?`<ul class="hint">${gl}</ul>`:''}
 <p>Combined probability (all selections win): <b>${pc(P)}</b><br>Range from the dependency assumption only: <b>${pc(Dlo)} to ${pc(Dhi)}</b> (a sensitivity range, NOT a confidence interval)<br>Plain multiplication of every probability: ${pc(ind)}${Math.abs(ind-P)>.0005?' (different, because of the dependency model)':''}<br>Combined decimal odds: <b>${f2(O)}</b> (the odds imply ${pc(1/O)})</p>
 <p>${st!=null&&st>=0?`Stake ${f2(st)}: total payout if all win <b>${f2(st*O)}</b>, profit if all win <b>${f2(st*(O-1))}</b>, expected return ${f2(st*P*O)}, expected profit ${f2(st*ev)}`:'Enter a valid stake to see payout and profit.'}</p>
 <p>Expected value per 1 unit: <b class="${ev>=0?'pos':'neg'}">${f2(ev,3)}</b><br>Expected return: <b>${f2(P*O*100,1)}%</b> of stake (ROI ${f2(ev*100,1)}%)<br>EV across the dependency range: ${f2(evl*100,1)}% to ${f2(evh*100,1)}% (${evl>0?'positive across the whole range':evh<0?'negative across the whole range':'the sign depends on the dependency assumption'})</p>
 <h3>Uncertainty, shown separately</h3><ul class="hint">
 <li><b>Dependency uncertainty:</b> ${unk.length?'unbounded within the Fréchet range for matches without a valid setting. ':''}${grp.some(g=>g.has&&!g.single)?'For matches with a setting, only a ±0.2 shift of the latent correlation was tested; the true dependence can lie outside it. ':''}${!grp.some(g=>!g.single)?'No same-match picks, so none was needed. ':''}</li>
 <li><b>Parameter (estimation) uncertainty:</b> ${nk?`approximate only. If each probability is an observed frequency from n independent matches, the log of the combined probability has standard error ≈${f2(si,3)} when errors are independent, giving ${pc(P*Math.exp(-1.96*si))} to ${pc(cut(P*Math.exp(1.96*si)))}. Errors of picks from the same match are probably positively correlated, and their covariance cannot be computed from n alone; if they were fully correlated the standard error would be ≤${f2(sc,3)} (${pc(P*Math.exp(-1.96*sc))} to ${pc(cut(P*Math.exp(1.96*sc)))}). These are NOT rigorous 95% confidence intervals: they use a normal approximation on the log scale and assume your probabilities are plain observed rates.`:'not quantified, because sample sizes were not entered for every pick. Do not read the numbers above as precise.'}${nk&&R.some(r=>r.n<30)?' Some samples are small (n below 30), so the normal approximation is poor.':''}</li>
 <li><b>Monte Carlo error:</b> ${mcse>0?`≈±${pc(mcse)} (one standard error, from the simulated groups; fixed seed 12345, adaptive draws up to 640,000)`:'none: every group was computed exactly or by deterministic integration.'}</li></ul>
 <p class="hint">${R.length>4?'With many selections small errors multiply. ':''}EV is a theoretical average over many repeats, not guaranteed profit, and it is only as good as the probabilities and dependency you entered. Never raise stakes to win back losses.</p>`}
['input','change'].forEach(ev=>$('crows').addEventListener(ev,e=>{const t=e.target;if(t.dataset.ci!==undefined){CS[+t.dataset.ci][t.dataset.f]=t.value;calcCombo()}}));
$('crows').addEventListener('click',e=>{if(e.target.dataset.crm!==undefined){CS.splice(+e.target.dataset.crm,1);renderCombo()}});
$('cdep').addEventListener('input',e=>{const t=e.target,k=t.dataset.rho;if(k!==undefined){RHO[k]=t.value===''?null:+t.value;calcCombo();return}const g=t.dataset.pwg;if(g!==undefined){(PW[g]=PW[g]||{})[t.dataset.pwk]=t.value;calcCombo()}});
$('cadd').onclick=()=>{CS.push({m:'',t:'',d:'',p:'',o:'',n:''});renderCombo()};
$('cclr').onclick=()=>{CS=[];renderCombo()};
$('cex').onclick=()=>{CS=[{m:'Example match',t:'Yellow cards',d:'Over 3.5 Yellow Cards',p:'72',o:'1.80',n:''},{m:'Example match',t:'Corners',d:'Over 8.5 Corners',p:'65',o:'1.70',n:''}];renderCombo()};
$('ctest').onclick=()=>{const T=selfTests(),f=T.filter(x=>!x[1]).length;$('ctres').innerHTML=`<p class="${f?'bad':'pos'}">${T.length-f} of ${T.length} tests passed.</p><div class="tw"><table><tr><th>Test</th><th>Result</th><th>Value</th></tr>${T.map(t=>`<tr><td>${esc(t[0])}</td><td class="${t[1]?'pos':'bad'}">${t[1]?'PASS':'FAIL'}</td><td>${esc(t[2])}</td></tr>`).join('')}</table></div>`};
/* ---------- tabs and rain ---------- */
function tab(){const h=(location.hash||'#analyzer').slice(1);['analyzer','bets','data','combo'].forEach(t=>{$('p_'+t).hidden=t!==h;$('n_'+t).classList.toggle('on',t===h)})}
addEventListener('hashchange',tab);tab();renderData();renderBets();renderCombo();
(()=>{const c=$('rain'),x=c.getContext('2d'),fs=16;let w,h,d;const rs=()=>{w=c.width=innerWidth;h=c.height=innerHeight;d=Array(Math.ceil(w/fs)).fill(1)};rs();addEventListener('resize',rs);
 if(matchMedia('(prefers-reduced-motion: reduce)').matches)return;
 setInterval(()=>{x.fillStyle='rgba(0,0,0,.08)';x.fillRect(0,0,w,h);x.fillStyle='#00ff41';x.font=fs+'px monospace';d.forEach((y,i)=>{x.fillText(String.fromCharCode(0x30A0+Math.random()*96),i*fs,y*fs);d[i]=y*fs>h&&Math.random()>.975?0:y+1})},70)})();
</script></body></html>