function [dxy,xc]=simple_piv(a,b,parms)
% Usage ... [dxy,xc]=simple_piv(a,b,parms)
%
% a,b should be doubles
% parms = [xc_type multid_type subpixest_flag]  (e.g. [1 2or3 1])

% added abs to ifft result prior to fftshift

verbose_flag=0;

if nargin<3,
  xc_type=1;
  multid_type=3;
  subpixest_flag=0;
else,
  xc_type=parms(1);
  multid_type=parms(2);
  if length(parms)>2,
    subpixest_flag=parms(3);
  else,
    subpixest_flag=0;
  end;
end;


if (size(a,1)==1)|(size(a,2)==1),
  oned_flag=1;
else,
  oned_flag=0;
end;


if oned_flag,
  % 1D data
  if (xc_type==2),
    xc=xcorr(a,b);
  else,
    xc=abs(ifft(fft(a).*fft(b(end:-1:1))));
  end;
  alen=length(a);
  maxi=find(xc>0.999*max(xc));
  if (subpixest_flag),
    if length(maxi)==1,
      f0=log(xc(maxi));
      f1=log(xc(maxi-1));
      f2=log(xc(maxi+1));
      maxi_sp=maxi+(f1-f2)/(2*f1-4*f0+2*f2);
      if isreal(maxi_sp),
        maxi=maxi_sp;
      end
    end;
  end;
  dxy=alen-maxi;
  if (dxy>alen/2), dxy=dxy-alen; end;

else,
  % assume 2D
  if verbose_flag,
    disp(sprintf('  2D simple_piv (xc=%d,subp=%d)',xc_type,subpixest_flag));
  end;
  if (xc_type==2),
    xc=xcorr2(a,b);
  else,
    xc=abs(ifft2(fft2(a).*fft2(b(end:-1:1,end:-1:1))));
  end;
  [maxi,maxj]=find(xc>0.999*max(max(xc)));
  if length(maxi)>1, [maxi,maxj]=find(xc==max(max(xc))); end;
  if verbose_flag, disp(sprintf('  xc_len=%d',length(maxi))); end;
  if (subpixest_flag),
    if (maxi>1)&(maxi<size(a,1)),
      f0=log(xc(maxi,maxj));
      f1=log(xc(maxi-1,maxj));
      f2=log(xc(maxi+1,maxj));
      maxi_sp=maxi+(f1-f2)./(2*f1-4*f0+2*f2);
    else,
      maxi_sp=maxi;
    end;
    if (maxj>1)&(maxj<size(a,2)),
      f0=log(xc(maxi,maxj));
      f1=log(xc(maxi,maxj-1));
      f2=log(xc(maxi,maxj+1));
      maxj_sp=maxj+(f1-f2)./(2*f1-4*f0+2*f2);
    else,
      maxj_sp=maxj;
    end;
    if isreal(maxi_sp)&isreal(maxj_sp)
      maxi=maxi_sp;
      maxj=maxj_sp;
    end;
  end;
  if (maxj>size(a,2)/2), maxj=size(a,2)-maxj; end;
  if (maxi>size(a,1)/2), maxi=size(a,1)-maxi; end;
  dxy=maxj+i*maxi;
  if verbose_flag, disp(sprintf('  len_dxy=%d',length(dxy))); end;
end;

if length(dxy)>1,
  tmpstr=sprintf('  warning: length of dxy > 1, ');
  if multid_type==1,
    tmpstr=sprintf('%s selecting 1st',tmpstr);
    tmpdxy=dxy(1);
  elseif multid_type==2,
    tmpstr=sprintf('%s selecting mean',tmpstr);
    tmpdxy=mean(dxy);
  elseif multid_type==3,
    tmpstr=sprintf('%s selecting max',tmpstr);
    tmpdxy=max(dxy);
  elseif multid_type==4,
    tmpstr=sprintf('%s selecting min',tmpstr);
    tmpdxy=min(dxy);
  elseif multid_type==5,
    tmpstr=sprintf('%s selecting last',tmpstr);
    tmpdxy=dxy(end);
  else,
    tmpstr=sprintf('%s selecting 1st',tmpstr);
    tmpdxy=dxy(1);
  end;
  if verbose_flag, disp(tmpstr); end;
  clear dxy
  dxy=tmpdxy;
end;

if nargout==0,
  if (oned_flag),
    plot(xc)
  else,
    show(fftshift(xc))
  end;
  title(sprintf('dxy= %f',dxy))
end;

