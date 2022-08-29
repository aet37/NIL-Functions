
clear all

do_movie=1;

% variables (actual dim)
vel=0.41;		% units: mm/s
namp=0.1;
nlam=1.00;
nfr=2560;
dt=0.010;		% units: s
dxy=[0.46 0.46]*1e-3;	% units: mm
hct=0.33;

% variables (pix dim)
vwid=12;		% cell width (pix)
vtopl=12;		% vessel top (pix)
per=[3 5];
ddim=[40 64 nfr];

Lx=ddim(2)*dxy(1);		% length of frame in mm
dpx=vel*dt/dxy(1);		% pix per frame
pxx=ceil(dpx*nfr+20*ddim(2));	% total pix for sim
xx=[1:pxx]*dxy(1);		% x_scale in mm
npart=round(hct*pxx/vwid);

% initial location in pixels
%xloc0=0.5*(rand(npart,1)-0.5)*(pxx/npart)+[1:npart]'*(pxx/npart);
xloc0=sort(rand(npart,1)*pxx);


gmy=vtopl+vwid/2;
gss=per*0.67;


eii=[17 50];
er=per;
eang=0;
%tmpim1p=ellipse(zeros(ddim(1:2)),eii(1),eii(2),er(1),er(2),eang,1);


data=zeros(ddim);
datawn=zeros(ddim);

tt=[1:nfr]*dt;
vel=vel*ones(size(tt(:)));
%vel=vel+(0.1*vel(1))*gammafun2(tt,[6:100]/5,0.2*.05,0.2,1);  % heart blips
vel=vel+vel(1)*0.4*gammafun2(tt,4,8*0.05,8,1);      % functional bump

ww=2*gauss_window(ddim(1),vtopl+vwid/2,0.25*vwid,1); ww(find(ww>1))=1;
vesim=rect2d(vwid,ddim(2),vtopl,1,ddim(1),ddim(2)).*(ww(:)*ones(1,ddim(2)));
for mm=1:ddim(3),
  if mm==1,
    tmpx=xloc0-vel(mm)*dt*(mm-1)/dxy(1);	% pix displacement
  else,
    dx(mm-1)=vel(mm)*dt/dxy(1);
    tmpx=tmpx-vel(mm)*dt/dxy(1);	% pix displacement
  end;
  tmpxi=find((tmpx>-1.5*dpx)&(tmpx<(ddim(2)+1.5*dpx)));
  tmpim1=zeros(size(vesim));
  if ~isempty(tmpxi),
    disp(sprintf('  frm# %d/%d,  particles_in_frm= %d',mm,nfr,length(tmpxi)));
    for nn=1:length(tmpxi),
      tmppx=tmpx(tmpxi(nn));
      tmppy=gmy;
      tmpim1p=2*gauss_window(ddim(1:2),[tmppy tmppx],gss,1); 
      tmpim1p(find(tmpim1p>1))=1;
      tmpim1=tmpim1+tmpim1p;
    end;  
    tmpim1(find(tmpim1>1))=1;
    tmpim1(find(tmpim1<1e-10))=0;
  else,
    disp(sprintf('  frm# %d/%d,  particles_in_frm= %d',mm,nfr,0));
  end;
  %show(tmpim1), pause,
  tmpim2=namp*randn(size(vesim));
  tmpim3=vesim-tmpim1;
  tmpim3(find(tmpim3>1))=1;
  tmpim3(find(tmpim3<1e-10))=0;
  tmpim3n=nlam*exp(-nlam*(tmpim3+abs(tmpim2)));
  if nlam==0, tmpim3n=abs(tmpim2); end;
  data(:,:,mm)=tmpim3;
  datawn(:,:,mm)=tmpim3+tmpim3n;
  %keyboard,
end;

lineim=squeeze(data(round(vtopl+vwid/2),:,:))';
lineimwn=squeeze(datawn(round(vtopl+vwid/2),:,:))';

if do_movie,
for mm=1:120,
  subplot(211)
  show(data(:,:,mm)),
  subplot(212)
  show(datawn(:,:,mm)),
  drawnow;
  pause(0.01);
end;
end;

subplot(121)
show(lineim)
subplot(122)
show(lineimwn)

clear tmp*

