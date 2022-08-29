function f=edge2(image,detectorx,detectory,thrm,thrd)
% Usage ... f=edge2(image,detectorx,detectory,thrm,thrd)
%
% Example of detectors,
%   detector_x=[1 1 1;0 0 0;-1 -1 -1]
%   detector_y=[1;1;1 0;0;0 -1;-1;-1]

[xr,xc]=size(detectorx);
[yr,yc]=size(detectory);

if ( (xr~=yr)|(xc~=yc)|(xr~=xc)|(yr~=yc) ),
  error('Error: detector sizes are not identical!');
end;
if ( ~exist('opsize') ), opsize=length(detectorx); end;

[ir,ic]=size(image);

gradx=zeros(size(image));
grady=zeros(size(image));
gradm=zeros(size(image));
gradd=zeros(size(image));
maskm=zeros(size(image));
maskd=zeros(size(image));

for m=2:ir-1, for n=2:ic-1,
  tmp=0; tmp2=0;
  for o=1:xr, for p=1:xc,
    tmp=tmp+image(m+o-ceil(xr/2),n+p-ceil(xr/2))*detectorx(o,p);
    tmp2=tmp2+image(m+o-ceil(xr/2),n+p-ceil(xr/2))*detectory(o,p);
  end; end;
  gradx(m,n)=tmp;
  grady(m,n)=tmp2;
end; end;

for m=1:ir, for n=1:ic,
  gradm(m,n)=sqrt( (gradx(m,n)^2)+(grady(m,n)^2) );
  if (gradx(m,n)==0) gradx(m,n)=1e-8; end;
  gradd(m,n)=atan( grady(m,n)/gradx(m,n) );
end; end;
maskm=(gradm>thrm);

for m=2:ir-1, for n=2:ic-1,
  if (maskm(m,n)==1),
    for o=1:3, for p=1:3,
      if ( abs( gradd(m,n)-gradd(m+o-2,n+p-2) )<=thrd ), 
        maskd(m+o-2,n+p-2)=1;
      end;
    end; end;
  end;
end; end;

f=(maskm&maskd);

if (nargout==0),
  clg;
  subplot(2,2,1);
  show(image);
  axis('on');
  grid;
  title('Original')
  subplot(2,2,2);
  show(maskm);
  axis('on');
  grid;
  title('Magnitude Thresholded')
  subplot(2,2,3);
  show(maskd);
  axis('on');
  grid;
  title('Direction Similarity Map')
  subplot(2,2,4);
  show(f);
  axis('on');
  grid;
  title('Output');
end;
