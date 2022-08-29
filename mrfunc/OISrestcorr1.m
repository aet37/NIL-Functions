function y=OISrestcorr1(stk,tcmask,allflag)
% Usage ... y=OISrestcorr1(stk,tcmask,allflag)

maski=find(tcmask);
[tmpi,tmpj]=find(tcmask);	% transpose this?
if allflag,
  y=zeros(size(stk,1)*size(stk,2),length(maski));
else,
  y=zeros(length(maski),length(maski));
end;

for mm=1:length(maski),
  tmptc=squeeze(stk(tmpi(mm),tmpj(mm),:));
  tmpcor=OIS_corr2(stk,tmptc(:));
  if allflag,
    y(:,mm)=tmpcor(:);
  else,
    y(:,mm)=tmpcor(maski);
  end;
end;

