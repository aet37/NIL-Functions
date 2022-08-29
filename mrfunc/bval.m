function [b,venc]=bval(Delta2,delta,Gamp)
%function [b,venc]=bval(Delta2,delta,Gamp)
%     Delta2 = spacing between lobes (ms)
%     delta = width of lobe (ms)
%     Gamp = gradient amplitude (Gauss/cm)



     gamma=4257.7; % (Hz/Gauss)
     gamma=gamma*2*pi; 

     Gamp=Gamp/10; % (make Gauss/mm)
     Delta2=Delta2/1000; delta=delta/1000; % (ms to s)


     b=(gamma*Gamp*delta).^2*(Delta2-delta/3);  %in s/mm

     venc=2*pi/(gamma*Gamp*Delta2*delta);

if (nargout==0),
  disp(sprintf('  b-value: %f s/mm^2   (v-enc: %f mm/s)',b,venc));
end;

