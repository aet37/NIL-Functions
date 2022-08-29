function [f,f2]=b_sph(space,B0v,a,m_in,m_out)
% Usage ... f=b_sph(space,B0v,a,m_in,m_out)
%
% Returns the magnetic field (B) that each particle (row) in the space 
% variable experiences due to a magnetic sphere located at (0,0,0) of
% radius a and susceptibility difference m_in=1+dX, m_out=1

% usual command: B=b_sphere(sp,[0 0 B0],r_sph,1+dX,1);
% B0=1500;
% r_sph=5e-6;
% dX=1e-6;
% m_water= -0.9e-5

spacesz=size(space);
if spacesz(1)>1,
  parametric_space=1;
else,
  parametric_space=0;
end;

B0mag=sqrt(sum(B0v.^2));
B0dir=B0v./B0mag;
dchi=m_in-1;

if parametric_space,		% 3D space
  do_loop=0;
  if (do_loop), 		% old way
    for m=1:size(space,1),	% many particles per row in space
      V=space(m,:);
      Vmag=sqrt(sum(V.^2));	% sphere centered at (0,0,0)
      if Vmag==0.0, Vdir=[0 0 0]; else, Vdir=V./Vmag; end;
      theta(m)=acos(dot(B0dir,Vdir));
      if (Vmag>a),		% outside the sphere
        Hterm1=1+2*(a*a*a/(Vmag*Vmag*Vmag))*((m_in-m_out)/(m_in+2*m_out));
        Hterm2=1-(a*a*a/(Vmag*Vmag*Vmag))*((m_in-m_out)/(m_in+2*m_out));
        Hterm1=Hterm1*cos(theta(m));
        Hterm2=-1*Hterm2*sin(theta(m));
        H(m)=B0mag*sqrt(Hterm1*Hterm1 + Hterm2*Hterm2);
        B(m)=m_out*H(m);
        B2(m)=(1+(dchi/(dchi+3))*((a/Vmag)^3)*(3*cos(theta(m))*cos(theta(m))-1))*B0mag;
      else,			% inside the sphere
        H(m)=3*m_out*B0mag/(m_in+2*m_out);
        B(m)=H(m)*m_in;
        B2(m)=3*((dchi+1)/(dchi+3))*B0mag;
      end;
    end;
  else,
    Vmag=(sum((space.^2)')').^(0.5);
    Vdir=zeros(spacesz);
    tmpzi=find(abs(Vmag)>1e-10);
    if ~isempty(tmpzi),
      Vdir(tmpzi,:)=space(tmpzi,:)./(Vmag(tmpzi)*ones(1,3));
    end;
    theta=acos(dot((ones(spacesz(1),1)*B0dir)',Vdir'))';
    tmpout=find(Vmag>a);
    tmpin=find(Vmag<=a);
    if ~isempty(tmpout),
      Hterm1=1+2*((a./Vmag(tmpout)).^3)*((m_in-m_out)/(m_in+2*m_out));
      Hterm2=1-((a./Vmag(tmpout)).^3)*((m_in-m_out)/(m_in+2*m_out));
      Hterm1=Hterm1.*cos(theta(tmpout));
      Hterm2=-1*Hterm2.*sin(theta(tmpout));
      H_out=B0mag*((Hterm1.*Hterm1 + Hterm2.*Hterm2).^(0.5));
      B_out=H_out*m_out;
      B2_out=B0mag*(1+(dchi/(dchi+3))*((a./Vmag(tmpout)).^3).*(3*cos(theta(tmpout)).*cos(theta(tmpout))-1));
    end;
    if ~isempty(tmpin),
      B_in=m_in*ones(size(tmpin))*(3*m_out*B0mag/(m_in+2*m_out));
      B2_in=3*((dchi+1)/(dchi+3))*B0mag*ones(size(tmpin));
    end;
    B=zeros(size(Vmag));
    B(tmpin)=B_in;
    B(tmpout)=B_out;
    B2=zeros(size(Vmag));
    B2(tmpin)=B2_in;
    B2(tmpout)=B2_out;
  end;
else,
  V=space;		% 2D space
  Vmag=sqrt(sum(V.^2));
  if Vmag==0.0, Vdir=[0 0 0]; else, Vdir=V./Vmag; end;
  theta=acos(dot(B0dir,Vdir));
  if (Vmag>a),
    Hterm1=1+2*(a*a*a/(Vmag*Vmag*Vmag))*((m_in-m_out)/(m_in+2*m_out));
    Hterm2=1-(a*a*a/(Vmag*Vmag*Vmag))*((m_in-m_out)/(m_in+2*m_out));
    Hterm1=Hterm1*cos(theta);
    Hterm2=-Hterm2*sin(theta);
    H=B0mag*((Hterm1*Hterm1 + Hterm2*Hterm2).^(1/2));
    B=H*m_out;
    B2=(1+(dchi/(dchi+3))*((a/Vmag)^3)*(3*cos(theta)*cos(theta)-1))*B0mag;
  else,
    H=3*m_out*B0mag/(m_in+2*m_out);
    B=H*m_in;
    B2=3*((dchi+1)/(dchi+3))*B0mag;
  end;
end;

%keyboard;

f=B-B0mag;
f2=B2-B0mag;

