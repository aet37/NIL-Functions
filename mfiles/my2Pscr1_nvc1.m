function my2Pscr1_nvc1(fnames,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17)
% Usage my2Pscf1_nvc1(fnames_or_summary,flags,parmaters,...)
%
% fnames='T*res.mat'
% flags/parameters= 'do_setup', 'do_group', 'do_vessels', 'do_cells', 
%     'do_propagate', 'do_setlabel', 'do_getmaskdata', 'do_getraddata'
%
% Ex. my2Pscr1_nvc1('T*_res.mat')
%     my2Pscr1_nvc1('','do_vessels',[1 0])
%     my2Pscr1_nvc1('','do_vessels',[1 0 0.6])
%     my2Pscr1_nvc1('','do_cells',[2])
%     my2Pscr1_nvc1('','do_propagate')
%     my2Pscr1_nvc1('','do_setlabel')
%     my2Pscr1_nvc1('','do_savemasks')
%     my2Pscr1_nvc1('','do_getmaskdata')
%     my2Pscr1_nvc1('','do_getraddata')
%     my2Pscr1_nvc1('','do_cells','do_propagate','do_setlabel')
%

vars={'do_setup','do_group','do_vessels','do_cells','do_motcredo','do_intcredo',...
      'do_propagate','do_getmaskdata','do_getmaskdataall','do_getraddata','do_summary','do_setlabel',...
      'do_propagateall','do_rim','do_savemasks','do_average','do_map'};
nvars=length(vars);

if nargin>1,
if iscell(p1),
  p1cell=p1;
  for mm=1:length(p1cell), eval(sprintf('p%d=p1cell{mm};',mm)); end;
  mynargin=length(p1cell)+1;
else,
  mynargin=nargin;
end;
else, mynargin=1;
end;

if isempty(fnames),
    load tmp_summ_all
else,
    if exist('tmp_summ_all.mat','file'),
        tmpin=input('  tmp summ all file exists [1/enter=load, 0=delete]: ');
        if isempty(tmpin), tmpin=1; end;
        if tmpin==0, eval(sprintf('!rm tmp_summ_all.mat')); end;
    end
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

if nargin==1, flags.do_setup=1; flags.do_group=1; end;

if isfield(flags,'do_setup_done'), flags.do_setup=0; end;
if isfield(flags,'do_group_done'), flags.do_group=0; end;
if isfield(flags,'do_setlabel_done'), flags.do_setlabel=0; end;


if flags.do_setup,
  if isempty(fnames), fnames='T*_res.mat'; end;
  tmpdir=dir(fnames);
  for mm=1:length(tmpdir), 
      fname_all{mm}=tmpdir(mm).name;
      disp(sprintf('  loading %d %s avgims',mm,tmpdir(mm).name));
      load(tmpdir(mm).name,'avgim_raw','avgtc_raw','avgim_motc','avgtc_motc','avgim_intc','avgtc_intc','info'),
      if exist('avgim_intc','var'),
          avgim_all{mm}=avgim_intc; avgtc_all{mm}=avgtc_intc; 
      elseif exist('avgim_motc','var'),
          avgim_all{mm}=avgim_motc; avgtc_all{mm}=avgtc_motc; 
      elseif exist('avgim_raw','var'),
          avgim_all{mm}=avgim_raw; avgtc_all{mm}=avgtc_raw;
      else,
          disp('  none found, skipping');
          avgim_all{mm}=[]; avgtc_all{mm}=[];
      end;
      if exist('info','var'),
          info_all{mm}=info;
      end
      clear avgim_raw avgtc_raw avgim_motc avgtc_motc avgim_intc avgtc_intc info
  end
  avgim_all_orig=avgim_all;
  
  disp('  displaying images in fig1...');
  for mm=1:length(tmpdir),
      tmpok=0;
      tmpim=avgim_all{mm};
      if isempty(tmpim), tmpok=1; disp(sprintf('  %d empty, skipping',mm)); end;
      tmpminmax=[];
      while(~tmpok),
        figure(1), clf,
        if ~isempty(tmpminmax), show(tmpim,tmpminmax), else, show(tmpim), end; 
        xlabel(sprintf('%d: %s',mm,fname_all{mm})); drawnow, 
        tmpin=input(sprintf('  %d: enter min/max= ',mm),'s');
        if isempty(tmpin), 
            tmpok=1;
        else
            tmpminmax=str2num(['[',tmpin,']']);
            show(tmpim,tmpminmax), drawnow,
        end
      end
      if ~isempty(tmpminmax), avgim_all{mm}=imwlevel(avgim_all_orig{mm},tmpminmax,0); end;
  end
  
  figure(1), clf,
  showmany(avgim_all), drawnow,
  print -dpng tmp_summ_avgim_all
  flags.do_setup_done=1;
  
  sname='tmp_summ_all.mat';
  
  save tmp_summ_all fnames sname fname_all* flags avgim_all* avgtc_all*
  if exist('info_all','var'), save tmp_summ_all -append info_all ; end;
end;


