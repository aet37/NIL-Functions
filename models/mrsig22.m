
clear all

% MR Signal simulation consisting of a cube with randomly distributed spins
% and a cyclinder with random orientation through the origin containing 
% spherical perturbers with susceptibility difference dX0.

% Initial design parameters:
%  * exp_TE, n_jumps = echo time, number of random walk realizations
%  * b, r = blood volume fraction, vessel radius
%  * dX0 = susceptibility difference
%  * theta_x,y,z = vessel orientation

% Dependencies: cubelinesrfpts, rot, b_sphere, einsteinwalk 

% Questions: 
%  * Is there a regime where the concentration of the perturbers
%    approximates a magnetized cylinder?
%  * What is the diffusion effect like?
%  * Is there a diffusion barrier effect?
%  * Is there an effect from the perturbers moving?
%  * Is there a difference between plug and laminar flows?

% Select step size to match average distance xm = sqrt(6Dt) = xl sqrt(6n/4pi)

% Lets start with a single cubic compartment of dimensions xdim ydim zdim
% in units of m and volume Vcube, with n_spins inside it... inside the 
% cubic compartment there is a cylinder of radius a and length L located
% in the very center of the compartment... this way the inter-vessel spacing
% is simply the dimension of a cubic compartment... the fraction b where
% b = Vcyl / Vcube although this is not of much meaning since the radius
% also determines this (in fact in this work it does)... the vessel inside
% the cube is oriented in angle theta (x-y), phi (xy-z) and the direction
% of the main magnetic field B0 is psi (xy-z)...
% Note: verify the concentration of water in plasma, rbc, intracellular and
% extracellular...
% Note: there is a serious problem at and near the boundary! not to mention
% the deviations that assuming the perturbers are assumed to be well modeled
% by spheres!
% The boundary problem can be resolved by selecting a compartment that is
% slightly bigger in all direction by an amount os (perhaps 5*mean diffusion
% distance) and in the end discarding those outside the compartment and
% thus simulating the infinite compartment...


mcid=1;
mcsavedir='/tmp/';
verbose_flag=1;


xdim=5e-2*3e-3;
ydim=5e-2*3e-3;
zdim=5e-2*3e-3;
Vcube=xdim*ydim*zdim;

thetax=0;
thetay=0;
thetaz=0;

seed1=11;

b=0.02;
Hct=0.4;
T2val=200e-3;

spins_per_vol=(10/100e-6)^3;		% 10 spins per 100micron
n_spins=floor(spins_per_vol*Vcube);

spinecho_flag=0;

D=1e-9;					% diffcoeff of water = 1e-9m2/s
n_jumps=10;
total_experiment_time=10e-3;		% ms


if (verbose_flag),
  msg=sprintf('Cube dimensions= %f mm  %f mm  %f mm\n',xdim*1e3,ydim*1e3,zdim*1e3); 
  msg=sprintf('%sCube volume= %f mm3',msg,Vcube*1e9);
  disp(msg); 
end;


initialps=[-xdim/2 0 0;+xdim/2 0 0];
[p1,p2]=cubelinesurfpts([xdim ydim zdim],[thetax thetay thetaz],initialps);
L=sum((p1-p2).^2).^(1/2);
ve=(p2-p1)./L;
Vcyl=b*Vcube;
a=(Vcyl/(pi*L))^(1/2);

if (verbose_flag),
  msg=sprintf('Origin pivoted cylinder, length= %f mm\n',L);
  msg=sprintf('%s orientation= (%f,%f,%f)\n',msg,thetax*180/pi,thetay*180/pi,thetaz*180/pi);
  msg=sprintf('%s end-points= (%f,%f,%f),(%f,%f,%f)\n',msg,p1(1)*1e3,p1(2)*1e3,p1(3)*1e3,p2(1)*1e3,p2(2)*1e3,p2(3)*1e3);
  msg=sprintf('%s radius= %f mm\n',msg,a*1e3);
  msg=sprintf('%s volume= %f mm3\n',msg,Vcyl*1e9);
  msg=sprintf('%s length= %f mm\n',msg,L*1e3);
  msg=sprintf('%sFraction of spins inside cylinder b= %f',msg,b);
  disp(msg);
end;

