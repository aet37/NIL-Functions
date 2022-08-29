function f=getdmodim(filename,vol,slice,info)
% Usage ... f=getdmodim(filename,vol,slice,info)
% This function retrieves the volume in the slice specified.
% Info is optional.

if isstr(filename),
  tmpfid=fopen(filename,'r');
  if tmpfid<3, error('Invalid or inexistent filename!'); end;
else,
  tmpfid=filename;
end;

if nargin==3,
  isize=getdmodinfo(tmpfid);
elseif nargin==4,
  isize=info;
end;

first_rec=isize(1);
xd=isize(2);
yd=isize(3);
pixtype=isize(6);
nsl=isize(7);
nim=isize(8);

if (slice>nsl), error('Invalid Slice!'); end;
if (vol>nim), error('Invalid Image!'); end;
sl=slice; 

if (pixtype==0),
  bksp=1;
  loadstr=['int8'];
elseif (pixtype==2),
  bskp=4;
  loadstr=['float'];
elseif (pixtype==3),
  bskp=4;
  loadstr=['int32'];
elseif (pixtype==8),
  bskp=8;
  loadstr=['double'];
else,
  bskp=2;
  loadstr=['int16'];
end;

tmploc=first_rec+bskp*( (nim*xd*yd*(sl-1))+(xd*yd*(vol-1)) );
tmpstatus=fseek(tmpfid,tmploc,'bof');
if tmpstatus, error('Invalid image location!'); end;
[f,tmpcount]=fread(tmpfid,[xd yd],loadstr);
if tmpcount~=(xd*yd), error('Could not bring entire image'); end;

if isstr(filename),
  fclose(tmpfid);
end;
