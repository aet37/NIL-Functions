function y=volshift2(x,y0,x0,z0,zero_flag)
% Usage ... y=volshift2(vol,x0,y0,z0,zero_flag)
%
% 3D shift in fourier domain

if nargin==2, zero_flag=0;  z0=y0(3); x0=y0(2); y0=y0(1); end;
if nargin==3, zero_flag=x0; z0=y0(3); x0=y0(2); y0=y0(1); end;

if nargin<4, zero_flag=0; end;
  
     % shift the function by the transit time in Frq Domain
     xfft = fftshift(fftn(x));

     xphase = [-size(x,2)/2:size(x,2)/2-1]*2*pi/size(x,2);
     xphase = ones(size(x,1),1)*xphase;
     xphase = x0*xphase;
     xphase = exp(-i.*xphase );

     yphase = [-size(x,1)/2:size(x,1)/2-1]*2*pi/size(x,1);
     yphase = yphase'*ones(1,size(x,2));
     yphase = y0*yphase;
     yphase = exp(-i.*yphase );

     zphase = [-size(x,3)/2:size(x,3)/2-1]*2*pi/size(x,3);
     zphase = z0*zphase;
     zphase = exp(-i.*zphase );

     xfft3=zeros(size(x));
     for mm=1:size(x,3),
       xfft3(:,:,mm) = xfft(:,:,mm).*xphase;
       xfft3(:,:,mm) = xfft3(:,:,mm).*yphase;
       xfft3(:,:,mm) = xfft3(:,:,mm)*zphase(mm);
     end;

     % carry out the convolution by multiplying in frq. domain
     y = real(ifftn(ifftshift(xfft3)));


if zero_flag,
  if y0>1, 
    y(1:floor(y0),:,:)=0;
  elseif y0<-1,
    y(end+floor(y0)+1:end,:,:)=0;
  end;
  if x0>1, 
    y(:,1:floor(x0),:)=0;
  elseif x0<-1,
    y(:,end+floor(x0)+1:end,:)=0;
  end;
  if z0>1, 
    y(:,:,1:floor(z0))=0;
  elseif x0<-1,
    y(:,:,end+floor(z0)+1:end)=0;
  end;
end;

 
if (nargout==0),
  showProj(y)
  clear y
end;