% Lets generate the spin population and distribute them uniformly
% throughout the cubic compartment... lets also generate a perturber
% population which is comparable to the Hematocrit Hct and also
% distribute them uniformly in space throughout the cylinder...

s_space=zeros([n_spins 3]);

jump_t=total_experiment_time/n_jumps;
Dtau=jump_t;
mean_Diff_dist=sqrt(6*D*total_experiment_time);
jump_x=sqrt(4*pi*D*total_experiment_time/n_jumps);  % mean_Diff_dist/n_jumps;
as=1.0*((6*D*Dtau)^(1/2));

exp_TE=total_experiment_time;

rand('seed',seed1);
s_space=rand([n_spins 3]);
s_space(:,1)=xdim*s_space(:,1)-xdim/2;
s_space(:,2)=ydim*s_space(:,2)-ydim/2;
s_space(:,3)=zdim*s_space(:,3)-zdim/2;


rbcdim=[9e-6 4e-6 4e-6];
ap=prod(rbcdim).^(1/3);
Vp=(4/3)*pi*(ap^3);

n_perturbers=floor(Hct*Vcyl/Vp);
%n_perturbers=floor(n_spins*b*Hct);		% this may present some
p_space=rand([n_perturbers 3]);			% problems since there are
p_space(:,1)=L*p_space(:,1)-L/2;		% some volume considerations
p_space(:,2)=2*a*p_space(:,2)-a;		% here there may be some
p_space(:,3)=2*pi*p_space(:,3)-pi;		% coordinate system problems
for m=1:n_perturbers,
  tmpp=p1+ve*p_space(m,1);
  tmpe=[cos(p_space(m,3)) sin(p_space(m,3)) 1];
  tmpv=tmpe.*[p_space(m,2) p_space(m,2) p_space(m,1)];
  p_space(m,:)=rot(tmpv',[1 2 3],[thetax thetay thetaz])';
end;

p_deoxyratio=ones([n_perturbers 1]);

if (verbose_flag),
  msg=sprintf('#Spins= %d\n',n_spins);
  msg=sprintf('%s#Perturbers= %d\n',msg,n_perturbers);
  msg=sprintf('%s  radius= %f mm\n',msg,ap*1e3);
  msg=sprintf('%s  volume= %f mm3',msg,Vp*1e9);
  disp(msg);
end;

% Next step is to do some checking that no 2 spins can occupy a certain
% space marked by a sphere of radius as for each spin (approximated as
% factor off the mean difussion distance) or radius ap from
% a perturber (approximated as the mean dimension of an rbc)...

checkspinloc_flag=0;
if (checkspinloc_flag),
tmpdist=zeros([n_spins 1]);
for m=1:n_spins,
  for n=1:n_spins,
    tmpdist(n,:)=sum((s_space(m,:)-s_space(n,:)).^2).^(1/2);
  end;
  tmpbad=find(tmpdist<as);
  if (length(tmpbad)>1),
    for o=1:length(tmpbad),
      if (tmpbad(o)~=m),
        found=0;
        while(~found),
          tmpnew=rand([1 3]).*[xdim ydim zdim]-[xdim/2 ydim/2 zdim/2];
          tmpdist2=sum((s_space(m,:)-tmpnew).^2).^(1/2);
          if tmpdist2>as,
            s_space(tmpbad(o),:)=tmpnew;
            found=1;
            break;
          end;
        end;
      end;
    end; 
  end;
end;
end;

tmpdist=zeros([n_perturbers 1]);
for m=1:n_perturbers,
  for n=1:n_perturbers,
    tmpdist(n,:)=sum((p_space(m,:)-p_space(n,:)).^2).^(1/2);
  end;
  tmpbad=find(tmpdist<ap);
  if (length(tmpbad)>1),
    for o=1:length(tmpbad),
      if (tmpbad(o)~=m),
        found=0;
        while(~found),
          tmpnew=rand([1 3]).*[L 2*a 2*pi]-[L/2 a pi];
          tmpdist2=sum((s_space(m,:)-tmpnew).^2).^(1/2);
          if tmpdist2>ap,
            s_space(tmpbad(o),:)=tmpnew;
            found=1;
            break;
          end;
        end;
      end;
    end;
  end;
end;

% Let's also check how many spins are located inside the cylinder...

s_vdist=zeros([n_spins 2]);
for m=1:n_spins,
  pL=sum((s_space(m,:)-p1).^2).^(1/2);
  pe=(s_space(m,:)-p1)./pL;
  tmpphi=acos(dot(ve,pe)/1.0);
  s_vdist(m)=pL*sin(tmpphi);
  if (s_vdist(m,1)<=a),
    s_vdist(m,2)=1;
  end;
end;
b_actual=sum(s_vdist(:,2))/n_spins;

if (verbose_flag),
  msg=sprintf('Actual fraction of spins inside cylinder b= %f',b_actual);
  disp(msg);
end;

% At this point we have a distribution of spins and disturbers to our
% liking, so the field can be determined at the position of each spin
% as the contribution of the main magnetic field and the that of each
% perturber (note that the direction of the magnetic field is quite
% important ???)...

H_GAMMA=26752;				% rad/Gs
B0=[0 0 3.0e4];
B0mag=sum(B0.^2)^(1/2);
B0e=B0./B0mag;
deoxyHb_dX=2e-7;

B_atspins=zeros([n_spins 1]);
for m=1:n_spins,
  for n=1:n_perturbers,
    B_contribution=0;
    B_r=s_space(m,:)-p_space(n,:);
    B_contribution=b_sph(B_r,B0,ap,1.0+p_deoxyratio(n)*deoxyHb_dX,1.0);
    B_atspins(m)=B_atspins(m)+sum(B_contribution-dot(B0,B0e));
  end;
end;

w_spins=zeros([n_spins 1]);
w_spins=H_GAMMA*B_atspins;

% Now that the field is determined, we can simulate the random walk in
% Einstein fashion... we should consider here to make the cylinder a
% rigid compartment where no spins can walk accross the vessel...

s_T2=ones([n_spins 1])*T2val;			% ms

s_finalspace=s_space;
s_Diffphase=zeros([n_spins 1]);
B_atspinsinitial=B_atspins;
B_atspinsfinal=zeros([n_spins 1]);
for m=1:n_jumps,
  if (verbose_flag), disp(sprintf('  jump #%d of %d',m,n_jumps)); end;
  jump_Rs=rand([n_spins 2])*2*pi;
  for n=1:n_spins,
    B_atspinsfinal(n)=0.0;
    s_finalspace(n,:)=einsteinwalk(s_finalspace(n,:),jump_x,jump_Rs(n,:));
    for o=1:n_perturbers,
      B_contribution=0;
      B_contribution=b_sph(s_finalspace(n,:)-p_space(o,:),B0,ap,1.0+p_deoxyratio(o)*deoxyHb_dX,1.0);
      B_atspinsfinal(n)=B_atspinsfinal(n)+sum(B_contribution-dot(B0,B0e));
    end;
    s_Diffphase(n)=s_Diffphase(n)+H_GAMMA*(B_atspinsinitial(n)-B_atspinsfinal(n))*jump_t;
    B_atspinsinitial(n)=B_atspinsfinal(n);
  end;
  s_signal=ones([n_spins 1]);
  s_signal=exp(-m*jump_t./s_T2).*exp(-j*s_Diffphase);
  total_signal_dephasing_perjump(m)=abs(sum(exp(-j*s_Diffphase)));
  total_signal_perjump(m)=abs(sum(s_signal));
  if (spinecho_flag),
    if ((m*jump_t)>=(exp_TE/2)),
      s_Diffphase=s_Diffphase+pi;
      spinecho_flag=0;
    end;  
  end;
end;

% There are a few concerns above, one being that the jump is considered
% "almost" discontinuous and very small so the field can be modeled linearly
% during the jump... 

% The jump dephasing has been calculated, the remainder of the experiment
% is the decay due to inherent T's (T1, T2) and signal measurements...
% Consider initially that the T2 of the spins is the same but perhaps this
% should be modified so that the intra-cylinder and extra-cylinder spins
% have different T2's...
% Assuming that a 90 degree pulse is applied and that TE is short enough
% to discard T1 relaxation... then...

total_signal=abs(sum(s_signal));
total_signalperspin=(1/n_spins)*total_signal;

if (verbose_flag),
  msg=sprintf('Total signal= %f\nTotal signal per spin= %f',total_signal,total_signalperspin);
  disp(msg);
end;

eval(sprintf('save %smrsigmc_id%d',mcsavedir,mcid));

