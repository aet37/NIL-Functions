load('hb_spectra');
clf,
plot(hb.nm,hb.hbo,'r', hb.nm,hb.hbr,'b');
axis([400 700 0 1.2]); 
line(572, 0:0.01:1.2)
line(620, 0:0.01:1.2)
legend('oxyHb', 'deoxyHb');
title('Mean Hb Absorption Spectrum'); xlabel('Wavelength (nm)'); ylabel('Relative Absorbance');
fatlines(1.5); grid('on'),
set(gca,'FontSize',12); 
dofontsize(15);

nm572 = find(hb.nm>571);
%hb.nm(nm572(1))
%hb.nm(nm572(2))

fprintf('pathlength included relative absorption coefficient of Hb (l*e): \n');
fprintf('HbO at 572 nm: %.2f\n', hb.hbo(nm572(2)));
fprintf('HbR at 572 nm: %.2f\n', hb.hbr(nm572(2)));

nm620 = find(hb.nm>619);
%hb.nm(nm620(1))
%hb.nm(nm620(2))

fprintf('HbO at 620 nm: %.2f\n', hb.hbo(nm620(1)));
fprintf('HbR at 620 nm: %.2f\n', hb.hbr(nm620(1)));
