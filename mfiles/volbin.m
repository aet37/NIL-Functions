function y3=volbin(x,bsize)
% Usage y=volbin(x,binsize)

x=squeeze(x);
xsz=size(x);

if bsize==1;
  y2=x;
  if nargout==0, show(y2), clear y2, end;
  return;
end

if length(bsize)==1,
  bsize=bsize*ones(1,length(xsz)); 
elseif length(bsize)==2,
  bsize=[bsize ones(1,length(xsz)-1)];
end;

imdim=size(x);
for mm=1:length(xsz),
  iend(mm)=floor(xsz(mm)/bsize(mm))*(bsize(mm));
end

if length(xsz)==4,

y=x(1:bsize(1):iend(1),:,:,:);
%[bsize iend1 iend2],
if bsize(1)>1, for mm=2:bsize(1),
  y=y+x(mm:bsize(1):iend(1),:,:,:);
end; end;
y=y/bsize(1);
y2=y(:,1:bsize(2):iend(2),:,:);
if bsize(2)>1, for mm=2:bsize(2),
  y2=y2+y(:,mm:bsize(2):iend(2),:,:);
end; end;
y2=y2/bsize(2);
y3=y2(:,:,1:bsize(3):iend(3),:);
if bsize(3)>1, for mm=2:bsize(3),
  y3=y3+y2(:,:,mm:bsize(3):iend(3),:);
end; end;
y3=y3/bsize(3);    
y4=y3(:,:,:,1:bsize(4):iend(4));
if bsize(4)>1, for mm=2:bsize(4),
  y4=y4+y3(:,:,:,mm:bsize(4):iend(4));
end; end;
y4=y4/bsize(4); 

clear y y2 y3

y3=y4;

clear y4


else,
    
y=x(1:bsize(1):iend(1),:,:);
%[bsize iend1 iend2],
if bsize(1)>1, for mm=2:bsize(1),
  y=y+x(mm:bsize(1):iend(1),:,:);
end; end;
y=y/bsize(1);
y2=y(:,1:bsize(2):iend(2),:);
if bsize(2)>1, for mm=2:bsize(2),
  y2=y2+y(:,mm:bsize(2):iend(2),:);
end; end;
y2=y2/bsize(2);
y3=y2(:,:,1:bsize(3):iend(3));
if bsize(3)>1, for mm=2:bsize(3),
  y3=y3+y2(:,:,mm:bsize(3):iend(3));
end; end;
y3=y3/bsize(3);

end
