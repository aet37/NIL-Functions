
clear all

% dimensions
rr=[-60e-6:2e-6:60e-6];

% sphere properties
sph_rad=5e-6;
dchi=18e-7;
sph_volf=0.1;
B0mag=3.0*1e4;
B0vec=[0 0 1]*B0mag;
TE=20e-3;
h_gam=26752;

% internal computations
npts_dim=length(rr);
npts_tot=npts_dim^3,
cubevol=((rr(2)-rr(1))*length(rr)).^3;
sph_vol=(4/3)*pi*sph_rad^3;
nsph=floor(cubevol*sph_volf/sph_vol),

% distribute spheres and check locations?
sph_locs=(rand([nsph 3])-0.5)*rr(end);

% calculate the field at each spin location from the
% conglomerate of spheres
dB=zeros(npts_dim,npts_dim,npts_dim);
for mm=1:npts_dim, fprintf('\r%d/%d',mm,npts_dim); for nn=1:npts_dim, for oo=1:npts_dim,
  for pp=1:nsph,
    pt_locvec=[rr(mm) rr(nn) rr(oo)];
    sph_locvec=sph_locs(pp,:);
    rr_vec=pt_locvec-sph_locvec;
    dB(mm,nn,oo)=dB(mm,nn,oo)+(b_sphere(rr_vec,B0vec,sph_rad,1+dchi,1)-B0mag);
  end;
end; end; end;

% calculate signal dephasing
dphi=h_gam*dB*TE;
dB_avg=sum(sum(sum(dB)))/npts_tot;
ss=sum(sum(sum(exp(-i*dphi))))/npts_tot,

