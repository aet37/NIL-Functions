function [val,count]=fasttcload(filename,isize,ibytesize,locations,byteoffset)
% Usage ... [val,count]=fasttcload(filename,volrange,slice,locations,format)
% This function retrieves the timecourse of a pixel or a set
% of pixels from several file formats. Currently only two are
% available. For the DMOD file format, you can replace filename
% with the file fid, volrange is the range of images to use or
% enter 'all' for all images in the slice requested, slice is the
% slice of interest, locations is the pixel matrix (2 cols) with
% the pixel list. In format 'DMOD' must be entered.
% For alternate format substitute volrange with image size [x y],
% slice with image-byte-size, and format with the offset in every
% image.

[lr,lc]=size(locations);
[ir,ic]=size(isize);

if isstr(byteoffset),
  if (byteoffset=='dmod')|(byteoffset=='DMOD'),
    dmod=1;
  elseif (byteoffset=='dmodim')|(byteoffset=='DMODIM')
    dmod=2;
  end;
else,
  dmod=0;
end;

if ~dmod,
  if (ic~=2), error('Improper file size!'); end;
  xdim=isize(1); ydim=isize(2);

  if (ibytesize==1)
    loadstr=['char'];
  elseif (ibytesize==4),
    loadstr=['long'];
  elseif (ibytesize==8),
    loadstr=['double'];
  else,
    loadstr=['short'];
  end;

  if ~exist('byteoffset'), byteoffset=0; end;

  tmpfid=fopen(filename,'r');
  if tmpfid<3, error('Invalid filename or file does not exist!'); end;

  for m=1:lr,
    tmploc=byteoffset+ibytesize*(((locations(m,2)-1)*xdim)+locations(m,1)-1);
    tmpstatus=fseek(tmpfid,tmploc,'bof');
    if tmpstatus, error('Invalid pixel location!'); end;
    [val(m),tmpcount]=fread(tmpfid,1,loadstr);
    if tmpcount>1, error('Invalid ibytesize!'); end;
  end;
  fclose(tmpfid);
  val=val(:);
  count=m;

  clear loadstr tmpfid tmpstatus tmpcount m lr lc tmploc

elseif dmod==1,
  % isize is image or image range
  % ibytesize is the slice of interest

  if isstr(filename),
    tmpfid=fopen(filename,'r');
    if tmpfid<3, error('Invalid filename or file does not exist!'); end;
  else,
    tmpfid=filename;
  end;

  dmod_info_partial=getdmodinfo(tmpfid);

  first_rec=dmod_info_partial(1);
  xd=dmod_info_partial(2);
  yd=dmod_info_partial(3);
  pixtype=dmod_info_partial(6);
  nsl=dmod_info_partial(7);
  nim=dmod_info_partial(8);

  if (ibytesize>nsl), error('Invalid Slice!'); end;
  sl=ibytesize; 
 
  if (pixtype==0),
    loadstr=['char'];
  elseif (pixtype==3),
    bskp=4;
    loadstr=['long'];
  elseif (pixtype==8),
    bskp=8;
    loadstr=['double'];
  else,
    bskp=2;
    loadstr=['short'];
  end;

  if isstr(isize),
    isize=[1 nim];
  else,
    if length(isize)==1,
      isize(2)=isize(1);
    end;
  end;

  for m=isize(1):isize(2),
    for n=1:lr,
      pixx=locations(n,1);
      pixy=locations(n,2);
      tmploc=first_rec+bskp*( (nim*xd*yd*(sl-1))+(xd*yd*(m-1))+(((pixy-1)*xd)+pixx-1) );
      tmpstatus=fseek(tmpfid,tmploc,'bof');
      if tmpstatus, error('Invalid pixel location!'); end;
      [val(m,n),tmpcount]=fread(tmpfid,1,loadstr);
      if tmpcount>1, error('Invalid ibytesize!'); end;
    end;
  end;
elseif dmod==2,
  first_rec=isize(1);
  xd=isize(2);
  yd=isize(3);
  pixtype=isize(6);
  nsl=isize(7);
  nim=isize(8);

  if (locations(1)>nsl), error('Invalid Slice!'); end;
  sl=locations; 

  if (pixtype==0),
    loadstr=['char'];
  elseif (pixtype==3),
    bskp=4;
    loadstr=['long'];
  elseif (pixtype==8),
    bskp=8;
    loadstr=['double'];
  else,
    bskp=2;
    loadstr=['short'];
  end;

  tmploc=first_rec+bskp*( (nim*xd*yd*(sl-1))+(xd*yd*(locations(2)-1)) );
  tmpstatus=fseek(tmpfid,tmploc,'bof');
  if tmpstatus, error('Invalid image location!'); end;
  [val(m,n),tmpcount]=fread(tmpfid,xd*yd,loadstr);
  if tmpcount>1, error('Invalid ibytesize!'); end;

end;
