function averageOIS4(fname,varname,fps,ntr,noff,nper,nfa,zoomdn,basediff)
% Usage ... averageOIS4(fname,varname,fps,ntrials,offset,trialdur,desiredres,zoomdown,basediff)
%
% Implementation for data already in a mat-file (fname, data in varname)

if (nargin<9), basediff=[]; end;
if (nargin<8), zoomdn=[]; end;

if isempty(basediff),
  do_norm=0;
else,
  do_norm=1;
end;
if isempty(zoomdn),
  zoomdn=1;
  do_zoomdn=0;
else,
  do_zoomdn=abs(zoomdn)>0;
  if (do_zoomdn==0),
    zoomdn=1;
  else,
    zoomdn=2*abs(zoomdn);
  end;
end;


verbose_flag=1;
if (verbose_flag),
  disp(sprintf('  Filename= \t%s',fname));
  disp(sprintf('  Varname= \t%s',varname));
  disp(sprintf('  Fr/sec= \t%f',fps));
  disp(sprintf('  #Trials= \t%d',ntr));
  disp(sprintf('  #Off= \t%f (s)',noff));
  disp(sprintf('  Period= \t%f (s)',nper));
  disp(sprintf('  Des.Res.= \t%f',nfa));
  disp(sprintf('  ZmDn= \t%d x2 (%d)',do_zoomdn,zoomdn));
  disp(sprintf('  BaseDiff= \t%d (%d)',do_norm,basediff));
  disp('  ');
end;

tic,
disp(sprintf('Reading file...'));
eval(sprintf('load %s %s',fname,varname));
eval(sprintf('dcim=%s(:,:,1);',varname));
noff=round(noff*fps);
nper=round(nper*fps);
nfa=nfa*fps;

if (do_norm),
  if (length(basediff)<5),
    if (length(basediff)==1),
      basediff=[0 basediff];
      basediff=round(basediff*fps/nfa);
      basediff(1)=1;
    elseif (length(basediff)==2),
      basediff=basediff*fps/nfa;
      if (basediff(1)==0), basediff(1)=1; end;
    elseif (length(basediff)==4),
      basediff=basediff*fps/nfa;
      if (basediff(1)==0), basediff(1)=1; end;
      if (basediff(3)==0), basediff(3)=1; end;
    end;
  end;
end;

cnt=noff; cnt2=0;
avgim=zeros([size(dcim,1)/zoomdn size(dcim,2)/zoomdn round(nper/nfa)]);
avgim2=avgim;
for mm=1:ntr,
  tmpim=zeros([size(dcim,1)/zoomdn size(dcim,2)/zoomdn round(nper/nfa)]);
  tmpim2=zeros(size(dcim)/zoomdn);
  tmpim3=zeros(size(dcim)/zoomdn);
  for nn=1:round(nper/nfa),
    clear tmpstk
    eval(sprintf('tmpstk=%s(:,:,cnt+1:cnt+nfa);',varname));
    tmpim1=zeros(size(tmpstk(:,:,1)));
    for oo=1:size(tmpstk,3),
      cnt2=cnt2+1; avgimtc(cnt2)=mean(mean(double(tmpstk(:,:,oo))));
      %tmpim1=tmpim1+double(tmpstk(:,:,oo))/avgimtc(cnt2);
      tmpim1=tmpim1+double(tmpstk(:,:,oo));
    end;
    tmpim1=tmpim1/nfa;
    avgtc(nn,mm)=mean(mean(tmpim1));
    if (do_zoomdn), tmpim1=zoomdn2(tmpim1); end;
    cnt=cnt+nfa;
    if (do_norm),
      if ((nn>=basediff(1))&(nn<=basediff(2))),
        tmpim2=tmpim2+tmpim1/(basediff(2)-basediff(1)+1);
      end;
      if (length(basediff)==4),
      if ((nn>=basediff(3))&(nn<=basediff(4))),
        tmpim3=tmpim3+tmpim1/(basediff(4)-basediff(3)+1);
      end;
      end;
    end;
    tmpim(:,:,nn)=tmpim(:,:,nn)+tmpim1;
  end;
  if (do_norm),
    disp(' subtracting trial baseline contribution');
    tmpim2dc=mean(mean(tmpim2));
    for nn=1:nper/nfa,
      tmpim(:,:,nn)=tmpim(:,:,nn)-tmpim2+tmpim2dc;
      tmpimdiv(:,:,nn)=tmpim(:,:,nn)./tmpim2;
    end;
  end;
  baseim(:,:,mm)=tmpim2;
  baseim2(:,:,mm)=tmpim3;
  avgim=avgim+tmpim*(1/ntr);
  avgim2=avgim2+(tmpimdiv/ntr);
  clear tmpim tmpim1 tmpim2 tmpim3
end;

oname=sprintf('%s_qm',fname);
disp(sprintf('Saving data to %s',oname));
if (do_norm), 
  eval(sprintf('save %s avgim avgtc avgimtc baseim baseim2 noff ntr nper nfa do_norm do_zoomdn basediff dcim ',oname));
else,
  eval(sprintf('save %s avgim avgtc avgimtc noff ntr nper nfa do_norm do_zoomdn dcim stk',oname));
end;
toc,

clear

