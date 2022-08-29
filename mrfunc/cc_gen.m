
function [ccvals] = cc_gen(file,wvfrm,trange,xrange,zrange);
%  General t-test
%  Usage - tvals = ttest_gen(file, waveform,trange, xrange, zrange);
%  returns t-values for each slice in file,
%  assumes the first indexes of file are the x,y dimensions
%  and the last index is the z-dimension
%  Can optionally specify the xrange and zrange to use

dims=size(file);

xsize=dims(1);
ysize=dims(2);
tsize=dims(3);
zsize=dims(length(dims));

xr=1:xsize;
yr=1:ysize;
tr=1:tsize;
zr=1:zsize;


if (exist('xrange'))
	xsize = length(xrange);
	xr=xrange;
end;

if (exist('zrange'))
	zsize = length(zrange);
	zr = zrange;
end;

if (exist('trange'))
	tsize = length(trange);
	tr= trange;
end;

ccvals=zeros(xsize,ysize,zsize);

if (length(wvfrm) ~= length(tr))
	error('Correlation waveform must be same length as timecourse')
end;


for i=xr
  for j=yr
	for z=zr

		tmcrs=squeeze(file(i,j,tr,z));

		p=corrcoef(wvfrm,tmcrs);

		r=p(1,2);

		ccvals((i-xr(1)+1),j,(z-zr(1)+1)) = r;
	end;
   end;
end;

