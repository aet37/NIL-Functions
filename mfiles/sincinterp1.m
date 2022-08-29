function [yi,w]=sincinterp1(x,y,xi,nn,wintype)
% Usage ... y1=sincinterp1(x,y,xi,n,wintype)
% 
% Assumes points in x are near-equally spaced
% and in order and n is samples (not in units of x)
% x, y, yi are assumed to be columnar
% Default: n=2

if (nargin<5), wintype=2; end;
if (nargin<4), nn=2; end;
if length(x)~=length(y),
  error('Error: x and y must be the same length');
end;
circ_flag=0;
orig_x=x;
orig_y=y;

if length(wintype)==1, nw=2; end;

xlen=length(x);
dx=mean(abs(diff(x)));

if length(xi)==1,

  if (length(find(x<=xi)))&(length(find(x>=xi))),
    disp('Warning: assymetry in the samples on each side!');
  end;
  if wintype==1, win=0.54+0.46*cos(pi*(x-xi)/(dx*nn));	% hamming
  elseif wintype==2, win=0.5*(1+cos(pi*(x-xi)/(dx*nn)));	% hanning
  elseif wintype==3, win=(cos((pi/4)*(x-xi)/(dx*nn))).^3;	% cos cubed
  else, win=1;						% rect
  end;
  w=sinc((x-xi)/dx).*win;
  sw=sum(w);
  yi=sum((w.*y)/sw);

else,

  %disp(sprintf('WinType= %d',wintype));
  yi=zeros(size(xi));
  for m=1:length(xi),
    %if ((xi(m)<x(1))&(circ_flag)),
    %  dx=x(2)-x(1);
    %  clear x y
    %  x=[([-1*circ_dist:-1:-1]*dx+orig_x(1))';orig_x];
    %  y=[orig_y(end:-1:end-circ_dist);orig_y];
    %elseif ((xi(m)>x(end))&(circ_flag)),
    %  dx=x(2)-x(1);
    %  clear x y
    %  x=[orig_x;([1:circ_dist]*dx+orig_x(end))'];
    %  y=[orig_y;orig_y(1:circ_dist)];
    %else,
    %  x=orig_x;
    %  y=orig_y;
    %end;

    Xi=find((abs((xi(m)-x)/dx)+10*eps)<=nn); 
    if isempty(Xi), 
     disp('Can not find samples to interpolate');
     yi(m)=NaN;
    else,
      X=x(Xi);
      Y=y(Xi);
      if wintype(1)==1, WIN=0.54+0.46*cos(pi*(X-xi(m))/(dx*nn));
      elseif wintype(1)==2, WIN=0.5*(1+cos(pi*(X-xi(m))/(dx*nn)));
      elseif wintype(1)==3, WIN=(cos((pi/4)*(X-xi(m))/(dx*nn))).^3;
      else, WIN=1;
      end;
      W=sinc((X-xi(m))/dx).*WIN; 
      SW=sum(W);
      yi(m)=sum((W(:).*Y(:))/SW);
      %if m==10, [xi(m) nn], X, Y, W, SW, yi(m), end;
      %plot(X,W,X,W,'x'), pause,
    end;
  end;
end;

yi=yi(:);

