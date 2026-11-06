const fs=require('fs'),p=require('path');const {Resvg}=require('/Users/ryandeniega/.agents/skills/app-icon-gen/scripts/node_modules/@resvg/resvg-js');
const d=__dirname;const gray='#70717b',violet='#aa80ef';
// Curves are an editable semantic redraw of the user's selected generated B2.
const shell='M 120 526 C 120 423 203 339 307 339 C 377 339 422 369 479 408 C 525 439 560 458 612 460 L 805 460 C 863 460 908 504 908 563 C 908 622 863 668 805 668 L 567 668 C 497 668 445 688 390 704 C 365 711 338 715 307 715 C 203 715 120 630 120 526 Z';
const moon='M 364 407 C 298 407 224 462 224 526 C 224 594 272 648 341 648 C 370 648 392 636 418 622 C 352 622 307 578 307 518 C 307 470 333 430 364 407 Z';
const purple='M 350 710 C 414 694 451 664 485 612 C 524 552 554 489 612 460 L 805 460 C 863 460 908 504 908 563 C 908 622 863 668 805 668 L 567 668 C 497 668 445 688 390 704 C 376 708 363 710 350 710 Z';
const hole='M 691 534 H 782 A 29 29 0 0 1 782 592 H 691 A 29 29 0 0 1 691 534 Z';
const svg=(body)=>`<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">${body}</svg>`;
const mark=(a,b)=>`<path fill="${a}" fill-rule="evenodd" d="${shell} ${moon} ${hole}"/><path fill="${b}" fill-rule="evenodd" d="${purple} ${hole}"/>`;
const output=(f,s)=>fs.writeFileSync(p.join(d,f),s);const png=(f,s,n)=>output(f,new Resvg(s,{fitTo:{mode:'width',value:n}}).render().asPng());
let master=svg(mark(gray,violet));output('lunotch-b2-master.svg',master);png('lunotch-b2-master-1024.png',master,1024);
let light=svg(mark('#575861','#8050cb'));output('lunotch-b2-light.svg',light);let dark=svg(mark('#c9c8d2','#bc9bff'));output('lunotch-b2-dark.svg',dark);
// Simplified symbol intentionally enlarges both cutouts for small-size reading.
const moonSmall='M 365 397 C 284 397 214 453 214 527 C 214 601 267 657 342 657 C 374 657 402 646 425 626 C 355 626 314 578 314 519 C 314 466 336 424 365 397 Z';
const holeSmall='M 680 522 H 785 A 41 41 0 0 1 785 604 H 680 A 41 41 0 0 1 680 522 Z';
const sym=(color)=>`<path fill="${color}" fill-rule="evenodd" d="${shell} ${moonSmall} ${holeSmall}"/>`;
for(const [mode,color] of [['dark','#171923'],['light','#ffffff']]){let s=svg(sym(color));output(`menu-${mode}.svg`,s);for(let n of [16,32,128])png(`menu-${mode}-${n}.png`,s,n)}
function tile(body,bg){return svg(`<rect x="12" y="12" width="1000" height="1000" rx="225" fill="${bg}"/>${body}`)}
let dockLight=tile(mark('#575861','#8050cb'),'#f4f4f6'),dockDark=tile(mark('#d5d4dd','#b494f3'),'#181c2c');for(const [id,s] of [['dock-light',dockLight],['dock-dark',dockDark]]){output(id+'.svg',s);png(id+'-1024.png',s,1024);png(id+'-128.png',s,128)}
const img=(file,x,y,w,h=w)=>`<image x="${x}" y="${y}" width="${w}" height="${h}" href="data:image/png;base64,${fs.readFileSync(file).toString('base64')}"/>`;
const source='/Users/ryandeniega/repos/Repo/alcove-personal/brand/lunotch-icon-1024.png';
let b=`<rect width="2200" height="1500" fill="#eff1f4"/><text x="90" y="100" font-family="Helvetica Neue,Arial" font-size="29" fill="#718095">LUNOTCH / B2 PRODUCTION REVIEW</text><text x="90" y="184" font-family="Helvetica Neue,Arial" font-size="68" font-weight="600" fill="#192236">Lunar Droplet, refined.</text>`;
for(const [i,title,file] of [[0,'Current icon',source],[1,'B2 / Light',p.join(d,'dock-light-1024.png')],[2,'B2 / Dark',p.join(d,'dock-dark-1024.png')]]){let x=90+i*680;b+=`<rect x="${x}" y="260" width="630" height="750" rx="28" fill="white"/>${img(file,x+60,320,510)}<text x="${x+55}" y="924" font-family="Helvetica Neue,Arial" font-size="32" font-weight="600" fill="#192236">${title}</text>`}
b+=`<text x="90" y="1110" font-family="Helvetica Neue,Arial" font-size="30" fill="#192236">Menu-bar symbol</text><rect x="90" y="1142" width="980" height="230" rx="20" fill="#ffffff"/><rect x="1120" y="1142" width="990" height="230" rx="20" fill="#171c2b"/>`;
for(const [x,f] of [[150,'menu-dark-128.png'],[435,'menu-dark-32.png'],[640,'menu-dark-16.png'],[1180,'menu-light-128.png'],[1465,'menu-light-32.png'],[1670,'menu-light-16.png']]){let n=f.includes('-128')?128:f.includes('-32')?32:16;b+=img(p.join(d,f),x,1190+(128-n)/2,n)+`<text x="${x}" y="1350" font-family="Helvetica Neue,Arial" font-size="20" fill="#8792a3">${n} px</text>`}
const board=`<svg xmlns="http://www.w3.org/2000/svg" width="2200" height="1500" viewBox="0 0 2200 1500">${b}</svg>`;png('review-board.png',board,2200);
