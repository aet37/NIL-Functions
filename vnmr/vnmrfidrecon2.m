function recon=vnmrfidrecon2(data,xy_shift,ft_shift_flag,cmplx_flag);
% Usage ... r=vnmrfidrecon2(data,xy_shift,ft_shift_flag,complex_flag);
%
% Performs a 2D iFFT to reconstruct the images parsed in data (complex)

xy_flag=0;
if exist('xy_shift'), xy_flag=1; end;
if ~exist('ft_shift_flag'), ft_shift_flag=0; end;
if ~exist('cmplx_flag'), cmplx_flag=0; end;

recon=zeros(size(data));
for ii=1:size(data,3),
  tmpim=ifft2(data(:,:,ii));
  if (ft_shift_flag), tmpim=fftshift(tmpim); end;
  if (cmplx_flag),
    recon(:,:,ii)=tmpim;
  else,
    if (xy_flag), tmpim=imshift2(tmpim,xy_shift(1),xy_shift(2)); end;
    recon(:,:,ii)=abs(tmpim);
  end;
end;

if (nargout==0),
  tile3d(recon)
  clear recon
end;

