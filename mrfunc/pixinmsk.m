function out=pixinmsk(pixcoord,mask)
%
% Usage ... out=pixinmsk(pixcoord,mask)
%
% Returns a zero if the pixel is not within the mask
% and a one if the pixel is contained within the mask.
%

if ( mask(pixcoord(1),pixcoord(2)) == 1 ),
  out = 1;
else
  out = 0;
end;
