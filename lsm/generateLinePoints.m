function y=generateLinePoints(im)
% Usage ... y=generateLinePoints(im)

show(im), drawnow,
disp('  select points, right-click when done...'),

runloc=[];
locim=zeros(size(im));
cnt=1; cnt2=0;
found=0;
while (~found),
  [xx,yy,bb]=round(ginput(1));
  if bb==1,
    if locim(xx,yy)==0,
      locim(xx,yy)=1;
    else,
      locim(xx,yy)=0;
    end;
    if cnt>=2,
      for mm=1:cnt-1,
        if (runloc(mm,1)==xx)&(runloc(mm,2)==yy),
          % no need to add
        else,
          runloc(cnt,:)=loc;
          cnt=cnt+1;
        end;
      end;
    end;
    show(locim), drawnow,
  else,
    found=1;
  end;
end;

% draw lines

