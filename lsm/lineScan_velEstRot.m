function f=lineScan_velEstRot(data,vparms,rparms,rtype)
% Usage ... y=lineScan_velEstRot(data,vparms,rparms,rtype)
%
% vparms=[nlns nskp smw]
% rparms=[l1 l2 rmin rmax dr rlook]

% vparms=[200 100 0];
% rparms=[20 60 0 30 0.2 1.25];

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
disp(sprintf('  l1=%d, l2=%d, rmin=%.1f, rmax=%.1f, dr=%.2f, rlook=%.2f',l1,l2,rmin,rmax,dr,rlook));

if (rtype==1),
  for nn=1:floor(totlns/nskp)-floor(nlns/nskp),
    %disp(sprintf('  %d to %d',(nn-1)*nskp+1,(nn-1)*nskp+nlns));
    tmpli=[(nn-1)*nskp+1:(nn-1)*nskp+nlns];
    lni(nn)=mean(tmpli);
    tmp0=data(tmpli,l1:l2);
    tmpmax=10*sum(sum(tmp0));
    for mm=1:length(rang),
      tmpval(mm,:)=fstripeImRotSum(rang(mm),tmp0);
    end;
    tmpmax1i=find(tmpval(:,1)==max(tmpval(:,1)));
    tmpmax2i=find(tmpval(:,2)==max(tmpval(:,2)));
    rang1i=find(abs(rang-rang(tmpmax1i))<=rlook);
    rang2i=find(abs(rang-rang(tmpmax2i))<=rlook);
    % % should be a gaussian fit
    %tmpfit1=polyfit(rang(rang1i),tmpval(rang1i,1),2);
    %tmpfit2=polyfit(rang(rang2i),tmpval(rang2i,2),2);
    %tmpval1=polyval(tmpfit1,rang(rang1i));
    %tmpval2=polyval(tmpfit2,rang(rang2i));
    %subplot(211)
    %plot(rang,tmpval)
    %subplot(212)
    %plot(rang(rang1i),tmpval(rang1i,1),rang(rang2i),tmpval(rang2i,2),rang(rang1i),tmpval1,rang(rang2i),tmpval2)
    %[rang1,ree,rex]=fminbnd(@fstripeImRotSum,-rmax,0,opt1,tmp0,[2*sum(sum(tmp0)) 1]);
    [rang1,ree,rex]=fminbnd(@fstripeImRotSum,rang(tmpmax1i)-rlook,rang(tmpmax1i)+rlook,opt1,tmp0,[tmpmax 1]);
    yy(nn)=rang1;
    smax(nn,:)=[tmpmax ree];
    seedi(nn,:)=[tmpmax1i tmpmax2i];
    [tmp9,tmp0frot,tmp0f]=fstripeImRotSum(rang1,tmp0);
    tmp0rot=imrotate(tmp0,rang1,'bilinear','crop');
    nstripes(nn,1)=fstripeImCnt(tmp0);
    nstripes(nn,2)=fstripeImCnt(tmp0rot);
  end;
  f.rang=yy;
  f.slope=1./tan(yy*pi/180);
  f.rang_range=rang;
  f.maxi=seedi;
  f.maxsval=smax;
  f.nstripes=nstripes;
  f.vparms=vparms;
  f.rparms=rparms;
  f.sampleIm=tmp0;
  f.sampleImRot=tmp0rot;
  f.samplefIm=tmp0f;
  f.samplefImRot=fftshift(tmp0frot);
else,
  for nn=1:floor(totlns/nskp)-floor(nlns/nskp),
    %disp(sprintf('  %d to %d',(nn-1)*nskp+1,(nn-1)*nskp+nlns));
    tmpli=[(nn-1)*nskp+1:(nn-1)*nskp+nlns];
    lni(nn)=mean(tmpli);
    tmp0=data(tmpli,l1:l2);
    [rang,ree,rex]=fminbnd(@fstripeImRotSum,rmin,rmax,opt1,tmp0,[2*sum(sum(tmp0)) 1]);
    if nn>1, if abs(rang-yy(nn-1))>dr,
      rang1=fminbnd(@fstripeImRotSum,yy(nn-1)-rlook,yy(nn-1)+rlook,opt1,tmp0,[2*sum(sum(tmp0)) 1]);
      %disp(sprintf('  %.2f %.2f',rang,rang1));
      yy_alt(nn)=rang1;
    end;  end;
    yy(nn)=rang;
    tmp0rot=imrotate(tmp0,rang1,'bilinear','crop');
    nstripes(nn,1)=fstripeImCnt(tmp0);
    nstripes(nn,2)=fstripeImCnt(tmp0rot);
  end;
  f.rang=yy;
  f.slope=1./tan(yy*pi/180);
  f.rang_alt=yy_alt;
  f.nstripes=nstripes;
  f.vparms=vparms;
  f.rparms=rparms;
end;



function [yout,rfim,fim]=fstripeImRotSum(rang,im,maxval)
if nargin<3, maxval=sum(sum(im)); end;
fim=fftshift(abs(fft2(im-mean(mean(im)))));
rfim=fftshift(imrotate(fim,rang,'bilinear','crop'));
rfimsum=sum(rfim);
yout=[rfimsum(1) rfimsum(2)];
if nargin==3,
  yout2=maxval(1)-yout(maxval(2));
  %disp(sprintf('  %.2f (%e), %f %f',rang,yout2,yout(1),yout(2)));
  yout=yout2;
end;
return;


function [yout]=fstripeImCnt(im)
fim=fft(im,[],1);
fimavg=mean(abs(fim),2);
yout=find(fimavg(1:floor(end/2))==max(fimavg(1:floor(end/2))));
return;

