function caa_scr1(fname_pre,fname_post,id)
% Usage ... caa_scr1(fname_pre,fname_post,id)
%
% CAA project script analysis
% Reads PRE and POST injection stacks (include slash in folder name)
% Reads stacks headers
% Defines masks for vessel and tissue
%
% Ex. caa_scr1('ZSeries-05032017-1350-3762/','ZSeries-05032017-1350-3766/','caa_x12a')

%fname_pre='ZSeries-05032017-1350-3762/';
%fname_post='ZSeries-05032017-1350-3766/';

% items to add to the script:
%  select channel and analyze other channel
%  select parenchymal blood vessel images (deeper than 125um)

if nargin<3, id=[]; end;
if isempty(id), id='tmp_caa1'; end;

flags.do_load=1;
flags.do_getpower=1;
flags.do_masks=1;
flags.do_applymasks=1;
flags.do_print=1;

tmpname=sprintf('%s_res.mat',id);
if exist(tmpname,'file'),
  tmpin=input('  result file exists [1=start-over, 2=load, 0=exit]: ');
  if tmpin==2,
    eval(sprintf('load %s',tmpname));
  elseif tmpin==0,
    return,
  end;
end;


if isfield(flags,'do_load_done'), if flags.do_load_done, flags.do_load=0; end; end;
if isfield(flags,'do_getpower_done'), if flags.do_getpower_done, flags.do_getpower=0; end; end;
if isfield(flags,'do_masks_done'), if flags.do_masks_done, flags.do_masks=0; end; end;
if isfield(flags,'do_applymasks_done'), if flags.do_applymasks_done, flags.do_applymasks=0; end; end;
if isfield(flags,'do_print_done'), if flags.do_print_done, flags.do_print=0; end; end;

disp(sprintf('  do_load=%d, do_getpower=%d, do_masks=%d, do_applymasks=%d, do_print=%d',...
     flags.do_load,flags.do_getpower,flags.do_masks,flags.do_applymasks,flags.do_print));
 
if flags.do_load,
  dname=pwd;
  disp('  reading pre-stack...');
  if ~exist('data_pre','var'), data_pre=single(twop_filt(readPrairie2(fname_pre),3,0.4)); end;
  if ~exist('header_pre','var'), header_pre=parsePrairieXML(fname_pre); end;

  disp('  reading post-stack...');
  if ~exist('data_post','var'), data_post=single(twop_filt(readPrairie2(fname_post),3,0.4)); end;
  if ~exist('header_post','var'), header_post=parsePrairieXML(fname_post); end;

  wavelen=header_post.PV_shared.laserWavelength;
  eval(sprintf('save %s_res',id));

  % check re-orient
  figure(1), clf,
  showProj(squeeze(data_pre(:,:,2,:))),
  tmpin=input('  reorient pre-stack [0=no, 1=yes]: ');
  if isempty(tmpin), tmpin=0; end;
  if tmpin==1,
    [data_pre(:,:,2,:),xor_pre]=reorientVolume1(squeeze(data_pre(:,:,2,:)));
    [data_pre(:,:,1,:)]=reorientVolume1(squeeze(data_pre(:,:,1,:)),xor_pre);
  end;
  
  figure(1), clf,
  showProj(squeeze(data_post(:,:,2,:))),
  tmpin=input('  reorient post-stack [0=no, 1=yes]: ');
  if isempty(tmpin), tmpin=0; end;
  if tmpin==1,
    [data_post(:,:,2,:),xor_post]=reorientVolume1(squeeze(data_post(:,:,2,:)));
    [data_post(:,:,1,:)]=reorientVolume1(squeeze(data_post(:,:,1,:)),xor_post);
  end;
  
  % establish max and avg images
  if ~exist('xor_post','var'),
    max_pre=max(data_pre,[],4);
    max_post=max(data_post,[],4);
    avg_pre=mean(data_pre,4);
    avg_post=mean(data_post,4);
  else,
    [max_pre,pre_ii]=stkProj(squeeze(data_pre(:,:,2,:)),'select');
    [max_post,post_ii]=stkProj(squeeze(data_post(:,:,2,:)),'select');
    max_pre(:,:,2)=max_pre(:,:,1); 
    max_pre(:,:,1)=max(squeeze(data_pre(:,:,1,pre_ii)),[],3);
    max_post(:,:,2)=max_post(:,:,1); 
    max_post(:,:,1)=max(squeeze(data_post(:,:,1,post_ii)),[],3);
    avg_pre=mean(data_pre(:,:,:,pre_ii),4);
    avg_post=mean(data_post(:,:,:,post_ii),4);      
  end;
  
  flags.do_load_done=1;
  
  eval(sprintf('save %s_res',id));
end;

