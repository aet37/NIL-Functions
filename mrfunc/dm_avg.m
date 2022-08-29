function f=dm_avg(dmfile,slc,volrange)
% Usage ... f=dm_avg(dmfile,slice,volrange)
%
% Calculates the average of the set of
% images in the slice. Volrange is an optional
% parameter. It determines only the std in the
% range specified by [a b].
% Volrange option not yet functional...

dmfid=fopen(dmfile,'r');
if dmfid<3,
  error('Could not open dmfile!');
end;

dminfo=getdmodinfo(dmfid);

imsum=0;
for m=1:dminfo(8),
  imsum=imsum+getdmodim(dmfid,m,1);
end;
f=(1/dminfo(8))*imsum;

fclose(dmfid);
