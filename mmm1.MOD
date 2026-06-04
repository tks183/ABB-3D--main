module mmm1
var jointtarget home:=[[0,0,0,0,90,0],[0,0,0,0,0,0]];
var num gd;
var num py;
var num xh;
var num ys1;
var num huan;
var num gjzt;
var num len1;
var num fej2;
var num fej1;
var num len;
var num d;
var num pos1{12};
var num zhi{8};
pers num ys{3,4,8};
var pos k1;
var rawbytes r1;
var string str1;
var string st{14};
var string t1;
var byte a{199};
var byte c{4};
var byte f{199};
var byte b{199};
var intnum xx1;
var intnum xx2;
var intnum xx3;
var intnum xx4;
var socketdev s1;
var socketdev s2;
var bool ol;
var robtarget lpos;
var jointtarget jpos;
var robtarget dian1;
var robtarget dianz;
var robtarget diant;
var robtarget dian11;
pers num aa{8}:=[1,2,4,5,7,8,10,11];
pers num bb{5}:=[14,15,16,19,22];
pers num cc{8}:=[26,28,30,32,34,36,38,40];
pers num dd{8}:=[43,44,45,46,47,48,49,50];
pers num zd{4}:=[13,25,42,51];
pers num qd{4}:=[1,14,26,43];
pers num dx{3,3}:=[[1,2,3],[1,6,7],[3,4,5]];
pers num sx{6,3}:=[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]];
pers num mhs{4}:=[1,2,4,8];
var num kk{90};
pers speeddata sp1:=[100,500,5000,1000];


proc aaa()
zz1;
while a{99} = 0 do
ssj;
endwhile
cl;
movej dian11,v200,z20,tool0;
mho;
endproc



proc  cl()
dian11:=gd1;
for i from 0 to 2 do
if a{100+i*4}>5 then
if i=0 dian11.trans.x:=a{102+i*4}*256+a{103+i*4}-65536;
if i=1 dian11.trans.y:=a{102+i*4}*256+a{103+i*4}-65536;
if i=2 dian11.trans.z:=a{102+i*4}*256+a{103+i*4}-65536;
else
if i=0 dian11.trans.x:=a{102+i*4}*256+a{103+i*4};
if i=1 dian11.trans.y:=a{102+i*4}*256+a{103+i*4};
if i=2 dian11.trans.z:=a{102+i*4}*256+a{103+i*4};
endif
endfor
endproc


trap tz
isleep xx4;
stopmove;
waitdi a2,0;
startmove;
iwatch xx4;
endtrap
trap js
speedrefresh 10;
endtrap
trap qs
speedrefresh 100;
endtrap

proc zz1()
idelete xx1;
connect xx1 with js;
isignaldi a1,1,xx1;
idelete xx2;
connect xx2 with qs;
isignaldi a1,0,xx2;
idelete xx3;
connect xx3 with tz;
isignaldi a2,1,xx3;
idelete xx4;
connect xx4 with fwz;
itimer 0.1, xx4;
endproc

proc lp()
for i from 1 to 8 do
zhi{i}:=0;
endfor
for i from 1 to 4 do
for j from 1 to 4 do
if ys{1,i,j}=1 and i=1 zhi{1}:=zhi{1}+1;
if ys{1,i,j}=2 and i=1 zhi{2}:=zhi{2}+1;
if ys{1,i,j}=1 and i=2 zhi{3}:=zhi{3}+1;
if ys{1,i,j}=2 and i=2 zhi{4}:=zhi{4}+1;
if ys{1,i,j}=1 and i=3 zhi{5}:=zhi{5}+1;
if ys{1,i,j}=2 and i=3 zhi{6}:=zhi{6}+1;
if ys{1,i,j}=1 and i=4 zhi{8}:=zhi{8}+1;
if ys{1,i,j}=2 and i=4 zhi{7}:=zhi{7}+1;
b{149+4*(i-1)+j}:=ys{3,i,j};
endfor
endfor
for i from 1 to 8 do
b{179+i}:=zhi{i};
endfor
endproc

