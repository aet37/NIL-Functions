function [ystd,yavg,ycon]=imstd(x,neigh,con)
% Usage ... [ystd,yavg,ycon]=imstd(x,neigh,con)
%
% neigh = neighborhood size to calc image stdev
% con = 1 returns ycon=ystd./yavg

if nargin<2, neigh=5; end;
if nargin<3, con=0; end;

neigh_lef=ceil(neigh/2)-1;
neigh_rig=floor(neigh/2);
neigh_top=ceil(neigh/2)-1;
neigh_bot=floor(neigh/2);

imdim=size(x);

for mm=1:imdim(1),
  tmplef=mm-neigh_lef;
  tmprig=mm+neigh_rig;
  if (tmplef<1), tmplef=1; end;
  if (tmprig>imdim(1)), tmprig=imdim(1); end;
  for nn=1:imdim(2),
    tmptop=nn-neigh_top;
    tmpbot=nn+neigh_bot;
    if (tmptop<1), tmptop=1; end;
    if (tmpbot>imdim(2)), tmpbot=imdim(2); end;
    subim=x(tmplef:tmprig,tmptop:tmpbot);
    yavg(mm,nn)=mean(subim(:));
    ystd(mm,nn)=std(subim(:));
    %yloc(mm,nn,:)=[tmplef tmprig tmptop tmpbot];
  end;
end;

if (con),
  ycon=ystd./yavg;
else,
  ycon=zeros(size(ystd));
end;

if nargout==0,
  if (con),
    show(ycon)
  else,
    show(imstd)
  end;
end;

%% alternate method
%kk=ones(neigh);
%x1n=conv2(ones(size(x)),kk,'same');
%x1a=conv2(x,kk,'same')./x1n;
%x1s=conv2((x1a-x).^2,kk,'same')./x1n;
%x1s=sqrt(x1s);
%if con, ycon=x1s./x1a; end;


