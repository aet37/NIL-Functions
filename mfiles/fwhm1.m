function [y,yint]=fwhm1(x,parms)
% Usage ... y=fwhm1(x,parms)
%
% parms=[inv_flag, out_in_flag, nbase_per_end, det_order, dx_int]
%
% Ex. fwhm1(y);
%     fw=fwhm1(x1,1);

if nargin<2, parms=[]; end;

if length(parms)==0, parms=[0 2 2 1 0.1];
elseif length(parms)==1, parms(2:5)=[1 2 1 0.1]; 
elseif length(parms)==2, parms(3:5)=[2 1 0.1];
elseif length(parms)==3, parms(4:5)=[1 0.1];
elseif length(parms)==4, parms(5)=0.1;
end;

inv_flag=parms(1);
fwtype=parms(2);
nii=parms(3);
dord=parms(4);
dx_int=parms(5);

xlen=length(x);
ii=[1:length(x)]';

% make x flat and subtract baseline
dii=[ii(1:nii); ii(xlen-[0:nii-1])];
tmpp=polyfit(dii,x(dii),dord);
xbase=polyval(tmpp,ii);

xnew=x-xbase;
if inv_flag, xnew=-1*xnew; end

% find max and max location
[xmax,xmax_i]=max(xnew);
xnew1=xnew/xmax;

% interpolate xnew
ii_int=[ii(1):dx_int:ii(end)]';
xnew1_int=interp1(ii(:),xnew1(:),ii_int(:));
[~,xmax_int_i]=max(xnew1_int);
xmax_int=xmax;


% calculate fwhm using one of two methods
%
if fwtype==2,
  % inside-out method
  tmpi1=find(xnew1(xmax_i:-1:1)<=0.5,1);
  tmpi2=find(xnew1(xmax_i:xlen)<=0.5,1);
  tmpi1=xmax_i-tmpi1+1;
  tmpi2=xmax_i+tmpi2-1;
  fwhm0=tmpi2-tmpi1;
  
  % interpoolate to value at 0.5
  tmpm1=(xnew1(tmpi1+1)-xnew1(tmpi1))/1;
  tmpm2=(xnew1(tmpi2)-xnew1(tmpi2-1))/1;
  i1est=(0.5 - (xnew1(tmpi1)-tmpi1*tmpm1))/tmpm1;
  i2est=(0.5 - (xnew1(tmpi2)-tmpi2*tmpm2))/tmpm2;
  fwhm=i2est-i1est;
  
  % repeat for interpolated version for comparison
  tmpi1_int=find(xnew1_int(xmax_int_i:-1:1)<=0.5,1);
  tmpi2_int=find(xnew1_int(xmax_int_i:length(xnew1_int))<=0.5,1);
  i1est_int=xmax_int_i-tmpi1_int+1;
  i2est_int=xmax_int_i+tmpi2_int-1;
  fwhm_int=(i2est_int-i1est_int)*dx_int;
  
else,
  % outside-in method
  tmpi=find(xnew1>=0.5);
  tmpi1=tmpi(1);
  tmpi2=tmpi(end);
  fwhm0=tmpi2-tmpi1;
  
  % interpolate to value at 0.5
  tmpm1=(xnew1(tmpi1)-xnew1(tmpi1-1))/1;
  tmpm2=(xnew1(tmpi2+1)-xnew1(tmpi2))/1;
  i1est=( 0.5 - (xnew1(tmpi1)-tmpi1*tmpm1))/tmpm1;
  i2est=( 0.5 - (xnew1(tmpi2)-tmpi2*tmpm2))/tmpm2;
  fwhm=i2est-i1est;
  
  % repeat for interpolated version for comparison
  tmpi_int=find(xnew1_int>=0.5);
  i1est_int=tmpi_int(1);
  i2est_int=tmpi_int(end);
  fwhm_int=(i2est_int-i1est_int)*dx_int;
 
end

y=fwhm;
y2=fwhm_int;

if nargout==0,
    [fwhm fwhm_int fwhm0],
    clf,
    subplot(311), plot(ii,x,ii,xnew,ii,xbase), axis tight, grid on,
    subplot(312), plot(ii,xnew1,[i1est i2est],[0.5 0.5],'ko'), axis tight, grid on,
    subplot(313), plot(ii_int,xnew1_int,...
        ii_int([i1est_int i2est_int]),xnew1_int([i1est_int i2est_int]),'ko'), axis tight, grid on,
    clear y
end

