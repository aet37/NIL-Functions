function quickmap_led(fname,led_parms,stim_parms,nbin_xy,nbin_t,basims,actims,pims)
% Usage ... quickmap_led(fname,led_parms,stim_parms,nbin_xy,nbin_t,baseim,actim,panelims)
%
% Same as quickmap_scr and quickmap_scr2 except for multi-led data
% nimtr,noff,nkeep,nbin_t,baseims,actims are for a single led numbers
% led_parms=[nled,ledno]
% stim_parms=[ntr,nimtr,noff,nkeep]
%
% Ex. quickmap_led('20200820mouse_1187_wh1.stk',[3 2],[12 360 300 20],1,5,[1:2],[5:8],[1:20])

if ~exist('led_parms','var'), led_parms=[]; end;
if isempty(led_parms), led_parms=[3 1]; end;
if length(led_parms)==1, led_parms(2)=1; end;

nled=led_parms(1);
ledno=led_parms(2);

ntr=stim_parms(1);
nimtr=stim_parms(2);
noff=stim_parms(3);
nkeep=stim_parms(4);

nimtr_orig=nimtr;
noff_orig=noff;
nkeep_orig=nkeep;
nimtr=nimtr_orig*nled;
noff=noff_orig*nled;
nkeep=nkeep_orig*nled;


im_leds=readOIS3(fname,nled*3+[1:nled]);
im=im_leds(:,:,ledno);
imsz=size(im_leds);
figure(1), showmany(im_leds), drawnow,

nims=noff+ntr*nimtr;

ims=single(zeros(imsz(1)/nbin_xy,imsz(2)/nbin_xy,nimtr/nled/nbin_t));
tmpims=ims;

for mm=1:ntr,
  tmpims=single(zeros(imsz(1)/nbin_xy,imsz(2)/nbin_xy,nimtr/nled/nbin_t));
  for nn=1:nimtr/nled/nbin_t,
    tmpimno=noff-nkeep+(mm-1)*nimtr+ledno+(nn-1)*nled*nbin_t;
    disp(sprintf('  reading tr#%02d %02d im#%05d (%d:%d)',mm,nn,tmpimno,nled,nbin_t));
    tmpims(:,:,nn)=imbin(mean(readOIS3(fname,tmpimno+[0:nled:nled*nbin_t]),3),nbin_xy);
  end;
  basim(:,:,mm)=mean(tmpims(:,:,basims),3);
  actim(:,:,mm)=mean(tmpims(:,:,actims),3);
  tmpims=tmpims./repmat(basim(:,:,mm),[1 1 size(tmpims,3)])-1;
  ims=ims+tmpims;
  clear tmpims
end;
ims=ims/ntr;

actim1=mean(actim./basim,3)-1;
panels=tile3d(volbin(ims(:,:,pims*2),[2 2 2]));

figure(1), clf, show(actim1),
figure(2), clf, show(panels),

disp(sprintf('save %s_%d fname led_parms stim_parms ims actim1 panels basim actim nled ledno im_leds im ntr nimtr noff nkeep',fname(1:end-4),ledno));
eval(sprintf('save %s_%d fname led_parms stim_parms ims actim1 panels basim actim nled ledno im_leds im ntr nimtr noff nkeep',fname(1:end-4),ledno));

