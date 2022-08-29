function out=fndpixvl(image,pixvalue,tolerance)
%
% Usage ... out=fndpixvl(image,pixvalue,tolerance)
%
% Finds the [x y] coordinate(s) of the image that matches
% the pixvalue specified. To find the maximum or minimum
% pixel coordinates (indeces) use the following functions
% as replacement for pixvalue, respectively:
%    max(max(image))
%    min(min(image))
%
% To find the exact pixel use tolerance = 0, otherwise
% a matrix with the pixel coordinates will be returned.
%

isize=size(image);
comph=pixvalue+tolerance;
compl=pixvalue-tolerance;
a=0; n=1; m=1;
pixcoord=[0];

if (tolerance~=0),
  for n=1:isize(1),
  for m=1:isize(2),
    if ((image(n,m)<=comph)&(image(n,m)<=compl)),
      a=a+1;
      pixcoord(a,1)=n;
      pixcoord(a,2)=m;
    end;
  end;
  end;
else  
  for n=1:isize(1),
  for m=1:isize(2),
    if (image(n,m)==pixvalue),
      pixcoord(1)=n;
      pixcoord(2)=m;
    end;
  end;
  end;
end;

out=pixcoord;
