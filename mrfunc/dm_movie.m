function M=dm_movie(filename,slc)
% Usage ... M=dm_movie(filename,slice)

dm_fid=fopen(filename,'r');

dm_info=getdmodinfo(dm_fid);

M = moviein(dm_info(8));

for j=1:dm_info(8),
  show(getdmodim(dm_fid,j,slc)');
  M(:,j) = getframe;
end;

movie(M)

fclose(dm_fid);