if flags.do_group,
  % now group together
  figure(1), clf,
  showmany(avgim_all), drawnow,
  
  tmpcnt=0;
  for mm=1:length(fname_all), 
      figure(2), clf,
      if ~isempty(avgim_all{mm}),
      show(avgim_all{mm}), drawnow,
      xlabel(sprintf('  %d: %s',mm,fname_all{mm})); 
      tmpin=input(sprintf('  %d: [n=new, a=add-to-prev, iX:ins-to-X, s/enter=skip: ',mm),'s');
      if isempty(tmpin), tmpin='s'; end;
      if strcmp(tmpin(1),'n'),
          tmpcnt=tmpcnt+1;
          tmpii{tmpcnt}=mm;
      elseif strcmp(tmpin(1),'a'),
          if ~exist('tmpii','var'), 
              tmpcnt=tmpcnt+1; 
              tmpii{tmpcnt}=mm;
          else,
            tmpii{tmpcnt}=[tmpii{tmpcnt} mm];
          end
      elseif strcmp(tmpin(1),'i'),
          if length(tmpin)>1,
              tmpin2=str2num(tmpin(2:end));
              tmpii{tmpin2}=[tmpii{tmpin2} mm];
          else,
              tmpin2=input('    enter group label#: ');
              if ~isempty(tmpin2),
                  tmpii{tmpin2}=[tmpii{tmpin2} mm];
              end;
          end
      end
      end
  end
  ii_all=tmpii;
  clear tmpii tmpcnt tmpin tmpin2
  flags.do_group_done=1;
  
  save tmp_summ_all -append ii_all flags
end


