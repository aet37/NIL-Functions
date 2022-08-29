function [f,vid,pdf_x]=vel_dist2(uitems,pdfitems,tvratio,t_parms,v_parms,type,voxeldim,seed1)
% Usage ... [f,id]=vel_dist2(uitems,pdfitems,tvratio,t_parms,v_parms,type,voxeldim,seed)

% tissue parameters [tau1]
% vascular parameters [mean spread]
% Type definitions: [tisue vascular]
% 1- Fast Exponential (diffusion)
% 1- Plugged flow (Gaussian), 2- Laminar flow (Linear)
% ---
% Voxel dimesions: [x(cm) y(cm) z(cm)]

if nargin<8, type=[1 1]; end;
if nargin<9, seed1=sum(clock); end;
rand('seed',seed1);

u=rand([uitems 1]);

% pdf_x is the "velocity" axis
pdf_x(:,1)=[0:1/(pdfitems-1):1]';

% pdf definition goes here (usually split into tissue pdf and vascular pdf...
% there are two possibilities which can be tested for the vascular pdf:
%  laminar and plugged flow...
% Laminar flow is relatively easy to describe #spins=2*pi*velocity;
% Plugged flow is modeled Gaussian for lack of a better method
% Tissue pdf is model as fast exponential decay for lack of a better method

if type(1)==2,
  % No other ideas here!
else,
  %pdf_t=exp(-pdf_x(:,1)/tau1);
  % note that the velocity here is normalized
  for m=1:length(x),
    pdf_t(m)=diff1(tau1,pdf_x(m,1)*vmax*tau1,diff_coef,x_area,c_0,t_tol)/tau1;
  end;
  pdf_t=pdf_t(:);
end;

% the direction of the velocity depends on the orientation of the vessel
% unless the velocity is less than diff_vmax which then indicates the spin
% is "freely" diffusing (although below a uniform distribution of velocity
% directions is assumed because of bends in the vasculature)
% to focus directionality, a random number is selected for the amount of
% spins in the vessel (related to vessel size)

voxeldim=voxeldim*1e-2;		% originally given in cm, cm3...
vol=prod(voxeldim);
vid=zeros([uitems 1]);

if type(2)==2,

  disp('Using discrete directional flow...');
  % v = cap=0.05-1.00cm/s, artl=3.00-10.00cm/s, venl=0.50-5.00cm/s
  % d = cap=8um, art=4mm, artl=30um, venl=20um, ven=5mm
  vmax=10e-2;
  vasc_avg_len=vol^(1/3);
  vasc_mindiam=v_parms(1);
  vasc_maxdiam=v_parms(2);
  vasc_dtau=v_parms(3);
  vasc_diam=vasc_mindiam+(vasc_maxdiam-vasc_mindiam)*exp_dist(uitems,vasc_dtau);
  vasc_vol=pi*(vasc_diam.*vasc_diam)*vasc_avg_len/4;
  vasc_nspins=round(uitems*vasc_vol./vol);
  found=0;
  for m=1:uitems,
    running_vol=sum(vasc_vol(1:m))/vol;
    if (running_vol>(1-tvratio))&(~found),
      found=m;
      break;
    end;
  end;
  if ~found,
    disp('Warning: No vessels found...'); 
  end;
  nvessels=found;
  vasc_diam=vasc_diam(1:nvessels);
  vasc_vol=vasc_vol(1:nvessels);
  vasc_nspins=vasc_nspins(1:nvessels);
  vasc_spins=sum(vasc_nspins);
  vasc_nspins(nvessels)=vasc_nspins(nvessels)-(vasc_spins-round(uitems*(1-tvratio)));
  % not so easy here because vascular diameter is correlated to flow vel
  % a linear relationship is assumed with a uniform range for the peak
  % velocity to allow for arterial or venous flow
  idstart=1;
  for m=1:nvessels,
    %tmpslope=-2*pi;
    %tmpyint=2*pi;
    tmp00=floor(uitems^(1/3));	% avg spins/length???
    tmp01=voxeldim./tmp00;
    tmp02=sqrt(sum(tmp01(1:2).^2));	% avg radius???
    tmp03=floor(pi*vasc_diam(m)/tmp02)*tmp00;
    tmpslope=(tmp00-tmp03)/(1-0);
    tmpyint=tmp03;
    art_ven=rand(1);
    if art_ven<0.5,
      vfrac=(22.67*vasc_diam(m)+0.00932)/vmax;
    else,
      vfrac=(9.799*vasc_diam(m)+0.00080402)/vmax;
    end;
    vessel_vmax(m)=vfrac*vmax;
    tmp1=u(idstart:idstart+vasc_nspins(m)-1);
    tmp2=vfrac*lin_dist(tmp1,tmpslope,tmpyint);
    %keyboard,
    f(idstart:idstart+vasc_nspins(m)-1)=tmp2;
    vid(idstart:idstart+vasc_nspins(m)-1)=m*ones(size([idstart:idstart+vasc_nspins(m)-1]))';
    idstart=idstart+vasc_nspins(m);
  end;
  vessel_vmax,
  pdf_t=pdf_t./trapz(pdf_x(:,1),pdf_t);
  f(idstart:uitems)=ran_dist([pdf_x(:) pdf_t(:)],u(idstart:uitems)); 

else,

  vmax=10e-2;
  if type(2)==2,
    % done above, no other ideas here!
  else,
    pdf_v=exp(-((pdf_x(:,1)-v_parms(1))/v_parms(2)).^2);
  end;

  area_t=trapz(pdf_x(:,1),pdf_t);
  area_v=trapz(pdf_x(:,1),pdf_v);
  pdf_t=(tvratio/area_t)*(area_t+area_v)*pdf_t;
  pdf_v=((1-tvratio)/(area_v))*(area_t+area_v)*pdf_v;
  pdf_x(:,2)=pdf_t+pdf_v;
  pdf_x(:,2)=pdf_x(:,2)/trapz(pdf_x(:,1),pdf_x(:,2));

  f=ran_dist(pdf_x,u);

end;

f=(vmax*1e2)*f(:);
