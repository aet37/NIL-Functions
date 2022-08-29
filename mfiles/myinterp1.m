function [yi,wi,ni]=myinterp1(x,y,xi,ww,itype)
% Usage ... yi=myinterp1(x,y,xi,w,itype)
%
% simple 1D interpolation with where xi matches x
% and ww is the interpolation kernel width in INDEX units
% kernel types can be linear(1 or 'lin'), cubic(3 or 'cub'), cosine(5 or 'cos'),
% sinc(2 or 'sinc') or kaiser-bessel1(4 or 'kbes'). Tke kernel can 
% be windowed using a second parameter (0/def=ones, 1=hamming, 2=cosine)
%
% Ex. yi=myinterp1([-50:50],-sin(2*pi*0.02*[-50:50]).^10,[-50:0.1:50],2.5,[1]);
%     yi=myinterp1([-50:50],-sin(2*pi*0.02*[-50:50]).^10,[-50:0.1:50],2.5,[2 1]);
%     x=[1:100]; y=zeros(1,100); y(10:50)=1; 
%     yi=myinterp1(x,y,xi,1,1); 
%     yi=myinterp1(x,y,xi,2.5,[2 1]);

if nargin<5, itype=[]; end;
if nargin<4, ww=[]; end;

if isempty(ww), ww=1; end;
if isempty(itype), itype='sinc'; end;

do_plot=0;

if ischar(itype),
  if strcmp(itype,'sinc'), itype=2; 
  elseif strcmp(itype,'cubic')|strcmp(itype,'cub'), itype=3;
  elseif strcmp(itype,'kbes'), itype=4; 
  elseif strcmp(itype,'cos')|strcmp(itype,'cosine'), itype=5; 
  else, itype=1; 
  end;
end;

if length(itype)==2, 
    wintype=itype(2);
    itype=itype(1);
else, 
    wintype=1; 
end;

if nargout==0,
  if itype==2, disp('  sinc interp');
  elseif itype==3, disp('  cubic interp');
  elseif itype==4, disp('  kbes interp');
  else, disp('  linear interp');
  end;
  disp(sprintf('  wintype= %d',wintype));
end;

xlen=length(x);
dx=x(2)-x(1);

for mm=1:length(xi),
  yi(mm)=0;
  tmpi=find(abs(x-xi(mm))<=ww);
  NW(mm)=length(tmpi);
  if ~isempty(tmpi),
    X=xi(mm)-x(tmpi);
    if (itype==2),		% sinc interpolation
      if wintype==1, WIN=0.54+0.46*cos(pi*X/ww);
      elseif wintype==2, WIN=0.5*(1+cos(pi*X/ww));
      elseif wintype==3, WIN=(cos((pi/4)*X/ww)).^3;
      else, WIN=1;
      end;
      W=sinc(X/dx).*WIN;
    elseif (itype==3),	% cubic interpolation
      X=abs(X/dx);
      W=zeros(size(X));
      i1=find(X<=1); i2=find(X>1); i3=find(X>=3);
      if ~isempty(i1), W(i1)=1-(5/2)*(X(i1).^2)+(3/2)*(X(i1).^3); end
      if ~isempty(i2), W(i2)=2-4*X(i2)+(5/2)*(X(i2).^2)-(1/2)*(X(i2).^3); end;
      if ~isempty(i3), W(i3)=0; end;
      clear i1 i2 i3
    elseif (itype==4),  % kaiser-bessel0 interpolation
      beta=interp1([1.5 2.0 2.5 3.0 3.5],[1.998 2.394 3.380 4.205 4.911],ww);
      W=(1/beta)*besseli(0,beta*sqrt(1-(2*X).^2));
      W=real(W);
    elseif (itype==5),  % cosine interpolation
      W=(1+cos(pi*X/ww))/2;
    else,				% linear interpolation
      %W=(1+cos(pi*X/ww))/2;
      W=1-abs(X/dx)/ww;
    end;
    SW(mm)=sum(W); if (SW(mm)==0.0), SW(mm)=1.0; end;
    if (do_plot), clf, plot(X,W,'*'), [xi(mm) x(tmpi)], W, pause, end;
  
    yi(mm)=sum(W.*y(tmpi))/SW(mm);
    %yi=yi+(W(n)/SW)*getslim(path,slno,x(Xi(n)),info,ext);
  end;
end;

if nargout==0,
    clf,
    subplot(211), plot(x,y,xi,yi), axis tight, grid on,
    subplot(212), plot(xi,yi), axis tight, grid on,
    clear yi wi
end


% for mm=1:length(xi),
%   tmpi=find(abs(x-xi(mm))<=ww);
%   xx=(x-xi(mm))/dx;
%   ni(mm)=length(tmpi);
%   yi(mm)=0;
%   wi(mm)=0;
%   if ni(mm)>0,
%     if itype==2,        w0=w_sinc(xx,ww,wintype);
%     elseif itype==3,    w0=w_cub(xx,ww);
%     elseif itype==4,    w0=w_kbes0(xx,ww);
%     else,               w0=w_lin(xx,ww);
%     end;
%     wi(mm)=sum(w0);
%     yi(mm)=sum(w0.*y(tmpi))/wi(mm);
%   end
% end
%
% % Sub-functions
% function f=w_lin(dr,w)
%   f=1-dr/w;
%   f(find(dr>w))=0;
% return 
% 
% function f=w_cub(dr,w)
%   f=1-(dr/w).^3;
%   f(find(dr>w))=0;
% return
% 
% function f=w_sinc(dr,w,win)
%   f=sinc(dr);
%   if nargin==2, win=0; end;
%   if win==1, ww=0.54+0.46*cos(pi*dr/w);
%   elseif win==2, ww=0.5*(1+cos(pi*dr/w));
%   else, ww=ones(size(f));
%   end;
%   f(find(dr>w))=0;
% return
% 
% function f=w_kbes0(dr,w)
%   beta=interp1([1.5 2.0 2.5 3.0 3.5],[1.998 2.394 3.380 4.205 4.911],w);
%   f=(1/w)*besseli(beta*sqrt(1-(2*dr).^2));
%   f(find(dr>w))=0;
% return
