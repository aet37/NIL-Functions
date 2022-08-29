function [data,datainfo]=readPrairie2e(fname)
% Usage ... y=readPrairie2e(fname)
%
% Reads all the PrairieView images in folder fname ending in *.ome.tif
% Images get type-casted to single by default.
%
% Ex. data=tmp_readPrairie2e('TSeries-08252022-1246-9255');

tmpdir=dir([fname,'/*.ome.tif']);

% figure out number of channels
cnt=0;
for mm=1:length(tmpdir), 
    tmpfound=strfind(tmpdir(mm).name,'_Ch'); 
    if ~isempty(tmpfound), 
        cnt=cnt+1; 
        tmpch(cnt)=str2num(tmpdir(mm).name(tmpfound+3)); 
    end;
end;
tmpch1=unique(tmpch);
disp(sprintf('  #ch= %d (%s)',length(tmpch1),num2str(tmpch1)));

% figure out number of cycles
cnt=0;
for mm=1:length(tmpdir), 
    tmpfound=strfind(tmpdir(mm).name,'_Cycle'); 
    if ~isempty(tmpfound), 
        cnt=cnt+1;
        tmpcyc(cnt)=str2num(tmpdir(mm).name(tmpfound+[1:5]+5));
        if cnt==1, tmproot=tmpdir(mm).name(1:tmpfound-1), end;
    end;
end;
tmpcyc1=unique(tmpcyc);
disp(sprintf('  #cycles= %d (%s)',length(tmpcyc1),num2str(tmpcyc1)));

% figure out number of images per cycle
for mm=1:length(tmpcyc1),
    for nn=1:length(tmpch1),
        tmptmpdir=dir(sprintf('%s/*_Cycle%05d_Ch%d_*.ome.tif',fname,tmpcyc1(mm),tmpch1(nn)));
        tmpims(mm,nn)=length(tmptmpdir);
    end
    disp(sprintf('  cyc#%d(%d) #ims=%d (%s)',mm,tmpcyc1(mm),max(tmpims(mm,:)),num2str(tmpims(mm,:))));
end

datainfo.fname=fname;
datainfo.flist=tmpdir;
datainfo.cyc=tmpcyc1;
datainfo.cyc_ii=tmpcyc;
datainfo.ch=tmpch1;
datainfo.ch_ii=tmpch;
datainfo.nims=tmpims;

save tmp_read_info datainfo


% now read everything
for mm=1:length(tmpcyc1),
  disp(sprintf('  reading cycle# %d of %d ...',mm,length(tmpcyc1)));
  for nn=1:length(tmpch1),
    if tmpims(mm,nn)>0,
      for oo=1:tmpims(mm,nn),
        tmpname=sprintf('%s%s%s_Cycle%05d_Ch%d_%06d.ome.tif',fname,filesep,tmproot,tmpcyc1(mm),tmpch1(nn),oo);
        %if exist(tmpname,'file'),
            tmpim=single(imread(tmpname));
            data{mm}(1:size(tmpim,1),1:size(tmpim,2),nn,oo)=tmpim;
        %else,
        %  data{mm}(:,:,nn,oo)=nan;
        %end
      end
    else
      data{mm}(:,:,nn,oo)=nan;
    end
  end
end
