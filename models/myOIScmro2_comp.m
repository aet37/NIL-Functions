function y=myOIScmro2_comp(ois,lambda,cbf,parms,cal,ii0)
% Usage ... y=myOIScmro2_comp(ois,lambda,cbf,parms,cal,ii0)
%
% Calculates CMRO2 using baseline normalized OIS and CBF data (S/S0) along  
% with the calibration parameters in cal (structure).
% If CBF data is not provided, it is estimated from the OIS data.
%
% Ex. cal=myOIScmro2_comp([tc570(:) tc620(:)],[570 620],ldf,[200e-6 0.6 1 1 0.8],cal);

if ~exist('cal','var'), cal=[]; end;
if ~exist('ii0','var'), ii0=[]; end;

if isempty(parms), if isstruct(cal), parms=cal.parms; else, parms=[70e-6 0.6 1 1 0.4]; end; end;
if length(parms)==2, parms=[parms 1 1 0.4]; end;

cHbT0=parms(1);
S0=parms(2);
gamma_r=parms(3);
gamma_t=parms(4);
grubb=parms(5);

do_cal=1;
if isempty(cal), do_cal=0; end;

if do_cal,
  if isstruct(cal),
    gamma_rr=cal.gamma_r;
    gamma_tt=cal.gamma_t;
    grubb=cal.parms(5);
    kk=cal.kk(1);
    kk_ideal=cal.kk(2);
    k1=cal.k12(1);
    k2=cal.k12(2);
  else,
    kk=cal;
    kk_ideal=cal;
    k1=cal;
    k2=cal;
  end
end

if ~isempty(ii0),
    if ischar(ii0),
        clf, plot(ois), axis tight, grid on,
        tmpin=input('  select ii0 range [i1 i2]: ');
        if isempty(tmpin), tmpin=[1 ceil(0.05*length(ois))+1]; end;
        ii0=tmpin;
    end
    if length(ii0)==2, ii0=[ii0(1):ii0(2)]; end;
    ois1=ois./(ones(size(ois,1),1)*mean(ois(ii0,:),1));
    cbf1=cbf/mean(cbf(ii0));
else,    
    ois1=ois;
    cbf1=cbf;
end

flag_onewavelength=0;
flag_cbfgrubb=0; 
if prod(size(ois))==length(ois), flag_onewavelength=1; end;
if isempty(cbf), flag_cbfgrubb=1; end

yHb=myOISdecomp(ois1,lambda,[],parms);

% Grubb CBF estimate
cbf1_grubb=(yHb.yHb_norm(:,3)+1).^(1/grubb);
if isempty(cbf), 
    disp('  using grubb as cbf estimate');
    cbf1=cbf1_grubb; 
end;


% Dunn CMRO2 calculations
cmro2a = cbf1.*( 1 + gamma_r*yHb.yHb_norm(:,1) )./( 1 + gamma_t*yHb.yHb_norm(:,3) );
cmro2_dunn_1 = cbf1.*( 1 + gamma_r*yHb.yHb_norm(:,1) )./( 1 + gamma_t*yHb.yHb_norm(:,3) );
cmro2_dunn_1g = cbf1_grubb.*( 1 + gamma_r*yHb.yHb_norm(:,1) )./( 1 + gamma_t*yHb.yHb_norm(:,3) );

% now calculate by calibration
if do_cal,
    cmro2_dunn_final=cbf1(:).*( 1 + gamma_rr*yHb.yHb_norm(:,1) )./( 1 + gamma_tt*yHb.yHb_norm(:,3) );
    
    ois620=ois1(:,find(lambda>=620,1));
    a620=-log(ois620);
    a620_ideal=yHb.yHb_norm(:,1);

    a620_1 = ((1+yHb.yHb_norm(:,3))./cbf1 - 1)/kk;

    cmro2_620=(cbf1./(1+yHb.yHb_norm(:,3))).*(1+kk*a620);
    cmro2_620_ideal=(cbf1./(1+yHb.yHb_norm(:,3))).*(1+kk_ideal*a620_ideal);

    cmro2b = (cbf1./(1+yHb.yHb_norm(:,3))).*( 1 + k1*a620 );
    cmro2c = (cbf1.^(1-grubb)).*( 1 + k2*a620 );
end;

if nargout==0,
figure(1), clf,
subplot(311), plot([cbf1(:) cbf1_grubb(:)]), axis tight, grid on,
legend('cbf','cbf grubb')
subplot(312), plot([ois1]), axis tight, grid on,
legend('ois in order')
subplot(313), plot(yHb.yHb_norm), axis tight, grid on,
legend('\DeltaHbR norm','\DeltaHbO norm','\DeltaHbT norm')

if do_cal,
    figure(2), clf,
    subplot(311), plot( [(cbf1./(1+yHb.yHb_norm(:,3))) (1+kk*a620)] ), axis tight, grid on,
    legend('term1','term2'),
    subplot(312), plot( [(1 + k1*a620(:)) (1 + k2*a620(:))]), axis tight, grid on,
    legend('term2a','term2b')
    subplot(313), plot([cmro2a(:) cmro2b(:) cmro2c(:)]), axis tight, grid on,
    legend('cmro2a','cmro2b','cmro2c')

    figure(3), clf,
    subplot(311), plot([cmro2_dunn_1(:) cmro2_dunn_final(:) cmro2_620(:)]), axis tight, grid on,
    legend('cmro2 dunn 1','cmro2 dunn final','cmro2 620')
    subplot(312), plot([cmro2_620(:) cmro2_620_ideal(:)]), axis tight, grid on,
    legend('cmro2 620','cmro2 620 ideal')
    subplot(313), plot([kk*a620(:) kk_ideal*a620_ideal(:) kk*a620_1(:)]), axis tight, grid on, legend('k*a620 measured','k*a620 ideal','k*a620 cmro2=1'),
else,
    figure(2), clf,
    plot([cmro2_dunn_1(:) cmro2_dunn_1g(:)]), axis tight, grid on,
    legend('cmro2 dunn 1','cmro2 dunn 1 grubb')
end

end

y.ois=ois1;
y.lamba=lambda;
y.parms=parms;
y.yHb=yHb;
y.cbf=cbf1;
y.cbf_grubb=cbf1_grubb;
y.cmro2=cmro2a;
y.cmro2_dunn=cmro2_dunn_1;
y.cmro2_dunn_g=cmro2_dunn_1g;
if do_cal,
  y.gamma_r=gamma_rr;
  y.gamma_t=gamma_tt;
  y.kk=kk;
  y.k12=[k1 k2];
  y.cmro2_dunn_final=cmro2_dunn_final;
  y.cmro2_620=cmro2_620;
end

