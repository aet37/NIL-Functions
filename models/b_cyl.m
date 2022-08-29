function [f]=b_cyl(space,B0v,r_cyl,angles,m_in,m_out)
% Usage ... f=b_sphere(space,B0v,r_cyl,angles,m_in,m_out)
%
% Returns the magnetic field (B) that each particle (row) in the space 
% variable experiences due to a magnetic cylinder (infinite) centered about
% (0,0,0) of a and angled with [theta(x-y) phi(x-z)] angles and
% susceptibility difference m_in=1+dX, m_out=1
% recall that dchi includes the overall susceptibility difference

% usual command: B=b_sphere(sp,[0 0 B0],r_cyl,[0 0],1+dX,1);
% B0=1500;
% r_cyl=25e-6;
% dX=1e-6;
% m_water= -0.9e-5

if size(space,1)>1,
  parametric_space=1;
else,
  parametric_space=0;
end;

B0mag=sqrt(sum(B0v.^2));
B0dir=B0v./B0mag;
dchi=m_in-1;

Ctheta=angles(1);	% cylinder angle off z-axis
Cphi=angles(2);		% cylinder angle off x-axis
Cdir=[sin(Ctheta)*cos(Cphi) sin(Ctheta)*sin(Cphi) cos(Ctheta)];

theta=acos(dot(B0dir,Cdir));	% angle between field and cylinder

if parametric_space,		% 3D space
  for m=1:size(space,1),	% many particles per row in space
    V=space(m,:);		% particle space location wrt (0,0,0)
    Vmag=sqrt(sum(V.^2));	% distance from the cylinder
    if (Vmag==0.0), Vdir=[0 0 0]; else, Vdir=V./Vmag; end;
    phi2=acos(dot(Cdir,Vdir));	% angle between point vector and cylinder
    aa=sin(phi2)*Vmag;		% distance to cylinder axis at closest point
    if (aa>r_cyl),		% outside the cylinder
      phi=acos(dot(B0dir,Vdir));	% angle between point vector and field
      B(m)=2*pi*dchi*B0mag*sin(theta)*sin(theta)*(r_cyl/aa)*(r_cyl/aa)*cos(2*phi);
    else,			% inside the cylinder
      B(m)=2*pi*dchi*B0mag*(3*cos(theta)*cos(theta)-1)/3;
    end;
  end;
else,
  V=space;			% 2D space
  Vmag=sqrt(sum(V.^2));
  if (Vmag==0.0), Vdir=[0 0 0]; else, Vdir=V./Vmag; end;
  phi2=acos(dot(Cdir,Vdir));	% angle between point vector and cylinder
  aa=sin(phi2)*Vmag;		% distance to cylinder axis at closest point
  if (aa>r_cyl),		% outside the cylinder
    phi=acos(dot(B0dir,Vdir));	% angle between point vector and field
    B=2*pi*dchi*B0mag*sin(theta)*sin(theta)*(r_cyl/aa)*(r_cyl/aa)*cos(2*phi);
  else,				% inside the sphere
    B=2*pi*dchi*B0mag*(3*cos(theta)*cos(theta)-1)/3;
  end;
end;

f=B.';

