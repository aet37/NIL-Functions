function out = roitmpp(slcseqfile,filelength,nocycles,isize,mask)
%
% Usage ... out = roitmpp(slcseqfile,filelength,nocycles,isize,mask)
%
% Makes an array containing an average of the
% temporal response of the area of interest
% contained in the mask according to the number
% of cycles recorded. The sizes of the image and
% the mask must match.
%

nomaskelements=0;
tmpim=zeros(isize);
resim=zeros(isize);
avgact=[0];
tmpsum=0;
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
trialsize = noimages/nocycles;
for jj=1:isize(1), for kk=1:isize(2),
  if ( mask(jj,kk)~=0 ), nomaskelements=nomaskelements+mask(jj,kk); end;
end; end;

for m=1:noimages,
  for n=1:filelength,
    tmpfile(n)=F(n+headersize+(m-1)*filelength);
  end;
  tmpim=readim(tmpfile,isize);
  resim=tmpim.*mask;
  for jj=1:isize(1), for kk=1:isize(2),
    tmpsum = tmpsum + resim(jj,kk);
  end; end;
  avgact(m)=tmpsum/nomaskelements;
  tmpsum=0;
end;

out = avgact;

