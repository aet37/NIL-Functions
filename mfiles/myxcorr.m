function y=myxcorr(xmat,nkeep)
% Usage ... y=myxcorr(xmat,nkeep)
%
% Calculates the cross-correlation between the columns of xmat

verbose_flag=0;

if nargin==1, nkeep=2*size(xmat,1)-1; end;

if verbose_flag, disp(sprintf('  generating variable...')); end;
y=zeros(size(xmat,2),size(xmat,2),2*size(xmat,1)-1);
%size(y),

if verbose_flag, disp(sprintf('  analyzing...')); end;
for mm=1:size(xmat,2),
  for nn=1:size(xmat,2),
    y(mm,nn,:)=xcorr(xmat(:,mm),xmat(:,nn));
  end;
end;

if nkeep<(size(y,3)-10),
  y=y(:,:,[0:nkeep-1]+round(size(y,3)/2));
end;

