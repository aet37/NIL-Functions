function out=roitmppf(slcseqfile,filelength,nocycles,isize,maskf)
%
% Usage ... out=roitmppf(slcseqfile,filelength,nocycles,isize,maskf)
%
% Faster method of computing the time course of a ROI.
% It must be accompained by the function mskpixls.
% See roitmpp function.
%

tmpim=zeros(isize);
tmpsum=0;
tmpavg=[0];
m=0; n=0;

headersize=3;
fid = fopen(slcseqfile,'r');
F = fread(fid);
F = setstr(F);
fclose(fid);

for n=1:headersize,
  tmp(n)=F(n);
end;
noimages = str2num(tmp);
trialsize = noimages/nocycles;
maskwt=0;
masksize=size(maskf);
for n=1:masksize(1), maskwt=maskwt+maskf(n,3); end;

for m=1:noimages,
  for n=1:filelength,
    tmpfile(n)=F(n+headersize+(m-1)*filelength);
  end;
  tmpim=readim(tmpfile,isize);
  for o=1:masksize(1),
    tmpsum=tmpsum+maskf(o,3)*tmpim(maskf(o,1),maskf(o,2));
  end;
  tmpavg(m)=tmpsum/maskwt;
  tmpsum=0;
end;

out=tmpavg;
