
% test of methods to measure slope of lines in an image
% 1. SVD
% 2. Proj STDEV
% 3. Proj FT
% 4. Radon transform

rmin=0;
rmax=-12;
dr=-0.1;

l1=[1 40];
l2=[1 40];
l3=[1 160];

lnskp=10;

rang=[rmin:dr:rmax];
dxdt=dxy(2)/dt;

% get line mean to correct for systematic variations along line
avgline=mean(lineim(l3(1):l3(2),l1(1):l1(2)),1);
ldim=size(lineim);

% get data and analyse it
for nn=1:floor(ldim(1)/lnskp - (l1(2)-l1(1)+1)/lnskp),
  % get piece of image
  tmpl1=lnskp*(nn-1)+l1;
  tmpim1=lineimwn(tmpl1(1):tmpl1(2),l2(1):l2(2));

  % correct for variation along line
  tmpim1lc=tmpim1-ones(size(tmpim1,1),1)*avgline+mean(avgline);

  % normalize image
  tmpim1n=tmpim1lc-min(min(tmpim1lc));
  tmpim1n=tmpim1n/max(max(tmpim1n));
  tmpim1n=tmpim1n-mean(mean(tmpim1n));

  % find angle by rotation
  for mm=1:length(rang),
    rw=floor(size(tmpim1n)*0.7);
    aloc=floor(size(tmpim1n)/2)+1;
    dx=[0.2 0.2];
    tmpim=getRectImGrid(tmpim1n,rw,dx,aloc,rang(mm))';
    tmpimf=fft2(tmpim);
    [tmpa,tmpb,tmpc]=svd(tmpim);
    tmpbtr(mm)=trace(tmpb);
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
end;

clf,
plot(rang,tmpbrat/max(tmpbrat),rang,tmpstd/max(tmpstd),rang,tmpfrsum/max(tmpfrsum),rang,tmprad1/max(tmprad1))
legend('1: SVD','2: RotVar','3: FT Rot','4: Radon',2),


[vel*ones(length(vel_brat1),1) vel_brat1(:) vel_std1(:) vel_frsum1(:) vel_rad1(:)],
[mean(ans);std(ans)],



