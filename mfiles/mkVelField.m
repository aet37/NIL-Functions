function im=tmp_mkVelField(imsize,locs,vel,scale)
% Usage ... y=tmp_mkVelField(imsize,locs,vel,scale)

if length(imsize)>2, imsize=size(imsize); end;
im=zeros(imsize);

for mm=1:length(vel),
  tmpy=round(vel(mm)*scale);
  tmpx1=locs(mm,2); 
  tmpy1=locs(mm,1);
  tmpy2=tmpy1+tmpy;
  if tmpy2>imsize(2), tmpy2=imsize(2); end;
  if tmpy2<1, tmpy2=1; end;
  if tmpy2>tmpy1,
    im(tmpx1,tmpy1:tmpy2)=mm;
  else,
    im(tmpx1,tmpy2:tmpy1)=mm;
  end;
  %show(im), drawnow, pause,
end;

