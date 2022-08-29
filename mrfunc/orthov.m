function zz=orthov(vol,zadj,wl,proj)
% Usage ... v=orthov(vol,zadj,wl,proj)
%

zadj_flag=0;
wl_flag=0;
proj_flag=0;
if ~exist('zadj','var'), zadj=[]; end;
if ~exist('proj','var'), proj=[]; end;
if ~exist('wl','var'), wl=[]; end;

if ~isempty(zadj), zadj_flag=1; end;
if ~isempty(wl), wl_flag=1; end;
if ~isempty(proj), proj_flag=2; proj=abs(proj); end;

if zadj_flag==0, zadj=1; end;

outflag=1;

% if zadj_flag,
%   disp(sprintf('  interpolating volume'));
%   xx=[1:size(vol,1)];
%   yy=[1:size(vol,2)];
%   zz=[1:size(vol,3)];
%   zznew=([1:size(vol,3)*zadj]-1)/(size(vol,3)*zadj-1);
%   zznew=zznew*(size(vol,3)-1)+1;
%   %zznew=zz;
%   [xx3,yy3,zz3]=meshgrid(xx,yy,zz);
%   [xx3n,yy3n,zz3n]=meshgrid(xx,yy,zznew);
%   tmpvol=interp3(xx3,yy3,zz3,single(vol),xx3n,yy3n,zz3n,'linear');
%   clear vol
%   vol=tmpvol;
% end;

[xdim,ydim,zdim]=size(vol);
stretch = zdim/xdim;
x=floor(xdim/2);
y=floor(ydim/2);
z=floor(zdim/2);

% display the orthogonal sections
%colordef black 	
%colormap(gray)

if wl_flag, disp('  using provided level'); end;
if proj_flag, disp(sprintf('  projection mode ON (%d)',proj_flag)); end;

figure,
exit_flag=0;

while (~exit_flag),
 
  fig1=subplot (221);
  if (proj_flag)&(proj(3)>0),
    zi=z+[-proj(3):proj(3)];
    zi=zi(find((zi>=1)&(zi<=zdim)));
    if proj_flag==2,
      z_im=squeeze(max(vol(:,:,zi),[],3));
    elseif proj_flag==3,
      z_im=squeeze(min(vol(:,:,zi),[],3));
    else,
      z_im=squeeze(mean(vol(:,:,zi),3));
    end;
    tmpstr=sprintf('  z=%d(%d,%d)',z,zi(1),zi(end));
  else,
    z_im=squeeze(vol(:,:,z));
  end;
  if wl_flag,
    show(z_im,wl), axis([1 ydim 1 xdim]), axis image, grid off, 
  else,
    show(z_im), axis([1 ydim 1 xdim]), axis image, grid off, 
  end;
  hold on; plot(y,x,'go'); hold off;

  fig2=subplot (222);
  if (proj_flag)&(proj(2)>0),
    yi=y+[-proj(2):proj(2)];
    yi=yi(find((yi>=1)&(yi<=ydim)));
    if proj_flag==2,
      y_im=squeeze(max(vol(:,yi,:),[],2)).';
    elseif proj_flag==3,
      y_im=squeeze(min(vol(:,yi,:),[],2)).';
    else,
      y_im=squeeze(mean(vol(:,yi,:),2)).';
    end;
    tmpstr=sprintf('%s  y=%d(%d,%d)',tmpstr,y,yi(1),yi(end));
  else,
    y_im=squeeze(vol(:,y,:)).';
  end;
  if zadj_flag,
    [tmp1,tmp2]=meshgrid([0:xdim-1]/(xdim-1),[0:zdim-1]/(zdim-1));
    [tmp1i,tmp2i]=meshgrid([0:xdim-1]/(xdim-1),[0:zdim*zadj-1]/(zdim*zadj-1));
    y_im_orig=y_im; clear y_im
    y_im=interp2(tmp1,tmp2,y_im_orig,tmp1i,tmp2i);
  end;
  if (wl_flag),
    show(y_im,wl), axis([1 xdim 1 zdim]), axis image, grid off, 
  else,
    show(y_im), axis([1 xdim 1 zdim]), axis image, grid off, 
  end;
  hold on; plot(x,z*zadj,'go'); hold off;

  fig3=subplot (223);
  if (proj_flag)&(proj(1)>0),
    xi=x+[-proj(1):proj(1)];
    xi=xi(find((xi>=1)&(xi<=xdim)));
    if proj_flag==2,
      x_im=squeeze(max(vol(xi,:,:),[],1)).';
    elseif proj_flag==3,
      x_im=squeeze(min(vol(xi,:,:),[],1)).';
    else,
      x_im=squeeze(mean(vol(xi,:,:),1)).';
    end;
    tmpstr=sprintf('%s  x=%d(%d,%d)',tmpstr,x,xi(1),xi(end));
    disp(tmpstr);
  else,
    x_im=squeeze(vol(x,:,:)).';
  end;
  if zadj_flag,
    [tmp1,tmp2]=meshgrid([0:ydim-1]/(ydim-1),[0:zdim-1]/(zdim-1));
    [tmp1i,tmp2i]=meshgrid([0:ydim-1]/(ydim-1),[0:zdim*zadj-1]/(zdim*zadj-1));
    x_im_orig=x_im; clear x_im
    x_im=interp2(tmp1,tmp2,x_im_orig,tmp1i,tmp2i);
  end;
  if (wl_flag),
    show(x_im,wl), axis ([1 ydim 1 zdim]), axis image, grid off,
  else,
    show(x_im), axis ([1 ydim 1 zdim]), axis image, grid off,
  end;
  hold on; plot(y,z*zadj,'go'); hold off;

  [i,j,button]=ginput(1);
  i=round(i);j=round(j); gca,
  fig=floor(gca);
  switch(fig),
    case floor(fig1)
      x=j;
      y=i;
    case floor(fig2)
      z=j;
      x=i;
      if zadj_flag, z=round(z/zadj); end;
    case floor(fig3)
      y=i;
      z=j;
      if zadj_flag, z=round(z/zadj); end;
  end
 
  if (button==3),
    exit_flag=1;
  elseif ((button==1)&(outflag)),
    if (x<0)|(y<0)|(z<0), 
      exit_flag=1; 
    elseif (x>xdim)|(y>ydim)|(z>zdim),
      exit_flag=1;
    else, 
      disp(sprintf(' vol(%d,%d,%d)= %d',x,y,z,vol(x,y,z)));
    end;
  end
 
end	

zz.x=x_im;
zz.y=y_im;
zz.z=z_im;

if nargout==0,
  clear zz
else,
  close
end;
