function plotBioCO2(bio,tt)
% Usage ... plotBioCO2(bio,tt)

if nargin==1, tt=[0.001 0]; end;

if length(tt)<3, 
  dt=tt(1);
  t0=tt(2);
  tt=[1:length(bio.FLUX)]*dt-t0;
else,
  t0=tt(1);
  dt=tt(2)-tt(1);
end;

subplot(211)
tmpflux=fermi1d(bio.FLUX,5,0.5,1,dt);
if tt(1)>0,
  tmpflux=tmpflux/mean(tmpflux(1:100));
else,
  tmpflux=tmpflux/mean(tmpflux(1:floor(t0/dt)-100));
end;
plot(tt,tmpflux,'r')
xlabel('Time (s)'), ylabel('LDF/LDF_0 (CBF)'),
axis('tight'), grid('on'),
dofontsize(15); set(gca,'FontSize',12);
fatlines(1.5);
subplot(212)
tmpco2=fermi1d(bio.Ex_CO2,5,0.5,1,dt);
plot(tt,tmpco2,'k')
xlabel('Time (s)'), ylabel('ET CO_2 (%)'),
axis('tight'), grid('on'),
dofontsize(15); set(gca,'FontSize',12);
fatlines(1.5);

