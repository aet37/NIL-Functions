function y=mygpix(imdim)
% Usage ... y=mygpix(imdim)

if length(imdim)>2, imdim=size(imdim); end;

cnt=0;
tmpdone=0;
while(~tmpdone),
  [tmplocx,tmplocy,tmpbut]=ginput(1);
  tmplocx=floor(tmplocx); tmplocy=floor(tmplocy);
  tmpgood=1;
  if (tmplocx<0)|(tmplocx>imdim(2)),
    tmpdone=1;
  elseif (tmplocy<0)|(tmplocy>imdim(1)),
    tmpdone=1;
  end;
  if tmpbut==3, tmpgood=0; end;
  if tmpgood&(~tmpdone),
    cnt=cnt+1;
    y(cnt,:)=[tmplocx tmplocy];
  end;
end;

