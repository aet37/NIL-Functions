
clear all

do_object=1;
do_data=0;

% variable defn
fov=[8 8];          % mm
dim=[1024 1024];    % pixels
fermd=150;          % pixels
fermw=20;           % pix
exp_dur=80;         % s
exp_per=10;         % s
dt=0.1;             % s
dxy=fov./dim;       % mm
nstims=floor(exp_dur/exp_per);

% pinwheel location
pw_locs=[200 200 1  0;
         500 200 -1 +0.5;
         800 200 1  0;
         200 500 -1 +0.5;
         500 500 1  0;
         800 500 -1 +0.5;
         200 800 1  0;
         500 800 -1 +0.5;
         800 800 1  0];
nlocs=size(pw_locs,1);

% make object
if (do_object),
aim=zeros(dim(1),dim(2));
dir_flag=1;
for oo=1:nlocs,  
for mm=1:size(aim,1), for nn=1:size(aim,2),
  tmpang=atan2(mm-pw_locs(oo,1),nn-pw_locs(oo,2));
  tmpdist=sqrt((mm-pw_locs(oo,1))^2+(nn-pw_locs(oo,2))^2);
  tmpfmag=1./(1+exp((tmpdist-fermd)/fermw));
  aim(mm,nn)=aim(mm,nn)+tmpfmag*exp(j*tmpang*pw_locs(oo,3)+pw_locs(oo,4)*pi);
end; end;
end;

figure(1)
show(abs(aim))
figure(2)
show(angle(aim))
colormap jet

end;

% make noise structure

% make data and noise
if (do_data),
t=[0:dt:exp_dur];
tlen=length(t);
hrf=((t/2.5).^1).*exp(-t/2);
for mm=1:size(aim,1), for nn=1:size(aim,2),
  tmpamp=abs(aim(mm,nn));
  tmpang=angle(aim(mm,nn));
  tmpang=tmpang+(tmpang<0)*2*pi;
  tmpdel=floor((tmpang/(2*pi))*exp_per/dt)+1;
  t0i=[0:nstims-1]*floor(exp_per/dt)+tmpdel;
  stims=zeros(size(t)); stims(t0i)=1;
  tmpy=conv(stims,hrf);
  yy=tmpamp*tmpy(1:tlen);
  keyboard,
  %ois(mm,nn,:)=yy;
end; end;
end;

