function showlsm(fname,imno,medfilt)
% Usage ... showlsm(fname,imno,medfilt)

if nargin<3, medfilt=[]; end;
if nargin<2, imno=1; end;

if isempty(medfilt),
  medfilt_flag=0;
else,
  medfilt_flag=1;
end;

blue_flag=1; green_flag=1; red_flag=1;

for nn=imno,

stk1=tiffread2c(fname,imno(nn));

if isempty(stk1.blue), blue_flag=0; end;
if isempty(stk1.green), green_flag=0; end;
if isempty(stk1.red), red_flag=0; end;

iim=[0 0 0];
if (blue_flag),
  blueim=double(stk1.blue);
  if (medfilt_flag),
    blueim=medfilt2(blueim,medfilt);
  end;
  iim(1)=1;
end;
if (green_flag),
  greenim=double(stk1.green);
  if (medfilt_flag),
    greenim=medfilt2(greenim,medfilt);
  end;
  iim(2)=1;
end;
if (red_flag),
  redim=double(stk1.red);
  if (medfilt_flag),
    redim=medfilt2(redim,medfilt);
  end;
  iim(3)=1;
end;

if sum(iim)==0,
  disp('no images to display');
elseif sum(iim)==1,
  if (blue_flag), show(blueim), end;
  if (green_flag), show(greenim), end;
  if (red_flag), show(redim), end;
elseif sum(iim)==2,
  cnt1=0;
  for mm=1:length(iim),
    if iim(mm)==1,
      cnt1=cnt1+1;
      eval(sprintf('subplot(12%d),',cnt1));
      if mm==1, show(blueim), end;
      if mm==2, show(greenim), end;
      if mm==3, show(redim), end;
    end;
  end;
else,
  subplot(221)
  show(blueim),
  subplot(222)
  show(greenim),
  subplot(223)
  show(redim)
end;

if length(imno)>1, pause, end;

end;


