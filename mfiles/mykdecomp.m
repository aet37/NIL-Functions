function y=mykdecomp(x,nk,mask,rf_ndeep)
% Usage ... y=mykdecomp(x,nk,mask,rf_ndeep)
%
% x is the data, nk is the number of clusters, mask for the data
% rf_ndeep option is in development

x=squeeze(x);
xdim=size(x);

if nargin<4, rf_ndeep=[]; end;
if isempty(rf_ndeep), rf_ndeep=0; end;

do_reshape=0;
if length(xdim)==3, do_reshape=1; end;


if do_reshape,
  disp('  reshaping...');
  if nargin<3, mask=ones(xdim(1),xdim(2)); end;
  maski=find(mask);
  tmplabel=zeros(xdim(1:2));
  tmplabel(maski)=[1:length(maski)];
  if length(maski)<prod(xdim(1:2)), do_reshape=2; end;
  x_orig=x;
  x=reshape(x_orig,[prod(xdim(1:2)) xdim(3)]);
  x=x(maski,:);
  disp(sprintf('  calculating k-means (%d,%d)...',size(x)));
  tmpk=mykmeans(x',nk,tmplabel);
  
  disp('  assigning labels...');
  tmplabel0=zeros(xdim(1),xdim(2),length(tmpk));
  for mm=1:length(tmpk),
    tmplabel1=zeros(xdim(1),xdim(2));
    if length(tmpk)==1,
      for nn=1:size(tmpk.klim,3),
        %tmplabel1(maski)=tmplabel1(maski)+tmpk{mm}.klim(:,1,nn);
        tmplabel1(maski(tmpk.ki{nn}))=nn;
      end;
    else,
      for nn=1:size(tmpk{mm}.klim,3),
        tmplabel1(maski(tmpk{mm}.ki{nn}))=nn;
        %tmplabel1(maski)=tmplabel1(maski)+tmpk{mm}.klim(:,1,nn);
      end;
    end;
    tmplabel0(:,:,mm)=tmplabel1;
  end;
  tmpks=mykmeans_sup(tmpk,x_orig,tmplabel);
  
  tmpklim=zeros(xdim(1:2));
  if length(tmpk)==1,
    tmpklim=squeeze(sum(tmpk.klim,3));
  else,
    tmpklim=squeeze(sum(tmpk{end}.klim,3));
  end;

else,

  tmplabel=[1:size(x,2)];
  tmpk=mykmeans(x,nk,tmplabel);
  %tmpks=mykmeans_sup(tmpk,x,tmplabel,1.5);
  tmpks=mykmeans_sup(tmpk,x,tmplabel);
  tmpklim=sum(squeeze(tmpk.klim),2);
end;

y.labelim=tmplabel;
if exist('mask','var'), y.mask=mask; end;
y.k=tmpk;
y.ks=tmpks;
y.klim=tmpklim;

if nargout==0,
  imagesc(tmpklim), colormap('jet'),
end;

