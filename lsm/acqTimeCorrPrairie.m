function y=acqTimeCorrPrairie(data,tparms,iparms)
% Usage ... y=acqTimeCorrPrairie(data,tparms,iparms)
%
% tparms=[frTime dwTime waitTime]
% iparms=[intN1pts intType intEnv]

do_linecorr=1;
if length(tparms)==1, tparms(2:3)=0; end;
if length(tparms)==2, tparms(3)=0; end;
if tparms(2)<10*eps, do_linecorr=0; end;

ddim=size(data);
frTime=tparms(1);
dwTime=tparms(2);
wtTime=tparms(3);

nInt=iparms(1);
iType=iparms(2);
wType=iparms(3);

tt=[1:ddim(3)]*frTime;

lineTime=frTime-ddim(1)*ddim(2)*tparms(2)-wtTime;
lineTime=lineTime/ddim(1);
tl=zeros(ddim(1),ddim(2));
for mm=1:size(data,1),
  tl(mm,:)=[0:ddim(2)-1]*dwTime+(mm-1)*lineTime;
end;

datai=zeros(size(data));
for mm=1:length(tt),
  tmptt=tt(mm)+tl(nn,oo)-tt;
  tmpii=find(abs(tmptt)<=nInt);
  if isempty(tmpi), error('  cannot find point to interpolate!'); end;
  tmpit=tmptt(tmpii);
  if (iType==3),		% sinc interpolation
    if wType==1, WIN=0.54+0.46*cos(pi*tmpit/(dt*nInt));
    elseif wType==2, WIN=0.5*(1+cos(pi*tmpit/(dt*nInt)));
    elseif wType==3, WIN=cos((pi/4)*tmpit/(dt*nInt)).^3;
    else, WIN=1;
    end;
    W=sinc(tmpit/(dt*nInt)).*WIN;
  elseif (iType==2),		% cubic interpolation
    for pp=1:length(tmpit),
      xx=abs(tmpit(pp)-tt(mm))/(dt*nInt(2));
      if (xx<=1),
        W(mm) = 1 - (5/2)*(xx^2) + (3/2)*(xx^3);
      elseif (xx<=2),
        W(mm) = 2 - 4*xx + (5/2)*(xx^2) - (1/2)*(xx^3);
      else,
        W(mm) = 0;
      end;
    end;
  else,				% linear interpolation
    W=1-abs(tmpit)/(dt*nInt);
  end;
  SW=sum(W); if (SW==0.0), SW=1.0; end;
  if (plotflag), plot(tmpit,W,'*'), pause, end;
  yi=zeros([info(1) info(2)]);
  for n=1:length(Xi),
    disp(sprintf(' interpolating im# %d using im# %d',xi(m),x(Xi(n))));
    if (intkeropt==2),
      yi=yi+(W(n)/SW)*getslim(path,slno,x(Xi(n)),info,ext);
    else,
      yi=yi+(W(n)/SW)*getslim(path,slno,Xi(n),info,ext);
    end;
  end;
end;

