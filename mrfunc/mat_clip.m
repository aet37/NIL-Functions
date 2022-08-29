function [f,g,h]=mat_clip(matrx,npieces,norm)
% Usage ... [f,g,h]=mat_clip(matrix,npieces,norm)
%
% Clips a matrix were the data is in columns into a
% series of column data, but but shorter by the number
% pieces. The new data is in f, the mean of the data
% in is g and the standard deviation of the data is in
% h. Norm performs normalization of the data.

if ~exist('norm'), norm=0; end;

[mr,mc]=size(matrx);
disp(['Matrix: ',int2str(mr),' x ',int2str(mc),' detected...']);

psize=floor(mr/npieces);
disp(['The new size of each piece is: ',int2str(psize)]);

cnt=0;
for m=1:mc,
  for n=1:npieces,
    cnt=cnt+1;
    tmp=matrx(1+(n-1)*psize:n*psize,m);
    f(:,cnt)=tmp;
  end;
end;

if norm,
  if (length(norm)~=2),
    norm(1)=1;
    norm(2)=psize;
  end;
  for m=1:mc*npieces,
    tmp=mean(f(norm(1):norm(2),m));
    f(:,m)=(f(:,m)-tmp)./tmp;
  end;
end;

g=mean(f');
h=std(f');
