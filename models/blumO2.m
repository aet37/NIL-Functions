
% The following is Blum's solution to the Diffusion-Convection Equation
% applied to the delivery of oxygen to tissue
% Some of the assumptions:
%  1- steady-state (dc/dt=0)
%  2- many others

% Equations to solve and boundary conditions:
%  Dt 1/r d/dr r dc/dr = k c 		Rc <= r <= Rt
%  dc/dr = 0  @  r = Rt
%  v~ dc~/dz = 2/Rc (Dt dc/dr)|r=Rc 	???
%  (Dt dc/dr)|r=Rc = (Db dc/dr)|r=Rc = P(c0 - c~)
%  c~ = c_in  @  z = 0			0 <= r <= Rc

% order of solution ????
%  1- set some c0z for the tissue and find cbarz for tube
%  2- use cbarz to find c(r,z) in the tissue
% problem: this does not involve vbar!!! if we solve to make
%  vbar into the problem then the selection of c0z is very very important
%  not to mention that there is NO time-dependent solution...


Db=1e-9;	% m^2 / s
Dt=1e-9;	% m^2 / s
Rc=100e-6;	% m
Rt=300e-6;	% m

vbar=1e-2;	% m/s
L=1e-2;		% m

cin=1;		% ???
P=1;		% permeability or pressure ???
k=1;		% oxygen-util-to-concentration proportion ???

dr=Rc/10;
r=[0:dr:Rt];	
rc=[0:dr:Rc];
rt=[Rc:dr:Rt];

dz=L/20;
z=[0:dz:L];

lambda=sqrt(k*Rc*Rc/Dt);

I0l=besseli(0,lambda);
I0r=besseli(0,lambda*rt/Rc);
I0R=besseli(0,lambda*Rt/Rc);

I1l=besseli(1,lambda);
I1r=besseli(1,lambda*rt/Rc);
I1R=besseli(1,lambda*Rt/Rc);

K0l=besseli(0,lambda);
K0r=besseli(0,lambda*rt/Rc);
K0R=besseli(0,lambda*Rt/Rc);

K1l=besseli(1,lambda);
K1r=besseli(1,lambda*rt/Rc);
K1R=besseli(1,lambda*Rt/Rc);

B = (I1R*K1l - I1l*K1R) / (I0l*K1R + I1R*K0l);

F = (I0r*K1R + I1R*K0r) / (I0l*K1R + I1R*K0l);

% this definition is very important for the second approach
c0z=1*ones(size(z));

% first approach we can either solve this OR just define cbarz
beta=lambda*Dt/(P*Rc);
cbarz1 = c0z*( 1 + beta*B );
%cbarz1 = cin*ones(size(z));

cc1=zeros([length(rt) length(z)]);
for m=1:length(rt),
  cc1(m,:) = (cbarz1/(1+beta*B)).*F;
end;
dcc1drb=diff(cc1(:,1));

% doing this we require that these statements are compatible
%   vbar dcbar/dz = P(c0z - cbarz)
cbbar1=cumsum((1/vbar)*(2/Rc)*Db*dcc1drb);


% second approach to solve this
cbarz2(1)=cin;
for m=2:length(z),
  cbarz2(m) = cbarz2(m-1) + dz*( (1/vbar)*(2*Dt/Rc)*(-c0z)*(lambda/Rc)*B );
end;

cc2=zeros([length(rt) length(z)]);
for m=1:length(rt),
  %cc2(m,:) = (cbarz2/(1+beta*B)).*F;
  cc2(m,:) = c0z.*F;
end;

