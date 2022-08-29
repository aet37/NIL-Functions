function [f,fpenv2]=getFPenv(FP,FPt,stimint,nstims,toff,newFPt)
% Usage ... [f,f2]=getFPenv(FP,FPt,stimint,nstims,toffset,newFPt)

do_plot=0;

dt=FPt(2)-FPt(1);

tmpamp=0.2*max(abs(FP));

tmpt0i=find((FPt>=(0-dt/2))&(FPt<dt/2));
if isempty(tmpt0i), t0i=1; else, t0i=tmpt0i(1); end;
%disp(sprintf('  t=0 @ i= %d',t0i'));

toffi=round(toff/dt);
stimi=round(stimint/dt);

for mm=1:nstims,
  tmp=zeros(size(FP));
  tmpt0i=find((FPt>=((mm-1)*stimint-dt/2))&(FPt<(mm-1)*stimint+dt/2));
  if isempty(tmpt0i), toi=(mm-1)*stimi+t0i; else, toi=tmpt0i(1); end;
  tmpi1=toi;
  tmpi2=toi+stimi-1;
  tmp(tmpi1+toffi(1):tmpi1+toffi(2))=1;
  [tmpmax,tmpmaxi]=max(FP.*tmp);
  [tmpmin,tmpmini]=min(FP.*tmp);
  if tmpmax==0, [tmpmax,tmpmaxi]=max(FP(tmpi1+toffi(1)-1:tmpi1+toffi(2)-1)); tmpmaxi=tmpmaxi+tmpi1(1)+toffi(1)-1; end;
  if tmpmin==0, [tmpmin,tmpmini]=min(FP(tmpi1+toffi(1)-1:tmpi1+toffi(2)-1)); tmpmini=tmpmini+tmpi1(1)+toffi(1)-1; end;
  if tmpmaxi==1, tmpmaxi=tmpi1+toffi(1); end;
  if tmpmini==1, tmpmini=tmpi1+toffi(1); end;
  fpenv(mm,:)=[tmpmax-tmpmin min([tmpmaxi tmpmini])]; 
  fpenv2(mm,:)=[tmpmax-tmpmin tmpmax FPt(tmpmaxi) tmpmaxi tmpmin FPt(tmpmini) tmpmini];
  if do_plot,
    plot(FPt(tmpi1:tmpi2),FP(tmpi1:tmpi2),FPt(tmpi1:tmpi2),-tmpamp*tmp(tmpi1:tmpi2),'k',FPt([tmpmaxi tmpmini]),FP([tmpmaxi tmpmini]),'ro'),
    xlabel(num2str(mm)),
    pause,
  end;
end;
fpenv=[0 fpenv(1,2)-1;fpenv;0 fpenv(mm,2)+1];

f=interp1(FPt(fpenv(:,2)),fpenv(:,1),FPt);
f(find(isnan(f)))=0;

if nargin>5,
  for mm=1:length(newFPt)-1,
    ii=find( (FPt>=newFPt(mm))&(FPt<newFPt(mm+1)) );
    if (~isempty(ii)),
      f2(mm)=sum(f(ii));
    else,
      f2(mm)=0;
    end;
  end;
  f2(mm+1)=0;

  clear f
  f=f2;
end;

if nargout==0,
  %fpenv
  subplot(211),
  plot(FPt,f)
  subplot(212),     
  plot(FPt,FP,'-',fpenv2(:,3),fpenv2(:,2),'go',fpenv2(:,6),fpenv2(:,5),'ro')
end;

