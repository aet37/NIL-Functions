function y=imAcqTimeCorr(stk,tparms,iparms,refpos)
% Usage ... newstk=imAcqTimeCorr(stk,tparms,iparms,refpos)
%
% tparms=[imTime dwTime]
% iparms=[int_type ilen wtype]
%   int_type=[1:sinc,2:lin,3:cubic], ilen=2:def, wtype=[1:hamm-def,2:hann]
% refpos=[x_ref_pos y_ref_pos] default is [1 1]

imTime=tparms(1);
dwTime=tparms(2);

int_type=iparms(1);
if int_type==1,
  if length(iparms)==1,
    ilen=3;
    wtype=2;
  else,
    ilen=iparms(2);
    wtype=iparms(3);
  end;
end;

sdim=size(stk);
tt=[1:sdim(3)]*imTime;
errt=(imTime-sdim(1)*sdim(2)*dwTime);

imtt=zeros(sdim(1),sdim(2));
for mm=1:sdim(1),
  imtt(mm,:)=(mm-1)*(sdim(2)*dwTime + errt/sdim(1)) + [0:sdim(2)-1]*dwTime;
end;

if ~exist('refpos','var'),
  reftt=imtt(1,1);
else,
  reftt=imtt(refpos(1),refpos(2));
end;
disp(sprintf('  refTime=%.6f  intType=%d iLen=%d wType=%d', ...
             reftt,int_type,ilen,wtype));

y=stk;
for mm=1:sdim(1), for nn=1:sdim(2),
  tmptc=squeeze(stk(mm,nn,:));
  if int_type==1,
    tmptci=sincinterp1(imtt(mm,nn)+tt,tmptc(:),reftt+tt,ilen,wtype);
  elseif int_type==3,
    tmptci=interp1(imtt(mm,nn)+tt,tmptc(:),reftt+tt,'cubic');
  else,
    tmptci=interp1(imtt(mm,nn)+tt,tmptc(:),reftt+tt);
  end;
  y(mm,nn,:)=tmptci;
end; end;


