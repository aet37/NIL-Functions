
% 2. Proj STDEV
% 3. Proj FT
% 4. Radon transform

rmin=0;
rmax=-20;
dr=-0.1;
sang=[-60:10:60];
dthr=0.5;

l1=[1 80];
l2=[1 60];
l3=[1 240];

lnskp=20;

lnim=lineimwn;
rang=[rmin:dr:rmax];
dxdt=dxy(2)/dt;


% get line mean to correct for systematic variations along line
avgline=mean(lnim(l3(1):l3(2),l2(1):l2(2)),1);
ldim=size(lnim);

% get data and analyse it
for nn=1:1,
  % get piece of image
  tmpl1=lnskp*(nn-1)+l1;
  tmpim1=lnim(tmpl1(1):tmpl1(2),l2(1):l2(2));

  % correct for variation along line
  tmpim1lc=tmpim1-ones(size(tmpim1,1),1)*avgline+mean(avgline);

  % normalize image
  tmpim1n=tmpim1lc-min(min(tmpim1lc));
  tmpim1n=tmpim1n/max(max(tmpim1n));
  tmpim1n=tmpim1n-mean(mean(tmpim1n));

  % find angle by rotation
  rw=floor(size(tmpim1n)*0.5);
  aloc=floor(size(tmpim1n)/2)+1;
  dx=[0.25 0.25];
  for mm=1:length(rang),
    tmpim=getRectImGrid(tmpim1n,rw,dx,aloc,rang(mm))';
    tmpimf=fft2(tmpim);
    [tmpa,tmpb,tmpc]=svd(tmpim);
    tmpbtr(mm)=sum(diag(tmpb));
    tmpbmax(mm)=max(diag(tmpb));
    tmpbrat(mm)=tmpbmax(mm)/tmpbtr(mm);
    tmpproj=mean(tmpim,2);
    tmpstd(mm)=var(tmpproj);
    tmpfsum=sum(abs(tmpimf.*tmpimf),1);
    tmpfrsum(mm)=tmpfsum(1);
    tmplrad(:,mm)=radon(tmpim',0)';
    tmplrad1(mm)=var(tmplrad(:,mm));
  end;
  tmprad=radon(tmpim1n',rang);
  tmprad1=var(tmprad,[],1);
  
  [tmpbrat_max,tmpbrat_maxi]=max(tmpbrat/max(tmpbrat));
  [tmpstd_max,tmpstd_maxi]=max(tmpstd/max(tmpstd));
  [tmpfrsum_max,tmpfrsum_maxi]=max(tmpfrsum/max(tmpfrsum));
  [tmprad1_max,tmprad1_maxi]=max(tmpfrsum/max(tmpfrsum));

  tmpi=find((tmpbrat/max(tmpbrat))>0.9); tmpp=polyfit(rang(tmpi),tmpbrat(tmpi)/max(tmpbrat),2); 
  vel_brat2(nn)=dxdt*cot(-tmpp(2)/(2*tmpp(1)));
  
  vel_brat1(nn)=dxdt*cot(rang(tmpbrat_maxi)*pi/180);
  vel_std1(nn)=dxdt*cot(rang(tmpstd_maxi)*pi/180);
  vel_frsum1(nn)=dxdt*cot(rang(tmpfrsum_maxi)*pi/180);
  vel_rad1(nn)=dxdt*cot(rang(tmprad1_maxi)*pi/180);
  
  % calculate SNR
  tmpsang=sang+rang(tmpbrat_maxi);
  for mm=1:length(sang),
    tmpim=getRectImGrid(tmpim1n,rw,dx,aloc,tmpsang(mm))';
    tmpsrad(:,mm)=radon(tmpim',0)';
    tmpsrad1(mm)=var(tmpsrad(:,mm));
  end;
  snr_rad1(nn)=tmpsrad1(7)/mean(tmpsrad1([[1:6] [8:13]]));
  
  % calculate nlines
  tmpim=getRectImGrid(tmpim1n,rw,dx,aloc,rang(tmprad1_maxi))';
  tmpsavg=mean(tmpim');
  tmpsdif=diff(tmpsavg);
  tmpsdifi=find(tmpsdif>dthr*max(tmpsdif));
  tmpsdifa=mean(tmpsdif(tmpsdifi));
  tmpsdifi=find(tmpsdif>dthr*tmpsdifa);
  tmpsdifid=diff(tmpsdifi);
  nln(nn)=length(find(tmpsdifid>1))+(tmpsdifid(1)==1);
  
  %tmpfn=mean(abs(fft(tmpim1n').^2));
  %[tmptmp,tmpfni]=max(tmpfn(1:end/2));
  %tmpn(nn)=tmpfni;
  %keyboard,
end;

clf,
plot(rang,tmpbrat/max(tmpbrat),rang,tmpstd/max(tmpstd),rang,tmpfrsum/max(tmpfrsum),rang,tmprad1/max(tmprad1))
legend('1: SVD','2: RotVar','3: FT Rot','4: Radon',2),


[vel(1)*ones(length(vel_brat1),1) vel_brat1(:) vel_std1(:) vel_frsum1(:) vel_rad1(:)],
[mean(ans);std(ans)],



