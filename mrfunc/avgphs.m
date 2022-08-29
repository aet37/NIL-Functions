function out=avgphs(pixmask,phase,conv)
%
% Usage ... out = avgphs(pixmask,phase,conv)
%
%
%

tmpsum=0;
for n=1:length(pixmask),
  tmpsum=tmpsum+pixmask(n,3)*phase(pixmask(n,1),pixmask(n,2));
end;
tmpavg=tmpsum/length(pixmask);
if ( conv ),
  tmpavg=(tmpavg/1000)*(180/pi);
end;

out=tmpavg;
