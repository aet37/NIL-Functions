function f=raw_detrend(filename,ps,order,sinusiod)
% Usage ... f=raw_detrend(filename,ps,order,sinusiod)
%
% Matlab v5.0 code only

RAWHEADERSIZE=39940;

% Defaults
if nargin<=2,
  ps='sf9';
end;
if nargin<=3,
  order=3;
end;
if nargin<=4,
  sinusoid=0;
end; 

% Reading header
[info1,info2,info3]=fidread(filename);

% Opening file
file_id=fopen(filename,'r');
if file_id<3, error('Could not open file...'); end;
status=fseek(file_id,RAWHEADERSIZE,'bof');
if status, error('Could not seek past header location...'); end;

% Reading raw data
framesize=info1(9);
if strcmp(ps,'sf9'),
  nshots=info3(6);
  nphs=info3(5);
  nphmult=info3(11);  
  nslc=info1(3)/nshots;
  nframes=nshots*(nphmult+1)*nphs*nslc;
elseif strcmp(ps,'sf3d'),
  nzpe=info3(20);
  nshots=info3(6);
  nphs=info3(5);
  nphmult=info3(11);
  nframes=(nshots*nzpe*nphmult+1)*nphs;
else,
  error('Invalid pulse sequence...');
end;

[raw_data,rcnt]=fread(file_id,[nframes 2*framesize],'short');
if rcnt~=nframes*framesize, error('Could not read all raw data...'); end;

% Parsing of data
frame_cnt=1;
if strcmp(ps,'sf9'),
elseif strcmp(ps,'sf3d'),
  for l=1:nphs,
    %baselines(bcnt,:)=raw_data(frame_cnt,:);
    frame_cnt=frame_cnt+1;
    for m=1:nphmult,
      for n=1:nzpe,
        for o=1:nshots,
          for p=1:framesize,
            parsed_data_real(n,o,(l-1)*nphmult+m,p)=raw_data(frame_cnt,2*p-1);
            parsed_data_imag(n,o,(l-1)*nphmult+m,p)=raw_data(frame_cnt,2*p);
          end;
          frame_cnt=frame_cnt+1;
        end;
      end;
    end;
  end;
end;

% Regress data
