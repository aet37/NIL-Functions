function f=myramp(t,fwhm,amp,slope,start)
% Usage ... f=myramp(t,fwhm,amp,slope,start)
% Builds a ramp with the specified parameters

tl=length(t);

if ( fwhm<(1/slope) ),
  disp(['Warning: FWHM min value exceeds 1/slope']);
  disp(['         Assigning minimum value']);
  slope=1/fwhm;
end;

% Ramp pulse construction
v=zeros(size(t));
tw=0.5/slope;
for n=1:tl,
  if ( ((t(n)-start)<=2*tw)&((t(n)-start)>=0) ), v(n)=slope*(t(n)-start);
  elseif ( ((t(n)-start)<=fwhm)&((t(n)-start)>=0) ), v(n)=1;
  elseif ( ((t(n)-start)<=(fwhm+2*tw))&((t(n)-start)>=0) ), v(n)=-slope*(t(n)-start-fwhm)+1;
  else, v(n)=0;
  end;
end;

f=amp.*v;

if (nargout==0),
  plot(t,f);
end;