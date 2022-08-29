function [freq,x,tc]=getpixdist(filename,poi,slc)
% Usage ... [freq,x,tc]=getpixdist(filename,poi,slc)

tmptc=fasttcload(filename,'all',slc,poi,'dmod');
[f,ax]=imhist(tmptc);

freq=f;
x=ax;
tc=tmptc;