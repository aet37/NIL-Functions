function [locs,mask]=getpix(im,dilate_flag)
% Usage ... [locs,mask]=getpix(im,dilate)
%
% Pseudo-interactive function to select pixel locations from an image
% Note that locs are returned in the same way as ginput

if nargin==1, dilate_flag=0; end;
if dilate_flag, dilatew=abs(floor(dilate_flag)); dilate_flag=1; end;

mycolor=[1 0 0];
mygray=[[0:254]' [0:254]' [0:254]']/254;
mymap=[mygray;mycolor];

tmpim=im-min(im(:));
tmpim=tmpim/max(tmpim(:));
tmpim=floor(tmpim*254+1);
tmpim_orig=tmpim;


clf,
disp('  select pixel location, press right-button to exit...')
%disp('  press enter to begin...'); pause;


mask=zeros(size(im));
found=0; cnt=0;
while(~found),
  image(tmpim), colormap(mymap), axis('image'), grid('on'), drawnow,
  [tmpi,tmpj,tmpbutton]=ginput(1);
  tmpi=round(tmpi); tmpj=round(tmpj);
  if tmpbutton==3, found=1; break; end;
  if isempty(tmpi),
    found=1;
  else,
    if (mask(tmpj,tmpi)==1),
      mask(tmpj,tmpi)=0;
    else,
      cnt=cnt+1;
      mask(tmpj,tmpi)=1;
      locs(cnt,:)=[tmpi tmpj];
    end;
  end;
  if dilate_flag,
    mask2=imdilate(mask,ones(dilatew,dilatew)); 
  else,
    mask2=mask;
  end;
  tmpim=tmpim_orig;
  tmpim(find(mask2))=256;
end;

% last check
cnt=0;
[tmpmj,tmpmi]=find(mask);
for mm=1:size(locs,1),
  found=0;
  for nn=1:length(tmpmj),
    if ((locs(mm,1)==tmpmi(nn))&(locs(mm,2)==tmpmj(nn))),
      found=1;
    end;
  end;
  if (found), cnt=cnt+1; locs_final(cnt,:)=locs(mm,:); end;
end;

locs=locs_final;

