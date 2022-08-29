function sl_writediff(path,slno,nims,info)
% Usage ... sl_writediff(path,slno,nims,info)
% 
% this function expects the files in sequence (alternated)!
% does linear linterpolation of the missing data to do difference
%  at every temporal frame collected
% data written as float , of 1-2 form

% data scaling factor
AMPF=10;

dsl=zeros([info(1:2)]);

for m=2:nims-1,
  disp(sprintf('Calculating im# %d',m));
  sl1=getslim(path,slno,m-1,info);
  sl2=getslim(path,slno,m,info);
  sl3=getslim(path,slno,m+1,info);
  sle=0.5*sl1+0.5*sl3;
  if rem(m,2),
    dsl=(sl2-sle);
  else,
    dsl=(sle-sl2);
  end;
  filename=sprintf('%sdiff.sl%d.%03d',path,slno,m);
  writeim(filename,round(AMPF*dsl));
end;

% now to write first
disp('Calculating im# 1');
sl1=getslim(path,slno,nims,info);
sl2=getslim(path,slno,1,info);
sl3=getslim(path,slno,2,info);
dsl=(sl2-sle);
filename=sprintf('%sdiff.sl%d.%03d',path,slno,1);
writeim(filename,round(AMPF*dsl));

% ... and last
disp(['Calculating im# ',int2str(nims)]);
sl1=getslim(path,slno,nims-1,info);
sl2=getslim(path,slno,nims,info);
sl3=getslim(path,slno,1,info);
dsl=(sle-sl2);
filename=sprintf('%sdiff.sl%d.%03d',path,slno,nims);
writeim(filename,round(AMPF*dsl));
%writeim(filename,dsl,'float');


