function [data,datasz]=readPrairie2c(foldername)
% Usage ... y=readPrairie2c(foldername)

do_reparse=1;

tmpfind_t=findstr(foldername,'TSeries');
tmpfind_l=findstr(foldername,'LineScan');

do_line=0;
if ~isempty(tmpfind_t),
  nCh_s=dir([foldername,filesep,'TSeries*_Cycle00001_Ch*_000001.ome.tif']);
  nCycles_s=dir([foldername,filesep,'TSeries*_Cycle*_Ch*_000001.ome.tif']);
  nCh=length(nCh_s);
  nCycles=length(nCycles_s)/nCh;
  for mm=1:nCh,
    tmpfind=findstr(nCh_s(mm).name,'Ch');
    nChNum(mm)=str2num(nCh_s(mm).name(tmpfind+2));
  end
  disp(sprintf('  detected:  #Ch=%d  nCycles=%d',nCh,nCycles));
  %nChNum,
elseif ~isempty(tmpfind_l),
  do_line=1;
  nCh_s=dir([foldername,filesep,'Line*_Cycle00001_Ch*_000001.ome.tif']);
  nCycles_s=dir([foldername,filesep,'Line*_Cycle*_Ch*_000001.ome.tif']);
  nCh=length(nCh_s);
  nCycles=length(nCycles_s)/nCh;
  for mm=1:nCh,
    tmpfind=findstr(nCh_s(mm).name,'Ch');
    nChNum(mm)=str2num(nCh_s(mm).name(tmpfind+2));
  end
  disp(sprintf('  detected:  #Ch=%d  nCycles=%d',nCh,nCycles));
  %nChNum,    
else,
  disp('  This function is currently only supported for TSeries...');
  return;
end

% read each cycle
for mm=1:nCycles,
  for nn=1:nCh,
    clear tmpname tmpdir
    if do_line,
      tmpname=sprintf('%sLineScan*_Cycle%05d_Ch%d_*.ome.tif',[foldername,filesep],mm,nChNum(nn));
    else,
      tmpname=sprintf('%sTSeries*_Cycle%05d_Ch%d_*.ome.tif',[foldername,filesep],mm,nChNum(nn));
    end
    tmpdir=dir(tmpname);
    if nn==1, disp(sprintf('  reading cycle#%d #ims=%d',mm,length(tmpdir))); end;
    for oo=1:length(tmpdir),
      %data{mm}{nn}{oo}=imread([tmpdir(oo).folder,filesep,tmpdir(oo).name]);
      data{mm}{nn}{oo}=single(imread([tmpdir(oo).folder,filesep,tmpdir(oo).name]));
      datasz{mm}(nn,oo,:)=size(data{mm}{nn}{oo});
    end;
  end
end

if do_reparse,
  % re-parse data
  %   concatinate last dimmension if its the same
  %   combine if they are not
  disp('  reparsing...');
  
  if do_line,
    for mm=1:nCycles,
      tmpdim1=[datasz{mm}(1,:,1)]; tmpdim1c=[0 cumsum(tmpdim1)];
      tmpdim2=[datasz{mm}(1,1,2)];
      data2{mm}=single(zeros(sum(tmpdim1),tmpdim2,nCh));
      for nn=1:length(tmpdim1), for oo=1:nCh,
        data2{mm}([1:tmpdim1(nn)]+tmpdim1c(nn),:,oo)=data{mm}{oo}{nn};
      end; end;
    end;
    data=data2;
    clear data2
    
    if nCycles==1, data=cell2mat(data); end;
  else,
    for mm=1:nCycles,
      tmpchk=squeeze(datasz{mm}(1,:,:));
      tmpchk=tmpchk./(ones(size(datasz{mm},2),1)*squeeze(datasz{mm}(1,1,:))');
      tmpchk2=sum(tmpchk(:)-1);
      if abs(tmpchk2)>100*eps, 
        % concatenate
        data2{mm}=single(zeros(sum(datasz{mm}(1,:,1)),datasz{mm}(1,1,2),nCh));
        for nn=1:nCh, for oo=1:length(data{mm}{nn}),
          if oo==1,
            data2{mm}(1:size(data{mm}{nn}{oo},1),:,nn)=data{mm}{nn}{oo};
          else,
            data2{mm}(end+1:end+size(data{mm}{nn}{oo},1),:,nn)=data{mm}{nn}{oo};
          end
        end; end;
      else,
        % combine
        for nn=1:nCh, for oo=1:length(data{mm}{nn}),
          data2{mm}(:,:,nn,oo)=data{mm}{nn}{oo};
        end; end;
      end;
    end;
    data=data2;
    clear data2
  end
  
end

