function [vel,rnln,rsnr]=lineScan_velEstRot3(lineim,lparms,sparms,dx_dt,rtype,rmin,rmax,idxy)
% Usage ... [vel,nln,snr]=lineScan_velEstRot3(lineim,lparms,snrparms,dx_dt,rtype,rmin,rmax,idxy)
%
% lparms=[#rows #rowskip #row_for_linenorm col1_to_col2 smw]
% snrparms=[Nsnr=12 SNRthr=3 fdiff=0.5 widN=1]
% dx_dt=[pixsize_in_mm linetime_in_sec];
% rtype=[default:4-Radon]

% test of methods to measure slope of lines in an image
% 1. SVD (square matrix is prefered)
% 2. Proj STDEV
% 3. Proj FT
% 4. Radon transform

% regression of signal over time -- pick the how many lines needed
% due to respiration
% correction along the image with the average image

do_finetune=1;
do_regress=0;
do_hcf=1;

if (nargin<8),
  idxy=[0.25 0.25];
end;
if (nargin<6),
  rmin=-90;
  rmax=+90;
end;
if (nargin<5),
  rtype=4;
end;


opt1=optimset('fminbnd');
opt1.TolX=1e-12;


l1=[1 lparms(1)];
l2=[lparms(4) lparms(5)];
l3=[1 lparms(3)];
lnskp=lparms(2);

dxdt=dx_dt(1)/dx_dt(2);

if length(lparms)==6,
  smw=lparms(6);
else,
  smw=0;
end;
if smw==0, do_smooth=0; else, do_smooth=1; end;

if isempty(sparms),
  do_snr=0;
else,
  do_snr=1;
  Nsnr=sparms(1);
  Nsnrthr=sparms(2);
  fdiff=sparms(3);
  widN=sparms(4);
end;

% get line mean to correct for systematic variations along line
if do_smooth,
  avgline1=mean(im_smooth(lineim(l3(1):l3(2),l2(1):l2(2)),smw),1);
else,
  avgline1=mean(lineim(l3(1):l3(2),l2(1):l2(2)),1);
end;
ldim=size(lineim);

% regress time variability -- todo
if do_regress,
  tmpline=mean(lineim(:,l2(1):l2(2)),2);
  tmplinef=myfilter(tmpline,round(0.25*length(tmpline)));
  tmpliner=tmplinef*ones(1,size(lineim,2));
  lineim_orig=lineim;
  lineim=lineim-tmpliner+mean(tmpliner(:));
end;

% get data and analyze it
for nn=1:floor(ldim(1)/lnskp - (l1(2)-l1(1)+1)/lnskp),
  % get piece of image
  tmpl1=lnskp*(nn-1)+l1;
  disp(sprintf('  lines: [%d %d]  [%d %d]',tmpl1(1),tmpl1(2),l2(1),l2(2)));
  tmpim1=lineim(tmpl1(1):tmpl1(2),l2(1):l2(2));
  if do_hcf, tmpim1=homocorOIS(tmpim1); end;
  if do_smooth,
    tmpim1=im_smooth(tmpim1,smw);
  end;
  
  % correct for variation along line
  %avgline1=mean(tmpim1,1);  % need to make sure there are many lines here
  %tmpim1la=polyval(polyfit(avgline,mean(tmpim1,1),1),avgline);
  %tmpim1lc=tmpim1-ones(size(tmpim1,1),1)*avgline+mean(avgline);
  tmpim1la=polyval(polyfit([1:size(tmpim1,2)],mean(tmpim1,1),1),[1:size(tmpim1,2)]);
  tmpim1lc=tmpim1-ones(size(tmpim1,1),1)*tmpim1la+mean(tmpim1la);
  
  % normalize image
  tmpim1n=tmpim1lc-min(tmpim1lc(:));
  tmpim1n=tmpim1n/max(tmpim1n(:));
  tmpim1n=tmpim1n-mean(tmpim1n(:));
  
  % find angle by rotation
  [rang(nn),ree(nn),rex(nn)]=fminbnd(@imlineRotf,rmin,rmax,opt1,tmpim1n,rtype,idxy);

  % fine-tune
  if do_finetune,
    tmpang=[0:179];
    tmprad=radon(tmpim1n',[0:179]);
    tmpvar=var(tmprad,[],1);
    [tmpmax,tmpmaxi]=max(tmpvar);
    tmpang2=tmpang(tmpmaxi)+[[-5:0.01:-0.001] [0:.01:5]];
    tmprad2=radon(tmpim1n',tmpang2);
    tmpvar2=var(tmprad2,[],1);
    [tmpmax,tmpmaxi]=max(tmpvar2);
    rang2(nn)=tmpang2(tmpmaxi);
    if abs(rang(nn)-rang2(nn))>0.1,
      disp(sprintf('  replacing with fine-tune angle (%.4f to %.4f) ...',rang(nn),rang2(nn)));
      rang(nn)=tmpang2(tmpmaxi);
    end;
  end;

  % estimate signal-to-noise
  if do_snr,
    rerr1=imlineRotf(rang(nn),tmpim1n,rtype,idxy);
    tmprad=radon(tmpim1n);
    if rtype==4,
      tmpim1r=imrotate(tmpim1n,rang(nn),'bicubic','crop');
      avgtmpim1r=sum(tmpim1r')./sum(tmpim1r'~=0);
      %tmpim1r=rot2d_f(tmpim1n,-rang(nn));
      %avgtmpim1r=mean(tmpim1r');
    else,
      [tmptmp,tmpim1r]=imlineRotf(rang(nn),tmpim1n,1,idxy);
      avgtmpim1r=mean(tmpim1r');
    end;
    tmpang=([1:Nsnr]-Nsnr/2)*180*(pi/180);
    for oo=1:Nsnr,
      tmprerr(oo)=imlineRotf(tmpang(oo),tmpim1n,rtype,idxy);
    end;
    rsnr(nn)=rerr1/mean(tmprerr);

    % estimate number of lines
    avgtmpim1rn=avgtmpim1r-min(avgtmpim1r(:));
    avgtmpim1rn=avgtmpim1rn/max(avgtmpim1rn(:));
    avgtmpim1rn=1-avgtmpim1rn;
    tmpic=getTrigLoc(avgtmpim1rn(:),2,1,0.5);
    rnln(nn)=length(tmpic);
    %tmpd=diff(avgtmpim1r);
    %if fdiff>0,
    %  tmpdi=find(tmpd>fdiff*max(tmpd));
    %  tmpdii=mean(tmpd(tmpdi));
    %  tmpdi=find(tmpd>fdiff*tmpdii);
    %  tmpdii=diff(tmpdi);
    %  tmpdi2=find(tmpdi>1);
    %else,
    %  tmpdi=find(tmpd<fdiff*max(tmpd));
    %  tmpdii=mean(tmpd(tmpdi));
    %  tmpdi=find(tmpd<fdiff*tmpdii);
    %  tmpdii=diff(tmpdi);
    %  tmpdi2=find(tmpdi>1);
    %end;
    %if isempty(tmpdii), tmpdii=0; end;

    tmpsi1=find(avgtmpim1rn(:)>0.5);
    tmpsi2=find(avgtmpim1rn(:)<=0.5);
    %tmpim1lcr=rot2d_f(tmpim1lc,-rang(nn));
    %avgim1lcr=mean(tmpim1lcr');
    tmpim1lcr=imrotate(tmpim1lc,rang(nn),'bicubic','crop');
    avgim1lcr=sum(tmpim1lcr')./sum(tmpim1lcr'~=0);
    rsnr2(nn)=1-mean(avgim1lcr(tmpsi1))/mean(avgim1lcr(tmpsi2));
  end;
  
  % calculate velocity
  vel(nn)=dxdt*cot(rang(nn)*pi/180);
  disp(sprintf('    ang= %0.4f    vel= %.4f',rang(nn),vel(nn)));
  subplot(121), show(tmpim1n), drawnow, 
  subplot(222), plot(vel), drawnow,
  tmpradv=var(tmprad,[],1);
  subplot(224), plot(tmpradv/mean(tmpradv)), drawnow,
  %keyboard,
end;

%if do_snr,
%  tmpii_ll=find(rsnr2<0.2);
%  if ~isempty(tmpii_ll), rnln(tmpii_ll)=0; end;
%  tmpii_vv=find((rsnr2<0.2)&(rsnr<1));
%  if ~isempty(tmpii_vv), vv(tmpii_vv)=NaN; end;
%end;


if nargout==1,
  yy.rtype=rtype;
  yy.dx_dt=dx_dt;
  yy.rang=rang;
  yy.vel=vel;
  if do_snr,
    yy.flux=rnln;
    yy.snr=rsnr;
    yy.snr2=rsnr2;
  end;
  vel=yy;
end;

if nargout==0,
  figure,
  subplot(411)
  plot(vel)
  axis('tight'), grid('on'),
  subplot(412)
  plot(rnln)
  axis('tight'), grid('on'),
  subplot(413)
  plot(rsnr)
  axis('tight'), grid('on'),
  subplot(414)
  plot(rsnr2)
  axis('tight'), grid('on'),
end;

