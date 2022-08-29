function ff=fermi2d(imsize,co,wid,amp)
% Usage ... y=fermi2d(imsize,co,wid,amp)

%[-imsize(1)/2 imsize(1)/2-1],
%[-imsize(1)/2 imsize(1)/2-1],

do_filt=0;
if length(imsize)>3,
  do_filt=1;
  zz=imsize;
  imsize=size(zz);
end;

[xx,yy]=meshgrid([-imsize(1)/2:imsize(1)/2-1],[-imsize(2)/2:imsize(2)/2-1]);

xprof=[0:min(imsize)/2];

ff=zeros(size(xx));
pp=zeros(size(xprof));
for mm=1:length(co),
  ff0=1./(1+exp((sqrt(xx.^2+yy.^2)-co(mm))/wid(mm)));
  pp0=1./(1+exp((xprof-co(mm))/wid(mm)));
  if amp(mm)<0,
    ff0=1-abs(amp(mm)).*ff0;
    pp0=1-abs(amp(mm)).*pp0;
  else,
    ff0=amp(mm).*ff0;
    pp0=amp(mm).*pp0;
  end;
  if mm==1, ff=ff0; pp=pp0; else, ff=ff.*ff0; pp=pp.*pp0; end;
end;

if do_filt,
  ff=fftshift(ff);
  zf=fft2(zz);
  z2=ifft2(zf.*ff);
else,
  z2=ff;
end;

if nargout==0,
subplot(211),
show(fftshift(ff)),
subplot(212),
if do_filt, 
  show(abs(z2))
else,
  plot(xprof,pp)
end;
end;

ff=z2;

