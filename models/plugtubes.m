function v=plugtubes(ntubes,nparts,vmin,vmax,dim)
% Usage ... v=plugtubes(ntubes,nparts,vmin,vmax,dim)

% 1-dim flow for now
dim=1;

% velocities: uniform
%   if these are physiological they should scale more on the lower vels? (more caps)
vr=rand([ntubes 1])*(vmax-vmin)+vmin;

% distribution of particles: uniform 
%   if these are physiological then more particles should be given to the faster
%   velocities since velocity may be a function of radius
ni=floor(nparts/ntubes);
nni=ni*ones([ntubes-1 1]);
nni(ntubes)=nparts-sum(nni);

if (dim==1),
  v=vr(1)*ones([nni(1) 1]);
  for m=2:ntubes,
    vv=vr(m)*ones([nni(m) 1]);
    v=[v;vv];
  end;
elseif (dim==2),
  theta=rand([ntubes 1])*pi;
  vv=vr(1)*ones([nni(1) 2]);
  vv(:,1)=vv(:,1)*cos(theta(1)); vv(:,2)=vv(:,2)*sin(theta(1));
  vv=v;
  for m=2:ntubes,
    vv=vr(m)*ones([nni(m) 2]);
    vv(:,1)=vv(:,1)*cos(theta(m)); vv(:,2)=vv(:,2)*sin(theta(m));
    v=[v;vv];
  end;
elseif (dim==3),
  theta=rand([ntubes 1])*pi;
  phi=rand([ntubes 1])*pi;
  vv=vr(1)*ones([nni(1) 3]); 
  vv(:,1)=vv(:,1)*cos(theta(1))*cos(phi(1)); 
  vv(:,2)=vv(:,2)*sin(theta(1))*cos(phi(1));
  vv(:,3)=vv(:,3)*sin(phi(1));
  vv=v;
  for m=2:ntubes,
    vv=vr(m)*ones([nni(m) 3]);
    vv(:,1)=vv(:,1)*cos(theta(m))*cos(phi(m));
    vv(:,2)=vv(:,2)*sin(theta(m))*cos(phi(m));
    vv(:,3)=vv(:,3)*sin(phi(m));
    v=[v;vv];
  end;
else,
  v=vr(1)*ones([nni(1) 1]);
  for m=2:ntubes,
    vv=vr(m)*ones([nni(m) 1]);
    v=[v;vv];
  end;
end;

if (nargout==0),
  if (dim==2),
    subplot(121), hist(v(:,1),floor(0.02*nparts)), xlabel('Vx')
    subplot(122), hist(v(:,2),floor(0.02*nparts)), xlabel('Vy')
  elseif (dim==3),
    subplot(131), hist(v(:,1),floor(0.02*nparts)), xlabel('Vx')
    subplot(132), hist(v(:,2),floor(0.02*nparts)), xlabel('Vy')
    subplot(132), hist(v(:,3),floor(0.02*nparts)), xlabel('Vz')
  else
    hist(v,floor(.02*nparts)), xlabel('V')
  end;
end;
  
