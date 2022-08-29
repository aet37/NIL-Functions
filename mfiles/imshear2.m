function y=imshear2(x,parms,shear_type,dim,zero_flag)
% Usage ... y=tshift2(im,parms,shear_type,dim,zero_flag)
%
% image shear in fourier domain
% shear_types= [0=bulk, 1=linear, 2=sinusoidal]
% zero_flag not implemented yet

verbose_flag=0;

if nargin<5, zero_flag=0; end;
if nargin<4, dim=1; end;
if nargin<3, shear_type=1; end;

if dim==2, x=x.'; end;

if shear_type==2, % sinusoidal shear
  xm=parms(1);
  x0=parms(2);
elseif shear_type==0, % bulk shift
  xm=parms(1);
else, % linear shear
  xm=parms(1);
  x0=ceil(size(x,dim)/2+0.5);
  if length(parms)>1,
    x0=x0+parms(2);
  end;
end;

% shift the function by the transit time in Frq Domain
xfft = fftshift(fft(x,[],2));
%xfft = fft(x,[],2);
xphase = [-size(x,2)/2:size(x,2)/2-1]*2*pi/size(x,2);
xphase = ones(size(x,1),1)*xphase;
xc = [0:size(x,1)-1];
if shear_type==2,
  xc = xm*sin(2*pi*x0*xc);
elseif shear_type==0,
  xc = ones(size(xc))*xm;
else,
  xc = xm*(xc-x0);
end;

xcm = ones(size(x,2),1)*fftshift(xc);
%size(x), size(xcm), size(xphase),
xphase = xcm'.*xphase;
xphase = exp(-i.*xphase );
xfft2 = xfft.*xphase;

% carry out the convolution by multiplying in frq. domain
y = real(ifft(ifftshift(xfft2),[],2));
%y = real(ifft(xfft2,[],2));
if dim==2, y=y.'; end;

%if zero_flag,
%  if y0>1, 
%    y(1:floor(y0),:)=0;
%  elseif y0<-1,
%    y(end+floor(y0)+1:end,:)=0;
%  end;
%  if x0>1, 
%    y(:,1:floor(x0))=0;
%  elseif x0<-1,
%    y(:,end+floor(x0)+1:end)=0;
%  end;
%end;

 
if (nargout==0),
  show(y)
  clear y
end;


