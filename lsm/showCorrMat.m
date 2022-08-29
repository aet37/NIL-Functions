function showCorrMat(cormat,corthr,mask,im,sel)
% Usage ... showCorrMat(cormat,corthr,mask,im,sel)

if nargin<5, sel=1; end;

clf,
subplot(211)
show(im)
subplot(212)
show(cormat)

imdim=size(im);
cordim=size(cormat);
corthr=sort(corthr);

found=0;
while(~found),
  figure(1),subplot(212)
  [tmpy,tmpx,tmpbut]=ginput(1);
  tmpx=round(tmpx); tmpy=round(tmpy);
  tmpflag=1;
  if sel==1,
    if (tmpx<0)|(tmpx>imdim(1)), tmpflag=0; found=1; end;
    if (tmpy<0)|(tmpy>imdim(2)), tmpflag=0; found=1; end;
  else,
    if (tmpx<0)|(tmpx>cordim(1)), tmpflag=0; found=1; end;
    if (tmpy<0)|(tmpy>cordim(2)), tmpflag=0; found=1; end;
  end;      
  %if tmpbut~=1, tmpflag=0; end;
  if tmpflag,
    tmpstr=sprintf('  (%d,%d)= ',tmpx,tmpy);
    tmp1=zeros(size(cormat));
    tmp2=zeros(size(im));
    if sel==1, tmpy=mask(tmpx,tmpy); end;
    tmpx=tmpy;
    tmp1(tmpx,tmpy)=1;
    tmp2(find(mask==tmpx))=1;
    disp(sprintf('%s%.2f',tmpstr,tmpx));
    for mm=1:length(corthr),
      if mm==length(corthr),
        tmpi=find(cormat(tmpx,:)>corthr(mm));
      else,
        tmpi=find((cormat(tmpx,:)>corthr(mm))&(cormat(tmpx,:)<=corthr(mm+1)));
      end;
      tmpn(mm)=length(tmpi);
      if ~isempty(tmpi),
        for nn=1:length(tmpi),
          tmp1(tmpi(nn),tmpy)=mm+1;
          tmp2(find(mask==tmpi(nn)))=mm+1;
        end;
      end;
    end;
    subplot(212)
    im_overlay4(cormat,tmp1,64);
    subplot(211)
    im_overlay4(im,tmp2,64);
  end;
end;
