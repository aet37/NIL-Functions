function dsl=sl_diff(path,slno,nims,info)
% Usage ... y=sl_diff(path,slno,nims,info)
% 
% this function expects the files in sequence (alternated)!
% done as 1-2 

dsl=zeros([info(1:2)]);

for m=1:nims/2,
  disp(sprintf('Calculating pair # %d',m));
  sl1=getslim(path,slno,2*m-1,info);
  sl2=getslim(path,slno,2*m,info);
  dsl=dsl+(sl1-sl2);
end;
dsl=(2/nims)*dsl;