if flags.do_getpower,
  if isfield(header_pre.Frame(1),'laserPower'),
    tmplpow=[header_pre.Frame(:).laserPower];
    %lpow_pre(1)=mean(tmplpow([1:length(header_pre.Frame(1).laserPower):end]));
    lpow_pre(1)=mean(tmplpow);
  else,
    lpow_pre(1)=header_pre.PV_shared.laserPower(1);
  end;
  lpow_pre(2)=header_pre.PV_shared.twophotonLaserPower;
  if isfield(header_post.Frame(1),'laserPower'),
    tmplpow=[header_post.Frame(:).laserPower];
    %lpow_post(1)=mean(tmplpow([1:length(header_post.Frame(1).laserPower):end]));
    lpow_post(1)=mean(tmplpow);
  else,
    lpow_post(1)=header_post.PV_shared.laserPower;
  end;
  lpow_post(2)=header_post.PV_shared.twophotonLaserPower;
  flags.do_getpower_done=1;
  
  eval(sprintf('save %s_res -append lpow_* flags',id));
end;

if flags.do_masks,
  % select masks based on post
  disp('  select vessel mask...');
  if ~exist('maskV_post','var'), maskV_post=selectMask(max_post(:,:,2)); end;
  disp('  select tissue mask...');
  if ~exist('maskT_post','var'), maskT_post=selectMask(max_post(:,:,2)); end;
  disp('  select plaque mask...');
  if ~exist('maskP_post','var'), 
    maskP_post=selectMask(max_post(:,:,2).*maskT_post); 
    maskP_post=imdilate(maskP_post,strel('disk',3)); 
  end;
  eval(sprintf('save %s_res -append maskV_post maskT_post maskP_post',id));
  
  % xfer masks to pre
  [maskV_pre,xx_pre]=xferMask1(maskV_post,max_post(:,:,2),max_pre(:,:,2));
  [maskT_pre]=xferMask1(maskT_post,max_post(:,:,2),max_pre(:,:,2),xx_pre);
  [maskP_pre]=xferMask1(maskP_post,max_post(:,:,2),max_pre(:,:,2),xx_pre);
  
  % ensure masks are ok
  maskT_pre=(maskT_pre)&(~maskV_pre);
  maskP_pre=(maskP_pre)&(~maskV_pre);
  maskT_post=(maskT_post)&(~maskV_post);
  maskP_post=(maskP_post)&(~maskV_post);
  
  flags.do_masks_done=1;
 
  eval(sprintf('save %s_res -append maskV_* maskT_* maskP_* xx_* flags',id));
  
end;

if flags.do_applymasks,
  clf, 
  subplot(121), show(im_super(max_pre(:,:,2),maskV_pre,0.5)), drawnow,
  subplot(122), show(im_super(max_post(:,:,2),maskV_post,0.5)), drawnow,

  % get numbers and scale according to power
  tmpV_pre=mean(avg_pre(find(maskV_pre)));
  tmpT_pre=mean(avg_pre(find(maskT_pre)));
  tmpP_pre=mean(avg_pre(find(maskP_pre)));
  tmpV_post=mean(avg_post(find(maskV_post)));
  tmpT_post=mean(avg_post(find(maskT_post)));
  tmpP_post=mean(avg_post(find(maskP_post)));

  % VTmat= vessel tissue- pre top, post bottom
  % adj has power adjusted numbers
  % x are from MAX projection images
  % want rVT_adj=100*(VTmat_adj(2,:)./VTmat_adj(1,:)-1)
  VTmat=[tmpV_pre tmpT_pre tmpP_pre; tmpV_post tmpT_post tmpP_post];
  PPmat=[[1 1 1]*lpow_pre(2)*estLaserPower(wavelen,lpow_pre(1)); [1 1 1]*lpow_post(2)*estLaserPower(wavelen,lpow_post(1))];

  VTmat_adj=VTmat./PPmat;

  tmpV_pre=mean(max_pre(find(maskV_pre)));
  tmpT_pre=mean(max_pre(find(maskT_pre)));
  tmpP_pre=mean(max_pre(find(maskP_pre)));
  tmpV_post=mean(max_post(find(maskV_post)));
  tmpT_post=mean(max_post(find(maskT_post)));
  tmpP_post=mean(max_post(find(maskP_post)));

  VTxmat=[tmpV_pre tmpT_pre tmpP_pre; tmpV_post tmpT_post tmpP_post];
  VTxmat_adj=VTxmat./PPmat;
  flags.do_applymasks_done=1;
  
  VTxmat_adj,
  
  eval(sprintf('save %s_res -append VTmat* VTxmat* PPmat flags',id));
end;

if flags.do_print,
  clf, subplot(121), show(max_pre(:,:,2)), xlabel('MAX PRE'),
  subplot(122), show(max_post(:,:,2)), xlabel('MAX POST'),
  eval(sprintf('print -dpng sample_%s_max',id));
  clf, subplot(121), show(im_super(max_pre(:,:,2),maskV_pre,0.5)), xlabel('MAX PRE MaskV'),
  subplot(122), show(im_super(max_post(:,:,2),maskV_post,0.5)), xlabel('MAX POST'),
  eval(sprintf('print -dpng sample_%s_maskVov',id));
  clf, subplot(121), show(im_super(max_pre(:,:,2),maskT_pre,0.5)), xlabel('MAX PRE MaskV'),
  subplot(122), show(im_super(max_post(:,:,2),maskT_post,0.5)), xlabel('MAX POST'),
  eval(sprintf('print -dpng sample_%s_maskTov',id));
  %flags.do_print_done=1;
  % eval(sprintf('save %s_res -append flags',id));
end;


