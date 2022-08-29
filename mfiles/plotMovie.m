function plotMovie(tt,yy,window,skip,fname)
% Usage ... plotMovie(tt,yy,window,skip,fname)

do_movie=0;
do_pause=0;
if exist('fname','var'), 
  if ischar(fname),
    do_movie=1;
  else,
    do_pause=1;
    pausetime=fname;
  end;
end;

yavg=mean(yy,1);
ystd=std(yy,[],1);

stdf=4;

ystep=2*stdf*mean(ystd)*ones(size(yy,2),1);
yminmax=[0-ystd(1)*stdf*2 sum(ystep)+ystd(end)*stdf];

for mm=1:size(yy,2),
  yplot(:,mm)=(mm-1)*ystep(mm)+(yy(:,mm)-yavg(mm));
end

dt=tt(2)-tt(1);
window=floor(window/dt);
skip=floor(skip/dt);

nsteps=floor((size(yy,1)-window)/skip)-1;
disp(sprintf('  #steps= %d',nsteps));

if do_movie,
    vid=VideoWriter(fname,'MPEG-4');
    if nsteps>100, datavid.FrameRate=30; else, datavid.FrameRate=5; end;    %7,10,20,30
    vid.Quality=100;
    open(vid);
end

for mm=1:nsteps,
  if mm*skip<=window,
    tmpii=[1:mm*skip];
    plot(tt(tmpii),yplot(tmpii,:)),
    xlim([tt(1) tt(window)]), ylim(yminmax),
    nn=mm;
  else,
    tmpii=[1:window]+(mm-nn-1)*skip;  
    plot(tt(tmpii),yplot(tmpii,:)),
    xlim([tt(tmpii(1)) tt(tmpii(end))]), ylim(yminmax),
  end
  drawnow,
  if do_pause,
    pause(pausetime),
  end
  if do_movie,
    currFrame=getframe(gcf);
    writeVideo(vid,currFrame)
  end
end

if do_movie,
    close(vid);
end

