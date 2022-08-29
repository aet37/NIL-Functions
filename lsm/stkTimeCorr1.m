function [y,imtime]=stkTimeCorr1(stk,t1,t2,parms,itype)
% Usage ... y=stkTimeCorr1(stk,t1,t2,parms,itype)

stk=squeeze(stk);
sdim=size(stk);

nlines=sdim(1);
npixperline=sdim(2);
nframes=sdim(3);

if ~exist('itype','var'), itype=[]; end;
if isempty(itype), itype=[2 1 2.5]; end;
if ~exist('parms','var'), parms=[]; end;
if isempty(parms), parms(1)=(t1(2)-t1(1))/nlines; end;
if isempty(t2), t2=t1; end;     %correct to entry [1,1]

linetime=parms(1);
frametime=mean(diff(t1));
linetime1=linetime;
if (linetime*nlines+100*eps)<frametime,
  linetime1=linetime1+0.5*(frametime-linetime*nlines)/nlines;
end;

imtime=ones(nlines,1)*[0:npixperline-1]*(linetime/(npixperline-1));
imtime=imtime + ([0:nlines-1]'*linetime1)*ones(1,npixperline);

y=stk;
if isa(stk,'single'), do_single=1; else, do_single=0; end;
for mm=1:sdim(1), 
  disp(sprintf('  interpolating line #%d',mm));
  for nn=1:sdim(2),
    tmptc=double(squeeze(stk(mm,nn,:)));
    if itype(1)==1,
      tmptc=interp1(double(t1(:))+imtime(mm,nn),tmptc(:),t2(:));
    else,
      tmptc=myinterp1(double(t1(:))+imtime(mm,nn),tmptc(:),t2(:),itype(3),itype(1:2));
    end;
    if do_single, y(mm,nn,:)=single(tmptc); else, y(mm,nn,:)=tmptc; end;
  end; 
end;

do_struct=0;
if do_struct,
  ys.parms=parms;
  ys.itype=itype;
  ys.imtime=imtime;
  ys.y=y;
  clear y
  y=ys;
  clear ys
end;


