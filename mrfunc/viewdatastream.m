function f=viewdatastream(data,t,window,overlap)
% Usage ... f=viewdatastream(data,t,window,overlap)
%
% Views a data stream in a window of length n samples
% with overlap of n samples. The default overlap is
% about 10% of the window. The default window is 10%
% of the data stream.

datalen=length(data);

if nargin<2, t=[1:datalen]; end;
if nargin<3, window=floor(.1*datalen); end;
if nargin<4, overlap=floor(.1*window); end;

datapieces=ceil(datalen/window);
inside=1;
pos=1;
while (inside),
  plot(t(pos:pos+window),data(pos:pos+window)) 
  axis([t(pos) t(pos+window) min(data(pos:pos+window)) max(data(pos:pos+window))])
  pause
  pos=pos+window-overlap;
  if ((pos+window-overlap)>datalen),
    inside=0;
  end; 
end;
