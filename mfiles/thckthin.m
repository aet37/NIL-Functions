function f=thckthin(image,opsize,thick,thin)
% Usage ... f=thckthin(image,opsize,thick,thin)
% Image must be binary.
% Opsize is the square operator size.

[ir,ic]=size(image);
orig=image;
thickim=zeros(size(image));
thinim=zeros(size(image));
start=ceil(opsize/2);

if (thick),
for d=1:thick,
  for m=start:ir-start+1, for n=start:ic-start+1,
    if (image(m,n)),
      for o=1:opsize, for p=1:opsize,
        thickim(m+o-start,n+p-start)=1;
      end; end;
    end;
  end; end;
end;
image=thickim;
end;

if (thin),
 for d=1:thin,
  for m=2:ir-1, for n=2:ic-1,
    if ( image(m,n)&image(m-1,n)&image(m+1,n)&image(m,n+1)&image(m,n-1)&image(m,n)&image(m-1,n-1)&image(m-1,n+1)&image(m+1,n-1)&image(m+1,n+1) ),
      thinim(m,n)=1;
    elseif ( image(m,n)&image(m-1,n)&image(m+1,n)&(~(image(m,n+1)|image(m,n-1))) ),
      thinim(m,n)=1;
    elseif ( image(m,n)&image(m,n-1)&image(m,n+1)&(~(image(m+1,n)|image(m-1,n))) ),
      thinim(m,n)=1;
    elseif ( image(m,n)&image(m-1,n-1)&image(m+1,n+1)&(~(image(m-1,n+1)|image(m+1,n-1))) ),
      thinim(m,n)=1;
    elseif ( image(m,n)&image(m+1,n-1)&image(m-1,n+1)&(~(image(m+1,n+1)|image(m-1,n-1))) ),
      thinim(m,n)=1;
    end;
  end; end;
 end;
 image=thinim;
end;

f=image;

if (nargout==0),
  clg;
  subplot(2,1,1)
  show(orig);
  axis('on');
  grid;
  title('Original Image');
  subplot(2,1,2)
  show(f);
  axis('on');
  grid;
  title('Output');
end;
