function [newim,newn]=myimhistnorm2(im,parms)
% Usage ... y=myimhistnorm2(im,parms)
%
% parms = [wx wy]
% wx and wy are in pixel units

if nargin==1, parms=round(size(im(1)/4)); end;

if length(parms)==1, parms(2)=parms(1); end;

imdim=size(im);
immax=max(im(:));
immin=min(im(:));

do_rescale=0;
rescalef=4096;
if (max(im(:))<=1)|(min(im(:))<=0),
  disp(sprintf('  rescaling image to %d (%f,%f)',rescalef,min(im(:)),max(im(:))));
  do_rescale=1;
  im=imwlevel(im,[],1)*rescalef;    % +1?
end;

wx=parms(1);
wy=parms(2);

wxl=ceil(wx/2);
wxr=floor(wx/2);
wyl=ceil(wy/2);
wyr=floor(wy/2);

disp(sprintf('  window: wx=%d (%d,%d)  wy=%d (%d,%d)',wx,wxl,wxr,wy,wyl,wyr));

for mm=1:imdim(1), for nn=1:imdim(2),
  tmpi=[mm-wxl:mm+wxr];
  tmpi=tmpi(find((tmpi>=1)&(tmpi<=imdim(1))));
  tmpi0=find(tmpi==mm);
  tmpj=[nn-wyl:nn+wyr];
  tmpj=tmpj(find((tmpj>=1)&(tmpj<=imdim(2))));
  tmpj0=find(tmpj==nn);
  %disp(sprintf('  i=%d j=%d  ii=[%d-%d]  jj=[%d-%d]  0=[%d,%d]',mm,nn,tmpi(1),tmpi(end),tmpj(1),tmpj(end),tmpi0,tmpj0));
  tmpim=im(tmpi,tmpj);
  tmpimhn=myimhistnorm(imwlevel(tmpim,[immin immax],1)*(immax-immin));
  newn(mm,nn)=prod(size(tmpim));
  newim(mm,nn)=tmpimhn(tmpi0,tmpj0);
end; end;
newim=newim+immin;

if do_rescale,
  newim=(newim/rescalef)*(immax-immin)+immin;
end;

if nargout==0,
  show(newim),
end;