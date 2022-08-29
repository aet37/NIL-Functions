function f=mytrapezoid(t,tstart,topdur,rampdur,ramptype)
% Usage ... f=mytrapezoid(t,tstart,topdur,rampdur)


% mytrapezoid(t,10/60,20/60,4/60,[10 10000000 200/60 .02]);


if (nargin<5), ramptype=1; end;

f=zeros(size(t));
m=1./rampdur;
if (ramptype==2),
  ff=1/(2*rampdur);
  y1=0.5*(1+cos(2*pi*ff*(t-t(1)-tstart)));
  y2=0.5*(1+cos(2*pi*ff*(t-t(1)-tstart-topdur)));
  f=f+((t>=(tstart-rampdur))&(t<tstart)).*y1;
  f=f+((t>=tstart)&(t<(tstart+topdur))).*1;
  f=f+((t>=(tstart+topdur))&(t<(tstart+topdur+rampdur))).*y2;
elseif (ramptype==3),
  dt=t(2)-t(1);
  hramp=hanning(2*round(rampdur/dt));
  f=f+((t>=tstart)&(t<(tstart+topdur))).*1;
  ri1=find((t>=(tstart-rampdur))&(t<tstart));
  ri2=find((t>=(tstart+topdur))&(t<(tstart+topdur+rampdur)));
  h1=hanning(length(ri1)*2);
  h2=hanning(length(ri2)*2);
  f(ri1)=h1(1:length(ri1));
  f(ri2)=h2(length(ri2)+1:end);
else,
  if (length(rampdur)==1), rampdur(2)=rampdur(1); end;
  m=1/rampdur(1);
  m2=1/rampdur(2);
  y1=m*(t-(tstart-rampdur(1)));
  y2=-m2*(t-(tstart+topdur+rampdur(2)));
  f=f+((t>=(tstart-rampdur(1)))&(t<tstart)).*y1;
  f=f+((t>=tstart)&(t<(tstart+topdur))).*1;
  f=f+((t>=(tstart+topdur))&(t<(tstart+topdur+rampdur(2)))).*y2;
end;

if (ramptype(1)==10),
  % [10 1e7 3 0.15]
  aa=ramptype(2); bb=ramptype(3); cc=ramptype(4);
  g=aa*(t>=tstart).*((t-tstart).^bb).*exp(-bb*(t-tstart)/cc);
  f=f+g;
elseif (ramptype(1)==11),
  % [11 50 0.5 10]
  aa=ramptype(2); bb=ramptype(3); cc=ramptype(4);
  g=aa*(t>=tstart).*exp(-(t-tstart)/bb).*(1-exp(-(t-tstart)/cc));
  f=f+g;
elseif (ramptype(1)==12),
  aa=ramptype(2); bb=ramptype(3);
  m=1/rampdur(1);
  ye1=aa*m*(t-(tstart-rampdur(1))); 
  ye2=aa*((t>=tstart)).*exp(-(t-tstart)/bb);
  %ye2=aa*((t>=tstart)&(t<=(tstart+topdur))).*exp(-(t-tstart)/bb);
  %size(t), size(f), size(ye1), size(ye2),
  f1=((t>=(tstart-rampdur(1)))&(t<tstart)).*ye1;
  f2=ye2;
  f=f.*(1+f1+f2);
  %f=f+(f1+f2);
elseif (ramptype(1)==14),
  aa=ramptype(2); bb=ramptype(3);
  f=f.*(1.0+aa*(t>=(tstart-rampdur(1))).*exp(-(t-(tstart-rampdur(1)))/bb));
end;


if (nargout==0),
  plot(t,f)
end;

