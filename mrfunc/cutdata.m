fid = fopen('/home/vazquez/studies/vis4/RespRun1.txt','r')
a = fscanf(fid,'%f',43750);
clipper
fid2 = fopen('/home/vazquez/studies/vis4/RespRun1.Cut.txt','w')
for n=1:length(b),fprintf(fid2,'%f\n',b(n));end;
fclose(fid2);
fclose(fid);
