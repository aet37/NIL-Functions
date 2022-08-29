function new_data_buff=phys_corr1(filename,ps,filter,skp,detorder)
% Usage ... new_data_buff=phys_corr1(filename,ps,filter,skp,detorder)
%
% Performs the physiological correction on the Pfile
% data given the pulse sequence (ps).
% Note: This code will not be able to correct Pfiles
%   greater than 250MB

HEADERSIZE=39940;

new_filename=[filename,'.corr'];
fid_orig=fopen(filename,'r');
fid_new=fopen(new_filename,'w');

% Opening files
disp(['Opening files...']);
if fid_orig<3, error('Could not open filename!'); end;
if fid_new<3, error('Could not open new filename!'); end;

% Reading/writing headers
disp(['Reading/writing header...']);
[header_buff,ver]=fread(fid_orig,HEADERSIZE,'char');
if ver!=HEADERSIZE, error('Could not read header!'); end;
ver=fwrite(fid_new,header_buff,'char');
if ver!=HEADERSIZE, error('Could not write header!'); end;

if strcmp(ps,'sf9'),
  disp(['Pulse sequence: sf9']);
  fclose(fid_orig);
  [info1,info2,info3]=fidread(filename);
  fid_orig=fopen(filename,'r');
  if fid_orig<3, error('Could not open filename!'); end;

  nslices=info1(3)/info3(5);
  nprj=info3(6);
  nmult=info3(5);
  nphs=info3(11);
  data_buff_dim=[nslices*(nphs*nmult*nprj+nmult) 2*info1(10)];

  % Reading data buffer
  disp(['Reading data buffer...']);
  ver=fseek(fid_orig,HEADERSIZE+1,'bof');
  if ver!=0, error('Could not seek to past header location!'); end;
  [data_buff,ver]=fread(fid_orig,data_buff_dim,'short');
  if ver!=(data_buff_dim(1)*data_buff_dim(2)), error('Could not read data successfully!'); end;

  % Splitting data into real and imaginary and copying baselines
  disp(['Splitting data into real and imaginary and copying baselines...']);
  %fid_tmp=fopen('tmp.matlab.pc1','w');
  %if fid_tmp<3, error('Could not open temporary file...'); end;
  new_data_buff=zeros(size(data_buff));
  cnt1=0; cnt2=0;
  for m=1:nslices,
    for n=0:nphs*nmult*nprj+nmult-1,
      cnt1=cnt1+1;
      if rem(n,nprj)==0,
        cnt2=cnt2+1;
        nbase(cnt2)=cnt1;
        new_data_buff(cnt1,:)=data_buff(cnt1,:);
      end;
    end;
  end;
  %ver=fwrite(fid_tmp,new_data_buff,'short');
  %if ver!=(data_buff_dim(1)*data_buff_dim(2)), error('Could not write tmp data successfully!'); end;
  %fclose(fid_tmp);
  %clear new_data_buff
  cnt1=0;
  for m=1:data_buff_dim(1),
    if isempty(find(nbase==m)),
      cnt1=cnt1+1;
      for n=1:data_buff_dim(2)/2,
        data_buff_re(cnt1,n)=data_buff(m,2*n-1);
        data_buff_im(cnt1,n)=data_buff(m,2*n);
      end;
    end;
  end;
  if size(data_buff_re,1)!=(nslices*nphs*nmult*nprj),
    error('Improper data buffer size!');
  end;
  clear data_buff
  
  % Analysis
  for m=1:nslices,
    disp(['Analyzing slice ',int2str(m)]);
    disp(['Getting and detrending zeros...']);
    zeros=data_buff_re((m-1)*nphs*nmult*nprj+1:m*nphs*nmult*prj,1)+i*data_buff_im((m-1)*nphs*nmult*nprj+1:m*nphs*nmult*prj,1);
    axis_zeros=[1:size(zeros,2)];
    p=polyfit(axis_zeros,zeros',1);
    p2=[p(1) 0];
    zeros_new=conj(zeros' -conj(polyval(p2,axis_zeros)));
    disp(['Getting phase...']);
    phase=get_phs(zeros_new,filter(m,:),nphs,nmult,nprj);
    for n=1:nprj,
      disp(['Reorganizing data (prj=',int2str(n),')']);
      for o=1:nphs*nmult,
        re_tmp(o,:)=data_buff_re((m-1)*nphs*nmult*prj+o*nprj,:);
        im_tmp(o,:)=data_buff_im((m-1)*nphs*nmult*prj+o*nprj,:);
      end;
      disp(['Getting new data...']);
      [new_re_tmp,new_im_tmp]=get_phs_rgr3_det(phase(:,n),n,nphs,nmult,nprj,'',m,skp,data_buff_dim(2)/2,re_tmp,im_tmp,detorder);
      cnt1=(m-1)*nphs*nmult*nprj+(m-1)*nmult; adj=0;
      disp(['Reorganizing new data...']);
      for o=1:nphs*nmult,
        cnt1=cnt1+1;
        if rem(o,nmult)==0, cnt1=cnt+1; end;
        if isempty(find(nbase==cnt1))==0, error('Trying to write to baseline location!'); end;
        for p=1:data_buff_dim(2)/2,
          new_data_buff(cnt1,2*p-1)=new_re_tmp(p);
          new_data_buff(cnt1,2*p)=new_im_tmp(p);
        end;
      end;
    end;
  end;
  
  % Clearing unnecessary memmory
  clear data_buff_re data_buff_im zeros p phase re_tmp im_tmp new_re_tmp new_im_tmp

  % Writing new data buffer
  disp(['Writing new data buffer...']);
  ver=fwrite(fid_new,new_data_buff,'short');
  if ver!=(data_buff_dim(1)*data_buff_dim(2)), error('Could not write data successfully!'); end;
end;

fclose(fid_new);
fclose(fid_orig);

disp(['Done...']);
