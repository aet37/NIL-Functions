function my2Pscr1(fname,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16)
% Usage ... my2Pscr1(fname,p1,a1,p2,a2,...)
%
% p#s = do_saveid, do_load, do_loadall, do_motc, do_maskreg, do_intc, do_motc_apply, 
%       do_crop, do_imfilt, do_loadfilt, do_intc_apply, do_keepall, do_cycleswap
% average_parms = [#off, #ims_per_trial, #trials]
% motcref = [im# ch#]
%
% ex. 
% my2Pscr1('TSeries-10202017-1531-3030/','do_saveid','tser3030','do_load',{[1],[1:2],[1:800]},...
%    'do_motc','do_motcref',{refim,1},'do_realign','do_intc','do_timing',tt);
% or
% my2Pscr1('TSeries-12282016-1414-2463/','do_load','do_imfilt',[3 0.4],'do_motc','do_motcref',[1 2],'do_intc','do_keepall')
% or
% my2Pscr1('TSeries-12282016-1414-2463/','do_loadall','do_motc',[4 100 1 1 0],'do_motcref',[1 2],'do_realign','do_intc','do_keepraw');
% or
% my2Pscr1('SingleImage-04262021-1927-540/','do_loadall','do_imfilt','do_proj','do_keepraw')
% or
% my2Pscr1('LineScan-10212021-0951-1447/','do_loadall')
% or
% my2Pscr1('TSeries-08252022-1246-9255/','do_loadall','do_cycleconcat','select','do_motc','do_motcref',[1 1],'do_intc','do_keepraw')

if nargin==1,
  saveid='';
  if strcmp(fname(1),'Z')|strcmp(fname(1),'z'),
    p1={'do_loadall'};
  else,
    %p1={'do_loadall','do_imfilt','do_motc','do_motcref',[1 2],'do_realign','do_intc','do_keepall'};
    p1={'do_loadall','do_motc',[4 100 1 1 0],'do_motcref',[1 2],'do_realign','do_intc','do_keepraw'};
  end;
end;
if ischar(p1),
  if strcmp(p1,'default')|strcmp(p1,'def')|strcmp(p1,'Default')|strcmp(p1,'defaults'),
    disp('  using defaults...');
    if strcmp(fname(1),'Z')|strcmp(fname(1),'z'),
      p1={'do_loadall','do_imfilt','do_keepraw'};
    else,
      p1={'do_loadall','do_motc',[4 100 1 1 0],'do_motcref',[1 2],'do_realign','do_intc','do_keepraw'};
    end;
    if nargin>1, 
      for mm=2:nargin-1, 
        disp(sprintf('  adding p%d',mm));
        eval(sprintf('p1{end+1}=p%d;',mm)); 
      end; 
    end;
  end;
end;


vars={'do_saveid','do_load','do_loadall','do_crop','do_motc','do_motcref','do_maskreg','do_intc','do_bin',...
      'do_realign','do_imfilt','do_ffilt','do_arfilt','do_detrend','do_motc_apply','do_intc_apply','do_motcmask',...
      'do_arfilt_apply','do_keepall','do_keepraw','do_saveraw','do_binfirst','do_average','do_timing','do_loadfilt',...
      'do_proj','do_movie','do_cycleswap','do_cycleconcat'};
nvars=length(vars);

if iscell(p1),
  p1cell=p1;
  for mm=1:length(p1cell), eval(sprintf('p%d=p1cell{mm};',mm)); end;
  mynargin=length(p1cell)+1;
else,
  mynargin=nargin;
end;

% initialize this-parse
disp(sprintf('nvars=%d',nvars));
for mm=1:length(vars), 
  eval(sprintf('flags.%s=0;',vars{mm}));
end;

% parse these-settings
disp(sprintf('nargs=%d',nargin));
for mm=1:mynargin-1,
  for nn=1:nvars,
    eval(sprintf('tmptest=strcmp(p%d,''%s'');',mm,vars{nn}));
    if tmptest,
      disp(sprintf('flags.%s=1;',vars{nn}));
      eval(sprintf('flags.%s=1;',vars{nn}));
      if mm<mynargin-1,
        disp(sprintf('flags.%s_parms=p%d;',vars{nn}(4:end),mm+1));
        eval(sprintf('flags.%s_parms=p%d;',vars{nn}(4:end),mm+1));
        eval(sprintf('tmptest2=p%d;',mm+1));
        if isstr(tmptest2), 
          if strcmp(tmptest2(1:2),'do'),
            disp(sprintf('flags.%s_parms=[];',vars{nn}(4:end)));
            eval(sprintf('flags.%s_parms=[];',vars{nn}(4:end)));
          end;
        else,
          disp(sprintf('flags.%s_parms=p%d;',vars{nn}(4:end),mm+1));
          eval(sprintf('flags.%s_parms=p%d;',vars{nn}(4:end),mm+1));
        end;
      else,
        eval(sprintf('flags.%s_parms=[];',vars{nn}(4:end)));
      end;
    end;
  end;
end;

%fname='20160517mouse_avxc1_ledstim01.stk';
%saveid='avxc1_ledstim01';
%nbin=[2 2 2];
%
%do_load=1;
%do_crop=1;
%do_figs=1;
%do_regmask=1;
%do_motdetect=1;
%do_realign=1;
%do_motregress=1;

do_readxml=1;

if flags.do_saveid, saveid=flags.saveid_parms; else, saveid=''; end;
if isempty(saveid),
  if strcmp(fname(end-4),'-'),
    saveid=[fname(1:4),fname(9:10),fname(end-3:end-1)]; 
  else,
    saveid=[fname(1:4),fname(end-4:end-1)]; 
  end
  disp(sprintf('  saveid= %s',saveid));
end;

sname=sprintf('%s_res.mat',saveid);
if exist(sname,'file'),
  tmpin=input(sprintf('--file %s exists [0=quit, 1=replace, 2=load]: ',sname));
  %if isempty(tmpin), return; end;
  if tmpin==2,
    disp(sprintf('  reloading...'));
    flags_here=flags;
    eval(sprintf('load %s',sname));
    flags_prev=flags;
    flags=flags_here;
    clear flags_here
    eval(sprintf('save %s -append flags_prev',sname))
  elseif tmpin==0,
    return;
  else,
    eval(sprintf('save %s -v7.3 flags fname sname saveid',sname));
    disp('--continuing...');
  end;
else,
  eval(sprintf('save %s -v7.3 flags fname sname saveid',sname));
end;
%if exist('tmp_scr.mat'),
%  tmpin=input('  tmp file found, use it? [0=no, 1=yes]: ');
%  if ~isempty(tmpin), if tmpin==1, load('tmp_scr.mat'), end; end;
%else,
%  save tmp_scr fname
%end;

if flags.do_binfirst, if flags.do_bin, flags.do_bin=0; end; end;

if isfield(flags,'do_crop_done'), flags.do_crop=0; end;
if isfield(flags,'do_load_done'), flags.do_load=0; flags.do_loadall=0; end;
if isfield(flags,'do_loadall_done'), flags.do_loadall=0; end;
if isfield(flags,'do_motc_done'), flags.do_motc=0; end;
if isfield(flags,'do_realign_done'), flags.do_realign=0; end;
if isfield(flags,'do_maskreg_done'), flags.do_maskreg=0; end;
if isfield(flags,'do_intc_done'), flags.do_intc=0; end;
if isfield(flags,'do_bin_done'), flags.do_bin=0; end;
if isfield(flags,'do_binfirst_done'), flags.do_binfirst=0; end;
if isfield(flags,'do_detrend_done'), flags.do_detrend=0; end;
if isfield(flags,'do_ffilt_done'), flags.do_ffilt=0; end;
if isfield(flags,'do_arfilt_done'), flags.do_arfilt=0; end;
if isfield(flags,'do_average_done'), flags.do_average=0; end;
if isfield(flags,'do_timing_done'), flags.do_timing=0; end;
if isfield(flags,'do_cycleswap_done'), flags.do_cycleswap=0; end;

if ~isfield(flags,'do_load'), flags.do_load=0; flags.do_load_all=1; end;

if flags.do_cycleconcat, do_readxml=0; end;

if do_readxml, 
  disp('  do read XML');
  info=parsePrairieXML(fname); 
  eval(sprintf('save %s -v7.3 -append info',sname));
else,
  info=[];
end;

flags.notes{1}='Notes';

if flags.do_crop,
  disp('  do_crop...');
  tmpim=readPrairie2(fname,[],[],[],1);
  if isempty(flags.crop_parms),
    tmpok=0;
    while(~tmpok),
      figure(1), clf,
      show(tmpim),
      disp('  select upper-left and lower-right corners...');
      tmpii=round(ginput(2));
      if tmpii(1,1)<1, tmpii(1,1)=1; end;
      if tmpii(1,1)>size(tmpim,2), tmpii(1,1)=size(tmpim,2); end;
      if tmpii(1,2)<1, tmpii(1,2)=1; end;
      if tmpii(1,2)>size(tmpim,1), tmpii(1,2)=size(tmpim,1); end;
      if tmpii(2,1)<1, tmpii(2,1)=1; end;
      if tmpii(2,1)>size(tmpim,2), tmpii(2,1)=size(tmpim,2); end;
      if tmpii(2,2)<1, tmpii(2,2)=1; end;
      if tmpii(2,2)>size(tmpim,1), tmpii(2,2)=size(tmpim,1); end;
      crop_ii=[min(tmpii(:,2)) max(tmpii(:,2)) min(tmpii(:,1)) max(tmpii(:,1))];
      tmpmask=zeros(size(tmpim));
      tmpmask(crop_ii(1):crop_ii(2),crop_ii(3):crop_ii(4))=1;
      show(im_super(tmpim,tmpmask,0.5)), drawnow;
      tmpin=input('  selection ok? [0=no, 1=yes, 9=no+exit]: ');
      if isempty(tmpin),
        tmpok=1;
      elseif tmpin==1,
        tmpok=1;
      elseif tmpin==9,
        crop_ii=[1 size(tmpim,2) 1 size(tmpim,1)];
        tmpok=1;
      end;
    end;
    disp(sprintf('  crop_ii=[%d %d %d %d]',crop_ii(1),crop_ii(2),crop_ii(3),crop_ii(4)));
    flags.crop_parms=crop_ii;
  else,
    crop_ii=flags.crop_parms;
  end;
  tmpim=tmpim(crop_ii(1):crop_ii(2),crop_ii(3):crop_ii(4));
  show(tmpim), drawnow,
  %eval(sprintf('print -dpng samplefig_%s_cropim',saveid));
  clear tmpim tmpok tmpii tmpin
  flags.do_crop_done=1;
  flags.notes{end+1}='  crop done';
  eval(sprintf('save %s -v7.3 -append flags crop_ii',sname));
else,
  if flags.do_cycleconcat,
    crop_ii=[];
  else,
    tmpim=readPrairie2(fname,[],[],[],1);
    crop_ii=[1 size(tmpim,1) 1 size(tmpim,2)];
  end;
  %flags.crop_parms=crop_ii;
end;


if flags.do_loadall,
  disp('  do_loadall...');
  if isempty(strfind(fname,'Line')),
    if flags.do_cycleconcat,
      disp('  using alternate reader (do_cycleconcat)...');
      [data_cycles,data_info]=readPrairie2e(fname);
      data_cycles,
      if flags.do_keepall|flags.do_keepraw, eval(sprintf('save %s -v7.3 -append data_cycles data_info',sname)); end;
      if flags.do_saveraw, eval(sprintf('save %s_cyc -v7.3 data_cycles data_info',sname)); end;
      
      if ischar(flags.cycleconcat_parms),
        flags.cycleconcat_parms=input('  enter cell# to include as matlab vector (eg. [1 2 5 6]): ');
      end;
      if isempty(flags.cycleconcat_parms), flags.cycleconcat_parms=[1:length(data_cycle)]; end;
      for oo=1:length(flags.cycleconcat_parms),
          if oo==1,
              data=data_cycles{flags.cycleconcat_parms(1)};
          else
              tmpsz=size(data_cycles{flags.cycleconcat_parms(oo)});
              data(:,:,:,end+1:end+tmpsz(4))=data_cycles{flags.cycleconcat_parms(oo)};
          end
      end
      if isempty(crop_ii), crop_ii=[1 size(data,1) 1 size(data,2)]; end;
      
      flags.do_cycleconcat_done=1;
      if flags.do_keepraw==0, clear data_cycles data_info , end
    else
      disp('  using regular reader (no do_cycleconcat)...');
      data=readPrairie2(fname);
    end
  else,
    disp('  warning: LineScan data, not all options are functional'),
    data=readPrairie2c(fname);
    % read reference and line position
    lineRefIm=readPrairieRef(fname);
    eval(sprintf('save %s -append lineRefIm',sname));
  end;
  if flags.do_crop,
    data=data(crop_ii(1):crop_ii(2),crop_ii(3):crop_ii(4),:,:,:);
  end;
  datasz=size(data);
  disp(sprintf('  vol_dim=[%d %d %d %d %d]',size(data,1),size(data,2),size(data,3),size(data,4),size(data,5)));
  nims=datasz(end);
  if isempty(strfind(fname,'Line')),
    avgim_raw=squeeze(mean(data,length(datasz))); 
    stdim_raw=squeeze(std(data,[],length(datasz)));
    avgtc_raw=squeeze(mean(mean(data,1),2));
    if length(datasz)<5,
      figure(2), clf,
      plot(avgtc_raw'), axis('tight'), grid('on'),
      xlabel('im#'), ylabel('data mean intensity'),
      eval(sprintf('print -dpng samplefig_%s_data_avgtc',saveid));
    end;
  else,
    avgim_raw=[];
    stdim_raw=[];
    avgtc_raw=squeeze(mean(data,2));
  end;
  flags.do_loadall_done=1;
  if (flags.do_keepraw)&((nims*prod(datasz(1:2)))>(8000*256*256)),
      disp('  warning: switching do_keepraw to do_saveraw');
      flags.do_keepraw=0;
      flags.do_saveraw=1;
  end
  if flags.do_keepall|flags.do_keepraw,
    data_raw=data;
    eval(sprintf('save %s -v7.3 -append data_raw',sname));
    clear data_raw
  elseif flags.do_saveraw,
    data_raw=data;
    eval(sprintf('save %s_raw -v7.3 data_raw',sname(1:end-4)));
    clear data_raw    
  end;
  flags.notes{end+1}='  loadall done';
  %disp(sprintf('save %s -v7.3 -append data avgim_raw stdim_raw avgtc_raw nims flags',sname));
  eval(sprintf('save %s -v7.3 -append data avgim_raw stdim_raw avgtc_raw nims flags',sname));
end;

if flags.do_load,
  disp('  do_load...');
  if flags.do_binfirst,
    disp('  do_binfirst also...');
    if isempty(flags.load_parms),
      ncycles=1;
      nch=[1:length(info.Frames(1).fname)]; %not correct
      nims=[1:length(info.Frames)]; %not correct
    else,
      nims=flags.load_parms{1};
      nch=flags.load_parms{2};
      ncycles=flags.load_parms{3};  
    end;
    if ncycles==1,
      for nn=1:nch, for oo=1:floor(nims(end)/flags.bin_parms(3)),
        tmpim=readPrairie2(fname,1,[],nn,(oo-1)*flags.bin_parms(3)+[1:flags.bin_parms(3)]);
        if flags.do_imfilt,
          tmpim=medfilt2(tmpim,flags.imfilt_parms);
        end;
        tmpim=squeeze(volbin(tmpim,flags.bin_parms));
        data(:,:,nn,oo)=tmpim;
      end; end;
    else,
      for mm=1:ncycles, for nn=1:nch, for oo=1:floor(nims(end)/flags.bin_parms(3)),
        tmpim=readPrairie2(fname,mm,[],nn,(oo-1)*flags.bin_parms(3)+[1:flags.bin_parms(3)]);
        if flags.do_imfilt,
          tmpim=medfilt2(tmpim,flags.imfilt_parms);
        end;
        tmpim=squeeze(volbin(tmpim,flags.bin_parms));
        data(:,:,mm,nn,oo)=tmpim;
      end; end; end;
    end;
    datasz=size(data);
    avgim_bin=squeeze(mean(data,length(datasz))); 
    stdim_bin=squeeze(std(data,[],length(datasz)));
    avgtc_bin=squeeze(mean(mean(data,1),2));
    disp(sprintf('  ... last im %d',nims(end)));
    flags.do_binfirst=0; flags.do_bin=0;
  else,    
    if isempty(flags.load_parms),
      data=readPrairie2(fname);
      nch=size(data,3);
      nims=size(data,4);
      ncycles=size(data,5);
    else,    
      nims=flags.load_parms{1};
      nch=flags.load_parms{2};
      ncycles=flags.load_parms{3};  
      data=readPrairie2(fname,flags.load_parms{1},[],flags.load_parms{2},flags.load_parms{3});
    end;
    if flags.do_crop, 
      data=data(crop_ii(1):crop_ii(2),crop_ii(3):crop_ii(4),:,:,:); 
    else,
      crop_ii=[1 size(tmpim,2) 1 size(tmpim,1)];
    end;
  end;
  datasz=size(data);
  avgim_raw=squeeze(mean(data,length(datasz))); 
  stdim_raw=squeeze(std(data,[],length(datasz)));
  avgtc_raw=squeeze(mean(mean(data,1),2));
  if length(datasz)<5,
    figure(2), clf,
    if length(avgtc_raw)==length(nims),
      plot(nims,avgtc_raw'), axis('tight'), grid('on'),
    else,
      plot(avgtc_raw'), axis('tight'), grid('on'),
    end;
    xlabel('im#'), ylabel('data mean intensity'),
    eval(sprintf('print -dpng samplefig_%s_data_avgtc',saveid));
  end;
  flags.do_load_done=1;
  flags.notes{end+1}='  load done';
  if (flags.do_keepraw)&((nims*prod(datasz(1:2)))>(8000*256*256)),
    disp('  warning: switching do_keepraw to do_saveraw');
    flags.do_keepraw=0;
    flags.do_saveraw=1;
  end
  if flags.do_keepall|flags.do_keepraw,
    data_raw=data;
    eval(sprintf('save %s -v7.3 -append data_raw',sname));
    clear data_raw
    flags.notes{end+1}='  save raw done';
  elseif flags.do_saveraw,
    data_raw=data;
    eval(sprintf('save %s_raw -v7.3 data_raw',sname(1:end-4)));
    clear data_raw
    flags.notes{end+1}='  save raw done';
  end;
  %disp(sprintf('save %s -v7.3 -append data avgtc_raw avgim_raw stdim_raw nims flags',sname));
  eval(sprintf('save %s -v7.3 -append data avgtc_raw avgim_raw stdim_raw nims nch ncycles flags',sname));
  if exist('avgtc_bin','var'),
    do_binfirst_done=1; do_bin_done=1;
    eval(sprintf('save %s -v7.3 -append avgtc_bin avgim_bin stdim_bin flags',sname));
  end;
end;


if flags.do_cycleswap,
  disp('  do_cycleswap...');
  data_orig=data;
  clear data
  for mm=1:datasz(4),
    data(:,:,:,:,mm)=squeeze(data_orig(:,:,:,mm,:));
  end
  datasz=size(data);
  clear data_orig
  avgim_raw=squeeze(mean(data,length(datasz))); 
  stdim_raw=squeeze(std(data,[],length(datasz)));
  avgtc_raw=squeeze(mean(mean(data,1),2));
  flags.notes{end+1}='  do cycleswap done';
  flags.do_cycleswap_done=1; 
  eval(sprintf('save %s -v7.3 -append data avgtc_raw avgim_raw stdim_raw flags',sname));
end


if flags.do_binfirst,
  disp('  do bin first...');
  data_bin=volbin(data,flags.bin_parms);
  avgtc_bin=squeeze(mean(mean(data_bin,1),2));
  avgim_bin=squeeze(mean(data_bin,length(datasz)));
  stdim_bin=squeeze(std(data_bin,[],length(datasz)));
  data=data_bin; clear data_bin
  flags.do_bin_done=1;
  flags.notes{end+1}='  binfirst done';
  if flags.do_keepall,
    data_bin=data;
    eval(sprintf('save %s -v7.3 -append data_bin',sname));
    clear data_bin
  end;
  disp(sprintf('save %s -v7.3 -append data avgim_bin stdim_bin avgtc_bin flags',sname))
  eval(sprintf('save %s -v7.3 -append data avgim_bin stdim_bin avgtc_bin flags',sname))
end;

if flags.do_imfilt,
  disp('  do imfilt...');
  if isempty(flags.imfilt_parms), flags.imfilt_parms=[3 0.4 0]; end;
  if length(flags.imfilt_parms)==1, flags.imfilt_parms(2:3)=0; end;
  if length(flags.imfilt_parms)==2, flags.imfilt_parms(3)=0; end;
  disp(sprintf('  imfilt_parms=[%d %.2f %d]',flags.imfilt_parms(1),flags.imfilt_parms(2),flags.imfilt_parms(3)));
  if flags.imfilt_parms(3)>0,
    data_if=twop_filt(data,flags.imfilt_parms(1),flags.imfilt_parms(2),flags.imfilt_parms(3));
  else,
    data_if=twop_filt(data,flags.imfilt_parms(1),flags.imfilt_parms(2));      
  end;
  if flags.do_keepall,
    disp(sprintf('save %s -v7.3 -append data_if',sname));
    eval(sprintf('save %s -v7.3 -append data_if',sname));
  end;
  avgim_if=mean(data_if,length(datasz));
  stdim_if=std(data_if,[],length(datasz));
  avgtc_if=squeeze(mean(mean(data_if,1),2));
  data=data_if; clear data_if
  flags.do_imfilt_done=1;
  flags.notes{end+1}='  imfilt done';
  disp(sprintf('save %s -v7.3 -append data avgim_if stdim_if avgtc_if flags',sname))
  eval(sprintf('save %s -v7.3 -append data avgim_if stdim_if avgtc_if flags',sname))  
end;

if flags.do_motcref==0,
  flags.motcref_parms=[1 1];
  motc_ref=flags.motcref_parms(1);
  motc_refch=flags.motcref_parms(2);
else,
  disp(sprintf('  motcref length= %d',length(flags.motcref_parms)));
  if iscell(flags.motcref_parms),
    motc_ref=flags.motcref_parms{1};
    motc_refch=flags.motcref_parms{2};
  elseif length(flags.motcref_parms)==2,
    motc_ref=flags.motcref_parms(1);
    motc_refch=flags.motcref_parms(2);
  elseif isempty(flags.motcref_parms),
    flags.motcref_parms=[1 1];
    motc_ref=1;
    motc_refch=1;
  else,
    motc_ref=flags.motcref_parms;
    motc_refch=1;
  end;
  disp(sprintf('  motc_ref= im#%d  ch#%d',motc_ref(1),motc_refch(1)));
  flags.notes{end+1}=sprintf('  motc_ref= im#%d  ch#%d',motc_ref(1),motc_refch(1));
end;


if flags.do_motc,
  disp(sprintf('  do_motc (refCh=%d)...',motc_refch));
  if isempty(flags.motc_parms), if (size(data,1)*size(data,2))>1600, flags.motc_parms=[4 100 1 1 0]; else, flags.motc_parms=[4 100 1 1 0]; end; end;
  if flags.do_motcmask,
    flags.motc_mask=flags.motcmask_parms;
  else,
    flags.motc_mask=ones(size(data(:,:,1)));
  end;
  if motc_refch>0,
    if length(datasz)>4,
      for oo=1:datasz(4), 
        xx_motc(:,:,oo)=imMotDetect(squeeze(data(:,:,motc_refch,oo,:)),motc_ref,flags.motc_parms,flags.motc_mask);
      end;
    elseif length(datasz)==3,
      xx_motc=imMotDetect(data,motc_ref,flags.motc_parms,flags.motc_mask);
    else,
      xx_motc=imMotDetect(squeeze(data(:,:,motc_refch,:)),motc_ref,flags.motc_parms,flags.motc_mask);
    end;
  else,
    if length(datasz)>4,
      for oo=1:datasz(4),
        xx_motc(:,:,oo)=imMotDetect(squeeze(mean(data(:,:,:,oo,:),3)),motc_ref,flags.motc_parms,flags.motc_mask);
      end;
    elseif length(datasz)==3,
      xx_motc=imMotDetect(data,motc_ref,flags.motc_parms,flags.motc_mask);
    else,
      xx_motc=imMotDetect(squeeze(mean(data,3)),motc_ref,flags.motc_parms,flags.motc_mask);
    end;
  end;
  
  if length(datasz)<5,
    figure(2), clf,
    plot(xx_motc), axis('tight'), grid('on'),
    xlabel('im#'), ylabel('pixel displacement'), legend('x','y'),
    eval(sprintf('print -dpng samplefig_%s_xxmotc',saveid));
  else,
    figure(2), clf,
    plot(xx_motc(:,:,1)), axis('tight'), grid('on'),
    xlabel('im#'), ylabel('pixel displacement'), legend('x','y'),
    eval(sprintf('print -dpng samplefig_%s_xxmotc',saveid));      
  end;
  flags.do_realign=1;
  flags.do_motc_done=1;
  if ~isfield(flags,'do_realign'), flags.do_realign=1; end;
  flags.notes{end+1}='  motc done'; 
  %disp(sprintf('save %s -v7.3 -append xx_motc motc_ref motc_refch flags',sname));
  eval(sprintf('save %s -v7.3 -append xx_motc motc_ref motc_refch flags',sname));
else,
  flags.do_realign=0;
end;

if flags.do_motc_apply,
  flags.do_realign=1;
  xx_motc=flags.motc_apply_parms;
end;
  
if flags.do_realign,
  disp('  do_realign...'); 
  if ~isfield(flags,'realign_parms'), flags.realign_parms=[]; end;
  if isempty(flags.realign_parms), flags.realign_parms=1; end;
  ss_xc=sum(xx_motc(:,1:2,:).^2,2).^0.5;
  disp(sprintf('  motc result %.2f percent (%d) over 0.2 pix xy shift',100*sum(ss_xc>0.14)/length(ss_xc),sum(ss_xc>0.14)));
  tmpok=sum(ss_xc(:)>0.14)>1;
  flags.do_realign_artinterp=0;
  if flags.realign_parms(1)==2,
    if length(datasz)<=4,
      clf,
      subplot(211), plot(xx_motc), 
      axis('tight'), grid('on'), ylabel('Displacement'),
      subplot(212), plot(avgtc_raw'),
      axis('tight'), grid('on'), ylabel('Avg Img Intensity'),
    else,
      if flags.do_cycleswap,
        xx_motc_all=[]; avgtc_raw_all=[];
        for pp=1:datasz(4),
          xx_motc_all=[xx_motc_all; xx_motc(:,:,pp)]; avgtc_raw_all=[avgtc_raw_all; avgtc_raw(:,:,pp)];
        end;
        clf,
        subplot(211), plot(xx_motc_all), 
        axis('tight'), grid('on'), ylabel('Displacement'),
        subplot(212), plot(avgtc_raw_all'),
        axis('tight'), grid('on'), ylabel('Avg Img Intensity'),
      else,
        clf,
        subplot(211), plot(xx_motc(:,:,1)), 
        axis('tight'), grid('on'), ylabel('Displacement'),
        subplot(212), plot(squeeze(avgtc_raw(:,1,:))'),
        axis('tight'), grid('on'), ylabel('Avg Img Intensity'),
      end
    end;

    tmpin=input('  continue? (0:skip, 1:yes, 3:interp-art): ');
    if isempty(tmpin), tmpin=1; end;
    if tmpin==0, tmpok=0; end;
    if tmpin==3,
      if (length(datasz)>4)&flags.do_cycleswap,
        tmptc=avgtc_raw_all(:,motc_refch);
        tmptc=tmptc/mean(tmptc(2:6))-1;
        clf,
        subplot(211), plot(xx_motc_all), 
        axis('tight'), grid('on'), ylabel('Displacement'),
        subplot(212), plot(tmptc),
        axis('tight'), grid('on'), ylabel('Avg Img Intensity'),
      elseif length(datasz)>4,
        tmptc=squeeze(mean(mean(data(:,:,motc_refch,1,:),1),2));
        tmptc=tmptc/mean(tmptc(2:6))-1;
        clf,
        subplot(211), plot(xx_motc(:,:,1)), 
        axis('tight'), grid('on'), ylabel('Displacement'),
        subplot(212), plot(tmptc),
        axis('tight'), grid('on'), ylabel('Avg Img Intensity'),
      else,
        tmptc=squeeze(mean(mean(data(:,:,motc_refch,:),1),2));
        tmptc=tmptc/mean(tmptc(2:6))-1;
        clf,
        subplot(211), plot(xx_motc), 
        axis('tight'), grid('on'), ylabel('Displacement'),
        subplot(212), plot(tmptc),
        axis('tight'), grid('on'), ylabel('Avg Img Intensity'),
      end;  
      thr_art=input('  artifact intensity thr [def=1.0]: ');
      if isempty(thr_art), thr_art=1.0; end;
      flags.do_realign_artinterp=1;
      flags.realign_artinterp_parms=thr_art;
    end;
  elseif flags.realign_parms(1)==3,
    flags.do_realign_artinterp=1;
    if length(flags.realign_parms)>1,
      flags.realign_artinterp_parms=flags.realign_parms(2);
    end;
  end;
  if flags.do_realign_artinterp,
    if ~isfield(flags,'realign_artinterp_parms'), flags.realign_artinterp_parms=[]; end;
    if isempty(flags.realign_artinterp_parms),
      thr_art=1.0;
    else,
      tht_art=flags.realign_artinterp_parms;
    end;
    disp(sprintf('  replacing motion artifacts with thr>%.3f',thr_art));
    flags.notes{end+1}=sprintf('  replacing motion artifacts with thr>%.3f',thr_art); 
    %tmpi1=find(sqrt(sum(xx_motc.^2,2))<thr_art);
    %tmpi2=find(sqrt(sum(xx_motc.^2,2))>thr_art);
    %tmptc=squeeze(mean(mean(data(:,:,motc_refch,:),1),2));
    %tmptc=tmptc/mean(tmptc(2:6))-1;
    %tmpi1=find(abs(tmptc)<thr_art);
    %tmpi2=find(abs(tmptc)>=thr_art);
    tmpi1=find(tmptc<thr_art);
    tmpi2=find(tmptc>=thr_art);
    if isempty(tmpi2),
      disp(sprintf('  no motion artifacts found with thr of %.3f, skipping...',thr_art));
    else,
      if exist('xx_motc_all','var'),
        xx_motc_orig=xx_motc;
        xx_motc_origall=xx_motc_all;
        xx_motc=xx_motc_all;
        xx_motc(tmpi2,1)=interp1(tmpi1,xx_motc_origall(tmpi1,1),tmpi2);
        xx_motc(tmpi2,2)=interp1(tmpi1,xx_motc_origall(tmpi1,2),tmpi2);
        xx_motc_all=xx_motc;
        clear xx_motc
        for pp=1:datasz(4), xx_motc(:,:,pp)=xx_motc_all([1:datasz(5)]+(mm-1)*datasz(5),:); end;
        flags.motc_i1=tmpi1; flags.motc_i2=tmpi2; flags.motc_avgtcf=tmptc; flags.motc_thrf=thr_art;
        eval(sprintf('save %s -append xx_motc xx_motc_all xx_motc_orig xx_motc_origall',sname));
      else,
        xx_motc_orig=xx_motc;
        xx_motc(tmpi2,1)=interp1(tmpi1,xx_motc_orig(tmpi1,1),tmpi2);
        xx_motc(tmpi2,2)=interp1(tmpi1,xx_motc_orig(tmpi1,2),tmpi2);
        flags.motc_i1=tmpi1; flags.motc_i2=tmpi2; flags.motc_avgtcf=tmptc; flags.motc_thrf=thr_art;
        eval(sprintf('save %s -append xx_motc xx_motc_orig',sname));
      end
    end;
    tmpok=sum(ss_xc(:)>0.14)>1;    
  end;
  if tmpok,
    data_motc=data;
    if length(datasz)>4,
      for oo=1:datasz(4), for nn=1:size(data,3),
        disp(sprintf('  realigning ch%d (%d) slice %d (%d)',nn,datasz(3),oo,datasz(4)));
        data_motc(:,:,nn,oo,:)=imMotApply(xx_motc(:,:,oo),squeeze(data(:,:,nn,oo,:)),flags.motc_parms,4);
      end; end;
    elseif length(datasz)==3,
      data_motc=imMotApply(xx_motc,data,flags.motc_parms,4);
    else,
      for nn=1:size(data,3),
        disp(sprintf('  realigning ch%d (%d)',nn,size(data_motc,4)));
        data_motc(:,:,nn,:)=imMotApply(xx_motc,squeeze(data(:,:,nn,:)),flags.motc_parms,4);
      end;
    end;
    avgtc_motc=squeeze(mean(mean(data_motc,1),2));
    avgim_motc=squeeze(mean(data_motc,length(datasz)));
    stdim_motc=squeeze(std(data_motc,[],length(datasz)));
    if flags.do_keepall,
      eval(sprintf('save %s -v7.3 -append data_motc',sname));
    end;
    data=data_motc;
    clear data_motc
    flags.do_realign_done=1;
    flags.notes{end+1}='  realign done'; 

    disp(sprintf('save %s -v7.3 -append data avgim_motc stdim_motc avgtc_motc flags',sname));
    eval(sprintf('save %s -v7.3 -append data avgim_motc stdim_motc avgtc_motc flags',sname));
  else,
    disp('  skipping realign, no significant motion detected...'),
    flags.do_realign=0;
    flags.do_realign_done=-1;
    eval(sprintf('save %s -v7.3 -append flags',sname));    
  end;
end;

if flags.do_maskreg,
  disp('  do_maskreg...');
  if ~isfield(flags,'realign_parms'), flags.realign_parms=[]; end;
  if isempty(flags.maskreg_parms),
    tmpim=data(:,:,1,1); 
    mask_reg=bwlabel(selectMask(tmpim));
  else,
    mask_reg=flags.maskreg_parms;
    clf, show(mask_reg), drawnow,
  end;
  mask_reg_tc=getStkMaskTC(data,mask_reg);

  eval(sprintf('print -dpng samplefig_%s_maskreg',saveid));
  clf, plot(mask_reg_tc(1).atc), axis('tight'), grid('on'), drawnow,
  xlabel('im#'), ylabel('maskreg roi intensity'),
  eval(sprintf('print -dpng samplefig_%s_maskregtc',saveid));
  flags.do_maskreg_done=1;
  flags.notes{end+1}='  mask reg done'; 
  %disp(sprintf('save %s -v7.3 -append mask_reg mask_reg_tc flags',sname))
  eval(sprintf('save %s -v7.3 -append mask_reg mask_reg_tc flags',sname))
end;

if flags.do_intc|flags.do_intc_apply|flags.do_maskreg,
  disp('  do_regress(intc/maskreg)...');
  reg_mat=[];
  if flags.do_maskreg, reg_mat=[reg_mat mask_reg_tc.atc]; end;
  if flags.do_intc_apply, reg_mat=[reg_mat flags.intc_apply_parms]; end;
  if ~isfield(flags,'intc_parms'), flags.intc_parms=[]; end;
  if isempty(flags.intc_parms), flags.intc_parms=0; end;
  if exist('xx_motc','var'),
    disp('  do_regress_with_motion...');
    if length(datasz)>4,
      if isfield(flags,'motc_i1'),
        disp(sprintf('  using %d out of %d (5-dim)',length(flags.motc_i1),datasz(end)));
        for oo=1:datasz(4), for nn=1:datasz(3),
          [data_intc(:,:,nn,oo,:),xx_intc(nn,oo)]=imMotReg(squeeze(data(:,:,nn,oo,:)),xx_motc(:,:,oo),flags.intc_parms,reg_mat,[],flags.motc_i1);
        end; end;
        avgim_intc_i1=mean(data(:,:,:,:,flags.motc_i1),5);
        stdim_intc_i1=std(data(:,:,:,:,flags.motc_i1),[],5);
        flags.notes{end+1}=sprintf('  intc: using %d out of %d (5-dim)',length(flags.motc_i1),datasz(end)); 
      else,
        for oo=1:datasz(4), for nn=1:datasz(3),
          [data_intc(:,:,nn,oo,:),xx_intc(nn,oo)]=imMotReg(squeeze(data(:,:,nn,oo,:)),xx_motc(:,:,oo),flags.intc_parms,reg_mat);
        end; end;
      end;
    else,
      if isfield(flags,'motc_i1'),
        disp(sprintf('  using %d out of %d (4-dim)',length(flags.motc_i1),datasz(end)));
        for nn=1:size(data,3),
          [data_intc(:,:,nn,:),xx_intc(nn)]=imMotReg(squeeze(data(:,:,nn,:)),xx_motc,flags.intc_parms,reg_mat,[],flags.motc_i1);
        end;
        avgim_intc_i1=mean(data(:,:,:,flags.motc_i1),4);
        stdim_intc_i1=std(data(:,:,:,flags.motc_i1),[],4);
        flags.notes{end+1}=sprintf('  intc: using %d out of %d (4-dim)',length(flags.motc_i1),datasz(end)); 
      else,
        for nn=1:size(data,3),
          [data_intc(:,:,nn,:),xx_intc(nn)]=imMotReg(squeeze(data(:,:,nn,:)),xx_motc,flags.intc_parms,reg_mat);
        end;
      end;
    end;
  else,
    if length(datasz)>4,
      for oo=1:datasz(4), for nn=1:datasz(3),   
        [data_intc(:,:,nn,oo,:),xx_intc(nn,oo)]=imMotReg(squeeze(data(:,:,nn,oo,:)),[],flags.intc_parms,reg_mat);
      end; end;
    else,
      for nn=1:size(data,3),   
        [data_intc(:,:,nn,:),xx_intc(nn)]=imMotReg(squeeze(data(:,:,nn,:)),[],flags.intc_parms,reg_mat);
      end;
    end;
  end;
  avgtc_intc=squeeze(mean(mean(data_intc,1),2));
  avgim_intc=squeeze(mean(data_intc,length(datasz)));
  stdim_intc=squeeze(std(data_intc,[],length(datasz)));

  if length(datasz)<5,
    figure(2), clf,
    plot(avgtc_intc'), axis('tight'), grid('on'),
    xlabel('im#'), ylabel('dataic mean intensity'),
    eval(sprintf('print -dpng samplefig_%s_dataic_avgtc',saveid));
  end;

  if isfield(flags,'motc_i1'),
    eval(sprintf('save %s -v7.3 -append data avgim_intc_i1 stdim_intc_i1',sname));
  end;
  
  if flags.do_keepall,
    eval(sprintf('save %s -v7.3 -append data_intc',sname));
  end;
  % exclusion or skipping of intc would go here
  % if necessary
  data=data_intc; clear data_intc
  
  flags.do_intc_done=1;
  flags.notes{end+1}='  intc done'; 

  disp(sprintf('save %s -v7.3 -append data xx_intc avgim_intc stdim_intc avgtc_intc flags',sname));
  eval(sprintf('save %s -v7.3 -append data xx_intc avgim_intc stdim_intc avgtc_intc flags',sname));
end;

if flags.do_bin,
  disp('  do bin...');
  if exist('data_intc','var'),
    data_bin=volbin(data_intc,flags.bin_parms);
    clear dataic
  else,
    data_bin=volbin(data,flags.bin_parms);
  end;
  avgtc_bin=squeeze(mean(mean(data_bin,1),2));
  avgim_bin=mean(data_bin,3); stdim_bin=std(data_bin,[],3);
  %eval(sprintf('save %s -v7.3 -append data_bin',saveid))
  data=data_bin; clear data_bin
  flags.do_bin_done=1;
  flags.notes{end+1}='  bin done'; 
  if flags.do_keepall,
    data_bin=data;
    eval(sprintf('save %s -v7.3 -append data_bin',sname));
    clear data_bin
  end;
  disp(sprintf('save %s -v7.3 -append data avgim_bin stdim_bin avgtc_bin flags',sname));
  eval(sprintf('save %s -v7.3 -append data avgim_bin stdim_bin avgtc_bin flags',sname));
end;

if flags.do_proj,
  if strcmp(sname(1:4),'Sing'),
    for mm=1:size(data,3),
      tmpim(:,:,mm)=imwlevel(data(:,:,mm),[],1);
    end;
    if mm==1, 
      tmpim(:,:,2)=tmpim(:,:,1); tmpim(:,:,3)=tmpim(:,:,1);
    elseif mm==2,
      tmpim(:,:,3)=0;
    end;
    imwrite(tmpim,[saveid,'_im.jpg'],'JPEG','Quality',100);
  else,
  if exist('xx_motc','var')&exist('data_raw','var'),
    if max(xx_motc(:))>0.33*mean([size(data,1) size(data,2)]),
      tmpdata=data;
      data=data_raw;
    end;
  end;
  figure(2), clf,
  if length(size(data))>3,
    if size(data,3)>3,
      showProj(data(:,:,end-2:end,:)),
    else,
      showProj(data),
    end;
  else,
    showProj(data),
  end;
  eval(sprintf('print -dpng %s_proj',saveid));
  if exist('tmpdata','var'),
    data=tmpdata;
    clear tmpdata
  end;
  end;
end;
 
if flags.do_movie,
  if exist('xx_motc','var')&exist('data_raw','var'),
    if max(xx_motc(:))<0.33*mean([size(data,1) size(data,2)]),
      tmpdata=data;
      data=data_raw;
    end;
  end;
  figure(2), clf,
  if length(datasz)>3,
    if size(data,3)>3,
      tmpim=mean(data(:,:,end-2:end,:),4);
      showMovie(data(:,:,end-2:end,:),[],[min(tmpim(:)) max(tmpim(:))],[saveid,'_mov.mp4']),
    elseif length(datasz)>4,
      tmpim=squeeze(mean(data,4));
      showMovie(tmpim,[],[min(tmpim(:)) max(tmpim(:))],[saveid,'_mov.mp4']),
    else
      tmpim=mean(data,4);
      showMovie(data,[],[min(tmpim(:)) max(tmpim(:))],[saveid,'_mov.mp4']),
    end;
  else,
    tmpim=mean(data,3);
    showMovie(data,[],[min(tmpim(:)) max(tmpim(:))],[saveid,'_mov.mp4']),
  end;
  if exist('tmpdata','var'),
    data=tmpdata;
    clear tmpdata
  end;
end;


if flags.do_detrend,
  if isempty(flags.detrend_parms), flags.detrend_parms=4; end;
  disp(sprintf('  do_detrend (%d)...',flags.detrend_parms));
  data_det=data;
  tmpx=[1:size(data_det,3)];
  xx_det=zeros(size(data_det,1),size(data_det,2),flags.detrend_parms+1);
  for mm=1:size(data_det,1), for nn=1:size(data_det,2),
    tmpy=squeeze(data_det(mm,nn,:));
    tmpp=polyfit(tmpx(:),tmpy(:),flags.detrend_parms);
    tmpd=polyval(tmpp,tmpx(:));
    data_det(mm,nn,:)=tmpy(:)-tmpd(:)+mean(tmpd);
    xx_det(mm,nn,:)=tmpp;
  end; end;
  avgtc_det=squeeze(mean(mean(data_det,1),2));
  avgim_det=mean(data_det,3);
  stdim_det=std(data_det,[],3);
  data=data_det;
  
  clear data_det
  flags.do_detrend_done=1;
  disp(sprintf('save %s -v7.3 -append data xx_det avgim_det stdim_det avgtc_det flags',sname));
  eval(sprintf('save %s -v7.3 -append data xx_det avgim_det stdim_det avgtc_det flags',sname));
end;


if flags.do_timing,
  % data has an accompanying time vector that will be used
end;


if flags.do_ffilt,
  if isempty(flags.ffilt_parms),
    flags.ffilt_parms={[0.03 0.2],[0.005 0.04],[-1 1],0.1};
  end;
  ffilt_parms=flags.ffilt_parms;
  data_ffilt=data;
  for mm=1:size(data_ffilt,1), for nn=1:size(data_ffilt,2),
    tmptc=squeeze(data_ffilt(mm,nn,:));
    tmptcf=fermi1d(tmptc(:)-mean(tmptc),ffilt_parms{1},ffilt_parms{2},ffilt_parms{3},ffilt_parms{4});
    data_ffilt(mm,nn,:)=tmptcf;
  end; end;
  avgtc_ffilt=squeeze(mean(mean(data_ffilt,1),2));
  avgim_ffilt=mean(data_ffilt,3);
  stdim_ffilt=std(data_ffilt,[],3);
  if flags.do_keepall,
    eval(sprintf('save %s -v7.3 -append data_ffilt',sname));
  end;
  data=data_ffilt;
  clear data_ffilt
  flags.do_ffilt_done=1;
  disp(sprintf('save %s -v7.3 -append data avgim_ffilt stdim_ffilt avgtc_ffilt flags',sname));
  eval(sprintf('save %s -v7.3 -append data avgim_ffilt stdim_ffilt avgtc_ffilt flags',sname));
end;


if flags.do_arfilt,
  if isempty(flags.arfilt_parms), flags.arfilt_parms=2; end;
  disp(sprintf('  do_arfilt (%d)...',flags.arfilt_parms));
  data_ar=data;
  xx_ar=zeros(size(data_det,1),size(data_det,2),flags.arfilt_parms);
  for mm=1:size(data_det,1), for nn=1:size(data_det,2),
    tmpy=squeeze(data_det(mm,nn,:));
    [tmpyf,tmparc]=myarfilt(tmpy,flags.arfilt_parms);
    data_ar(mm,nn,:)=tmpyf(:);
    xx_ar(mm,nn,:)=tmparc;
  end; end;
  avgtc_ar=squeeze(mean(mean(data_ar,1),2));
  avgim_ar=mean(data_ar,3);
  stdim_ar=std(data_ar,[],3);
  
  if flags.do_keepall,
     eval(sprintf('save %s -v7.3 -append data_ar',sname));
  end;     
  data=data_ar;
  clear data_ar
  flags.do_arfilt_done=1;
  disp(sprintf('save %s -v7.3 -append data xx_ar avgim_ar stdim_ar avgtc_ar flags',sname));
  eval(sprintf('save %s -v7.3 -append data xx_ar avgim_ar stdim_ar avgtc_ar flags',sname));
end;


if flags.do_average,
  disp('  do average...');
  if isempty(flags.average_parms),
    disp('  no average parameters found, skipping...');
    flags.do_average=-1;
  else,
    ddim=size(data);
    noff=flags.average_parms(1);
    nimtr=flags.average_parms(2);
    ntr=flags.average_parms(3);
    if flags.do_timing,
      adata=zeros(ddim(1),ddim(2),nimtr);
      for nn=1:ntr, adata=data(:,:,[1:nimtr]+timing_parms(nn)-1); end;
      adata=adata/ntr;
      avgtc_avg=squeeze(mean(mean(adata,1),2));
      flags.do_average_done=1; flags.do_timing_done=1;
      disp(sprintf('save %s -v7.3 -append adata avgtc_avg flags',sname));
      eval(sprintf('save %s -v7.3 -append adata avgtc_avg flags',sname));
    else,
      adata=mean(reshape(data(:,:,[1:nimtr*ntr]+noff-1),ddim(1),ddim(2),nimtr,ntr),4);
      avgtc_avg=squeeze(mean(mean(adata,1),2));
      avgim_avg=mean(adata,3); stdim_avg=std(adata,[],3);
      flags.do_average_done=1;
      disp(sprintf('save %s -v7.3 -append adata avgim_avg stdim_avg avgtc_avg flags',sname));
      eval(sprintf('save %s -v7.3 -append adata avgim_avg stdim_avg avgtc_avg flags',sname));
    end;
  end;
end;


