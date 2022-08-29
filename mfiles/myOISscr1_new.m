function myOISscr1_new(fname,saveid,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19)
% Usage ... myOISscr1_new(fname,saveid,p1,a1,p2,a2,...)
%
% p#s = do_load, do_loadall, do_motc, do_maskreg, do_intc, do_motc_apply,
% do_intc_apply, do_keepalldata, do_keepraw
% intc_parms=[motf_thr_filt(1=yes_filt_def), verify__flag=0_def]
% average_parms = [#off, #ims_per_trial, #trials,opt=bin3,subfr]
%
% ex. 
% myOISscr1_new('20160517mouse_avxc1_ledstim01.stk','avxc1_ledstim01','do_load',[1:6100],...
%    'do_crop','do_motc','do_realign','do_intc','do_maskreg','do_bin',[2 2 2]);
% or
% myOISscr1_new('20170104mouse_gapp7_gcamp_rest1.stk','gcamp_rest1','do_ffilt',...
%    [0.05 0.02 0.2 0.01 0.04],'do_keepalldata')
% or
% myOISscr1_new([],'gcamp_rest1','do_ffilt','do_keepraw');
%
% or
% myOISscr1_new('20190905mouse_gad2a_2x_rest1.stk','rest1','do_load',[1:15000],'do_sequential',3,'do_saveraw');
% myOISscr1_new('20190905mouse_gad2a_2x_rest1.stk','rest1','do_load',[1:15000],'do_sequential',-3,'do_saveraw');
% myOISscr1_new('20200812mouse_g43k_3p2x_whisker1.stk','wh1','do_load',[1:9450],'do_sequential',[3 1 2],'do_motc',...
%               'do_realign','do_maskreg',mask_reg,'do_intc',1,'do_keepraw');

% notes:
% july-01-2021 alv added xx_motc artifact correction to do_motc and do_intc

do_loadmat=0;

if nargin==1, saveid=''; end;
if isempty(saveid), saveid=fname(1:end-4); end;
if isempty(fname), do_loadmat=1; end;

if nargin==2,
  p1={'do_loadall','do_crop','do_motc','do_realign','do_intc',1,'do_maskreg','do_bin',[2 2 1],'do_binfirst'};
end;
if ischar(p1),
  if strcmp(p1,'default')|strcmp(p1,'def')|strcmp(p1,'Default')|strcmp(p1,'defaults'),
    disp('  using defaults...');
    p1={'do_loadall','do_crop','do_motc','do_intc',1,'do_maskreg','do_bin',[2 2 2]};
    if nargin>3, 
      for mm=2:nargin-2, 
        disp(sprintf('  adding p%d',mm));
        eval(sprintf('p1{end+1}=p%d;',mm)); 
      end; 
    end;
  end;
end;


sname=sprintf('%s_res.mat',saveid);
if exist(sname,'file'),
  if do_loadmat,
    disp(sprintf('  loading...'));
    eval(sprintf('load %s',sname));
  else,    
    tmpin=input(sprintf('--file %s exists [0=quit, 1=replace, 2=load]: ',sname));
    %if isempty(tmpin), return; end;
    if tmpin==2,
      disp(sprintf('  reloading...'));
      eval(sprintf('load %s',sname));
      flags_prev=flags;
      eval(sprintf('save %s -append flags_prev',sname));
    elseif tmpin==0,
      return;
    else,
      eval(sprintf('save %s -v7.3 fname sname saveid',sname));
      disp('--continuing...');
    end;
  end;
else,
  eval(sprintf('save %s -v7.3 fname sname saveid',sname));
end;
%if exist('tmp_scr.mat'),
%  tmpin=input('  tmp file found, use it? [0=no, 1=yes]: ');
%  if ~isempty(tmpin), if tmpin==1, load('tmp_scr.mat'), end; end;
%else,
%  save tmp_scr fname
%end;



vars={'do_load','do_loadall','do_crop','do_motc','do_maskreg','do_intc','do_bin','do_realign',...
      'do_ffilt','do_arfilt','do_detrend','do_motc_apply','do_intc_apply','do_motcmask','do_motcref',...
      'do_arfilt_apply','do_keepalldata','do_keepraw','do_saveraw','do_binfirst','do_average','do_timing',...
      'do_sequential','do_seqinterp','do_loadmat','do_cropset','do_maskregset'};
nvars=length(vars);

if iscell(p1),
  p1cell=p1;
  for mm=1:length(p1cell), eval(sprintf('p%d=p1cell{mm};',mm)); end;
  mynargin=length(p1cell)+2;
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
for mm=1:mynargin-2,
  for nn=1:nvars,
    eval(sprintf('tmptest=strcmp(p%d,''%s'');',mm,vars{nn}));
    if tmptest,
      disp(sprintf('flags.%s=1;',vars{nn}));
      eval(sprintf('flags.%s=1;',vars{nn}));
      if mm<mynargin-2,
        eval(sprintf('flags.%s_parms=p%d;',vars{nn}(4:end),mm+1));
        eval(sprintf('tmptest2=p%d;',mm+1));
        if isstr(tmptest2),
          disp(sprintf('flags.%s_parms=[];',vars{nn}(4:end)));
          eval(sprintf('flags.%s_parms=[];',vars{nn}(4:end)));
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
flags.notes{1}='';

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
if isfield(flags,'do_sequential_done'), flags.do_sequential=0; end;
if isfield(flags,'do_seqinterp_done'), flags.do_seqinterp=0; end;

if ~isfield(flags,'do_load'), flags.do_load=0; flags.do_load_all=1; end;

% if flags.do_sequential,
%   if ~isempty(flags.sequential_parms),
%     if (length(flags.sequential_parms)==1)&(flags.sequential_parms(1)<0),
%       flags.do_sequentialset=1;
%       nseq=abs(flags.sequential_parms);
%       flags.sequential_parms=nseq;
%     end;
%   end;
% end;

if flags.do_crop,
  if ~isempty(flags.crop_parms),
    if strcmp(flags.crop_parms,'set'),
      flags.do_cropset=1;
    end;
  end;
end;

if flags.do_maskreg,
  if ~isempty(flags.maskreg_parms),
    if strcmp(flags.maskreg_parms,'set'),
      flags.do_maskregset=1;
    end;
  end;
end;

% if flags.do_sequentialset,
%   tmpims=readOIS3(fname,[1:nseq]+nseq);
%   size(tmpims)
%   tmpord=[1:nseq];  
%   tmpok=0;
%   while(~tmpok),
%     clf, showmany(tmpims(:,:,tmpord)), drawnow,
%     tmpin=input('  enter led order as [3 1 2] or press <enter> if ok: ');
%     if isempty(tmpin),
%         ledOrd=tmpord;
%         tmpok=1;
%     else,
%         tmpord=tmpin;
%     end;
%     clear tmpord tmpok tmpims
%   end;
%   
%   flags.sequential_parms=ledOrd;
%   disp(sprintf('  re-ordering sequential to [%d]',ledOrd));
%   eval(sprintf('save %s -append -v7.3 ledOrd flags',sname))
% end;

if flags.do_cropset,
  disp('  do_crop(set)...');
  if do_sequential, tmpim=readOIS3(fname,10); else, tmpim=readOIS3(fname,1); end;
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
  tmpstr=sprintf('  crop_ii values set');
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  eval(sprintf('save %s -append -v7.3 flags crop_ii',sname));
end;

if flags.do_maskregset,
  disp('  do_maskreg(set)...');
  if ~exist('tmpim','var'),
    if do_sequential, tmpim=readOIS3(fname,2); else, tmpim=readOIS3(fname,1); end;
  end;
  mask_reg=bwlabel(selectMask(tmpim));
  tmpstr=sprintf('  mask_reg set');
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  eval(sprintf('save %s -append -v7.3 mask_reg flags',sname))
end;

if flags.do_crop,
  disp('  do_crop...');
  tmpim=readOIS3(fname,1);
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
  tmpstr=sprintf('  crop done');
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  eval(sprintf('save %s -append -v7.3 flags crop_ii',sname));
else,
  tmpim=readOIS3(fname,1);
  crop_ii=[1 size(tmpim,1) 1 size(tmpim,2)];
  tmpstr=sprintf('  crop_ii set to default');
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  %flags.crop_parms=crop_ii;
end;

if flags.do_loadall,
  disp('  do_loadall...');
  if strcmp(fname(end-2:end),'raw'),
    [im1,dim,info]=readOIS(fname);
    nfr=info.nfr;
  elseif strcmp(fname(end-2:end),'stk'),
    info=imfinfo(fname);
    im1=readOIS3(fname,1);
    if isfield(info,'UnknownTags'),
        info.nImages=length(info.UnknownTags(2).Value);
        nfr=info.nImages;
    else,
      nfr=length(info);
      if nfr==1, 
        disp('  warning: only 1 frame found, counting...');
        tmpcnt=0; tmpfnd=0;
        while(~tmpfnd),
          tmpcnt=tmpcnt+1;
          tmpa=tiffread2(fname,tmpcnt);
          if isempty(tmpa), tmpfnd=1; nfr=tmpcnt-1; end;
        end;
        disp(sprintf('  #frames= %d',nfr));
      end;
    end
    %keyboard,
  else,
    info=imfinfo(fname);
    im1=readOIS3(fname,1);
    nfr=length(info);
    if nfr==1, disp('  warning: only 1 frame found'); end;
  end;
  data=single(zeros(size(im1,1),size(im1,2),nfr));
  cnt=1;
  tmpfnd=0;
  while(~tmpfnd),
    tmpim=readOIS3(fname,cnt);
    if cnt>nfr,
      tmpfnd=1;
      cnt=cnt-1;
    else,
      if flags.do_crop, tmpim=tmpim(crop_ii(1):crop_ii(2),crop_ii(3):crop_ii(4)); end;
      data(:,:,cnt)=single(tmpim);
      cnt=cnt+1;
    end;
  end;
  disp(sprintf('  vol_dim=[%d %d %d]',size(data,1),size(data,2),size(data,3)));
  nims=size(data,3);
  avgim_raw=mean(data,3); stdim_raw=std(data,[],3);
  avgtc_raw=squeeze(mean(mean(data,1),2));
  figure(2), clf,
  plot(avgtc_raw), axis('tight'), grid('on'),
  xlabel('im#'), ylabel('data mean intensity'),
  eval(sprintf('print -dpng samplefig_%s_data_avgtc',saveid));
  figure(2), clf, showmany(avgim_raw), drawnow,
  eval(sprintf('print -dpng samplefig_%s_data_avgim',saveid));
  figure(2), clf, showmany(stdim_raw), drawnow,
  eval(sprintf('print -dpng samplefig_%s_data_stdim',saveid));

  flags.do_loadall_done=1;
  if flags.do_keepalldata|flags.do_keepraw|flags.do_saveraw,
    data_raw=data;
    if flags.do_saveraw,
      eval(sprintf('save %s_raw -v7.3 data_raw',saveid));
      clear data_raw
    else,
      eval(sprintf('save %s -append -v7.3 data_raw',sname));
    end;
  end;
  tmpstr=sprintf('  load all done, nims= %s',nims);
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  tmpstr=sprintf('  stdim min/max=[%.3f %.3f]',min(stdim_raw(:)),max(stdim_raw(:)));
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  %disp(sprintf('save %s -append -v7.3 data avgim_raw stdim_raw avgtc_raw nims flags',sname));
  eval(sprintf('save %s -append -v7.3 data avgim_raw stdim_raw avgtc_raw nims flags',sname));
end;

if flags.do_load,
  disp('  do_load...');
  nims=flags.load_parms;
  if iscell(nims), tmpim=readOIS3(fname,nims{1}(1)); else, tmpim=readOIS3(fname,nims(1)); end;
  if flags.do_crop, 
    tmpim=tmpim(crop_ii(1):crop_ii(2),crop_ii(3):crop_ii(4)); 
  else,
    crop_ii=[1 size(tmpim,1) 1 size(tmpim,2)];
  end;
  if flags.do_binfirst,
    disp('  do_binfirst also...');
    tmpim=imbin(tmpim,flags.bin_parms(1:2));
    tmpdim=[size(tmpim) floor(length(nims)/flags.bin_parms(3))];
    data=single(zeros(tmpdim));
    cnt=0;
    for mm=1:flags.bin_parms(3):length(nims),
      cnt=cnt+1;
      if cnt<4, disp(sprintf('  reading %d',nims(mm))); end; 
      tmpim=mean(readOIS3(fname,nims(mm)+[0:flags.bin_parms(3)-1]),3);
      data(:,:,cnt)=single(imbin(tmpim(crop_ii(1):crop_ii(2),crop_ii(3):crop_ii(4)),flags.bin_parms(1:2)));
    end;
    disp(sprintf('  ... last im %d',nims(mm)));
    clear tmpim tmpdim cnt
    avgim_bin=mean(data,3); stdim_bin=std(data,[],3);
    avgtc_bin=squeeze(mean(mean(data,1),2));
    flags.do_binfirst=0; flags.do_bin=0;
  else,
    if iscell(nims),
      nims_orig=nims; nims_all=0;
      for mm=1:length(nims), 
        if length(nims{mm})==1, nims{mm}=[1:nims{1}(1)]; end; 
        nims_all=nims_all+length(nims{mm}); 
        if mm==1, 
          tmp_fname_all{mm}=fname;
        else,
          if strcmp(fname(end-2:end),'tif')|strcmp(fname(end-2:end),'TIF')
            tmp_fname_all{mm}=sprintf('%s-file%03d.%s',fname,mm);
          else,
            tmp_fname_all{mm}=sprintf('%s-%02d.%s',fname,mm);
          end;
        end;          
      end;
      tmpdim=[size(tmpim) nims_all];
      data=single(zeros(tmpdim));
      tmpcnt=0;
      for nn=1:length(nims),
        for mm=1:length(nims{nn}),
          tmpcnt=tmpcnt+1;
          %if mm<4, 
              disp(sprintf('  reading %d/%d (%d) from %s',nims{nn}(mm),nims{nn}(end),tmpcnt,tmp_fname_all{nn})); 
          %end; 
          tmpim=readOIS3(tmp_fname_all{nn},nims{nn}(mm));
          data(:,:,tmpcnt)=single(tmpim(crop_ii(1):crop_ii(2),crop_ii(3):crop_ii(4)));
        end;
      end;
      clear tmpim tmpdim tmpcnt
    else,
      tmpdim=[size(tmpim) length(nims)];
      if strcmp(fname(end-2:end),'tif')|strcmp(fname(end-2:end),'TIF')|strcmp(fname(end-2:end),'iff')|strcmp(fname(end-2:end),'IFF'),
        disp('  doing direct read of tif file...');
        tmpdata=tiffread2(fname,nims(1),nims(end));
        data=reshape(single([tmpdata(:).data]),[tmpdata(1).width tmpdata(1).height nims(end)-nims(1)+1]);
        clear tmpdata
        data=data(crop_ii(1):crop_ii(2),crop_ii(3),crop_ii(4),:);
      else,
        data=single(zeros(tmpdim));
        for mm=1:length(nims),
          if mm<4, disp(sprintf('  reading %d',nims(mm))); end; 
          tmpim=readOIS3(fname,nims(mm));
          data(:,:,mm)=single(tmpim(crop_ii(1):crop_ii(2),crop_ii(3):crop_ii(4)));
        end;
      end;
    end
    clear tmpim tmpdim
  end;
  avgim_raw=mean(data,3); stdim_raw=std(data,[],3);
  avgtc_raw=squeeze(mean(mean(data,1),2));
  figure(2), clf,
  if length(avgtc_raw)==length(nims),
    plot(nims,avgtc_raw), axis('tight'), grid('on'),
  else,
    plot(avgtc_raw), axis('tight'), grid('on'),
  end;
  xlabel('im#'), ylabel('data mean intensity'), drawnow,
  eval(sprintf('print -dpng samplefig_%s_data_avgtc',saveid));
  figure(2), clf, showmany(avgim_raw), drawnow,
  eval(sprintf('print -dpng samplefig_%s_data_avgim',saveid));
  figure(2), clf, showmany(stdim_raw), drawnow,
  eval(sprintf('print -dpng samplefig_%s_data_stdim',saveid));
  
  flags.do_load_done=1;
  if flags.do_keepalldata|flags.do_keepraw|flags.do_saveraw,
    data_raw=data;
    if flags.do_saveraw,
      eval(sprintf('save %s_raw -v7.3 data_raw',saveid));
      clear data_raw
    else,
      eval(sprintf('save %s -append -v7.3 data_raw',sname));
    end;
  end;
  tmpstr=sprintf('  load done');
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  tmpstr=sprintf('  stdim min/max=[%.3f %.3f]',min(stdim_raw(:)),max(stdim_raw(:)));
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  %disp(sprintf('save %s -append -v7.3 data avgtc_raw avgim_raw stdim_raw nims flags',sname));
  eval(sprintf('save %s -append -v7.3 data avgtc_raw avgim_raw stdim_raw nims flags',sname));
  if exist('avgtc_bin','var'),
    do_binfirst_done=1; do_bin_done=1;
    eval(sprintf('save %s -append -v7.3 avgtc_bin avgim_bin stdim_bin flags',sname));
  end;
end;

if flags.do_sequential,
  disp('  do sequential...');
  if (length(flags.sequential_parms)>1)&(~iscell(flags.sequential_parms)),
    flags.do_sequential_reorder=1;
    flags.sequential_parms_orig=flags.sequential_parms;
    flags.sequential_reorder_parms=flags.sequential_parms;
    flags.sequential_parms=length(flags.sequential_parms);
  elseif iscell(flags.sequential_parms),
    flags.do_sequential_reorder=1;      
    flags.sequential_parms_orig=flags.sequential_parms;
    flags.sequential_parms=flags.sequential_parms{1};
    flags.sequential_reorder_parms=flags.sequential_parms_orig{2};
  else,
    flags.do_sequential_reorder=0;
  end;
  if length(flags.sequential_parms)==1,
    flags.sequential_parms(2)=0; 
  end;
  if flags.sequential_parms(1)<0,
    flags.do_sequential_reorder=1;
    flags.sequential_parms(1)=abs(flags.sequential_parms(1));
  end;

  nseq=flags.sequential_parms(1);
  datasz=size(data); nims=datasz(end);
  seq_nims=floor(nims/nseq);
  data_seq=single(zeros(size(data,1),size(data,2),nseq,seq_nims));
  disp(sprintf('  seq dim= %d %d %d %d, reorder= %d',size(data_seq),flags.do_sequential_reorder));
  flags.do_seqcheck=flags.sequential_parms(2);
  
  im1_orig=data(:,:,1);
  data(:,:,1)=data(:,:,nseq+1);
  
  if flags.do_seqcheck,
    disp('  checking seq data...');
    seq_ii=chkOISseq1(data,nseq,data(:,:,1:nseq));
    for mm=1:nseq,
      tmpii=find(seq_ii==mm);
      data_seq(:,:,mm,1:length(tmpii))=data(:,:,tmpii);
    end;
  else,
    seq_ii=[];
    for mm=1:nseq, data_seq(:,:,mm,:)=data(:,:,mm:nseq:nseq*seq_nims); end;
  end;
  data=data_seq;
  clear data_seq
  
  if flags.do_sequential_reorder,
    if ~isfield(flags,'sequential_reorder_parms'), flags.sequential_reorder_parms=[]; end;
    if isempty(flags.sequential_reorder_parms), flags.sequential_reorder_parms=-1; end;
    
    if flags.sequential_reorder_parms==-1,
      tmpord=[1:nseq];  
      tmpok=0;
      while(~tmpok),
        clf, showmany(data(:,:,tmpord,2)), drawnow,
        tmpin=input('  enter led order as [3 1 2] or press <enter> if ok: ');
        if isempty(tmpin),
          flags.sequential_reorder_parms=tmpord;
          tmpok=1;
        else,
          tmpord=tmpin;
        end;
      end;
    end;
    clear tmpord tmpok
    
    ledOrd=flags.sequential_reorder_parms;
    disp(sprintf('  re-ordering sequential to [%d]',ledOrd));
    if sum((ledOrd-[1:length(ledOrd)]).^2)>100*eps,
      data=data(:,:,ledOrd,:);
      flags.do_sequential_reorder_done=1;
      tmpstr=sprintf('  sequential reorder done, ord= %d',ledOrd);
      if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
    end;
  else,
    ledOrd=[1 2 3];
  end;
  
  %if flags.do_keepalldata,
  %  eval(sprintf('save %s -append -v7.3 data_seq',sname));
  %end;
  avgim_seq=squeeze(mean(data,4));
  stdim_seq=squeeze(std(data,[],4));
  avgtc_seq=squeeze(mean(mean(data,1),2))';
  %data=data_seq;
  %clear data_seq;
  figure(2), clf,
  plot(avgtc_seq), axis('tight'), grid('on'),
  xlabel('im#'), ylabel('data mean intensity'),
  eval(sprintf('print -dpng samplefig_%s_data_avgtc_seq',saveid));
  figure(2), clf, showmany(avgim_raw), drawnow,
  eval(sprintf('print -dpng samplefig_%s_data_avgim_seq',saveid));
  figure(2), clf, showmany(stdim_raw), drawnow,
  eval(sprintf('print -dpng samplefig_%s_data_stdim_seq',saveid));

  flags.do_sequential_done=1;
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  disp(sprintf('save %s -append -v7.3 data im1_orig nseq ledOrd avgim_seq stdim_seq avgtc_seq flags',sname))
  eval(sprintf('save %s -append -v7.3 data im1_orig nseq ledOrd avgim_seq stdim_seq avgtc_seq flags',sname))
else
  nseq=1;
end;


if flags.do_binfirst,
  % need to add do_sequential
  disp('  do bin first...');
  data_bin=volbin(data,flags.bin_parms);
  avgtc_bin=squeeze(mean(mean(data_bin,1),2));
  avgim_bin=mean(data_bin,3); stdim_bin=std(data_bin,[],3);
  data=data_bin; clear data_bin
  flags.do_bin_done=1;
  if flags.do_keepalldata,
    data_bin=data;
    eval(sprintf('save %s -append -v7.3 data_bin',sname));
    clear data_bin
  end;
  tmpstr=sprintf('  bin first done');
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  tmpstr=sprintf('  stdim min/max=[%.3f %.3f]',min(stdim_bin(:)),max(stdim_bin(:)));
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  disp(sprintf('save %s -append -v7.3 data avgim_bin stdim_bin avgtc_bin flags',sname))
  eval(sprintf('save %s -append -v7.3 data avgim_bin stdim_bin avgtc_bin flags',sname))
end;


if flags.do_seqinterp,
  disp('  do_seqinterp...');
  tt=[1:nims]; tt=tt(:);
  if isempty(seq_ii),
    for mm=1:nseq, ttseq(:,mm)=tt(mm:nseq:end); end;
  else,
    for mm=1:nseq, ttseq(:,mm)=tt(find(seq_ii==mm)); end;
  end;
  data_iseq=single(size(data,1),size(data,2),nseq*size(data,3),size(data,4));
  for oo=1:nseq, for mm=1:size(data,1), for nn=1:size(data,2),
    tmptc=squeeze(data(mm,nn,oo,:));
    tmptc2=interp1(ttseq(:,oo),tmptc,tt);
    data_iseq(mm,nn,oo,:)=tmptc2;
  end; end; end;
  if flags.do_keepalldata,
    eval(sprintf('save %s -append data_iseq',sname));
  end;
  avgtc_iseq=squeeze(mean(mean(data_iseq,1),2));
  data=data_iseq;
  clear data_iseq;

  flags.do_seqinterp_done=1;
  tmpstr=sprintf('  sequential interp done');
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  disp(sprintf('save %s -append data avgtc_iseq tt ttseq flags',sname))
  eval(sprintf('save %s -append data avgtc_iseq tt ttseq flags',sname))
end;


if flags.do_motc,
  disp('  do_motc...');
  if isempty(flags.motc_parms), flags.motc_parms=[4 20 1 1 0]; end;
  if flags.do_motcmask,
    flags.motc_mask=flags.motcmask_parms;
  else,
    flags.motc_mask=ones(size(data(:,:,1)));
  end;
  if flags.do_motcref==0,
    if flags.do_sequential, flags.motcref_parms=10; else, flags.motcref_parms=1; end;
  end;      
  if flags.do_sequential,
    for nn=1:nseq,
      disp(sprintf('  motc seq %d (ref=%d)',nn,flags.motcref_parms(1)));
      xx_motc(:,:,nn)=imMotDetect(squeeze(data(:,:,nn,:)),flags.motcref_parms,flags.motc_parms,flags.motc_mask);
      xx_motc(1,:,nn)=xx_motc(2,:,nn);
    end;
    xx_motc_rs=reshape(xx_motc,[size(xx_motc,1) size(xx_motc,2)*nseq]);
  else,
    xx_motc=imMotDetect(data,flags.motcref_parms,flags.motc_parms,flags.motc_mask);
  end;
  figure(2), clf,
  plot(xx_motc(:,:,1)), axis('tight'), grid('on'),
  xlabel('im#'), ylabel('pixel displacement'), legend('x','y'),
  eval(sprintf('print -dpng samplefig_%s_xxmotc',saveid));
  if flags.do_realign==0, flags.do_realign=1; end;
  flags.do_motc_done=1;
  tmpstr=sprintf('  motc done');
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  tmpstr=sprintf('  xx min/max=[%.3f %.3f]',min(xx_motc(:)),max(xx_motc(:)));
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  %disp(sprintf('save %s -append xx_motc* flags',sname));
  eval(sprintf('save %s -append xx_motc* flags',sname));
else,
  flags.do_realign=0;
end;


if flags.do_motc_apply,
  if flags.do_realign==0, flags.do_realign=1; end;
  xx_motc=flags.motc_apply_parms;
end;
  

if flags.do_realign,
  disp('  do_realign...'); 
  if ~isfield(flags,'realign_parms'), flags.realign_parms=[]; end;
  if isempty(flags.realign_parms), flags.realign_parms=1; end;
  
  ss_xc=sum(xx_motc(:,1:2,1).^2,2).^0.5;
  disp(sprintf('  motc result %.2f percent (%d) over 0.2 pix xy shift in ch1',100*sum(ss_xc>0.14)/length(ss_xc),sum(ss_xc>0.14)));
  tmpok=sum(ss_xc>0.14)>1;
  
  flags.do_realign_artinterp=0;
  if (flags.realign_parms(1)==2)&(flags.do_sequential==0),
    tmpin=input('  continue? (0:skip, 1:yes, 3:interp-art): ');
    if isempty(tmpin), tmpin=1; end;
    if tmpin==0, tmpok=0; end;
    if tmpin==3,
        % get threshold for each potential color
        tmptc=avgtc_raw;
        tmptc=tmptc/mean(tmptc(2:6))-1;
        clf,
        subplot(211), plot(xx_motc), 
        axis('tight'), grid('on'), ylabel('Displacement'),
        subplot(212), plot(tmptc),
        axis('tight'), grid('on'), ylabel('Avg Img Intensity'),
        title('Avg Img Intensity'),
        thr_art=input('  artifact intensity thr [def=1.0]: ');
        if isempty(thr_art), thr_art=1.0; end;
        flags.do_realign_artinterp=1;
        flags.realign_artinterp_parms(1)=thr_art;
    end
  elseif (flags.realign_parms(1)==2),
    if ~exist('avgtc_seq','var'), nseq=1; avgtc_seq(:,1)=avgtc_raw(:); end;
    clf,
    subplot(211), plot(xx_motc(:,:,1)), 
    axis('tight'), grid('on'), ylabel('Displacement'),
    subplot(212), plot([avgtc_seq]),
    axis('tight'), grid('on'), ylabel(['Avg Img Intensity SEQ #',num2str(1)]),

    tmpin=input(sprintf('  continue? (0:skip, 1:yes, 3:interp-art): '));
    if isempty(tmpin), tmpin=1; end;
    if tmpin==0, tmpok=0; end;
    if tmpin==3,
      for oo=1:nseq,
        % get threshold for each potential color
        tmptc=avgtc_seq(:,oo);
        tmptc=tmptc/mean(tmptc(2:6))-1;
        clf,
        subplot(211), plot(xx_motc(:,:,oo)), 
        axis('tight'), grid('on'), ylabel('Displacement'),
        subplot(212), plot(tmptc),
        axis('tight'), grid('on'), ylabel('Avg Img Intensity'),
        title(['Avg Img Intensity SEQ #',num2str(1)]),
        thr_art=input(sprintf('  artifact intensity thr ch#%d [def=1.0]: ',oo));
        if isempty(thr_art), thr_art=1.0; end;
        flags.do_realign_artinterp=1;
        flags.realign_artinterp_parms(oo)=thr_art;
      end;
    end
  elseif flags.realign_parms(1)==3,
    flags.do_realign_artinterp=1;
    if length(flags.realign_parms)>1,
      flags.realign_artinterp_parms=flags.realign_parms(2:end);
    end;
  end;

  if flags.do_realign_artinterp,
    if ~exist('avgtc_seq','var'), nseq=1; avgtc_seq(:,1)=avgtc_raw(:); end;
    if ~isfield(flags,'realign_artinterp_parms'), flags.realign_artinterp_parms=[]; end;
    if isempty(flags.realign_artinterp_parms),
      thr_art=1.0*ones(nseq,1);
    else,
      thr_art=flags.realign_artinterp_parms;
    end;
    %thr_art,
    xx_motc_orig=xx_motc;
    for oo=1:nseq,
      disp(sprintf('  replacing motion artifacts with thr>%.3f',thr_art));
      flags.notes{end+1}=sprintf('  replacing motion artifacts with thr>%.3f',thr_art(oo)); 
      tmptc=avgtc_seq(:,oo);
      tmptc=tmptc/mean(tmptc(2:6))-1;
      tmpi1=find(tmptc<thr_art(oo));
      tmpi2=find(tmptc>=thr_art(oo));
      flags.motc_i1{oo}=tmpi1; 
      flags.motc_i2{oo}=tmpi2; 
      flags.motc_avgtcf{oo}=tmptc; 
      flags.motc_thrf{oo}=thr_art(oo);
      if isempty(tmpi2),
        disp(sprintf('  no motion artifacts found in ch%d with thr of %.3f, skipping...',oo,thr_art(oo)));
      else,
        tmp_xx_motc=xx_motc(:,:,oo);
        tmp_xx_motc(tmpi2,1)=interp1(tmpi1,xx_motc_orig(tmpi1,1,oo),tmpi2);
        tmp_xx_motc(tmpi2,2)=interp1(tmpi1,xx_motc_orig(tmpi1,2,oo),tmpi2);
        xx_motc(:,:,oo)=tmp_xx_motc;
      end;
    end;
    eval(sprintf('save %s -append xx_motc xx_motc_orig flags',sname));
    tmpok=sum(ss_xc(:)>0.14)>1;    
  end;
  
  if tmpok,
    if flags.do_sequential,
      for nn=1:nseq,
        ss_xc=sum(xx_motc(:,1:2,nn).^2,2).^0.5;
        disp(sprintf('  motc result %.2f percent (%d) over 0.2 pix xy shift in seq #%d',100*sum(ss_xc>0.14)/length(ss_xc),sum(ss_xc>0.14),nn));
        tmpok=sum(ss_xc>0.14)>1;
        if flags.realign_parms==2,
          tmpin=input('  continue? (0:skip, 1:yes): ');
          if isempty(tmpin), tmpin=1; end;
          if tmpin==0, tmpok=0; end;
        end;
        if tmpok,
          disp(sprintf('  realign seq %d',nn));
          data(:,:,nn,:)=imMotApply(xx_motc(:,:,nn),squeeze(data(:,:,nn,:)),flags.motc_parms,4);
        end;
      end;
      avgtc_motc=squeeze(mean(mean(data,1),2))';
      avgim_motc=mean(data,4); stdim_motc=std(data,[],4);
     else,
      data=imMotApply(xx_motc,data,flags.motc_parms,4);
      avgtc_motc=squeeze(mean(mean(data,1),2));
      avgim_motc=mean(data,3); stdim_motc=std(data,[],3);
    end;
    figure(2), clf, showmany(stdim_motc), drawnow,
    eval(sprintf('print -dpng samplefig_%s_data_stdim_motc',saveid));

    flags.do_realign_done=1;
    if flags.do_keepalldata,
      data_motc=data;
      eval(sprintf('save %s -append data_motc',sname));
      clear data_motc
    end;
    
    tmpstr=sprintf('  realign done');
    if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
    tmpstr=sprintf('  stdim min/max=[%.3f %.3f]',min(stdim_motc(:)),max(stdim_motc(:)));
    if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;

    disp(sprintf('save %s -append data avgim_motc stdim_motc avgtc_motc flags',sname));
    eval(sprintf('save %s -append data avgim_motc stdim_motc avgtc_motc flags',sname));
  else,
    disp('  skipping realign, no significant motion detected...'),
    flags.do_realign=0;
    flags.do_realign_done=-1;
    eval(sprintf('save %s -append flags',sname));    
  end;
end;

if flags.do_maskreg,
  disp('  do_maskreg...');
  if ~isfield(flags,'realign_parms'), flags.realign_parms=[]; end;
  if ~isfield(flags,'motcref_parms'), flags.motcref_parms=1; end;
  if isempty(flags.maskreg_parms),
    if length(flags.motcref_parms)==1,
      if flags.do_sequential,tmpim=data(:,:,1,flags.motcref_parms); else, tmpim=data(:,:,flags.motcref_parms); end;
    else,
      if flags.do_sequential, tmpim=flags.motcref_parms; end;
    end;
    if ~exist('mask_reg','var'),
      mask_reg=bwlabel(selectMask(tmpim));
    else,
      tmpin=input('  found a mask_reg, use it? [0=no, 1/enter=yes]: ');
      clf, im_overlay4(tmpim,mask_reg), drawnow,
      if isempty(tmpin), tmpin=1; end;
      if tmpin==0, mask_reg=bwlabel(selectMask(tmpim)); end;
    end;
  else,
    if ischar(flags.maskreg_parms), if strcmp(flags.maskreg_parms,'auto'),
        flags.maskreg_parms=mkMaskReg(avgim_raw(:,:,1));
    end; end;
    mask_reg=flags.maskreg_parms;
    clf, show(mask_reg), drawnow,
  end;
  mask_reg_tc=getStkMaskTC(data,mask_reg);

  eval(sprintf('print -dpng samplefig_%s_maskreg',saveid));
  clf, plot(mask_reg_tc.atc(:,:,1)), axis('tight'), grid('on'), drawnow,
  xlabel('im#'), ylabel('maskreg roi intensity'),
  eval(sprintf('print -dpng samplefig_%s_maskregtc',saveid));
  flags.do_maskreg_done=1;
  tmpstr=sprintf('  mask reg set');
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  %disp(sprintf('save %s -append mask_reg mask_reg_tc flags',sname))
  eval(sprintf('save %s -append mask_reg mask_reg_tc flags',sname))
end;

if flags.do_intc|flags.do_intc_apply|flags.do_maskreg,
  disp('  do_regress(intc/maskreg)...');
  reg_mat=[];
  %if flags.do_maskreg, reg_mat=[reg_mat mask_reg_tc.atc]; end;
  if flags.do_intc_apply, reg_mat=[reg_mat flags.intc_apply_parms]; end;
  if ~isfield(flags,'intc_parms'), flags.intc_parms=[]; end;
  if isempty(flags.intc_parms), flags.intc_parms=1; end;
  if length(flags.intc_parms)==1, flags.intc_parms(2)=0; end;
  if length(size(data))>3,      
    for nn=1:nseq,
      if exist('mask_reg_tc','var'),
        reg_mat2=[reg_mat mask_reg_tc.atc(:,:,nn)];
      else,
        reg_mat2=reg_mat;
      end;
      if exist('xx_motc','var')&(flags.do_realign_done==1),
        tmp_ss_xc=sum(xx_motc(:,1:2,nn).^2,2).^0.5;
        tmp_ss_xc=sum(tmp_ss_xc(:)>0.14);
        if isfield(flags,'motc_i1')&(~isempty(flags.motc_i1{nn})),
          if tmp_ss_xc>1,
            disp(sprintf('  do_regress_with_motion seq %d...',nn));
            [data_intc(:,:,nn,:),xx_intc(nn)]=imMotReg(squeeze(data(:,:,nn,:)),xx_motc(:,:,nn),flags.intc_parms,zscore(reg_mat2),flags.motc_i1{nn});
          else,
            disp(sprintf('  do_regress_withOUT_motion seq %d...',nn));
            [data_intc(:,:,nn,:),xx_intc(nn)]=imMotReg(squeeze(data(:,:,nn,:)),[],flags.intc_parms,zscore(reg_mat2),flags.motc_i1{nn});
          end
          avgim_intc_i1{nn}=mean(data_intc(:,:,nn,flags.motc_i1{nn}),4);
          stdim_intc_i1{nn}=std(data_intc(:,:,nn,flags.motc_i1{nn}),[],4);
        else,
          if tmp_ss_xc>1,
            disp(sprintf('  do_regress_with_motion seq %d...',nn));
            [data_intc(:,:,nn,:),xx_intc(nn)]=imMotReg(squeeze(data(:,:,nn,:)),xx_motc(:,:,nn),flags.intc_parms,zscore(reg_mat2));
          else
            disp(sprintf('  do_regress_withOUT_motion seq %d...',nn));
            [data_intc(:,:,nn,:),xx_intc(nn)]=imMotReg(squeeze(data(:,:,nn,:)),[],flags.intc_parms,zscore(reg_mat2));
          end
        end;
      else,
        [data_intc(:,:,nn,:),xx_intc(nn)]=imMotReg(squeeze(data(:,:,nn,:)),[],flags.intc_parms,zscore(reg_mat2));
      end;
      
      tmpnan=isnan(data(:,:,nn,:));
      tmpnan=sum(tmpnan(:));
      if tmpnan,
        disp(sprintf('  warning: intc option appears to have misbehaved, check avgtc_intc plot, skipping'));
        data_intc(:,:,nn,:)=data(:,:,nn,:);
      end
    end;
    avgtc_intc=squeeze(mean(mean(data_intc,1),2))';
    avgim_intc=squeeze(mean(data_intc,4)); 
    stdim_intc=squeeze(std(data_intc,[],4));

    tmpstd_pre=std(data,[],4);
    tmpstd_post=std(data_intc,[],4);
    if (sum(tmpstd_post(:))>1.05*sum(tmpstd_pre(:)))|sum(isnan(tmpstd_post(:)>1))
      disp(sprintf('  warning: intc option appears to have misbehaved, check avgtc_intc plot'));
      disp(sprintf('           skipping and saving intc result for inspection later'));
      flags.do_intc_done=-1;
   else,
      data=data_intc; 
    end;
  else,
    if exist('mask_reg_tc','var'),
      reg_mat2=[reg_mat mask_reg_tc.atc];
    else,
      reg_mat2=reg_mat;
    end;
    if exist('xx_motc','var'),
      tmp_ss_xc=sum(xx_motc(:,1:2).^2,2).^0.5;
      tmp_ss_xc=sum(tmp_ss_xc(:)>0.14);
      if isfield(flags,'motc_i1')&(~isempty(flags.motc_i1)),
        if tmp_ss_xc>1,
          disp('  do_regress_with_motion with i1 ...');
          [data_intc,xx_intc]=imMotReg(data,xx_motc,flags.intc_parms,zscore(reg_mat2),flags.motc_i1{1});
        else
          disp('  do_regress_withOUT_motion with i1 ...');
          [data_intc,xx_intc]=imMotReg(data,[],flags.intc_parms,zscore(reg_mat2),flags.motc_i1{1});
        end
        avgim_intc_i1=mean(data_intc(:,:,flags.motc_i1{1}),3);
        stdim_intc_i1=std(data_intc(:,:,flags.motc_i1{1}),[],3);
      else,
        if tmp_ss_xc>1,
          disp('  do_regress_with_motion...');
          [data_intc,xx_intc]=imMotReg(data,xx_motc,flags.intc_parms,zscore(reg_mat2));
        else
          disp('  do_regress_withOUT_motion...');
          [data_intc,xx_intc]=imMotReg(data,[],flags.intc_parms,zscore(reg_mat2));
        end
      end
    else,
      [data_intc,xx_intc]=imMotReg(data,[],flags.intc_parms,zscore(reg_mat2));
    end;
    
    tmpnan=isnan(data);
    tmpnan=sum(tmpnan(:));
    if tmpnan,
      disp(sprintf('  warning: intc option appears to have misbehaved, check avgtc_intc plot, skipping'));
      data_intc=data;
    end

    avgtc_intc=squeeze(mean(mean(data_intc,1),2))';
    avgim_intc=squeeze(mean(data_intc,3)); 
    stdim_intc=squeeze(std(data_intc,[],3));

    tmpstd_pre=std(data,[],3);
    tmpstd_post=std(data_intc,[],3);
    if (sum(tmpstd_post(:))>1.05*sum(tmpstd_pre(:)))|sum(isnan(tmpstd_post(:)>1)),
      disp(sprintf('  warning: intc option appears to have misbehaved, check avgtc_intc plot'));
      disp(sprintf('           skipping and saving intc result for inspection later'));
      flags.do_intc_done=-1;
    else,
      data=data_intc; 
    end;
  end;
  figure(2), clf,
  plot(avgtc_intc), axis('tight'), grid('on'),
  xlabel('im#'), ylabel('data intc mean intensity'), drawnow,
  eval(sprintf('print -dpng samplefig_%s_dataic_avgtc',saveid));
  figure(2), clf, showmany(stdim_intc), drawnow,
  eval(sprintf('print -dpng samplefig_%s_data_stdim_intc',saveid));
  
  %if flags.do_keepalldata,
  %  eval(sprintf('save %s -append data_intc',sname));
  %end;
  clear data_intc

  if exist('reg_mat2','var'), tmpstr=sprintf('  intc done, #cols= %d',size(reg_mat2,2)); else, tmpstr=sprintf('  intc done'); end;
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  tmpstr=sprintf('  stdim min/max=[%.3f %.3f]',min(stdim_intc(:)),max(stdim_intc(:)));
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  
  disp(sprintf('save %s -append data xx_intc avgim_intc* stdim_intc* avgtc_intc* flags',sname));
  eval(sprintf('save %s -append data xx_intc avgim_intc* stdim_intc* avgtc_intc* flags',sname));
end;

if flags.do_bin,
  % need to add do_sequential
  disp('  do bin...');
  if exist('data_intc','var'),
    data_bin=volbin(data_intc,flags.bin_parms);
    clear data_intc
  else,
    data_bin=volbin(data,flags.bin_parms);
  end;
  avgtc_bin=squeeze(mean(mean(data_bin,1),2));
  avgim_bin=mean(data_bin,3); stdim_bin=std(data_bin,[],3);
  %eval(sprintf('save %s -append data_bin',saveid))
  data=data_bin; clear data_bin
  flags.do_bin_done=1;
  if flags.do_keepalldata,
    data_bin=data;
    eval(sprintf('save %s -append data_bin',sname));
    clear data_bin
  end;
  tmpstr=sprintf('  binning done');
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  disp(sprintf('save %s -append data avgim_bin stdim_bin avgtc_bin flags',sname));
  eval(sprintf('save %s -append data avgim_bin stdim_bin avgtc_bin flags',sname));
end;


if flags.do_detrend,
  % need to add do_sequential
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
  tmpstr=sprintf('  detrend done');
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  disp(sprintf('save %s -append data xx_det avgim_det stdim_det avgtc_det flags',sname));
  eval(sprintf('save %s -append data xx_det avgim_det stdim_det avgtc_det flags',sname));
end;


if flags.do_ffilt,
  % need to add do_sequential
  if isempty(flags.ffilt_parms),
    flags.ffilt_parms={[0.02 0.2],[0.005 0.04],[-1 1],0.1};
  elseif ~iscell(flags.ffilt_parms),
    tmp_parms={flags.ffilt_parms(2:3),flags.ffilt_parms(4:5),[-1 1],flags.ffilt_parms(1)};
    flags.ffilt_parms_orig=flags.ffilt_parms;
    flags.ffilt_parms=tmp_parms;
    clear tmp_parms
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
  
  flags.do_ffilt_done=1;
  tmpstr=sprintf('  ffilt done');
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;

  if flags.do_keepalldata,
    eval(sprintf('save %s -append data_ffilt avgim_ffilt stdim_ffilt flags',sname));
  else,
    data=data_ffilt;
    clear data_ffilt
    disp(sprintf('save %s -append data avgim_ffilt stdim_ffilt avgtc_ffilt flags',sname));
    eval(sprintf('save %s -append data avgim_ffilt stdim_ffilt avgtc_ffilt flags',sname));
  end;
end;


if flags.do_arfilt,
  % need to add do_sequential
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
  
  if flags.do_keepalldata,
     eval(sprintf('save %s -append data_ar',sname));
  end;     
  data=data_ar;
  clear data_ar
  flags.do_arfilt_done=1;
  tmpstr=sprintf('  ar filt done');
  if isempty(flags.notes{end}), flags.notes{end}=tmpstr; else, flags.notes{end+1}=tmpstr; end;
  disp(sprintf('save %s -append data xx_ar avgim_ar stdim_ar avgtc_ar flags',sname));
  eval(sprintf('save %s -append data xx_ar avgim_ar stdim_ar avgtc_ar flags',sname));
end;


if flags.do_average,
  % need to add do_sequential
  disp('  do average...');
  if isempty(flags.average_parms),
    disp('  no average parameters found, skipping...');
    flags.do_average=-1;
  else,
    ddim=size(data);
    noff=flags.average_parms(1);
    nimtr=flags.average_parms(2);
    ntr=flags.average_parms(3);
    flags.noff=noff; flags.nimtr=nimtr; flags.ntr=ntr;
    if flags.do_timing,
      adata=zeros(ddim(1),ddim(2),nimtr);
      for nn=1:ntr, adata=data(:,:,[1:nimtr]+timing_parms(nn)-1); end;
      adata=adata/ntr;
      avgtc_avg=squeeze(mean(mean(adata,1),2));
      flags.do_average_done=1; flags.do_timing_done=1;
      disp(sprintf('save %s -append adata avgtc_avg flags',sname));
      eval(sprintf('save %s -append adata avgtc_avg flags',sname));
    else,
      adata=mean(reshape(data(:,:,[1:nimtr*ntr]+noff),ddim(1),ddim(2),nimtr,ntr),4);
      avgtc_avg=squeeze(mean(mean(adata,1),2));
      avgim_avg=mean(adata,3); stdim_avg=std(adata,[],3);
      flags.do_average_done=1;
      disp(sprintf('save %s -append adata avgim_avg stdim_avg avgtc_avg flags',sname));
      eval(sprintf('save %s -append adata avgim_avg stdim_avg avgtc_avg flags',sname));
    end;
    if length(flags.average_parms)>3,
      aadata=volbin(adata,[1 1 flags.average_parms(4)]);
      if length(flags.average_parms)>4,
        aadata=aadata-repmat(aadata(:,:,flags.average_parms(5)),[1 1 size(aadata,3)]);
      end;
      eval(sprintf('save %s -append aadata',sname));
    end;
  end;
end;

if flags.do_timing,
  % data has an accompanying time vector that will be used
  % need to add do_sequential
end;

