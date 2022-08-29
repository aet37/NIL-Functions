function y=writeanlz(vol,volno,rootname,hdrinfo)
% Usage ... y=writeanlz(vol,volno,rootname,hdrinfo)
%

fname=sprintf('%s_%04d.img',rootname,volno);
writeim(fname,vol);

if (nargin>3),
  hdrname=sprintf('%s_%04d.hdr',rootname,volno);
  ftype=hdrinfo(1);	% 0=char, 1=un_short, 2=short/2, 3=short
  xdim=hdrinfo(2);	% total pixels
  ydim=hdrinfo(3);	% total pixels
  zdim=hdrinfo(4);	% total pixels
  xsize=hdrinfo(5);	% in mm per pixel
  ysize=hdrinfo(6);	% in mm per pixel
  zsize=hdrinfo(7);	% in mm per pixel
  unix(sprintf('makeaheader %s %d %f %f %f %d %d %d',));
end;

