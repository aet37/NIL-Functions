function y=mykmeans(x,k,labelim,dist_str)
% Usage ... y=mykmeans(x,k,labelim,distance_type)
%
% x data assumed to be in columns (2D data)
% labelim is a labeled image if available
% default distance is correlation

do_smaller=1;


if ~exist('dist_str'), dist_str='correlation'; end;
if ~exist('labelim'), labelim=[]; end;

if ~isempty(labelim), if max(labelim(:))<=1,
  disp('  no labels in labelim found, inserting indeces');
  labelim(find(labelim))=find(labelim);
end; end;

if length(size(x))==3,
  disp('  x is 3D, attempting to use labelim to reshape to 2D');
  if isempty(labelim), labelim=ones(size(x(:,:,1))); end;
  tmpi=find(labelim>0);
  tmpx=zeros(size(x,3),length(tmpi));
  for mm=1:size(x,3), tmpim=x(:,:,mm); tmpx(mm,:)=tmpim(tmpi); end;
  x=tmpx;
  clear tmpx
end;


for nk=1:length(k),  

  [cl_ii,tmp]=kmeans(x',k(nk),'distance',dist_str);

  for mm=1:k(nk),
    tmpii=find(cl_ii==mm);
    if mm==1,
      xp=x(:,tmpii);
    else,
      xp=[xp x(:,tmpii)];
    end;
    xm(:,mm)=mean(x(:,tmpii),2);
    clear tmps
    for nn=1:length(tmpii),
      tmps(:,nn)=x(:,tmpii(nn))-xm(:,mm);
      [tmptmp,tmptmpp]=corrcoef(x(:,tmpii(nn)),xm(:,mm));
      tmpr(nn)=tmptmp(1,2);
      tmpp(nn)=tmptmpp(1,2);
    end;
    ki{mm}=tmpii;
    xr{mm}=tmpr;
    xr_p{mm}=tmpp;
    xra(mm)=mean(tmpr);
    xrs(mm)=std(tmpr);
    xs2(mm)=mean(tmps(:,nn).*tmps(:,nn));
    if ~isempty(labelim),
      tmpim=zeros(size(labelim));
      for nn=1:length(tmpii),
        tmpim(find(labelim==tmpii(nn)))=mm;
      end;
      klim(:,:,mm)=tmpim;
    end;
  end;

  if (do_smaller)&(length(xp)<1000), do_smaller=0; end;
  if ~do_smaller, [xc,xp]=corrcoef(xp); else, xc=[]; end;
  [xmc,xmp]=corrcoef(xm);

  if length(k)>1,
    y{nk}.cli=cl_ii;
    y{nk}.ki=ki;
    y{nk}.xm=xm;
    y{nk}.xr=xr;
    y{nk}.xr_p=xr_p;
    y{nk}.xra=xra;
    y{nk}.xrs=xrs;
    y{nk}.xs2=xs2;
    y{nk}.xmc=xmc;
    y{nk}.xmp=xmp;
    if do_smaller, y{nk}.xc=[]; else, y{nk}.xc=xc; end;
    if ~isempty(labelim), y{nk}.klim=klim; y{nk}.kim=sum(klim,3); end;
  else,
    y.cli=cl_ii;
    y.ki=ki;
    y.xm=xm;
    y.xr=xr;
    y.xr_p=xr_p;
    y.xra=xra;
    y.xrs=xrs;
    y.xs2=xs2;
    y.xmc=xmc;
    y.xmp=xmp;
    if do_smaller, y.xc=[]; else, y.xc=xc; end;
    if ~isempty(labelim), y.klim=klim; y.kim=sum(klim,3); end;
  end;
  
  clear cl_ii tmp tmpii xp xm tmp* ki xr* xs* klim xc xp xmc xmp
end;

