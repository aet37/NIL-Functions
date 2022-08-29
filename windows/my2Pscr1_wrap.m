function my2Pscr1_wrap(flist,saveid,opt1,opt2,vars2load,skip1load)
% Usage ... my2Pscr1_wrap(filelist,saveids,option1str,optionAllstr,loadVars,skip1load)
%
% Ex.
%   opt1=sprintf('''do_loadall'',''do_crop'',''do_motc'',''do_motcref'',[1 2],''do_maskreg'',''do_intc''');
%   opt2=sprintf('''do_loadall'',''do_crop'',crop_ii,''do_motc'',''do_motcref'',[1 2],''do_maskreg'',mask_reg,''do_intc''');
%   my2Pscr1_wrap('*TSeries*',[],opt1,opt2,{'crop_ii','mask_reg'})
% or
%   opt1=sprintf('''do_loadall'',''do_keepraw'',''do_movie'',''do_motc'',''do_motcref'',[1 2]');
%   my2Pscr1_wrap('*TSeries*',[],opt1)
%
%   opt1=sprintf('''do_loadall'',''do_keepraw'',''do_movie'',''do_motc'',''do_realign'',2,''do_motcref'',[1 2]');
%   my2Pscr1_wrap('*TSeries*',[],opt1)
%
%   opt1=sprintf('''do_loadall'',''do_proj'',''do_movie''');
%   my2Pscr1_wrap('*ZSeries*',[],opt1)

do_dryrun=0;

if nargin<6, skip1load=[]; end;
if nargin<5, vars2load=[]; end;
if nargin<4, opt2=[]; end;

if isempty(flist),
  tmpdir=dir('*Series*');
  if isempty(tmpdir),
    tmpdir=dir('*.raw');
  else,
    for mm=1:length(tmpdir), tmpdir(mm).name(end+1)=filesep; end;
  end;
  if isempty(tmpdir), tmpdir=dir('*.tif'); end;
  if isempty(tmpfir),
    disp('  error: no files found');
    return,
  end;
end;

if ischar(flist)
  disp(sprintf('  searching for files %s',flist));
  tmpdir=dir(flist);
%   for mm=1:length(tmpdir)
%     tmpflist{mm}=[tmpdir(mm).folder,filesep,tmpdir(mm).name,filesep];
%     %tmpflist{mm}=[tmpdir(mm).name,filesep];
%   end
%   flist=tmpflist;
end
% 
% if iscell(flist)
%     if length(flist)==1
%         tmpdir=dir(flist{1});
%     end
% end

if exist('tmpdir','var')
    for mm=1:length(tmpdir)
        if strcmp(tmpdir(mm).name(end),filesep)
            tmpflist{mm}=tmpdir(mm).name;
            tmpids{mm}=[tmpdir(mm).name(1:4),tmpdir(mm).name(end-4:end-1)];
        else
            tmpflist{mm}=[tmpdir(mm).folder,filesep,tmpdir(mm).name,filesep];
            %tmpflist{mm}=[tmpdir(mm).name,filesep];
            tmpids{mm}=[tmpdir(mm).name(1:4),tmpdir(mm).name(end-3:end)];
        end
    end
    flist=tmpflist;
    flist{1}
end

do_loadvars=0;
if ~isempty(vars2load)
  do_loadvars=1;
  tmpvars2load=[];
  for mm=1:length(vars2load)
    tmpvars2load=[tmpvars2load,' ',vars2load{mm}];
    %if ~istrcmp(opt2{mm}(1:3),'do_'),
    %  tmpvars2load=[tmpvars2load,' ',opt2{mm}];
    %end;
  end
  disp(sprintf('  load vars (#%d)= %s',mm,tmpvars2load));
else
  tmpvars2load='';
end

if isempty(saveid),
  if exist('tmpids','var'), 
    saveid=tmpids;
  else,
    for mm=1:length(flist),
      saveid{mm}=[flist{mm}(1:4),flist{mm}(end-4:end-1)];
      disp(sprintf('  generating id=%s for %s',saveid{mm},flist{mm}));
      %saveid{mm}=sprintf('''do_saveid'',''%s''',saveid{mm});
    end;
  end;
else,
  for mm=1:length(flist),
    disp(sprintf('  using id=%s for %s',saveid{mm},flist{mm}));
    %saveid{mm}=sprintf('''do_saveid'',''%s''',saveid{mm});
  end;
end;

if isempty(skip1load),
  i1=1;
else,
  i1=2;
  disp(sprintf('  loading %s_res  %s',saveid{1},tmpvars2load));
  eval(sprintf('  load %s_res %s',saveid{1},tmpvars2load));
end;

for mm=i1:length(flist),
  if mm==1,
    if do_dryrun,
      disp(sprintf('  my2Pscr1(''%s'',''do_saveid'',''%s'',%s);',flist{mm},saveid{mm},opt1));
      disp(sprintf('  loading %s_res  %s',saveid{mm},tmpvars2load));
    else,
      disp(sprintf('  my2Pscr1(flist{mm},''do_saveid'',saveid{mm},%s);',opt1));
      eval(sprintf('  my2Pscr1(flist{mm},''do_saveid'',saveid{mm},%s);',opt1));
      if do_loadvars,
        disp(sprintf('  loading %s_res  %s',saveid{mm},tmpvars2load));
        eval(sprintf('  load %s_res %s',saveid{mm},tmpvars2load));
      end;
    end;
  else,
    if do_loadvars,
      if do_dryrun,
        disp(sprintf('  my2Pscr1(''%s'',''do_saveid'',''%s'',%s);',flist{mm},saveid{mm},opt2));
      else,
        disp(sprintf('  my2Pscr1(flist{mm},''do_saveid'',saveid{mm},%s);',opt2));
        eval(sprintf('  my2Pscr1(flist{mm},''do_saveid'',saveid{mm},%s);',opt2));
      end;
    else,
      if do_dryrun,
        disp(sprintf('  my2Pscr1(''%s'',''do_saveid'',''%s'',%s);',flist{mm},saveid{mm},opt1));
      else,
        disp(sprintf('  my2Pscr1(flist{mm},''do_saveid'',saveid{mm},%s);',opt1));
        eval(sprintf('  my2Pscr1(flist{mm},''do_saveid'',saveid{mm},%s);',opt1));
      end;
    end;
  end;
end;

    
