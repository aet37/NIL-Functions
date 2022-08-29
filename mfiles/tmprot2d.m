
x=zeros(640,480);
x(100:300,40:140)=1;

x0=2;
y0=10;

xfft = fftshift(fft2(x));

xphase = [-size(x,2)/2:size(x,2)/2-1]*2*pi/size(x,2);
xphase = ones(size(x,1),1)*xphase;
yphase = [-size(x,1)/2:size(x,1)/2-1]*2*pi/size(x,1);
yphase = yphase'*ones(1,size(x,2));

xphase1 = x0*xphase.*yphase;
xphase1 = exp(-i.*xphase1 );
yphase1 = y0*yphase.*xphase;
yphase1 = exp(-i.*yphase1 );

xfft2 = xfft.*xphase1;
xfft2 = xfft2.*yphase1;

% carry out the convolution by multiplying in frq. domain
y = real(ifft2(ifftshift(xfft2)));

