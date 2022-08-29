function f=match_pix_map(x_list,pix_list,im_size,operator,value)
% Usage ... f=match_pix_map(x_list,pix_list,im_size,operator,value)
%
% x_list=data (vector), pix_list=corresponding pixels(2 col)
% x_list and pix_list must be the same length
% x_list must be a vector and pix_list is a 2col vector

if nargin<3,
  tmp=max(log2(pix_list));
  imsize=[2^(floor(tmp(1))) 2^(floor(tmp(2)))];
end;

im=zeros(im_size);

if nargin<4,
  for m=1:length(x_list),
    im(pix_list(m,1),pix_list(m,2))=x_list(m);
  end;
else,
  for m=1:length(x_list),
    a=0;
    tmpcmd=['if x_list(m)',operator,'value, a=1; else, a=0; end;'];
    eval(tmpcmd);
    if a,
      im(pix_list(m,1),pix_list(m,2))=1;
    end;
  end;
end;

f=im;

if nargout==0,
  show(im');
end;