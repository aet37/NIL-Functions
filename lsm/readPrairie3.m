function f=readPrairie2(froot,cycle,label,chno,imno)
% Usage ... f=readPrairie2(froot,cycle,label,chno,imno)

if ~exist('cycle'), cycle=[]; end;
if ~exist('label'), label=[]; end;
if ~exist('chno'), chno=[]; end;
if ~exist('imno'), imno=[1 1e6]; end;
if length(imno)==2, imno=[imno(1):imno(2)]; end;
if isempty(label), label='ome'; end;
if isempty(cycle), cycle=1; end;
%if isempty(chno), chno=2; end;
if strcmp(froot(end),'/'), do_addpath=1; else, do_addpath=0; end;
if ~strcmp(label(end),'.'), label=[label,'.']; end;

do_oldcycle=0;


if do_addpath,
  tmpfound=0; tmpcnt=0;
  for mm=1:6,
    tmpname=sprintf('%s%s_Cycle%05d_Ch%d_%06d.%stif',froot,froot(1:end-1),cycle(1),mm,1,label);
    %disp(tmpname);
    if exist(tmpname), chno=[chno mm]; end;
  end;
  fname=sprintf('%s%s_Cycle%05d_Ch%d_%06d.%stif',froot,froot(1:end-1),cycle(1),chno(1),imno(1),label);
  if ~exist(fname), do_oldcycle=1; end;
  %while(~tmpfound),
  %  tmpcnt=tmpcnt+1;
  %  if do_oldcycle,
  %     tmpname=sprintf('%s%s_Cycle%03d_%s_Ch%d_%06d.tif',froot,froot(1:end-1),tmpcnt,label,chno(1),1);
  %  else,
  %     tmpname=sprintf('%s%s_Cycle%05d_%s_Ch%d_%06d.tif',froot,froot(1:end-1),tmpcnt,label,chno(1),1);
  %  end;
  %  if exist(tmpname), cycle=[cycle tmpcnt]; else, tmpfound=1; end;
  %end;
else,
  for mm=1:6,
    tmpname=sprintf('%s_Cycle%05d_Ch%d_%06d.%stif',froot,cycle(1),mm,1,label);
    if exist(tmpname), chno=[chno mm]; end;
  end;
  fname=sprintf('%s_Cycle%05d_Ch%d_%06d.%stif',froot,cycle(1),chno(1),imno(1),label);
  if ~exist(fname), do_oldcycle=1; end;
end;



tmpout=0;
for mm=1:length(cycle),
  for nn=1:length(chno),
    for oo=1:length(imno),
      if do_addpath,
        if do_oldcycle,
          fname=sprintf('%s%s_Cycle%03d_Ch%d_%06d.%stif',froot,froot(1:end-1),cycle(mm),chno(nn),imno(oo),label);      
        else,
          fname=sprintf('%s%s_Cycle%05d_Ch%d_%06d.%stif',froot,froot(1:end-1),cycle(mm),chno(nn),imno(oo),label);    
        end;
      else,
        if do_oldcycle,
          fname=sprintf('%s_Cycle%03d_Ch%d_%06d.%stif',froot,cycle(mm),chno(nn),imno(oo),label);
        else,
          fname=sprintf('%s_Cycle%05d_Ch%d_%06d.%stif',froot,cycle(mm),chno(nn),imno(oo),label);
        end;
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

