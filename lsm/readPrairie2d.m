function y=readPrairie2d(foldername,rootname)
% Usage ... y=readPrairie2d(foldername,rootname)
%
% Reads all the files in foldername. If the foldername has a different
% rootname than foldername, it will use the given rootname to read the
% files. It uses built-in TIFF reader and places all cycles in cells.

tmpii=strfind(foldername,filesep);
if isempty(tmpii), foldername=[foldername,filesep]; end;

if ~exist('rootname','var'), 
    rootname=foldername; 
    tmpii=strfind(rootname,filesep);
    if isempty(tmpii),
        % do nothing
    elseif length(tmpii)>1,
        rootname=rootname(tmpii(end-1):tmpii(end)); 
    elseif tmpii(1)>length(rootname(1:end-1)),
        rootname=rootname(1:end-1);
    end
end;

%foldername, rootname,

tmpdir=dir([foldername,rootname,'*Cycle*.tif']);
tmpcyc=tmpdir(end).name;
tmpii1=strfind(tmpcyc,'Cycle');
tmpcyc1=tmpcyc(tmpii1(end)+5:end);
%tmpii2=strfind(tmpcyc1,'_');
%nCycles=str2num(tmpcyc1(1:tmpii2(1)-1));

nCycles=str2num(tmpcyc1(1:5));

for mm=1:nCycles,
    tmpname1=sprintf('%s%s%s_Cycle%05d_*_%06d.*.tif',foldername,filesep,rootname,mm,1);
    %tmpname1,
    tmpdir1=dir(tmpname1);
    if ~isempty(tmpdir1),
      nCh=length(tmpdir1);
      for nn=1:nCh,
        tmpii=strfind(tmpdir1(nn).name,'Ch');
        chNo(nn)=str2num(tmpdir1(nn).name(tmpii+2));
      end
    
      tmpname=sprintf('%s%s%s_Cycle%05d*Ch%d*.tif',foldername,filesep,rootname,mm,chNo(1));
      tmpdir=dir(tmpname);
      nIms=length(tmpdir);
      tmpChii=strfind(tmpdir(1).name,'Ch');
      disp(sprintf('  reading Cycle#%d Ch#%d Ims#%d',mm,nCh,nIms));
      for nn=1:nIms, for oo=1:nCh,
        tmpname1=tmpdir(nn).name;
        tmpname1(tmpChii+2)=num2str(chNo(oo));
        %disp([tmpdir(nn).folder,filesep,tmpname1]);
        y{mm}(:,:,oo,nn)=imread([tmpdir(nn).folder,filesep,tmpname1]);
      end; end;
    end
end