if flags.do_setlabel,
  for mm=1:length(avgim_all),
      figure(1), clf,
      showmany(avgim_all), drawnow,
      figure(2), clf,
      show(avgim_all{mm}), drawnow,
      xlabel(sprintf('  %d: %s',mm,fname_all{mm})); 
      figure(3), clf,
      plot(avgtc_all{mm}'), drawnow,
      xlabel(sprintf('  %d: %s',mm,fname_all{mm}));
      if ~exist('label_all','var'), label_all{mm}=[]; end;
      if length(label_all)<mm, label_all{mm}=[]; end;
      disp(sprintf('  %02d: current label= %s',mm,label_all{mm}));
      tmpin=input(sprintf('  enter label for %d %s: ',mm,fname_all{mm}),'s');
      if isempty(tmpin)&isempty(label_all{mm}), tmpin=sprintf('run%02d',mm); end;
      if strcmp(tmpin,'skip'), tmpin=[]; end; 
      label_all{mm}=tmpin;
      disp(sprintf('  %d: assinging label %s',mm,label_all{mm}));
      tmpin2=input('  enter stim parameters [ntr nimtr noff nkeep nstim]: ');
      if ~isempty(tmpin2),
        if length(tmpin2)<3, tmpin2=[]; end;
        if length(tmpin2)==3, 
          tmpin2(4:5)=tmpin2(3);
          disp(sprintf('    nkeep set to %d and nstim set to %d',tmpin2(4),tmpin2(5)));
        elseif length(tmpin2)==4,
          tmpin2(5)=tmpin2(4);
          disp(sprintf('    nstim set to %d',tmpin2(5)));
        end;
        stimparms_all{mm}=tmpin2; 
      else, 
        stimparms_all{mm}=[];
      end;
  end;
  flags.do_label_done=1;
  save tmp_summ_all -append flags label_all stimparms_all
end


if flags.do_rim,
  flags_here=flags;
  for mm=1:length(fname_all),
      clear data tmptc rim data flags
      disp(sprintf('load %s data',fname_all{mm}));
      eval(sprintf('load %s data flags',fname_all{mm}));
      if isfield(flags,'motc_i1'),
        tmptc=squeeze(mean(mean(data(:,:,:,flags.motc_i1),1),2))';
        for oo=1:size(data,3), rim{oo}=OIS_corr2(squeeze(data(:,:,oo,flags.motc_i1)),tmptc); end;
      else,
        tmptc=squeeze(mean(mean(data,1),2))';
        for oo=1:size(data,3), rim{oo}=OIS_corr2(squeeze(data(:,:,oo,:)),tmptc); end;
      end;
      rim_all{mm}=rim;
      rim_avgtc_all{mm}=tmptc;
      eval(sprintf('save %s -append rim',fname_all{mm}));
      %if exist('label_all','var'), if ~isempty(label_all{mm}),
      %    eval(sprintf('%s.rim=rim;',label_all{mm}));
      %    eval(sprintf('%s.rim_avgtc=tmptc;',label_all{mm}));
      %    eval(sprintf('save tmp_summ_all -append %s',label_all{mm}));
      %end; end;
      save tmp_summ_all -append rim_all
  end;
  clear flags data
  flags=flags_here;
  
  flags.do_rim_done=1;
  save tmp_summ_all -append flags
end


if flags.do_vessels,
    if isempty(flags.vessels_parms), flags.vessels_parms=[1 1]; end;
    vch=flags.vessels_parms(1);
    invflag=flags.vessels_parms(2);
    for mm=1:length(ii_all),
        tmpok=0; tmpskip=0;
        while(~tmpok),
          figure(3), clf,
          show(avgim_all{ii_all{mm}(1)}),
          xlabel(sprintf('  %d: %s',ii_all{mm}(1),fname_all{ii_all{mm}(1)}));
          drawnow,
          figure(2), clf,
          show(avgim_all{ii_all{mm}(1)}(:,:,vch)),
          xlabel(sprintf('  %d-ch%d: %s',ii_all{mm}(1),vch,fname_all{ii_all{mm}(1)}));
          drawnow,
          if exist('rad_all','var'), if length(rad_all)>=ii_all{mm}(1), if ~isempty(rad_all{ii_all{mm}(1)}),
            figure(1), clf,
            im_overlay4(avgim_all{ii_all{mm}(1)}(:,:,vch),radiimask_all{ii_all{mm}(1)});
            drawnow,
          end; end; end;
          tmpin=input(sprintf('  %d: vch=%d inv=%d: verify [1/enter=ok, 0=skip, c#, i=inv, j=imadj]: ',ii_all{mm}(1),vch,invflag),'s');
          if isempty(tmpin), tmpin='1'; end;
          if strcmp(tmpin(1),'c'), vch=str2num(tmpin(2:end));
          elseif strcmp(tmpin(1),'s')|strcmp(tmpin(1),'0'), tmpok=1; tmpskip=1;
          elseif strcmp(tmpin(1),'Z'), tmpok=1; tmpskip=2;
          elseif strcmp(tmpin(1),'i'), invflag=abs(1-invflag);
          elseif strcmp(tmpin(1),'j'), [~,tmpims]=selectMask(avgim_all{ii_all{mm}(1)}(:,:,vch)); avgim_all{ii_all{mm}(1)}(:,:,vch)=tmpims.im1; clear tmpims
          elseif strcmp(tmpin(1),'1'), tmpok=1;
          end        
        end
        if tmpskip==2,
          rad_all{ii_all{mm}(1)}=[];
          radii_all{ii_all{mm}(1)}=[];
          radiimask_all{ii_all{mm}(1)}=[];
          radparms_all{ii_all{mm}(1)}=[];
        elseif tmpskip==1, 
          % flow thorough
    	else,
          figure(1), clf,
          tmprad1=manyRadROIs(avgim_all{ii_all{mm}(1)}(:,:,vch),invflag,[],[],0);
          [tmprad1ii,tmprad1ii_mask]=iiMasks1({tmprad1(:).mask},avgim_all{ii_all{mm}(1)}(:,:,vch),'select');
          rad_all{ii_all{mm}(1)}=tmprad1;
          radii_all{ii_all{mm}(1)}=tmprad1ii;
          radiimask_all{ii_all{mm}(1)}=tmprad1ii_mask;
          radparms_all{ii_all{mm}(1)}=[vch invflag];
          clear tmprad1
          save tmp_summ_all -append flags rad_all radii_all radiimask_all radparms_all
    	end
    end
end;


if flags.do_cells,
    if isempty(flags.cells_parms), flags.cells_parms=2; end;
    cch=flags.cells_parms(1);
    for mm=1:length(ii_all),
      tmpok=0; tmpskip=0;
      while(~tmpok),
        disp(sprintf('  %d-ch%d: %s',ii_all{mm}(1),cch,fname_all{ii_all{mm}(1)}));
        [~,tmpims]=selectMask(avgim_all{ii_all{mm}(1)}(:,:,cch));
        tmpim1=tmpims.im1;
        figure(1), clf,
        show(tmpim1),
        xlabel(sprintf('  %d-ch%d: %s',ii_all{mm}(1),cch,fname_all{ii_all{mm}(1)}));
        drawnow,
        tmpin3=input(sprintf('  %d: cch=%d: ok? [1/enter=y, s=skip, c#]: ',ii_all{mm}(1),cch),'s');
        if isempty(tmpin3), tmpin3='1'; end;
        if strcmp(tmpin3,'1'), tmpok=1;
        elseif strcmp(tmpin3,'s')|strcmp(tmpin3,'0'), tmpok=1; tmpskip=1;
        elseif strcmp(tmpin3(1),'c'), cch=str2num(tmpin3(2:end));
        end;
      end;
      if tmpskip,
        tmpCC=[];
      else,
        figure(1), clf,
        tmpCC=chkCellRing2bb(tmpim1);
      end;
      maskC_all{ii_all{mm}(1)}=tmpCC;
      clear tmpCC
      save tmp_summ_all -append flags maskC_all
    end
end


if flags.do_propagate,
    if isempty(flags.propagate_parms), propagate_cells=1; propagate_vessels=1; end;
    if strcmp(flags.propagate_parms,'vessels'), propagate_vessels=1; propagate_cells=0; end;
    if strcmp(flags.propagate_parms,'cells'), propagate_vessels=0; propagate_cells=1; end;
    if propagate_cells, disp('  propagating cells'); end;
    if propagate_vessels, disp('  propagating vessels'); end;
    for mm=1:length(ii_all),
      if length(ii_all{mm})>1,
        for nn=2:length(ii_all{mm}),
          if exist('maskC_all','var')&(propagate_cells),
            if ~isfield(flags,'cells_parms'), flags.cells_parms=2; end;
            cch=flags.cells_parms(1);
            tmpxx=imMotDetect(avgim_all{ii_all{mm}(nn)}(:,:,cch),avgim_all{ii_all{mm}(1)}(:,:,cch),[4 20 1 1 0]);
            tmpxx=-1*tmpxx;
            tmpxxf.mask_type=1; tmpxxf.xfer_type=1; tmpxxf.xo0to1=[0 0];
            tmpok=0; 
            while(~tmpok),
              tmpxxf.xx0to1=[tmpxx 0 1 1];
              [tmpmask,tmpmask_s]=xferMask1(maskC_all{ii_all{mm}(1)}.maskl,avgim_all{ii_all{mm}(1)}(:,:,cch),avgim_all{ii_all{mm}(nn)}(:,:,cch),tmpxxf);
              % check and adjust
              for oo=1:4,
                figure(1), clf, 
                subplot(221), show(avgim_all{ii_all{mm}(1)}(:,:,cch)), 
                xlabel(sprintf('  [1-REF] %d-ch%d: %s',ii_all{mm}(1),cch,fname_all{ii_all{mm}(1)}));
                subplot(222), show(avgim_all{ii_all{mm}(nn)}(:,:,cch)), 
                xlabel(sprintf('  [2-NoMove] %d-ch%d: %s',ii_all{mm}(nn),cch,fname_all{ii_all{mm}(nn)}));
                subplot(223), show(avgim_all{ii_all{mm}(nn)}(:,:,cch)), 
                xlabel(sprintf('  [2-ACT] %d-ch%d: %s',ii_all{mm}(nn),cch,fname_all{ii_all{mm}(nn)}));
                drawnow, pause(0.2),
                figure(1), clf, 
                subplot(221), im_overlay4(avgim_all{ii_all{mm}(1)}(:,:,cch),maskC_all{ii_all{mm}(1)}.maskl), 
                xlabel(sprintf('  [1-REF] %d-ch%d: %s',ii_all{mm}(1),cch,fname_all{ii_all{mm}(1)}));
                subplot(222), im_overlay4(avgim_all{ii_all{mm}(nn)}(:,:,cch),maskC_all{ii_all{mm}(1)}.maskl), 
                xlabel(sprintf('  [2-NoMove] %d-ch%d: %s',ii_all{mm}(nn),cch,fname_all{ii_all{mm}(nn)}));
                subplot(223), im_overlay4(avgim_all{ii_all{mm}(nn)}(:,:,cch),tmpmask), 
                xlabel(sprintf('  [2-ACT] %d-ch%d: %s',ii_all{mm}(nn),cch,fname_all{ii_all{mm}(nn)}));
                drawnow, pause(0.2),
              end;
              tmpin3=input(sprintf('  %d:[%.1f %.1f] adjust [x y], flash (f) or continue [enter]: ',ii_all{mm}(nn),tmpxx(1),tmpxx(2)),'s');
              if isempty(tmpin3),
                tmpok=1;
              elseif strcmp(tmpin3(1),'f')|strcmp(tmpin3(1),'F'),
                % ignore and flash
              else,
                tmpxx=str2num(['[',tmpin3,']']);
                if length(tmpxx)==1, tmpxx(2)=0; else, tmpxx=tmpxx(1:2); end;
              end;
            end;
            maskC_all{ii_all{mm}(nn)}=maskC_all{ii_all{mm}(1)};
            maskC_all{ii_all{mm}(nn)}.im=imshift2(maskC_all{ii_all{mm}(nn)}.im,tmpxx(1),tmpxx(2),1);
            maskC_all{ii_all{mm}(nn)}.maskl=xferMask1(maskC_all{ii_all{mm}(1)}.maskl,tmpmask_s);
            maskC_all{ii_all{mm}(nn)}.mask2l=xferMask1(maskC_all{ii_all{mm}(1)}.mask2l,tmpmask_s);
            maskC_all{ii_all{mm}(nn)}.maskll=xferMask1(maskC_all{ii_all{mm}(1)}.maskll,tmpmask_s);
            maskC_all{ii_all{mm}(nn)}.maskl_cm=maskC_all{ii_all{mm}(nn)}.maskl_cm+tmpxx;
            maskC_all{ii_all{mm}(nn)}.mask2l_cm=maskC_all{ii_all{mm}(nn)}.mask2l_cm+tmpxx;
            maskC_all{ii_all{mm}(nn)}.maskll_cm=maskC_all{ii_all{mm}(nn)}.maskll_cm+tmpxx;
          end; 
          
          if exist('rad_all','var')&(propagate_vessels), 
            if ~isempty(rad_all{mm}),
     	      if ~isfield(flags,'vessels_parms'), flags.vessels_parms=[1 1]; vessels_parms=[1 1]; end;
     	      if exist('radparms_all','var'), vessels_parms=radparms_all{ii_all{mm}(1)}; end;
        	  vch=vessels_parms(1);
           	  if ~exist('tmpxx','var'),
           	    tmpxx=imMotDetect(avgim_all{ii_all{mm}(nn)}(:,:,vch),avgim_all{ii_all{mm}(1)}(:,:,vch),[4 20 1 1 0]);
              	tmpxx=-1*tmpxx;
                tmpxxf.mask_type=1; tmpxxf.xfer_type=1; tmpxxf.xo0to1=[0 0];
              end;
              tmpok=0; 
              while(~tmpok),
                tmpmask=zeros(size(rad_all{ii_all{mm}(1)}(1).mask));
                for oo=1:length({rad_all{ii_all{mm}(1)}(:).mask}), tmpmask(find(rad_all{ii_all{mm}(1)}(oo).mask))=oo; end;
                tmpxxf.xx0to1=[tmpxx 0 1 1];
                [tmpmask,tmpmask_s]=xferMask1(tmpmask,avgim_all{ii_all{mm}(1)}(:,:,vch),avgim_all{ii_all{mm}(nn)}(:,:,vch),tmpxxf);
                % check and adjust 
                for oo=1:4,
              	  figure(1), clf, 
    		  	  subplot(221), show(avgim_all{ii_all{mm}(1)}(:,:,vch)), 
                  xlabel(sprintf('  [1-REF] %d-ch%d: %s',ii_all{mm}(1),vch,fname_all{ii_all{mm}(1)}));
                  subplot(222), show(avgim_all{ii_all{mm}(nn)}(:,:,vch)), 
                  xlabel(sprintf('  [2-NoMove] %d-ch%d: %s',ii_all{mm}(nn),vch,fname_all{ii_all{mm}(nn)}));
                  subplot(223), show(avgim_all{ii_all{mm}(nn)}(:,:,vch)), 
                  xlabel(sprintf('  [2-ACT] %d-ch%d: %s',ii_all{mm}(nn),vch,fname_all{ii_all{mm}(nn)}));
                  drawnow,
                  figure(1), clf, 
                  subplot(221), im_overlay4(avgim_all{ii_all{mm}(1)}(:,:,vch),{rad_all{ii_all{mm}(1)}(:).mask}), 
            	  xlabel(sprintf('  [1-REF] %d-ch%d: %s',ii_all{mm}(1),vch,fname_all{ii_all{mm}(1)}));
                  subplot(222), im_overlay4(avgim_all{ii_all{mm}(nn)}(:,:,vch),{rad_all{ii_all{mm}(1)}(:).mask}), 
                  xlabel(sprintf('  [2-NoMove] %d-ch%d: %s',ii_all{mm}(nn),vch,fname_all{ii_all{mm}(nn)}));
                  subplot(223), im_overlay4(avgim_all{ii_all{mm}(nn)}(:,:,vch),tmpmask), 
                  xlabel(sprintf('  [2-ACT] %d-ch%d: %s',ii_all{mm}(nn),vch,fname_all{ii_all{mm}(nn)}));
                  drawnow,
                end;
                tmpin3=input(sprintf('  %d:[%.1f %.1f] adjust [x y], flash (f) or continue [enter]: ',ii_all{mm}(nn),tmpxx(1),tmpxx(2)),'s');
                if isempty(tmpin3),
                  tmpok=1;
                elseif strcmp(tmpin3(1),'f')|strcmp(tmpin3(1),'F'),
                  % ignore and flash
                else,
                  tmpxx=str2num(['[',tmpin3,']']);
                  if length(tmpxx)==1, tmpxx(2)=0; else, tmpxx=tmpxx(1:2); end;
                end;
              end;
              rad_all{ii_all{mm}(nn)}=rad_all{ii_all{mm}(1)};
              radii_all{ii_all{mm}(nn)}=radii_all{ii_all{mm}(1)};
              radiimask_all{ii_all{mm}(nn)}=radiimask_all{ii_all{mm}(1)};
              radparms_all{ii_all{mm}(nn)}=radparms_all{ii_all{mm}(1)};
              for oo=1:length(rad_all{ii_all{mm}(nn)}),
                  rad_all{ii_all{mm}(nn)}(oo).aloc=rad_all{ii_all{mm}(nn)}(oo).aloc+tmpxx;
                  rad_all{ii_all{mm}(nn)}(oo).mask=xferMask1(rad_all{ii_all{mm}(nn)}(oo).mask,tmpmask_s);
                  [tmpa,tmpb]=getRectImGrid(avgim_all{ii_all{mm}(nn)}(:,:,vch),rad_all{ii_all{mm}(nn)}(oo));
                  % determine if new location is valid or skip
                  %rad_all{ii_all{mm}(nn)}(oo).valid=1;
              end
              xxf_all{ii_all{mm}(nn)}=tmpxxf;
            else,
              % not sure what to do here -- empty but not right
              %rad_all{ii_all{mm}(nn)}=[];
              %radii_all{ii_all{mm}(nn)}=[];
              %radiimask_all{ii_all{mm}(nn)}=[];
              %radparms_all{ii_all{mm}(nn)}=[];
              %xxf_all{ii_all{mm}(nn)}=[];
              %tmpxxf=[];
            end;
          end;
          clear tmpxx tmpxxf
        end;
      else,
        xxf_all{ii_all{mm}(1)}=[0 0 0 1 1];
      end;
      if exist('maskC_all','var'),
        save tmp_summ_all -append  xxf_all maskC_all 
      end
      if exist('rad_all','var'), 
        save tmp_summ_all -append xxf_all rad_all radii_all radiimask_all radparms_all
      end;
    end;
end


% if flags.do_propagateall,
%   if isempty(flags.propagateall_parms), flags.propagateall_parms={[1:length(ii_all)],2}; end;
%   if iscell(flags.propagateall_parms), 
%       prop_ii=flags.propagateall_parms{1}; 
%       pch=flags.propagate_all{2}; 
%   else,
%       prop_ii=flags.propagateall_parms;
%       pch=2;
%   end;
%   for mm=1:length(prop_ii),
%     if length(ii_all{prop_ii(mm)})>1,
%       clear mask*
%       eval(sprintf('load %s mask*',fname_all{ii_all{prop_ii(mm)}(1)}));
%       tmrmaskvar=who('mask*');
%       eval(sprintf('tmpmask1=%s;',tmpmaskvar{1}));
%       for nn=2:length(ii_all{prop_ii(mm)}),
%         clear xxf_here tmpvarmask
%         disp(sprintf('  group %d, %d of %d',ii_all{prop_ii(mm)}(1),nn,length(ii_all{prop_ii(mm)})));
%         if exist('xxf_all','var'), if ~isempty(xxf_all{mm}(1)),
%           tmpin1=input('  found xfer values, use? [1/enter=yes. 0=no]: ');
%           if isempty(tmpin1), tmpin1=1; end;
%           if tmpin1==1, xxf_here=xxf_all{ii_all{prop_ii(mm)}(1)}; end;
%         end; end;
%         if ~exist('xxf_here','var'),  % set xxf
%           tmpxxf.xx0to1=[tmpxx 0 1 1];
%           [tmpmask2,tmpmask2_s]=xferMask1(tmpmask1,avgim_all{ii_all{prop_ii(mm)}(1)}(:,:,pch),avgim_all{ii_all{prop_ii(mm)}(nn)}(:,:,pch),tmpxxf);
%         end;
%         for oo=1:length(tmpvarmask),
%           disp(sprintf('    propagating %s ...',tmpvarmask{oo});
%           eval(sprintf('tmpmask1=%s;',tmpvarmask{oo}));
%           eval(sprintf('%s_ref=%s;',tmpvarmask{oo}));
%           tmpmask2=xferMask1(maskC_all{ii_all{mm}(1)}.maskl,avgim_all{ii_all{mm}(1)}(:,:,cch),avgim_all{ii_all{mm}(nn)}(:,:,cch),tmpxxf);
%           eval(sprintf('%s=tmpmask1;',tmpvarmask{oo}));
%           eval(sprintf('save %s -append %s %s_ref',
%           eval(sprintf('%s=%s_ref;'
%           eval(sprintf('clear %s_ref'
%         end;
%       end;
%     else,
%       disp(sprintf('  group %d, %d of %d',ii_all{prop_ii(mm)}(1),nn,length(ii_all{prop_ii(mm)})));
%       disp('  nothing to propagate in this group');
%     end;
%   end;
%   load tmp_summ_all masks_all
% end


if flags.do_savemasks,
    if isempty(flags.savemasks_parms), save_ii=[1:length(fname_all)]; else, save_ii=flags.savemasks_parms; end;
    for mm=save_ii,
        if exist('maskC_all','var'), if ~isempty(maskC_all{mm}),
            clear maskC
            maskC=maskC_all{mm};
            if ~isempty(maskC),
            disp(sprintf('save %s -append maskC',fname_all{mm}));
            eval(sprintf('save %s -append maskC',fname_all{mm}));
            end
        end; end;
        if exist('rad_all','var'), if ~isempty(rad_all{mm}),
            clear rad radii radiimask
            rad=rad_all{mm};
            radii=radii_all{mm};
            radiimask=radiimask_all{mm};
            if ~isempty(rad),
            disp(sprintf('save %s -append rad radii radiimask',fname_all{mm}));
            eval(sprintf('save %s -append rad radii radiimask',fname_all{mm}));
            end
        end; end;
    end
end


if flags.do_getmaskdata,
  if isempty(flags.getmaskdata_parms), get_ii=[1:length(fname_all)]; else, get_ii=flags.getmaskdata_parms; end;
  for mm=get_ii,
    if exist('maskC_all','var'), if ~isempty(maskC_all{mm}),
      clear data maskC
      disp(sprintf('load %s data maskC',fname_all{mm}));
      eval(sprintf('load %s data maskC',fname_all{mm}));
      tmpavg=0;
      if isstruct(maskC), 
          if exist('stimparms_all','var'), if length(stimparms_all)>=mm, if ~isempty(stimparms_all{mm}), tmpavg=1; end; end; end;
          if tmpavg,
            tcC=getStkMaskTC(data,maskC.maskl,[1:stimparms_all{mm}(5)],[],[],stimparms_all{mm});
          else
            tcC=getStkMaskTC(data,maskC.maskl);
          end
      else,
          if exist('stimparms_all','var'), if length(stimparms_all)>=mm, if ~isempty(stimparms_all{mm}), tmpavg=1; end; end; end;
          if tmpavg,
            tcC=getStkMaskTC(data,maskC,[1:stimparms_all{mm}(5)],[],[],stimparms_all{mm});
          else
            tcC=getStkMaskTC(data,maskC);
          end
      end
      tcC_all{mm}=tcC;
      eval(sprintf('save %s -append tcC',fname_all{mm}));
      if exist('label_all','var'), if ~isempty(label_all{mm}),
          eval(sprintf('load tmp_varsumm_all %s',label_all{mm}));
          eval(sprintf('%s.maskC=maskC;',label_all{mm}));
          eval(sprintf('%s.tcC=tcC;',label_all{mm}));
          eval(sprintf('save tmp_varsumm_all -append %s',label_all{mm}));
          eval(sprintf('clear %s',label_all{mm}));
      end; end;
      save tmp_summ_all -append tcC_all
    end; end;
  end;
end


if flags.do_getmaskdataall,
  if isempty(flags.getmaskdataall_parms), get_ii=[1:length(fname_all)]; else, get_ii=flags.getmaskdataall_parms; end;
  for mm=get_ii,
    clear data mask* tc*
    disp(sprintf('load %s data mask*',fname_all{mm}));
    eval(sprintf('load %s data mask*',fname_all{mm}));
    tmpvar=who('mask*');
    for oo=1:length(tmpvar),
      if length(tmpvar{oo})>4,
        eval(sprintf('tmpflag=isstruct(%s);',tmpvar{oo}));
        if tmpflag,
          tmpavg=0;
          if exist('stimparms_all','var'), if length(stimparms_all)>=mm, if ~isempty(stimparms_all{mm}), tmpavg=1; end; end; end;
          if tmpavg,
              eval(sprintf('tc%s=getStkMaskTC(data,mask%s,[1:stimparms_all{mm}(5)],[],[],stimparms_all{mm});',tmpvar{oo}(5:end),tmpvar{oo}(5:end)));
          else,
              eval(sprintf('tc%s=getStkMaskTC(data,mask%s);',tmpvar{oo}(5:end),tmpvar{oo}(5:end)));
          end
        else,
          tmpavg=0;
          if exist('stimparms_all','var'), if length(stimparms_all)>=mm, if ~isempty(stimparms_all{mm}), tmpavg=1; end; end; end;
          if tmpavg,
            eval(sprintf('tc%s=getStkMaskTC(data,mask%s.maskl,[1:stimparms_all{mm}(5)],[],[],stimparms_all{mm});',tmpvar{oo}(5:end),tmpvar{oo}(5:end)));
          else
            eval(sprintf('tc%s=getStkMaskTC(data,mask%s.maskl);',tmpvar{oo}(5:end),tmpvar{oo}(5:end)));
          end
        end;
        if exist('label_all','var'), if ~isempty(label_all{mm}),
          eval(sprintf('load tmp_varsumm_all %s',label_all{mm}));
          eval(sprintf('%s.tc%s=tc%s;',label_all{mm},tmpvar{oo}(5:end),tmpvar{oo}(5:end)));
        end; end;
      end;
    end;
    eval(sprintf('save %s -append tc*',fname_all{mm}));
    if ~isempty(label_all{mm}),
      eval(sprintf('save tmp_varsumm_all -append %s',label_all{mm}));
      eval(sprintf('clear %s',label_all{mm}));
    end
  end;
end


if flags.do_getraddata,
  if isempty(flags.getraddata_parms), get_ii=[1:length(fname_all)]; else, get_ii=flags.getraddata_parms; end;
  for mm=get_ii,
    if exist('rad_all','var'), if ~isempty(rad_all{mm}),
      clear data rad radii rr rra
      disp(sprintf('load %s data rad radii',fname_all{mm}));
      eval(sprintf('load %s data rad radii',fname_all{mm}));
      if length(radparms_all{mm})>2,
          rr=calcRadius6(im_smooth(squeeze(data(:,:,radparms_all{mm}(1),:)),radparms_all{mm}(3)),rad,radparms_all{mm}(2));
      else,
          rr=calcRadius6(squeeze(data(:,:,radparms_all{mm}(1),:)),rad,radparms_all{mm}(2));
      end;
      %[size(rr) length(radii)],
      for oo=1:length(radii), rra(:,oo)=mean(mysmooth(rr(:,radii{oo})),2); end;
      rr_all{mm}=rr;
      rra_all{mm}=rra;
      eval(sprintf('save %s -append rr rra',fname_all{mm}));
      %if exist('label_all','var'), if ~isempty(label_all{mm}),
      %    eval(sprintf('%s.rr=rr;',label_all{mm}));
      %    eval(sprintf('%s.rra=rra;',label_all{mm}));
      %    eval(sprintf('%s.radii=radii;',label_all{mm}));
      %    eval(sprintf('save tmp_varsumm_all -append %s',label_all{mm}));
      %end; end;
      save tmp_summ_all -append rr_all rra_all
    end; end;
  end;
end


if flags.do_average,
    if ~isempty(flags.average_parms), avgii=flags.average_parms; else, avgii=[1:length(fname_all)]; end;
    if exist('stimparms_all','var'),
        for mm=avgii,
            if (length(stimparms_all)>=mm), if ~isempty(stimparms_all{mm}),
                clear data
                ntr=stimparms_all{mm}(1); nimtr=stimparms_all{mm}(2); noff=stimparms_all{mm}(3); nkeep=stimparms_all{mm}(4);
                eval(sprintf('load %s data',fname_all{mm}));
                adata=mean(reshape(data(:,:,:,[1:nimtr*ntr]+noff-nkeep),[size(data,1),size(data,2),size(data,3),nimtr,ntr]),5);
                adata_all{mm}=adata;
                disp(sprintf('  saving adata to (%d) %s',mm,fname_all{mm}));
                eval(sprintf('save %s -append adata nimtr ntr noff nkeep',fname_all{mm}));
                clear data adata ntr nimtr noff nkeep
                save tmp_summ_all -append adata_all
            end; end;
        end 
    end
end


if flags.do_map,
    %  consider the artifact -- flags.realign_parms=2,motc_i2=xxx to skip artifact if present
    %  ask to get data from maps
    %  check if map present
    %  save map mask as maskMap or maskA or maskA1
    if ~isempty(flags.map_parms), mapii=flags.map_parms; else, mapii=[1:length(fname_all)]; end;
    if exist('stimparms_all','var'),
        for mm=mapii,
            if (length(stimparms_all)>=mm), if ~isempty(stimparms_all{mm}),
               clear data
               eval(sprintf('load %s data',fname_all{mm}));
               ntr=stimparms_all{mm}(1); 
               nimtr=stimparms_all{mm}(2); 
               noff=stimparms_all{mm}(3); 
               nkeep=stimparms_all{mm}(4);
               nstim=stimparms_all{mm}(5);
               for oo=1:size(data,3),
                  map(oo)=myOISmap1b(data(:,:,oo,:),[ntr nimtr noff nkeep],[nstim nkeep],{'x0.5',2});
               end 
               disp(sprintf('  saving map to (%d) %s',mm,fname_all{mm}));
               eval(sprintf('save %s -append map',fname_all{mm}));
               map_all{mm}=map;
               clear data map ntr nimtr noff nkeep nstim
               save tmp_summ_all -append map_all
            end; end;
        end
    end
end

if flags.do_summary,
    if ~exist('label_all','var'), error('  label variable not set'); end;
    for mm=1:length(label_all),
      if exist('avgim_all','var')&(length(avgim_all)>=mm),
          eval(sprintf('%s.avgim=avgim_all{mm};',label_all{mm}));
      end
      if exist('avgtc_all','var')&(length(avgtc_all)>=mm),
          eval(sprintf('%s.avgtc=avgtc_all{mm};',label_all{mm}));
      end
      if exist('rim_all','var')&(length(rim_all)>=mm),
          eval(sprintf('%s.rim=rim_all{mm};',label_all{mm}));
          %eval(sprintf('%s.rim_avgtc=rim_avgtc_all{mm};',label_all{mm}));
      end
      if exist('rr_all','var')&(length(rr_all)>=mm),
          eval(sprintf('%s.rr=rr_all{mm};',label_all{mm}));
          eval(sprintf('%s.rra=rra_all{mm};',label_all{mm}));
      end
      if exist('rad_all','var')&(length(rad_all)>=mm),
          eval(sprintf('%s.rad=rad_all{mm};',label_all{mm}));
          eval(sprintf('%s.radii=radii_all{mm};',label_all{mm}));
          eval(sprintf('%s.radiimask=radiimask_all{mm};',label_all{mm}));
          eval(sprintf('%s.radparms=radparms_all{mm};',label_all{mm}));
      end
      if exist('maskC_all','var')&(length(maskC_all)>=mm),
          eval(sprintf('%s.maskC=maskC_all{mm};',label_all{mm}));
      end
      if exist('tcC_all','var')&(length(tcC_all)>=mm),
          eval(sprintf('%s.tcC=tcC_all{mm};',label_all{mm}));
      end
      if exist('map_all','var')&(length(map_all)>=mm),
          eval(sprintf('%s.map=map_all{mm};',label_all{mm}));
      end
      if exist('adata_all','var')&(length(adata_all)>=mm),
          eval(sprintf('%s.adata=adata_all{mm};',label_all{mm}));
      end
      
      %eval(sprintf('save tmp_summ_all -append %s',label_all{mm}));
      if ~exist('tmp_varsumm_all.mat','file'),
          eval(sprintf('save tmp_varsumm_all %s',label_all{mm}));
      else,
          eval(sprintf('save tmp_varsumm_all -append %s',label_all{mm}));
      end
    end;
end;
