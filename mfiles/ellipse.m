function outmat=ellipse(inmat,x0,y0,u,v,a,val)
% ELLIPSE (inmatrix, row-center, col-center, major-axis, minor-axis, tilt-angle, value)
%	ELLIPSE adds an oval of magnitude 'value' with tilt-angle (degrees) to the input matrix.

if nargin<7, val=1; end;
if nargin<6, a=0; end;

if length(inmat)==2, inmat=zeros(inmat); end;

do_orig=0;
if a~=0, do_orig=0; end;

outmat=inmat;

if do_orig,
  ss=size(inmat);
  x1=round(x0-u); if x1<1, x1=1; end; %ceil
  x2=round(x0+u); if x2>ss(1), x2=ss(1); end; %floor
  for ii=x1:x2,
      r=abs(sqrt(u^2-(ii-x0)^2))*v/u; %added abs
      y1=round(y0-r); if y1<1, y1=1; end; %ceil
      y2=round(y0+r); if y2>ss(2), y2=ss(2); end; %floor
      outmat(ii,y1:y2)=outmat(ii,y1:y2)+val;
      %for j=ceil(y-r):floor(y+r),  
      %  outmat(i,j)=outmat(i,j)+val;
      %end
  end
else,
  sz=size(inmat);
  [yy,xx]=meshgrid([1:sz(2)]-y0,[1:sz(1)]-x0);
  %size(xx), size(yy),
  if a~=0,
    a=a*pi/180;
    tmprxy=[xx(:) yy(:)]*[cos(a) -sin(a); sin(a) cos(a)];
    xr=reshape(tmprxy(:,1),sz);
    yr=reshape(tmprxy(:,2),sz);
    xx=xr; yy=yr;
    clear tmprxy xr yr
  end;
  tmpi=find((xx.^2/u^2 + yy.^2/v^2)<=1);
  if length(tmpi)>0, outmat(tmpi)=outmat(tmpi)+val; end;
end;

% outmat2=outmat;
% u2=0.5*u/size(inmat,1);
% v2=0.5*v/size(inmat,2);
% dd=size(inmat);
% 
% for ii=1:dd(1), for jj=1:dd(2),
%   iloc=(ii-1-fix(dd(1)/2))/fix(dd(1)/2);
%   jloc=(jj-1-fix(dd(2)/2))/fix(dd(2)/2);
%   outmat2(ii,jj)=fellik(iloc,jloc,x/dd(1),y/dd(2),u/dd(1),v/dd(2),a,val);
% end; end;
% 
% show(abs(outmat2))
