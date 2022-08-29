function plaque_scr1(dname,chno,thrf)
% Usage ... plaque_scr1(dname,chno,thrf)

if nargin<3, thrf='select'; end;
if nargin<2, chno=[]; end;

do_load=1;
do_reor=1;

close all

if strcmp(dname(end-2:end),'mat'),
  eval(sprintf('load %s',dname));
  do_load=0; do_reor=1;
else,
  sname=[dname(1:4),dname(end-4:end-1),'_res'];
  if exist([sname,'.mat'],'file'),
    tmpin=input(sprintf('  %s.mat file exists [1=load, 2=restart-default]: ',sname));
    if isempty(tmpin), tmpin==2; end;
    if tmpin==1, 
      disp(sprintf('load %s   [do_load=0, do_reorient=0]',sname));
      eval(sprintf('load %s',sname));
      do_load=0; do_reor=0;
      if ~exist('data','var'), do_load=1; end;
      if ~exist('data_c','var'), do_reor=1; end;
    end;
  else,  
    disp(sprintf('sname= %s',sname));
    %eval(sprintf('save %s %s',sname,sname));
  end;
end;

if do_load,
  data=readPrairie2(dname);
  info=parsePrairieXML(dname);
  showStack(data)
  if isempty(chno),
    chno=input('Enter channel number (eg. red=1, grn=2-default): ');
    if isempty(chno), chno=2; end;
  else,
    disp('  press enter to continue...'); pause;
  end;
  disp(sprintf('save %s sname info data chno thrf',sname));
  eval(sprintf('save %s sname info data chno thrf',sname));
end;

if do_reor,
  data_c=volzAdj1(squeeze(data(:,:,chno,:)),'avg',0.5);
  data_c=twop_filt(squeeze(data(:,:,chno,:)),5);
  [data_c,xx_ro]=reorientVolume1(data_c);
  disp(sprintf('save %s -append data_c chno thrf xx_ro do_*',sname));
  eval(sprintf('save %s -append data_c chno thrf xx_ro do_*',sname));
end;

do_thr=1;
if do_thr,
  % pick first and last
  showStack(data_c)
  tmpin1=input(sprintf('Enter first slice# for measurement (1-%d): ',size(data_c,3))); 
  if isempty(tmpin1), tmpin1=1; end; 
  tmpin2=input(sprintf('Enter last slice# for measurement (%d-%d): ',tmpin1,size(data_c,3)));  
  if isempty(tmpin2), tmpin2=size(data_c,3); end; 
  i1=tmpin1(1); if i1<1, i1=1; end;
  i2=tmpin2(1); if i2>size(data_c,3), i2=size(data_c,3); end;
  if i1>i2, i3=i2; i2=i1; i1=i3; clear i3 ; end;
  % do thresholding and measurements
  pixdim=[info.PV_shared.micronsPerPixel{1} info.PV_shared.micronsPerPixel{2}];
  pixdim=pixdim/info.PV_shared.opticalZoom;
  if length(info.PV_shared.micronsPerPixel)==3,
    pixdim(3)=info.PV_shared.micronsPerPixel{3};
  else,
    pixdim(3)=abs(info.Frame(2).ZAxis-info.Frame(1).ZAxis);
  end;
  if ischar(thrf),
    [tmpdataP,dataP_n,thr,cthr]=volthr2(data_c(:,:,i1:i2),thrf);
    dataP=zeros(size(data_c));
    dataP(:,:,i1:i2)=single(tmpdataP);
    clear tmpdataP
  else,
    thr=mean(data_c(:))+thrf(1)*std(data_c(:));
    if length(thrf)>1, cthr=thrf(2); else, cthr=round(size(data_c,1)*size(data_c,2)*size(data_c,3)*.1*.1*.2); end;
    [tmpdataP,dataP_n]=volthr2(data_c(:,:,i1:i2),thr,cthr);
    dataP=zeros(size(data_c));
    dataP(:,:,i1:i2)=single(tmpdataP);
    clear tmpdataP
  end;
  tmpin1=input('  edit the volume? [0/enter=no, 1=yes]: ');
  if isempty(tmpin1), tmpin1=0; end;
  if tmpin1, dataP=editVolMask1(dataP,data_c); end;
  dataP_vol=dataP_n*prod(pixdim)*prod([1e-4 1e-4 1e-4]);
  dataP_vf=dataP_n/prod(size(data_c));
  dataP_vf2=dataP_vol/(prod(pixdim)*prod([1e-4 1e-4 1e-4])*prod(size(data_c)));
  dataP_cm=volCenterMass(data_c,dataP);
  disp('volume-fraction');
  [dataP_vf2(:)],
  disp('volume(nl)');
  [dataP_vol(:)*1e6],
  
  disp(sprintf('save %s -append data_c chno thrf xx_ro i1 i2 thr cthr dataP dataP_n dataP_cm dataP_vf do_*',sname));
  eval(sprintf('save %s -append data_c chno thrf xx_ro i1 i2 thr cthr dataP dataP_n dataP_cm dataP_vf do_*',sname));
end;

