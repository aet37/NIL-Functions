function ff=rect2d(wx,wy,xloc,yloc,xdim,ydim)
% Usage ... f=rect2d(wx,wy,xloc,yloc,xdim,ydim)
% All units in pixels

if nargin==5,
  if length(xdim)>2, 
    xdim=size(xdim);
  end;
  ydim=xdim(2); xdim=xdim(1); 
end;

%[yy,xx]=meshgrid([1:xdim],[1:ydim]');
xx=[1:xdim]; yy=[1:ydim];
ff=zeros(xdim,ydim);

if length(xloc)>1,
  for mm=1:length(xloc),
    ff(find((xx>=(xloc(mm)-wx/2))&(xx<(xloc(mm)+wx/2))),find((yy>=(yloc(mm)-wy/2))&(yy<(yloc(mm)+wy/2))))=1;
  end;
else,
  ff(find((xx>=(xloc-wx/2))&(xx<(xloc+wx/2))),find((yy>=(yloc-wy/2))&(yy<(yloc+wy/2))))=1;
end;

ff=ff.';

%startx=xloc;
%starty=yloc;
%finix=xloc+wx;
%finiy=yloc+wy;

%for m=1:xdim,
%  for n=1:ydim,
%    if (m>=startx)&(m<=finix)&(n>=starty)&(n<=finiy),
%      f(m,n)=1;
%    else,
%      f(m,n)=0;
%    end;
%  end;
%end;

if nargout==0,
  show(ff);
  axis('on');
  grid on;
  title('Rectangle Object Plot');
end;

%clear m n startx starty finix finiy