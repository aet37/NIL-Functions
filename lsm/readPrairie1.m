function y=readStackP(fname,ch,parms,rang)
% Usage ... y=readStackP(fname,ch,parms,rang)
%
% ch=channelID
% parms=[medfiltn, smoothwid] or 'select' to enter interactive mode
% rang=rotation in x, y, z in degrees

if ~exist('parms','var'),
  parms=[0 0];
end;
if ~exist('rang','var'),
  rang=[0 0 0];
end;

do_select=0;
if strcmp(rang,'select'),
  do_select=1;
  rang=[0 0 0];
end;
if strcmp(parms,'select'),
  do_select=1;
  parms=[0 0];
end;

mfw=parms(1);
sfw=parms(2);

header=readPrairie(fname,0);
data=single(readPrairie2(fname,[],[],ch));
datap=data;

for mm=1:size(data,3),
  if mfw>0, datap(:,:,mm)=medfilt2(datap(:,:,mm),[mfw mfw]); end;
  if sfw>0, datap(:,:,mm)=im_smooth(datap(:,:,mm),sfw); end;
end;

if do_select,
  tmpdatap=datap;
  tmprang=rang;
  tmpfound=0;
  tmpupdate=1; tmpmfw=0; tmpsm=0;
  while(~tmpfound),
    if tmpupdate, figure(1), clf, showProj(tmpdatap), tmpupdate=0; end;
    disp(sprintf('   current angles= [%.3f, %.3f, %.3f]',tmprang(1),tmprang(2),tmprang(3)));
    tmpin=input('  [e=EnterAngles, f=FindAngle, s=smooth, m=medfilt, p=showProj, R=reset, x=Exit]: ','s');
    if strcmp(tmpin,'e')|strcmp(tmpin,'r'),
      tmprang=input('  enter angles [x,y,z]= ');
      tmpdatap=rot3d_nf(tmpdatap,tmprang);
      tmpupdate=1;
    elseif strcmp(tmpin,'f'),
      figure(1), myangle2;
    elseif strcmp(tmpin,'s'),
       tmpsm=input('  enter smoothing width: ');
       for mm=1:size(tmpdatap,3),
         if sfw>0, tmpdatap(:,:,mm)=im_smooth(tmpdatap(:,:,mm),sfw); end;
       end; disp('  smooth done');
       tmpupdate=1;
    elseif strcmp(tmpin,'m'),
       tmpmw=input('  enter median width: ');
       if length(tmpmw)==1, tmpmw=[tmpmw tmpmw]; end;
       for mm=1:size(tmpdatap,3),
         if mfw>0, datap(:,:,mm)=medfilt2(datap(:,:,mm),[mfw mfw]); end;
       end; disp('  median filt done');
       tmpupdate=1;
    elseif strcmp(tmpin,'R'),
      tmpdatap=datap;
      tmpupdate=1;
    elseif strcmp(tmpin,'p'),
      figure(2), showProj(data);
      tmpupdate=1;
    elseif strcmp(tmpin,'k'),
      showStack(tmpdatap);
    elseif strcmp(tmpin,'x')|strcmp(tmpin,'q'),
      tmpfound=1;
    end;
  end;
  parms=[tmpmfw tmpsm];
  rang=tmprang;
  datap=tmpdatap;
  clear tmpdatap tmp*
else,
  datap=rot3d_nf(datap,rang);
end;

y.header=header;
y.fname=fname;
y.ch=ch;
y.parms=parms;
y.rang=rang;
y.data=datap;



