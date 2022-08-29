function im_out=myimwrite(im,fname,opt1,opt2,opt3,opt4)
% Usage ... myimwrite(im,fname,opt1,opt2,opt3,opt4)

nopts=nargin-4;

im_min=min(min(im));
im_max=max(max(im));
im_out=(im-im_min)/(im_max-im_min);
im_out=round(im_out*255);
im_out=uint8(im_out)';

if nopts>0,
  imcmd=sprintf('imwrite(im_out,fname');
  for m=1:nopts, 
    % need to figure this out
  end; 
  imcmd=sprintf('%s);',imcmd);
else,
  imwrite(im_out,fname);
end;

if (nargout==0), 
  clear im_out
end;
