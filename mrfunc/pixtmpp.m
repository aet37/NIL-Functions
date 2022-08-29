function out = pixtmpp(slcseqfile,filelength,itypesize,isize,pixel)
%
% Usage ... out = pixtmpp(slcseqfile,filelength,itypesize,isize,pixel)
%
% Makes an array containing an average of the
% temporal response of the pixel of interest
% according to the number
% of cycles recorded. The pixel location must be
% given in [x y] coordinates according to the matlab
% index in the image.
%

pixval=[0];
m=0; n=0;

headersize = 3;
fid = fopen(slcseqfile,'r');
F = fread(fid);
F = setstr(F);
fclose(fid);

for n=1:headersize,
  tmp(n)=F(n);
end;
noimages = str2num(tmp);

for m=1:noimages,
  for n=1:filelength,
    tmpfile(n)=F(n+headersize+(m-1)*filelength);
  end;
  pixval(m)=myfastload(tmpfile,isize,itypesize,pixel);
end;

out = pixval;

