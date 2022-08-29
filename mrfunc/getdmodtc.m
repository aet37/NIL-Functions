function [val,count]=getdmodtc(filename,isize,ibytesize,locations,detrend)
% Usage ... [val,count]=getdmodtc(filename,range,slice,locs,detrend)

[lr,lc]=size(locations);
[ir,ic]=size(isize);

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
    loadstr=['int8'];
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

  if isstr(isize),
    isize=[1 nim];
  else,
    if length(isize)==1,
      isize(2)=isize(1);
    end;
    if isize(2)>nim,
      error('Invalid range!');
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

  if isstr(filename), fclose(tmpfid); end;

  if nargin==5,
    [m,n]=size(val);
    for ii=1:n,
      tmp1=polyfit([1:m]',val(:,ii),detrend);
      tmp2=polyval(tmp1,[1:m]');
      val(:,ii)=val(:,ii)-tmp2+mean(val(:,ii));
    end;    
  end;

%if dmod==2,
%  first_rec=isize(1);
%  xd=isize(2);
%  yd=isize(3);
%  pixtype=isize(6);
%  nsl=isize(7);
%  nim=isize(8);

%  if (locations(1)>nsl), error('Invalid Slice!'); end;
%  sl=locations; 

%  if (pixtype==0),
%    loadstr=['char'];
%  elseif (pixtype==3),
%    bskp=4;
%    loadstr=['long'];
%  elseif (pixtype==8),
%    bskp=8;
%    loadstr=['double'];
%  else,
%    bskp=2;
%    loadstr=['short'];
%  end;
%
%  tmploc=first_rec+bskp*( (nim*xd*yd*(sl-1))+(xd*yd*(locations(2)-1)) );
%  tmpstatus=fseek(tmpfid,tmploc,'bof');
%  if tmpstatus, error('Invalid image location!'); end;
%  [val(m,n),tmpcount]=fread(tmpfid,xd*yd,loadstr);
%  if tmpcount>1, error('Invalid ibytesize!'); end;

%end;
