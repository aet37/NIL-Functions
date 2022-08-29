function f=lineScan_velEstRot2(data,vparms,rparms,rtype)
% Usage ... y=lineScan_velEstRot2(data,vparms,rparms,rtype)
%
% vparms=[nlns nskp smw]
% rparms=[l1 l2 rmin rmax dr rlook]

% vparms=[200 100 0];
% rparms=[20 60 0 30 0.2 1.5];

if nargin<4, rtype=1; end;

opt1=optimset('fminbnd');
opt1.TolX=1e-12;

if length(vparms)<3, vparms(3)=0; end;

nlns=vparms(1);
nskp=vparms(2);
smw=vparms(3);

l1=rparms(1);
l2=rparms(2);
rmin=rparms(3);
rmax=rparms(4);
dr=rparms(5);
rlook=rparms(6);
rang=[rmin:dr:rmax]';

if (smw>0), data=im_smooth(data,smw); end;
totlns=size(data,1);
ncols=size(data,2);


% two options for rotation, fixed number of tries, find min
% or, search for min

disp(sprintf('  nlns=%d, nskp=%d, smw=%d',nlns,nskp,smw));
disp(sprintf('  l1=%d, l2=%d, rmin=%.1f, rmax=%.1f, dr=%.2f',l1,l2,rmin,rmax,dr));

if (rtype==1),
  for nn=1:floor(totlns/nskp)-floor(nlns/nskp),
    %disp(sprintf('  %d to %d',(nn-1)*nskp+1,(nn-1)*nskp+nlns));
    tmpli=[(nn-1)*nskp+1:(nn-1)*nskp+nlns];
    lni(nn)=mean(tmpli);
    tmp0=data(tmpli,l1:l2);
    for mm=1:length(rang),
      tmpval(mm)=stripeImSVDtrace(rang(mm),tmp0);
    end;
    tmpmin1i=find(tmpval==min(tmpval));
    rang1i=find(abs(rang-rang(tmpmin1i))<=rlook);
    % now that we are close, search for min
    [rang1,ree,rex]=fminbnd(@stripeImSVDtrace,rang(tmpmin1i)-rlook,rang(tmpmin1i)+rlook,opt1,tmp0);
    yy(nn)=rang1;
    frmin(nn)=[ree];
    seedi(nn)=[tmpmin1i];
    tmp0rot=getRectImGrid(tmp0,floor(size(tmp0)*.7),[0.2 0.2],floor(size(tmp0)/2),rang1);
    tmp0rot_alt=imrotate(tmp0,rang1,'bilinear','crop');
    tmp0rot_alt2=getRectImGrid(tmp0rot_alt,floor(size(tmp0rot_alt)*.7),[0.2 0.2],floor(size(tmp0rot_alt)/2),0);
    %[tmp9,tmp0frot,tmp0f]=fstripeImRotSum(rang1,tmp0);
    %nstripes(nn,1)=fstripeImCnt(tmp0);
    %stripes(nn,2)=fstripeImCnt(tmp0rot);
  end;
  f.rang=yy;
  f.slope=1./tan(yy*pi/180);
  f.rang_range=rang;
  f.mini=seedi;
  f.frmin=frmin;
  %f.nstripes=nstripes;
  f.vparms=vparms;
  f.rparms=rparms;
  f.sampleIm=tmp0;
  f.sampleImRot=tmp0rot;
else,
  for nn=1:floor(totlns/nskp)-floor(nlns/nskp),
    %disp(sprintf('  %d to %d',(nn-1)*nskp+1,(nn-1)*nskp+nlns));
    tmpli=[(nn-1)*nskp+1:(nn-1)*nskp+nlns];
    lni(nn)=mean(tmpli);
    tmp0=data(tmpli,l1:l2);
    [rang,ree,rex]=fminbnd(@stripeImSVDtrace,rmin,rmax,opt1,tmp0);
    if nn>1, if abs(rang-yy(nn-1))>dr,
      rang1=fminbnd(@fstripeImRotSum,yy(nn-1)-rlook,yy(nn-1)+rlook,opt1,tmp0,[2*sum(sum(tmp0)) 1]);
      %disp(sprintf('  %.2f %.2f',rang,rang1));
      yy_alt(nn)=rang1;
    end;  end;
    yy(nn)=rang;
    tmp0rot=imrotate(tmp0,rang,'bilinear','crop');
    %nstripes(nn,1)=fstripeImCnt(tmp0);
    %nstripes(nn,2)=fstripeImCnt(tmp0rot);
  end;
  f.rang=yy;
  f.slope=1./tan(yy*pi/180);
  f.rang_alt=yy_alt;
  %f.nstripes=nstripes;
  f.vparms=vparms;
  f.rparms=rparms;
end;



function [yout,rim,tmpa,tmpb,tmpc]=stripeImSVDtrace(rang,im)
szim=size(im);
if szim(1)>szim(2),
  rim=getRectImGrid(im,floor(size(im)*.7),[0.25 0.25/round(szim(1)/szim(2))],floor(size(im)/2),rang);
else,
  rim=getRectImGrid(im,floor(size(im)*.7),[0.25/round(szim(1)/szim(2)) 0.25],floor(size(im)/2),rang);
end;
szrim=size(rim);
if szim(1)~=szim(2),
  tmpim=rim; clear rim
  if szrim(1)>szrim(2),
    rim=tmpim(1:szrim(2),:);
  else,
    rim=tmpim(:,1:szrim(1),:);
  end;
  disp(sprintf('  warning: im not square (%dx%d), forcing (%dx%d -> %dx%d)...',szim(1),szim(2),szrim(1),szrim(2),size(rim,1),size(rim,2)));
end;
rim_alt=imrotate(im,rang,'bilinear','crop');
[tmpa,tmpb,tmpc]=svd(rim);
yout=trace(tmpb);
%[tmpa,tmpb,tmpc]=svd(rim_alt);
%yout=trace(tmpb);
keyboard,
return;


function [yout]=fstripeImCnt(im)
fim=fft(im,[],1);
fimavg=mean(abs(fim),2);
yout=find(fimavg(1:floor(end/2))==max(fimavg(1:floor(end/2))));
return;

