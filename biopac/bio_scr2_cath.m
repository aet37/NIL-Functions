
clear all
close all

do_save=1;
bioroot='20210317_MOUSE_G43L_WH';

bparms1=[-2000 18000];
bparms2=[-5000 32000];
bparms4=[-5000 62000];

sparms1=[200 20];	% 5Hz 4s
sparms12=[200 40];	% 5Hz 8s
sparms2=[100 40];	% 10Hz 4s
sparms22=[100 80];	% 10Hz 8s
sparms4=[50 80];	% 20Hz 4s
sparms42=[50 160];	% 20Hz 8s

skpi=[4:62];
skp1=skpi-bparms1(1);  for mm=2:sparms1(2),  skp1=[skp1 skpi+(mm-1)*sparms1(1)-bparms1(1)]; end;
skp12=skpi-bparms1(1); for mm=2:sparms12(2), skp12=[skp12 skpi+(mm-1)*sparms12(1)-bparms1(1)]; end;
skp2=skpi-bparms2(1);  for mm=2:sparms2(2),  skp2=[skp2 skpi+(mm-1)*sparms2(1)-bparms2(1)]; end;
skp22=skpi-bparms2(1); for mm=2:sparms22(2), skp22=[skp22 skpi+(mm-1)*sparms22(1)-bparms2(1)]; end;


biots=0.001;
imChName='FPS';
trigChName='StimON';

% bioid={{'','dyn1Wh1S1',[1 5],bparms2,'skp1'},
%        {'','dyn1l1p0aWh1S1d15',[6 10],bparms2,'skp1'},
%        {'','dyn1l1p0dc1',[11 15],bparms2,'skp1'},
%        {'','dyn2Wh1S1',[16 20],bparms2,'skp1'},
%        {'','dyn1l1p0aWh1S2d15',[21 25],bparms2,'skp1'},
%        {'','dyn2l1p0aWh1S1d15',[26 30],bparms2,'skp1'},
%        {'','dyn2l1p0aWh1S1d15',[31 35],bparms2,'skp1'},
%        {'','dyn2Wh1S2',[36 40],bparms2,'skp1'},
%        {'','dyn2l1p0aWh1S2d15',[41 45],bparms2,'skp1'},
%        {'','dyn1Wh1S2',[46 50],bparms2,'skp1'},
%        {'','dyn1l1p0aWh1S3d15',[51 55],bparms2,'skp1'},
%        {'','dyn1l1p0dc2',[56 60],bparms2,'skp1'},
%        {'','dyn2l1p0aWh1S3d15',[61 65],bparms2,'skp1'},
%        {'','dyn1l1p0cWh1S1d15',[66 70],bparms2,'skp1'},
%        {'','dyn2l1p0cWh1S1d15',[71 75],bparms2,'skp1'},
%        {'','dyn1l1p0cWh1S2d15',[76 80],bparms2,'skp1'},
%        {'','dyn1Wh1S3',[81 85],bparms2,'skp1'},
%        {'','dyn2l1p0cWh1S2d15',[86 90],bparms2,'skp1'},
%        {'','dyn1l1p0cWh1S3d15',[91 95],bparms2,'skp1'},
%        {'','dyn1l1p0dcWh1S2',[96 100],bparms2,'skp1'},
%        {'','dyn2Wh1S3',[101 105],bparms2,'skp1'},
%        {'','dyn1l1p0dcWh1S3',[106 110],bparms2,'skp1'},
%        {'','dyn2l1p0cWh1S3d15',[111 115],bparms2,'skp1'},
%        {'','dyn1l1p0dc3',[116 120],bparms2,'skp1'}};

bioid={{'','dyn1wh1S1',[1 5],bparms2,'skp1'},
       {'','dyn1l1p0aaS1whn50',[6 10],bparms2,'skp1'},
       {'','dyn1l1p0dcS1',[11 15],bparms2,'skp1'},
       {'','dyn1l1p0aaS1wh',[16 20],bparms2,'skp1'},
       {'','dyn1l1p0dcS1wh',[21 25],bparms2,'skp1'},
       {'','dyn1l1p0aaS1whp15',[26 30],bparms2,'skp1'},
       {'','dyn1l1p0aaS2whn50',[31 35],bparms2,'skp1'},
       {'','dyn1l1p0dcS2',[36 40],bparms2,'skp1'},
       {'','dyn1l1p0aaS1whn15',[41 45],bparms2,'skp1'},
       {'','dyn1l1p0aaS1whp50',[46 50],bparms2,'skp1'},
       {'','dyn1l1p0dcS2wh',[51 55],bparms2,'skp1'},
       {'','dyn1l1p0aaS3whn50',[56 60],bparms2,'skp1'},
       {'','dyn1l1p0aaS2wh',[61 65],bparms2,'skp1'},
       {'','dyn1wh1S2',[66 70],bparms2,'skp1'},
       {'','dyn1l1p0aaS2whn15',[71 75],bparms2,'skp1'},
       {'','dyn1l1p0aaS2whp15',[76 80],bparms2,'skp1'},
       {'','dyn1l1p0aaS3wh',[81 85],bparms2,'skp1'},
       {'','dyn1l1p0dcS3wh',[86 90],bparms2,'skp1'},
       {'','dyn1l1p0aaS3whp15',[91 95],bparms2,'skp1'},
       {'','dyn1l1p0aaS2whp50',[96 100],bparms2,'skp1'},
       {'','dyn1l1p0dcS3',[101 105],bparms2,'skp1'},
       {'','dyn1l1p0aaS3whn15',[106 110],bparms2,'skp1'},
       {'','dyn1wh1S3',[111 115],bparms2,'skp1'},
       {'','dyn1l1p0aaS3whp50',[116 120],bparms2,'skp1'}};

   
if do_save,
  save biopac_data bioroot bioid biots imChName bparms* sparms* skp*
end;

for mm=1:length(bioid),
  disp(sprintf('%s=parseBiopac(''%s%s'',''StimON'',[%d:%d],[%d %d]);',bioid{mm}{2},bioroot,bioid{mm}{1},bioid{mm}{3}(1),bioid{mm}{3}(2),bioid{mm}{4}(1),bioid{mm}{4}(2)));
  eval(sprintf('%s=parseBiopac(''%s%s'',''StimON'',[%d:%d],[%d %d]);',bioid{mm}{2},bioroot,bioid{mm}{1},bioid{mm}{3}(1),bioid{mm}{3}(2),bioid{mm}{4}(1),bioid{mm}{4}(2)));
  disp(sprintf('save biopac_data -append %s',bioid{mm}{2}));
  eval(sprintf('save biopac_data -append %s',bioid{mm}{2}));
  disp(sprintf('%s_new=processBiopacStruc2(%s,[1/biots 100 0.1],4,[-4 -1],[[-4 -1] [-6 -3]+%d*biots],[],[],[],%s);',bioid{mm}{2},bioid{mm}{2},bioid{mm}{4}(2),bioid{mm}{5}));
  eval(sprintf('%s_new=processBiopacStruc2(%s,[1/biots 100 0.1],4,[-4 -1],[[-4 -1] [-6 -3]+%d*biots],[],[],[],%s);',bioid{mm}{2},bioid{mm}{2},bioid{mm}{4}(2),bioid{mm}{5}));
  disp(sprintf('save biopac_data -append %s_new',bioid{mm}{2}));
  eval(sprintf('save biopac_data -append %s_new',bioid{mm}{2}));
end;


