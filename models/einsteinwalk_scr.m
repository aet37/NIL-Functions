
clear all

n_particles=1000;
xx=zeros(n_particles,3);

n_jumps=50;
l=1;

myseed=11;
rand('seed',myseed);
walk1=0;

for nn=1:n_jumps,
  disp(sprintf('  jump #%d of %d',nn,n_jumps));
  for mm=1:n_particles,
    if (walk1),
      tmp_phi=2*pi*rand(1);
      tmp_theta=2*pi*rand(1);
      xx(mm,:)=einsteinwalk(xx(mm,:),l,[tmp_phi tmp_theta]);
    else,
      xx(mm,:)=einsteinwalk2(xx(mm,:),l,rand(1,3),[1 1 1]*0.5);
    end;
  end;
end;

% 3D walk
xm=sqrt(2*n_jumps/pi);
stdx1=std(xx(:,1));
stdx2=std(xx(:,2));
stdx3=std(xx(:,3));


subplot(311)
hist(xx(:,1),50)
subplot(312)
hist(xx(:,2),50)
subplot(313)
hist(xx(:,3),50)

disp(sprintf('  std (x,y,z)= (%f,%f,%f)  %f',stdx1,stdx2,stdx3,xm));

% interesting in this simulation, we get a smaller expected distance
% best described by xm=sqrt(1.5*n_jumps/pi)


