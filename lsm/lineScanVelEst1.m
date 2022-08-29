function y=lineScanVelEst1(lineIm,lineParms,dx_dt,supParms)
% Usage ... y=lineScanVelEst1(lineIm,lineParms,dx_dt,supParms)
%
% lineParms=[#lines-per-velcalc #lines-skip col1 col2]
% dxdt=[pix-size-in-mm linetime-in-sec]
% supParms=[mfw smfw hcf snrthr fluxthr]

do_radc=1;
do_optim=0;
do_finetune=1;
do_figure=1;

opt1=optimset('fminbnd');
opt1.TolX=1e-12;

if ~exist('supParms','var'), supParms=[]; end;
if ~exist('dx_dt','var'), dx_dt=[]; end;
if ~exist('lineParms','var'), lineParms=[]; end;

ldim=size(lineIm);

if isempty(lineParms),
  lineParms(1)=ldim(2);
  lineParms(2)=round(ldim(2)/2);
end;
if length(lineParms)==2,
  lineParms(3)=1;
  lineParms(4)=ldim(2);
end;
if isempty(dx_dt), dx_dt=[1 1]; end;
if isempty(supParms),
  supParms(1)=3;
  supParms(2)=0.8;
  supParms(3)=1;
  supParms(4)=0;
  supParms(5)=0.40;
end;

dxdt=dx_dt(1)/dx_dt(2);

do_snr=1;
if supParms(4)==0, do_snr=0; end;

nlines=lineParms(1);
nskp=lineParms(2);
col1=lineParms(3);
col2=lineParms(4);
mfw=supParms(1);
smw=supParms(2);
hcf=supParms(3);
snrthr=supParms(4);
fluxthr=supParms(5);

rang=[0:2:179];
rfine=[5 0.02];

rmin=-90;
rmax=+90;
rtype=4;
idxy=[0.25 0.25];

for mm=1:floor((ldim(1)-nlines-1)/nskp),
  % get and prep line image
  tmpii=[1:nlines]+(mm-1)*nskp;
  tmpim=lineIm(tmpii,col1:col2);
  
  if mfw>0, tmpim=medfilt2(tmpim,[1 mfw]); end;
  if smw>0, tmpim=im_smooth(tmpim,smw); end;
  if hcf>0, if hcf==1, tmpim=homocorOIS(tmpim); else, tmpim=homocorOIS(tmpim,hcf); end; end;
  tmpim=imwlevel(tmpim,[],1);
  
  if do_optim,
     % find angle by rotation
    [tmp_rang,tmp_ree,tmp_rex]=fminbnd(@imlineRotf,rmin,rmax,opt1,tmpim,rtype,idxy);
    if do_finetune,
      tmpang2=tmp_rang+[[-5:0.01:-0.001] [0:.01:5]];
      tmprad2=radon(tmpim',tmpang2);
      tmpvar2=var(tmprad2,[],1);
      [tmpmax,tmpmaxi]=max(tmpvar2);
      tmp_rang2=tmpang2(tmpmaxi);
      if abs(tmp_rang-tmp_rang2)>0.1,
        disp(sprintf('  replacing with fine-tune angle (%.4f to %.4f) ...',tmp_rang,tmp_rang2));
        tmp_rang=tmp_rang2;
      end;
    end;
    
    lang(mm)=tmp_rang;
    tmpang=tmp_rang+[0:10:90];
    tmprad=radon(tmpim',tmpang);
    tmpvar=var(tmprad,[],1);
    lsnr(mm)=(tmpvar(1)-tmpvar(end))/mean(tmpvar);
    
    % estimate flux
    tmpim_r=imrotate(tmpim,tmp_rang,'bicubic','crop');
    tmpim_rr=sum(tmpim_r')./sum(tmpim_r'~=0);
    tmpim_rr=(tmpim_rr-min(tmpim_rr))/(max(tmpim_rr)-min(tmpim_rr));
    tmpfluxi=getTrigLoc(tmpim_rr(:).^2,2,1,fluxthr);
    lflux(mm)=length(tmpfluxi);
          
  else,
    % non-iterative angle search
    tmpang=rang;
    tmprad=radon(tmpim',rang);
    if do_radc,
      tmprefim=ones(size(tmpim));
      tmpradc=tmprad;
      tmpradref=radon(tmprefim',rang);
      for nn=1:length(rang),
        tmpp=polyfit(tmpradref(:,nn),tmprad(:,nn),1);
        tmpradc(:,nn)=tmprad(:,nn)-polyval(tmpp,tmpradref(:,nn));
      end;
      tmpvar=var(tmpradc,[],1);
    else,
      tmpvar=var(tmprad,[],1);
    end;
    [tmpmax,tmpmaxi]=max(tmpvar);
    [tmpmin,tmpmini]=min(tmpvar);
    tmpang2=rang(tmpmaxi)+[[-rfine(1):rfine(2):0-10*eps] [0:rfine(2):rfine(1)]];
    tmprad2=radon(tmpim',tmpang2);
    if do_radc,
      tmprad2c=tmprad2;
      tmprad2ref=radon(tmprefim',tmpang2);
      for nn=1:length(tmpang2),
        tmpp=polyfit(tmprad2ref(:,nn),tmprad2(:,nn),1);
        tmprad2c(:,nn)=tmprad2(:,nn)-polyval(tmpp,tmprad2ref(:,nn));
      end;
      tmpvar2=var(tmprad2c,[],1);
    else,
      tmpvar2=var(tmprad2,[],1);
    end;
    [tmpmax2,tmpmax2i]=max(tmpvar2);
    tmppmax=polyfit(tmpang2,tmpvar2,2);

    tmpang2min=rang(tmpmini)+[[-rfine(1):rfine(2):0-10*eps] [0:rfine(2):rfine(1)]];
    tmprad2min=radon(tmpim',tmpang2min);
    if do_radc,
      tmprad2minc=tmprad2min;
      tmprad2minref=radon(tmprefim',tmpang2min);
      for nn=1:length(tmpang2min),
        tmpp=polyfit(tmprad2minref(:,nn),tmprad2min(:,nn),1);
        tmprad2minc(:,nn)=tmprad2min(:,nn)-polyval(tmpp,tmprad2minref(:,nn));
      end;
      tmpvar2min=var(tmprad2minc,[],1);
    else,   
      tmpvar2min=var(tmprad2min,[],1);
    end;
    [tmpmin2,tmpmin2i]=min(tmpvar2min);
    tmppmin=polyfit(tmpang2min,tmpvar2min,2);
    
    lang(mm,:)=[rang(tmpmaxi) tmpang2(tmpmax2i) -tmppmax(2)/(2*tmppmax(1)) rang(tmpmini) tmpang2min(tmpmin2i) -tmppmin(2)/(2*tmppmin(1))];
    lsnr(mm,:)=[(tmpmax2-tmpmin2)/mean(tmpvar) tmpmax2 tmpmin2];
    disp(sprintf('  #%d: %.2f %.3f',mm,lang(mm,1),lsnr(mm)));

    % estimate flux
    tmpim_r=imrotate(tmpim,lang(mm,1),'bicubic','crop');
    tmpim_rr=sum(tmpim_r')./sum(tmpim_r'~=0);
    tmpim_rr=(tmpim_rr-min(tmpim_rr))/(max(tmpim_rr)-min(tmpim_rr));
    tmpproj=tmprad(:,tmpmaxi);
    tmpproj=(tmpproj-min(tmpproj))/(max(tmpproj)-min(tmpproj));
    tmpfluxi=getTrigLoc(tmpim_rr(:).^2,2,1,fluxthr);
    lflux(mm)=length(tmpfluxi);
  end;

  if do_figure,
    figure(1), clf,
    subplot(241), show(tmpim), xlabel('Image Segment'), axis('tight'), grid('on'),
    subplot(245), show(tmpim_r), xlabel('Rotated Segment'), axis('tight'), grid('on'),
    subplot(242), plot(lang(:,1)), ylabel('Angle (deg)'), xlabel('Seg#'), axis('tight'), grid('on'),
    subplot(246), plot(lsnr(:,1)), ylabel('SNR ratio'), xlabel('Seg#'), axis('tight'), grid('on'),
    subplot(243), plot(tmpang,tmprad), ylabel('Radon'), xlabel('Angle'), axis('tight'), grid('on'),
    subplot(247), plot(tmpang,tmpvar), ylabel('Var'), xlabel('Angle'),
    subplot(244), plot(tmpim_rr(:)), axis('tight'), grid('on'),
    %subplot(248), plot(tmpproj(:)), axis('tight'), grid('on'),
    drawnow, pause,
  end;

end;

ltt=[1:size(lang,1)]*dx_dt(2)*nskp;
lvel=dxdt*cot(lang*pi/180);
if do_snr,
  lvel2=lvel;
  lflux2=lflux;
  noii=find(lsnr(:,1)<snrthr);
  if ~isempty(noii),
    lvel(noii,:)=NaN;
    lflux2(noii,:)=NaN;
  end;
end;

y.lineParms=lineParms;
y.dx_dt=dx_dt;
y.supParms=supParms;
y.ltt=ltt;
y.lang=lang;
y.lvel=lvel;
y.lsnr=lsnr;
y.lflux=lflux;
if do_snr,
  y.noii=no_ii;
  y.lvels=lvel2;
  y.lfluxs=lflux2;
end;


if nargout==0,
  subplot(411), plot(ltt,lang)
  subplot(412), plot(ltt,lvel)
  subplot(413), plot(ltt,lflux)
  subplot(414), plot(ltt,lsnr)
end;

