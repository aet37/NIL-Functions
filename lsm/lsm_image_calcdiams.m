function dim=lsm_image_calcdiams(fname,parms,chName,imno)
% Usage ... dim=lsm_image_calcdiams(fname,parms,chName,imno)

data=tiffread2c(fname);
if nargin<4, imno=1:length(data); end;
if nargin<3, chName='red'; end;

im_thr=parms(1);
im_medfltk=parms(2);
im_openthr=5;

for mm=1:imno,
  eval(sprintf('tmpim0=double(data(imno(mm)).%s);',chName));
  if im_medfltk>1, tmpim0=medfilt2(tmpim0,[im_medfltk im_medfltk]); end;
  tmpim1=tmpim0>im_thr;
  tmpim2=imclose(tmpim1,strel('disk',im_openthr));
  tmpim3=edge(double(tmpim2),'canny');
  tmpim4=bwdist(tmpim2);
  tmpim5=bwdist(~tmpim2);
  dim(:,:,mm)=tmpim5;
  %keyboard,
end;

if nargout==0,
  subplot(221)
  show(tmpim2)
  subplot(222)
  show(tmpim5)
  subplot(224)
  show(tmpim4)
else,
  dim.dim=dim;
  dim.fim=tmpim2;
  dim.dimi=tmpim4;
  dim.fname=fname;
  dim.chname=chName;
  dim.parms=parms;
  dim.imno=imno;
end;