proc swz()
jpos:=cjointt();
lpos:=crobt();
pos1{1}:=jpos.robax.rax_1;
pos1{2}:=jpos.robax.rax_2;
pos1{3}:=jpos.robax.rax_3;
pos1{4}:=jpos.robax.rax_4;
pos1{5}:=jpos.robax.rax_5;
pos1{6}:=jpos.robax.rax_6;
pos1{7}:=lpos.trans.x;
pos1{8}:=lpos.trans.y;
pos1{9}:=lpos.trans.z;
d:=0;
for i from 1 to 9 do
packrawbytes pos1{i},r1,1\float4;
for j from 1 to 4 do
unpackrawbytes r1,j,c{j}\hex1;
endfor
for k from 4 to 1 do
b{100+d}:=c{k};
d:=d+1;
endfor
endfor
endproc


proc dd91()
zz1;wt 1;
while a{91}=0 do
ssj;
endwhile
a{91}:=0;b{90}:=0;
endproc
proc dd90()
zz1;
while a{90}=0 do
ssj;
endwhile
a{90}:=0;
endproc

trap fwz
swz;
lp;
if socketgetstatus(s1)<>socket_connected then
socketcreate s1;
socketconnect s1,"192.168.0.1",1400;
endif
socketsend s1\data:=b;
endtrap

proc fsj(num x,num y)
zz1;
isleep xx4;
socketclose s1;
wt 0.1;
socketcreate s1;
socketconnect s1,"192.168.0.1",1400;
b{x}:=y;
socketsend s1\data:=b;
iwatch xx4;
endproc


proc ssj()
isleep xx4;
socketclose s1;
wt 0.1;
socketcreate s1;
socketconnect s1,"192.168.0.1",1400;
socketreceive s1\data:=a;
iwatch xx4;
endproc

proc js1()
for i from 1 to 2 do
for j from 1 to 2 do
k1:=(xp{i,j,4}.trans-xp{i,j,1}.trans)*0.3333;
for o from 2 to 3 do
xp{i,j,o}:=xp{i,j,1};
xp{i,j,o}.trans:=xp{i,j,1}.trans+k1*(o-1);
endfor
endfor
endfor
for j from 1 to 2 do
k1:=(xie{j,6}.trans-xie{j,1}.trans)*0.2;
for o from 2 to 5 do
xie{j,o}:=xie{j,1};
xie{j,o}.trans:=xie{j,1}.trans+k1*(o-1);
endfor
endfor
endproc

proc run(robtarget d,num x)
if x=1 huan:=0;
accset 100,40;
for i from 1 to 3 do
for j from 1 to 4 do
for o from 1 to 8 do
test d
case gj{j}:gd:=0;xh:=2;py:=200;if j=4 gd:=3;gjzt:=j;goto r1;
endtest
endfor
endfor
endfor
r1:
if gd=0 mho;
if gd=1 gd1;
if gd=2 gd2;
if gd=3 gd3;
if gd=3 or gd=2 then
movel offs(d,0,0,py),v2000,z10,tool0;
else
movej offs(d,0,0,py),v2000,z10,tool0;
endif
movel offs(d,0,0,0),v200,fine,tool0;
if x=1 then
test xh
case 1:set dls;
case 2:reset kh;
case 3:set vc1;
case 4:set vc2;
case 5:fsj 15,1;wt 1;fsj 15,2;
case 6:set do1;wt 2;reset do1;
case 7:set do1;wt 3;reset do1;
endtest
else
test xh
case 1:reset dls;
case 2:set kh;
case 3:reset vc1;
case 4:reset vc2;set bvac;
endtest
endif
wt 0.5;
movel offs(d,0,0,25),v100,z10,tool0;
if vs1=1 and d<>lsd reset vc1;
if vs2=1 reset vc2;
reset bvac;
movel offs(d,0,0,py),v2000,z10,tool0;
if gd=0 mho;
if gd=1 gd1;
if gd=2 gd2;
if gd=3 gd3;
endproc

proc gd2()
movel gdd2,v2000,z10,tool0;
endproc
proc gd4()
movej gdd4,v2000,z10,tool0;
endproc
proc gd3()
movel gdd3,v2000,z10,tool0;
endproc
proc gd1()
movej gdd1,v2000,z10,tool0;
endproc

proc mho()
moveabsj home,v2000,z10,tool0;
endproc

proc wt(num x)
waittime x;
endproc

endmodule