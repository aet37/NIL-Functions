function y=myvolinterpf(vol,sze)
% Usage ... y=myvolinterp1(vol,size_or_scale)
%
% size is the desired dimensionality of vol 

if length(sze)==1, sze=[1 1 1]*sze(1); end;

%volf=fftn(vol);
%y=ifftn(volf,sze);


% do rounding
sze = floor( sze + 10*eps );

% calculate target sizes
initial_x_size  = size(vol,2);
initial_y_size  = size(vol,1);
initial_z_size  = size(vol,3);
target_x_size   = initial_x_size*sze(1);
target_y_size   = initial_y_size*sze(2);
target_z_size   = initial_z_size*sze(3);
fourier_gain    = prod(sze);

% calculate user sizes
center_x    = floor(target_x_size/2);
center_y    = floor(target_y_size/2);
center_z    = floor(target_z_size/2);
span_x      = [1:initial_x_size]-ceil(initial_x_size/2);
span_y      = [1:initial_y_size]-ceil(initial_y_size/2);
span_z      = [1:initial_z_size]-ceil(initial_z_size/2);

% transform to fourier domain
spectrum_m = fftshift( fftn( vol )*fourier_gain );

% zero padding (=condensing the frequency domain)
padded_specturm_m = zeros( target_y_size,target_x_size,target_z_size );
padded_specturm_m( center_y+span_y+1,center_x+span_x+1,center_z+span_z+1 ) = spectrum_m; 

% inverse transform to reveal the interpolated series in space domain. 
y = ifftn( ifftshift( padded_specturm_m ) );

% we want values which are ONLY between the given points (interpolation and not extrapolation)
y = y(1:end-sze(1)+1,1:end-sze(2)+1,1:end-sze(3)+1);
