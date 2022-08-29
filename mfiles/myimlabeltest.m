function [y,yim,yim2,yavg,ystd]=myimlabeltest(sim,thr,label,mask)
% Usage ... [y,yim,yim2,yavg,ystd]=myimlabeltest(testim,thr,labelim,masks_ibin)
%
% maski must be organized in columns and it should be binary

yim=zeros(size(mask));

for oo=1:size(sim,3),
  for nn=1:max(label(:)),
    [tmpi,tmpj]=find(label==nn);
    if isempty(tmpi),
      yavg(nn,oo)=0;
      ystd(nn,oo)=0;
    else,
      tmpval=sim(tmpi,tmpj,oo);
      yavg(nn,oo)=mean(tmpval(:));
      ystd(nn,oo)=std(tmpval(:));
    end;
  end;
end;

ythr=yavg>thr;
y=zeros(size(mask,1),size(mask,2),size(sim,3));
yim=zeros(size(label,1),size(label,2),size(sim,3));

for oo=1:size(sim,3),
  tmpim=zeros(size(label));
  for mm=1:size(mask,2),
    tmpii=find(mask(:,mm));
    if ~isempty(tmpii),
      y(tmpii,mm,oo)=yavg(tmpii,oo)>thr;
      for nn=1:length(tmpii), 
        [tmpij]=find(label==tmpii(nn)); 
        if ~isempty(tmpij), tmpim(tmpij)=tmpim(tmpij)+double(yavg(tmpii(nn))>thr); end;
      end;
    end;
  end;
  yim(:,:,oo)=tmpim;
end;

yim2=zeros(size(label,1),size(label,2),size(mask,2));
for mm=1:size(mask,2),
  tmpim=zeros(size(label));
  tmpii=find(mask(:,mm));
  if ~isempty(tmpii),
    for nn=1:length(tmpii),
      [tmpij]=find(label==tmpii(nn));
      if ~isempty(tmpij), for oo=1:size(sim,3), tmpim(tmpij)=tmpim(tmpij)+double(yavg(tmpii(nn),oo)>thr); end; end;
    end;
  end;
  yim2(:,:,mm)=tmpim;
end;

if nargout==1,
  ytmp.y=y;
  ytmp.yavg=yavg;
  ytmp.ystd=ystd;
  ytmp.yim=yim;
  ytmp.yim2=yim2;
  clear y
  y=ytmp;
end;
  
if nargout==0,
  figure(1), clf,
  showmany(yim)
  disp('fig1: #items for all mask for each image')
  figure(2), clf,
  showmany(yim2)
  disp('fig2: #items across images for each mask')
end;

