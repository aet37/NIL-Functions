function y=LoGfilter(x,sigma,smw,minflag,minthr)
% Usage ... y=LoGfilter(x,sigma,smw,minflag,minthr)
%
% Calculates the LoG filtered result with kernel width sigma
% and pre-smoothing of smw (gaussian) if provided
% This function will also provide the local minima with 
% neighborhood of minflag (default or empty uses the largest between  
% smw and half the min of sigma).
% If a minthr is provided, only local minimal that exceed minthr
% are included
%
% Ex. imlog=LoGfilter(im,6);
%     imlog=LoGfilter(im,[6],2,2);
%     imlog=LoGfilter(im,[2:2:20],2,2,0);
%     imlog=LoGfilter(im,[2:2:20],2,2,'0.1');


if ~exist('minflag','var'), minflag=[]; end;
if ~exist('smw','var'), smw=[]; end;

if isempty(smw), smw=0; end;
if isempty(minflag), if length(sigma)>1, minflag=-1; else, minflag=0; end; end;
minedge_flag=0;

xdim=size(x);
x_orig=x;

r1=[0:xdim(1)-1]-floor(xdim(1)/2);
c1=[0:xdim(2)-1]-floor(xdim(2)/2);
[rr,cc]=meshgrid(r1',c1);

if smw>1e-10,
  x=im_smooth(x,smw);
end;

if length(sigma)>1,
  y=zeros([xdim(1:2) length(sigma)]);
  for mm=1:length(sigma),
    LoGarg=(rr.^2 + cc.^2)/(2*sigma(mm)^2);
    LoG=-1*(1/(pi*sigma(mm)^4)).*(1-LoGarg).*exp(-LoGarg);

    xf=fft2(x);
    LoGf=(fft2(LoG));

    tmpy=ifftshift(ifft2(abs(xf).*abs(LoGf).*exp(j*angle(xf)+j*angle(LoGf))));
    tmpy=real(tmpy);
    if minflag, tmpy=(sigma(mm)^2)*tmpy; end;
    y(:,:,mm)=tmpy;
  end;
else,
  LoGarg=(rr.^2 + cc.^2)/(2*sigma^2);
  LoG=-1*(1/(pi*sigma^4)).*(1-LoGarg).*exp(-LoGarg);

  xf=fft2(x);
  LoGf=(fft2(LoG));

  y=ifftshift(ifft2(abs(xf).*abs(LoGf).*exp(j*angle(xf)+j*angle(LoGf))));
  y=real(y);
end;

if abs(minflag),
  if minflag>0, 
      oo=minflag; 
  else, 
      oo=ceil(max([smw(1) 0.5*min(sigma)])); 
  end;
  
  imlmin=zeros(xdim(1:2));
  imlminn=zeros(xdim(1:2));
  nsig=length(sigma);
  immin=min(y,[],3);
  
  if ~exist('minthr','var'),
    minthr=mean(immin(:))-2*std(immin(:));
    disp(sprintf('  using %f (%f, %f)',minthr,mean(immin(:)),std(immin(:))));
  elseif ischar(minthr),
    minthr=mean(immin(:))-str2num(minthr)*std(immin(:));
    disp(sprintf('  using %f (%f, %f)',minthr,mean(immin(:)),std(immin(:))));
  else,
    disp(sprintf('  using %f (%f, %f)',minthr,mean(immin(:)),std(immin(:))));
  end;
  
  tmpok=1;
  if minedge_flag==0, tmpok=0; end;
  for mm=1:xdim(1), for nn=1:xdim(2),
    if minedge_flag,
      if mm>oo, tmpni=[-oo:oo]+mm; else, tmpni=[1:mm]; end;
      if mm>=(xdim(1)-oo+1), tmpni=[mm:xdim(1)]; end;
      if nn>oo, tmpnj=[-oo:oo]+nn; else, tmpnj=[1:nn]; end;
      if nn>=(xdim(2)-oo+1), tmpnj=[nn:xdim(2)]; end;
      tmpok=1;
    else,
      tmpok=0;
      if (mm>oo)&(mm<xdim(1)-oo-1)&(nn>oo)&(nn<xdim(2)-oo-1),
        tmpni=[-oo:oo]+mm;
        tmpnj=[-oo:oo]+nn;
        tmpok=1;
      end;
    end;
    
    if tmpok,
    tmpmin=immin(mm,nn);
    if nsig>1,
      tmpkk=find(squeeze(y(mm,nn,:))==tmpmin);
      if isempty(tmpkk), tmpkk=find(abs(squeeze(y(mm,nn,:))-tmpmin)>100*eps); end;
      if tmpkk>1, tmpnk=[-1:1]+tmpkk(1); else, tmpnk=[0:1]+tmpkk(1); end;
      if tmpkk==nsig, tmpnk=[-1:0]+tmpkk(1); end;
    else,
      tmpkk=1;
      tmpnk=1;
    end;
    
    tmpneigh=y(tmpni,tmpnj,tmpnk);
    %if (sum(tmpmin>=tmpneigh(:))==1), 
    if (tmpmin<minthr)&(sum(tmpmin>=tmpneigh(:))==1), 
      imlmin(mm,nn)=tmpmin; 
      imlminn(mm,nn)=sigma(tmpkk); 
    end; 
    end;
    %if (mm==168)&(nn==262), keyboard, end
  end; end;
end;


if nargout==0,
  clf,
  subplot(221), show(x),
  subplot(222), show(LoG),
  subplot(223), show(y(:,:,1)),
  clear y
else,
  if minflag,
    tmps.x=x_orig;
    tmps.sigma=sigma;
    tmps.smw=smw;
    tmps.minflag=minflag;
    tmps.y=y;
    tmps.imlmin=imlmin;
    tmps.imlminn=imlminn;
    tmps.immin=immin;
    tmps.imminthr=minthr;
    y=tmps;
    clear tmps
  end
end

