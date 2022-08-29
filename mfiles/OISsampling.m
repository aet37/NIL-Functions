function [tsample,tdesired,ii1,ii2]=OISsampling(fname,fps)
% Usage ... [tsample,tdesired]=OISsampling(fname,fps)

if nargin<2,
  fps=30;
end;

fid=fopen(fname,'r','l');
if (fid<3),
  error(sprintf('Could not open file %s',fname));
end;

tsample=fread(fid,inf,'double');
tdesired=[1:length(tsample)]*(1/fps);

tsample=tsample(:)/1000;
tdesired=tdesired(:);

tdiff=diff(tsample);
tdiff=[tsample(1);tdiff];
terr=tsample-tdesired;

dtol=1.3;
%tdiff(1:10)
%[dtol/fps 1/(dtol*fps)]
ii1=find(tdiff>dtol/fps);
ii2=find(tdiff<1/(dtol*fps));
ii1len=length(ii1);
ii2len=length(ii2);
disp(sprintf('  #errors= %d (%d,%d)',ii1len+ii2len,ii1len,ii2len));

if (nargout==0),
  subplot(211)
  plot(tdesired,tsample)
  ylabel('Sampled Time (s)')
  xlabel('Desired Time (s)')
  title(sprintf('Final error = %f s',terr(end)));
  axis('tight'); grid('on'); 
  subplot(212)
  plot(terr)
  ylabel('Time error (s)')
  xlabel('Frame#')
  axis('tight'); grid('on'); 
end;

