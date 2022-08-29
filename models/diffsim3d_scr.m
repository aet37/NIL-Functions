
%
% Simulation of the diffusion-convection equation in 3D
% The velocity field is assumed known and controlled by
% max velocity, which is 1.5x (???) the mean velocity
% The diffusion-convection equation in the vessel is as
% follows with the corresponding velocity field
% In the tissue, the diffusion-convection is as follows
% with the corresponding consumption field
%
% Vessel:
%   dC/dt + u dC/dz = D ( 1/r d/dr ( r dC/dr ) + dddC/ddz )
%   v(y) = v_max ( 1 - (y/y0)^2 )
%   C(r,z):  C(0,0)=C0a 
%
% Tissue:
%   dC/dt = D ( ddC/ddx + ddC/ddy ) - G
%   v = 0
%   C(r,z):  C(tiss,all)=C0t
%


clear all

alpha_o2=1.39e-3;	% mmol/mmHg

D=100;		% units: um
L=400;		% units: um

dR=1;		% units: um
dL=1;		% units: um

RR=400;
LL=400;

R=[0:round(RR/dR)]*dR;
L=[0:round(LL/dL)]*dL;

D_bl = 2e-9;
D_tiss = 2e-9;

Pa=70;
CHb=2.3;
hill=2.73;
P50=26;

V0max = 4e-3;	% units mm/s
V0r = V0max*(1 - (R./(D/2)).^2);
V0r(find(R>=(D/2)))=0;

G=2.5e-9;	% mmol/s

C0a = Pa*alpha_o2 + CHb*4/(1 + (Pa/P50)^hill) ;

C(1,1) = C0a;

%
% First solve the steady-state problem
%   u dC/dx = D ( 1/r dC/dr + ddC/ddr + dddC/ddx )
%   v(r) = v_max ( 1 - (r/r0)^2 )
%   C(r,x):  C(0,0)=C0a   dC/dr(r=0)=0
%
% Tissue:
%   D ( 1/r dC/dr + ddC/ddr + ddC/ddx ) = G
%   C(r,x):  C(tiss,all)=C0t  dC/dr(r=R)=0
%


%
% C(mm,nn) = C(xx,rr)
%
% ORDER IS INCORRECT, NEED MORE ASSUMPTIONS?
% convert to C to plasma equivalent
for mm=1:length(L),
  for nn=2:length(R),
    % C(mm,nn)=C(xx,rr)
    if (mm>2),
      Cxx = (C(mm,nn)-C(mm-1,nn))*(C(mm-1,nn)-C(mm-2,nn))/(dL*dL);
    else,
      Cxx = 0;
    end;
    if (mm>1),
      Cx = (C(mm,nn)-C(mm-1,nn))/dL;
    else,
      Cx = 0;
    end;
    if (nn>2),
      Crr = (C(mm,nn)-C(mm,nn-1))*(C(mm,nn-1)-C(mm,nn-2))/(dR*dR);
    else,
      Crr = 0;
    end;
    if (nn>2),
      Cr = (C(mm,nn)-C(mm,nn-1))/dR;
    else,
      Cr = 0;
    end;
    if (R(nn)<=(D/2)), 
      if (abs(V0r(nn))<=1e-3*D_bl),
        V0r(nn)=1e-3*D_bl*sign(V0r(nn));
      end;
      C(mm,nn) = C(mm-1,nn) + dL*(D_bl/V0r(nn))*( 1/R(nn)*Cr + Crr + Cxx );
    else,
      C(mm,nn) = C(mm-1,nn) + dR*(R(nn)-D/2)*( G/D_tiss - Crr - Cxx );
    end;
    if (C(mm,nn)<0), C(mm,nn)=0; end;
  end;
end;




%% Lax approximation example
%A(1,:) = input;
%A(2,:) = A(1,:);
%
%for t = 2 :length(tvec)-1
%  % first time derivative of V and f:
%  Vt = ( V(t+1) - V(t-1) ) / (2*dt);
%  ft = ( f(t+1) - f(t-1) ) / (2*dt);
%
%  %Vtt = (V(t+1) -2*V(t) + V(t+1) / (dt*dt)
%
%  for x=2:length(xvec)-1
%    % first derivatives in space and time
%    Ax = ( A(x+1,t) - A(x-1,t) ) / (2*dx);
%    At = -V(t)*Ax - R1a*A(x,t);
%
%    % second derivative in space and time
%    Axx = (A(x-1,t) - 2*A(x,t) + A(x+1,t)) / (dx*dx);
%    Att = -V(t)*(-V(t)*Axx - R1a*Ax) - Vt*Ax - R1a*At;
%    A(x,t+1) = A(x,t) + dt*At + (dt^2)*Att/2;
%
%    A(dist*CM,t) = A(dist*CM,t) - f(t) * A(dist*CM,t);
%    art(t) = A(dist*CM,t) - f(t) * A(dist*CM,t);;
%    artt = (art(t)-art(t-1))/dt;    % backward difference
%    Tt = f(t)*art(t) - R1t*tis(t);% - (f(t)/lambda)*tis(t-xchange_time);
%    Ttt = ft*art(t) + f(t)*artt - R1t*Tt;% - (ft*tis(t-xchange_time) + f(t)*Tt)/lambda
%  end;
%
%  tis(t+1) = tis(t) + dt*Tt +(dt^2)*Ttt/2;
%end;

