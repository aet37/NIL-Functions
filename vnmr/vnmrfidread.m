function [data,datafilehead,datablockhead]=vnmrfidread(FID_filename,FID_alt_header);
% Usage ... [data,filehead,blockhead]=vnmrfidread(FID_filename);
%
% This function reads "fid" files from Varian VNMR system.
% The input parameter is "filename" that contains the path
% and the file name of the "fid" file.
% The output parameters are:
%    Data File Header "datafilehead" (structure) that contains:
%       nblocks = Number of blocks in file
%       ntraces = Number of traces per block
%       np = Number of elements per trace
%       ebytes = Number of bytes per element
%       tbytes = Number of bytes per trace
%       bbytes = Number of bytes per block
%       vers_id = Software version, file_id status bits
%       status = Status of whole file
%       nbheaders = Number of block headers per block
%    Data Block Header "datablockhead" (structure) that contains:
%       scale
%       status
%       index
%       mode
%       ctcount
%       lpval
%       rpval
%       lvl
%       tlt
%    "data" (Complex matrix with FID's)

%
% Rev. 2.0   Jun/27/2001
% Francisco M. Martinez S.
% Please send comments and/or modifications to sfmartin@umich.edu
%
% Modified by Alberto Vazquez
%


if (nargin==0),
  [FID_file,FID_path]=uigetfile('*fid*','Free Induction Decays (Raw Data - FID File)');
  cd(FID_path);
  FID_filename=strcat(FID_path,FID_file);
end;
filedata=fopen(FID_filename,'r','ieee-be');
if (filedata<3),
  error(sprintf('Could not open fid file (%s)!',FID_filename));
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (exist('FID_alt_header')),
datafilehead.nblocks=FID_alt_header(1);
datafilehead.ntraces=FID_alt_header(2);
datafilehead.np=FID_alt_header(3);
datafilehead.ebytes=FID_alt_header(4);
datafilehead.tbytes=FID_alt_header(5);
datafilehead.bbytes=FID_alt_header(6);
datafilehead.vers_id=FID_alt_header(7);
datafilehead.status=FID_alt_header(8);
datafilehead.nbheaders=FID_alt_header(9);
else,
datafilehead.nblocks=fread(filedata,1,'int32');		% Number of blocks in file
datafilehead.ntraces=fread(filedata,1,'int32');		% Number of traces per block
datafilehead.np=fread(filedata,1,'int32');		% Number of elements per trace
datafilehead.ebytes=fread(filedata,1,'int32');		% Number of bytes per element
datafilehead.tbytes=fread(filedata,1,'int32');		% Number of bytes per trace
datafilehead.bbytes=fread(filedata,1,'int32');		% Number of bytes per block
datafilehead.vers_id=fread(filedata,1,'int16'); 	% Software version, file_id status bits 
datafilehead.status=fread(filedata,1,'int16');  	% Status of whole file, Check bit order
datafilehead.nbheaders=fread(filedata,1,'int32');	% Number of block headers per block
end;

if (datafilehead.ebytes==2),
  datatype='int16';
else,
  datatype='int32';
end;

%fclose(filedata);

% The following 10 lines are optional. Used to display file header information
display_header_flag=1;
if (display_header_flag),
  disp('File Header');
  disp(sprintf('Number of Data Blocks in File = %i',datafilehead.nblocks));
  disp(sprintf('Number of Traces per Block = %i',datafilehead.ntraces));
  disp(sprintf('Number of Simple Elements per Trace = %i',datafilehead.np));
  disp(sprintf('Number of Bytes per Element = %i',datafilehead.ebytes));
  disp(sprintf('Number of Bytes per Trace = %i',datafilehead.tbytes));
  disp(sprintf('Number of Bytes per Block = %i',datafilehead.bbytes));
  disp(sprintf('Software Version = %i',datafilehead.vers_id));
  disp(sprintf('Status = %i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i',datafilehead.status));
  disp(sprintf('Number of Block Headers per Block = %i',datafilehead.nbheaders));
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Block Header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data = zeros(datafilehead.np/2,datafilehead.ntraces,datafilehead.nblocks);

for ii=1:datafilehead.nblocks

   datablockhead.scale(ii)=fread(filedata,1,'int16'); % bitshift(A(9+(ii-1)*datafilehead.bbytes/datafilehead.ebytes),-16);
   datablockhead.status(ii,:)=fread(filedata,1,'int16'); %bitget(A(9+(ii-1)*datafilehead.bbytes/datafilehead.ebytes),1:16);
   datablockhead.index(ii)=fread(filedata,1,'int16'); % bitshift(A(10+(ii-1)*datafilehead.bbytes/datafilehead.ebytes),-16);
   datablockhead.mode(ii,:)=fread(filedata,1,'int16'); % bitget(A(10+(ii-1)*datafilehead.bbytes/datafilehead.ebytes),1:16);
   datablockhead.ctcount(ii)=fread(filedata,1,'int32'); % A(11+(ii-1)*datafilehead.bbytes/datafilehead.ebytes);
   datablockhead.lpval(ii)=fread(filedata,1,'int32'); % double(A(12+(ii-1)*datafilehead.bbytes/datafilehead.ebytes));
   datablockhead.rpval(ii)=fread(filedata,1,'int32'); % double(A(13+(ii-1)*datafilehead.bbytes/datafilehead.ebytes));
   datablockhead.lvl(ii)=fread(filedata,1,'int32'); % double(A(14+(ii-1)*datafilehead.bbytes/datafilehead.ebytes));
   datablockhead.tlt(ii)=fread(filedata,1,'int32'); % double(A(15+(ii-1)*datafilehead.bbytes/datafilehead.ebytes));
    
   % The following 10 lines are optional. Used to display block header information
   %disp(sprintf('Block Header %i',ii));
   %disp(sprintf('Scale = %f',datablockhead.scale(ii)));
   %disp(sprintf('Status = %i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i',datablockhead.status(ii,:)));
   %disp(sprintf('Index = %i',datablockhead.index(ii)));
   %disp(sprintf('Mode = %i%i%i%i%i%i%i%i%i%i%i%i%i%i%i%i',datablockhead.mode(ii,:)));
   %disp(sprintf('CTCount = %f',datablockhead.ctcount(ii)));
   %disp(sprintf('lpval = %f',datablockhead.lpval(ii)));
   %disp(sprintf('rpval = %f',datablockhead.rpval(ii)));
   %disp(sprintf('lvl = %f',datablockhead.lvl(ii)));
   %disp(sprintf('tlt = %f',datablockhead.tlt(ii)));
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Extracting data
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   data_block=fread(filedata,[datafilehead.np,datafilehead.ntraces],datatype);
   disp(sprintf(' reading# %d (%d,%d; %d)',ii,datafilehead.np/2,datafilehead.ntraces,ftell(filedata)));
   dataR(:,:,ii)=reshape(data_block([1:2:end]),datafilehead.np/2,datafilehead.ntraces);
   dataI(:,:,ii)=reshape(data_block([2:2:end]),datafilehead.np/2,datafilehead.ntraces);

end;
fclose(filedata);

data=dataR+i*dataI;

if nargin==1,
  tmp.header=datafilehead;
  tmp.block_header=datablockhead;
  tmp.data=data;
  clear data
  data=tmp;
end;

 
