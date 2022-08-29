function f=readPrairie2(froot,cycle,label,chno,imno)
% Usage ... f=readPrairie2(froot,cycle,label,chno,imno)

if ~exist('cycle','var'), cycle=[]; end;
if ~exist('label','var'), label=[]; end;
if ~exist('chno','var'), chno=[]; end;
if ~exist('imno','var'), imno=[1 1e6]; end;

if length(imno)==2, imno=[imno(1):imno(2)]; end;

if isempty(label), label='CurrentSettings'; end;
if isempty(cycle), cycle=1; end;
if isempty(chno), chno=2; end;
if strcmp(froot(end),'/'), do_addpath=1; else, do_addpath=0; end;


tmpout=0;
for mm=1:length(cycle),
  for nn=1:length(chno),
    for oo=1:length(imno),
      if do_addpath,
        fname=sprintf('%s%s_Cycle%05d_%s_Ch%d_%06d.tif',froot,froot(1:end-1),cycle(mm),label,chno(nn),imno(oo));      
      else,
        fname=sprintf('%s_Cycle%05d_%s_Ch%d_%06d.tif',froot,cycle(mm),label,chno(nn),imno(oo));
      end;
      if exist(fname),
        tmpstk=tiffread2(fname);
        if (mm==1)&(nn==1)&(oo==1), f=zeros(size(tmpstk.data,1),size(tmpstk.data,2),length(chno),length(imno),length(cycle)); end;
        f(:,:,nn,oo,mm)=double(tmpstk.data);
      else,
        disp(sprintf('  warning: did not find %s... returning...',fname));
        tmpout=1;
        break;
      end;
    end;
  end;
end;

f=squeeze(f(:,:,:,1:oo-tmpout,:));

