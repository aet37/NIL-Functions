function y=imMotApply(xx,ims,inparms,outparms)
% Usage ... y=imMotApply(xx,ims,inparms,outparms)
%
% inparms=[opt_type(4=2d-xy)]
% outparms=[prectype(4=single)]

ims=squeeze(ims);

if nargin<4, outparms=4; end;
if nargin<3, inparms=4; end;

if outparms(1)==4,
  y=single(zeros(size(ims)));
else,
  y=zeros(size(ims));
end;

imdim=size(ims);
if (length(imdim)==4)&(imdim(end)==length(xx)),
  disp(sprintf('  aligning %d images in %d channels',imdim(4),imdim(3)));
  for mm=1:imdim(4), for nn=1:imdim(3),
    tmpim=double(ims(:,:,nn,mm));
    if inparms(1)==1,
      yc1=imshift2(tmpim,-1*xx(mm,1),-1*xx(mm,2),1);
    elseif inparms(1)==4,
      yc1=imshift2(tmpim,xx(mm,1),xx(mm,2),1);
    elseif inparms(1)==3,
      yc1=imshift2(tmpim,xx(mm,1),xx(mm,2),1);
      yc1=rot2d_f(yc1,xx(mm,3));
    elseif inparms(1)==30,
      yc1=imshift2(tmpim,xx(mm,1),xx(mm,2),1);
      yc1=rot2d_nf(yc1,-1*xx(mm,3));
    else,
      yc1=imshift2(tmpim,xx(mm,1),xx(mm,2),1);
    end;
    if outparms(1)==4,
      y(:,:,nn,mm)=single(yc1);
    else,
      y(:,:,nn,mm)=yc1;
    end;
  end; end;
else,
  for mm=1:size(ims,3),
    tmpim=double(ims(:,:,mm));
    if inparms(1)==1,
      yc1=imshift2(tmpim,-1*xx(mm,1),-1*xx(mm,2),1);
    elseif inparms(1)==4,
      yc1=imshift2(tmpim,xx(mm,1),xx(mm,2),1);
    elseif inparms(1)==3,
      yc1=imshift2(tmpim,xx(mm,1),xx(mm,2),1);
      yc1=rot2d_f(yc1,xx(mm,3));
    elseif inparms(1)==30,
      yc1=imshift2(tmpim,xx(mm,1),xx(mm,2),1);
      yc1=rot2d_nf(yc1,-1*xx(mm,3));
    else,
      yc1=imshift2(tmpim,xx(mm,1),xx(mm,2),1);
    end;
    if outparms(1)==4,
      y(:,:,mm)=single(yc1);
    else,
      y(:,:,mm)=yc1;
    end;
  end;
end;


