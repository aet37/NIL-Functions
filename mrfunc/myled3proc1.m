function y=myled3proc1(tc,wlen,parms,xx0,tt)
% Usage ... y=myled3proc1(tc,wlen,parms,xx0,tt)
%
% tc are input time series that are already normalized and detrended
% as desired. If not, parms=[nbase ndord]
% xx0 if included will calculate the HRF using xx0 as initial guess
% for gammafit2_scr
%
% Ex. tcA.gc1=myled3proc1(tcA.atc_n,{'gcamp',572,620});
% Ex. tmpAvg=myled3proc1(squeeze(mean(tcMN_all{10}.atc_n,2)),{'gcamp',572,620},[-1 4],[0 1 1 0.3 0 2.5 1 -0.15]);
%

tc=squeeze(tc);

do_many=0;
if length(size(tc))>2, do_many=1; end;

do_hrf=0;
if nargin>3,
  if isempty(xx0), xx0=[0 1 1 0.3 0 2.5 1 -0.15]; end;
  if nargin<5, tt=[1:size(tc,1)]'; end;
  do_hrf=1;
end;

if exist('parms','var'), if ~isempty(parms),
  if parms(2)>0,
    if do_many, 
      for nn=1:size(tc,3), tcd(:,:,nn)=tcdetrend(tc(:,:,nn),parms(2)); end;
    else,
      size(tc),
      tcd=tcdetrend(tc,parms(2));
    end;
  else, 
    tcd=tc;
  end;
  if parms(1)<0,
    if do_many,
      for nn=1:size(tc,3), tcn(:,:,nn)=tc(:,:,nn)./(ones(size(tc,1),1)*mymode(tc(:,:,nn))); end;
    else,
      tcn=tc./(ones(size(tc,1),1)*mymode(tc));
    end;
  else,
    if do_many,
      for nn=1:size(tc,3), tcn(:,:,nn)=tc(:,:,nn)./(ones(size(tc,1),1)*mean(tc(1:parms(1),:,nn),1)); end;
    else,
      tcn=tc./(ones(size(tc,1),1)*mean(tc(1:parms(1),:),1));
    end;
  end;
  tc=tcn;
end; end;

do_gcamp=0;

if iscell(wlen),
  if strcmp(wlen{1},'gcamp'), do_gcamp=1; end;
  wlen1=470;
  wlen2=wlen{2};
  wlen3=wlen{3};
  clear wlen
  wlen=[wlen1 wlen2 wlen3];
end;

if do_many,
  for nn=1:size(tc,3),
    yHb=myOISdecomp(tc(:,2:3,nn),wlen(2:3));
    yHb_520(:,nn)=myOISrecomp(yHb,520);
    yHbn(:,:,nn)=1+yHb.yHb_norm;
    gc1a(:,nn)=tc(:,1,nn)./tc(:,2,nn);
    gc1(:,nn)=tc(:,1,nn)./yHb_520(:,nn);
    if do_hrf,
      [xx1(nn,:),yf1(:,nn),yh1(:,nn)]=gammafit2_scr(yHbn(:,3,nn)-1,[tt(:)-tt(1) gc1(:,nn)-1],xx0,[1 2 3 4 6 7 8]);
      [xcc(nn),xcp(nn)]=corr(yHbn(:,3,nn)-1,yf1(:,nn));
      [yfp(nn,:)]=polyfit(yf1(:,nn),yHbn(:,3,nn)-1,1);
      figure(1), clf,
      subplot(311), plot(tt,[gc1(:,nn)-1 yHbn(:,3,nn)-1]), axis tight, grid on,
      subplot(312), plot(tt-tt(1),yh1(:,nn)), axis tight, grid on,
      subplot(313), plot(tt,yHbn(:,3,nn)-1,tt,yf1(:,nn)), axis tight, grid on, 
      legend('data',sprintf('fit r=%.3f',xcc)),
      drawnow,
    end;
  end;
else,
  yHb=myOISdecomp(tc(:,2:3),wlen(2:3));
  yHb_520=myOISrecomp(yHb,520);
  yHbn=1+yHb.yHb_norm;
  gc1a=tc(:,1)./tc(:,2);
  gc1=tc(:,1)./yHb_520;
  if do_hrf,
    [xx1,yf1,yh1]=gammafit2_scr(yHbn(:,3)-1,[tt(:)-tt(1) gc1(:)-1],xx0,[1 2 3 4 6 7 8]);
    [xcc,xcp]=corr(yHbn(:,3)-1,yf1);
    [yfp]=polyfit(yf1(:),yHbn(:,3)-1,1);
    figure(1), clf, 
    subplot(311), plot(tt,[gc1(:)-1 yHbn(:,3)-1]), axis tight, grid on,
    subplot(312), plot(tt-tt(1),yh1), axis tight, grid on,
    subplot(313), plot(tt,yHbn(:,3)-1,tt,yf1), axis tight, grid on, 
    legend('data',sprintf('fit r=%.3f',xcc)),
    drawnow,
  end;
end;



if do_many==0, y.yHb=yHb; end;
y.yHbn=yHbn;
y.yHb_520=yHb_520;
y.gc1a=gc1a;
y.gc1=gc1;
if do_hrf,
  y.xx=xx1;
  y.yHbn_fit=yf1;
  y.yh=yh1;
  y.xcc=xcc;
  y.xcp=xcp;
  y.pp_fit=yfp;
end;

