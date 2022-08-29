function [yp,ls]=getLineProfile1(data,locations,parms)
% Usage ... [y,line]=getLineProfile1(data,locations,parms)
%
% data is the 3D images
% locations are { {[x1 y1; x2 y2]}, {[...]}, ...} pair for the line
% parms = [nwid]
%
% Ex. [line,lstruc]=getLineProfile1(data(:,:,2,:),'select');


do_select=0;
if ischar(locations),
    if strcmp(locations,'select'), do_select=1; end
end

if nargin<3, parms=[4 0.2]; end

ny=parms(1);
dxy=parms(2);

data=squeeze(data);

im1=data(:,:,1);

if do_select,
  clear locations
  cnt=0;
  tmp_ok=0;
  msk1=zeros(size(im1));
  while(~tmp_ok),
    disp(sprintf('  select cross-section (two pixel locations)...'));
    figure(1), clf,
    show(im_super(im1,msk1,0.3)), drawnow,
    p1=round(ginput(2));
    msk1=pixtoim([p1(:,2) p1(:,1)],size(im1));
    show(im_super(im1,msk1,0.5)), drawnow,
    tmpin=input('  location ok? [1=yes, 9/enter=yes+done, 0=no]: ');
    if isempty(tmpin), tmpin=9; end;
    if tmpin==1,
      cnt=cnt+1;
      locations{cnt}=p1;
    elseif tmpin==9,
      cnt=cnt+1;
      locations{cnt}=p1;
      tmp_ok=1;
    end;
  end;
  %locations
  disp(sprintf('  #lines= %d',length(locations)));
elseif isstruct(locations),
    tmploc=locations;
    clear locations
    for nn=1:length(tmploc), locations{nn}=tmploc(nn).loc; end;
end
    
for nn=1:length(locations),
  p1=locations{nn};
  aloc(nn,:)=mean(p1);
  dloc(nn,:)=diff(p1);
  dd(nn)=sqrt(sum(dloc(nn,:).^2));
  dang(nn)=atan(dloc(nn,2)/dloc(nn,1))*(180/pi);
  rw=[ny ceil(dd(nn))];

  [tmp1,tmpmsk1]=getRectImGrid(im1,rw,dxy,[aloc(nn,2) aloc(nn,1)],dang(nn));
  y1p{nn}=mean(tmp1,2)';
  
  ls(nn).loc=locations{nn};
  ls(nn).rw=rw;
  ls(nn).dxy=dxy;
  ls(nn).aloc=[aloc(nn,2) aloc(nn,1)];
  ls(nn).ang=dang(nn);
  ls(nn).mask=tmpmsk1;
end;

for mm=1:size(data,3),
  im=data(:,:,mm);
  for nn=1:length(ls),
    tmp2=getRectImGrid(im,ls(nn));
    yp{nn}(:,mm)=mean(tmp2,2)'; 
  end;
end

if nargout==0,
  figure(1), clf,
  showmany(yp)
  figure(2), clf,
  im_overlay4(im1,{ls(:).mask}),
end

    
