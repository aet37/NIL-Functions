function f=loadtc2(seqfile,filelength,isize,pixlist)
% Usage ... f=loadtc2(seqfile,filelength,isize,pixlist)
% Loads timecourses in pixlist from the specified images in seqfile.
% The first two columns in pixlist must be the (r,c) of pixels.
% More explicitly they must be the coordinates obtained from the
% transposed displayed image!

headersize=3;
[rp,cp]=size(pixlist);
if (rp<cp), pixlist=pixlist'; end;

fid = fopen(seqfile,'r');
F = fread(fid);
F = setstr(F);
fclose(fid);
for n=1:headersize,
  tmp(n)=F(n);
end;
noimages = str2num(tmp);

tc=zeros([rp noimages]);
for m=1:noimages,
  for n=1:filelength,
    tmpfile(n)=F(n+headersize+(m-1)*filelength);
  end;
  tc(:,m)=myfastload(tmpfile,isize,2,pixlist);
end;

f=tc;
