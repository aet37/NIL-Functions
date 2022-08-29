function y=myiminterpf(im,sze)
% Usage ... y=myiminterp1(im,scale)
%
% size is the desired dimensionality of im

if length(sze)==1, sze=[1 1]*sze(1); end;

%imf=fftn(im);
%y=ifftn(imf,sze);


% do rounding
sze = floor( sze + 10*eps );

% calculate target sizes
initial_x_size  = size(im,2);
initial_y_size  = size(im,1);
target_x_size   = round(initial_x_size*sze(1));
target_y_size   = round(initial_y_size*sze(2));
fourier_gain    = prod(sze);	%not sure about this

% calculate user sizes
center_x    = floor(target_x_size/2);
center_y    = floor(target_y_size/2);
span_x      = [1:initial_x_size]-ceil(initial_x_size/2);
span_y      = [1:initial_y_size]-ceil(initial_y_size/2);

% transform to fourier domain
spectrum_m = fftshift( fft2( im )*fourier_gain );

% zero padding (=condensing the frequency domain)
padded_specturm_m = zeros( target_y_size,target_x_size );
padded_specturm_m( center_y+span_y+1,center_x+span_x+1 ) = spectrum_m; 

% inverse transform to reveal the interpolated series in space domain. 
y = ifft2( ifftshift( padded_specturm_m ) );

% we want values which are ONLY between the given points (interpolation and not extrapolation)
y = y(1:end-sze(1)+1,1:end-sze(2)+1);

