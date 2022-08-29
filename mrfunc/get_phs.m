function [phs_data,s,phs]=get_phs(dzeros,filt,nphs,npmult,spirals)
% Usage ...  [phs_data,phs]=get_phs(zeros,filter,nphases,npmult,spirals)
%
% Returns the relative phase for every shot. 

OVERSAMPLEFACTOR=4;

sg = (fft(dzeros).*filt);

halfind=floor(length(dzeros)/2);
if rem(halfind,2) halfind2=halfind; else halfind2=halfind+1; end;

sbg = [sg(1:halfind) zeros(1,3*length(dzeros)+1) sg(halfind2+1:length(dzeros))];

gb = ifft(sbg) + mean(dzeros);

try=(gb - mean(gb))*4 + mean(gb);

x = [1:.25:length(dzeros)+.75];
y = try;

s = [x.' y.'];

phs=res_phs(s);

for m=1:spirals,
  o=0;
  indx=(m-1)*spirals+1;
  for n=1:nphs*npmult,
    phs_data(n,m)=phs(indx);
    indx=indx+OVERSAMPLEFACTOR*spirals;
  end;
end;

if nargout==0,
  %plot([1:length(sg)],abs(sg),[1:length(dzeros)],abs(fft(dzeros-mean(dzeros))))
  %plot(filt)
  %plot(angle(gb))
  plot(x,angle(y),x,.01*phs+mean(angle(y)));
end;
