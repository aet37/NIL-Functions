function y=myOIScmro2_cal(ois,lambda,cbf,parms,ii0,ii1)
% Usage ... y=myOIScmro2_cal(ois,lambda,cbf,parms,ii0,ii1)
%
% Calculates calibration coefficients for OIS and CBF data.
% If CBF data is not provided, it is estimated from the OIS data.
%
% Ex. cal=myOIScmro2_cal([tc570(:) tc620(:)],[570 620],ldf,[70e-6 0.6 1 1 0.4],[50 150],[350 450]);

do_iiselect=0;
if ~exist('ii0','var'), ii0=[]; do_iiselect=1; end;
if ischar(ii0), if strcmp(ii0,'mode'), do_iiselect=-1; end; end;

if do_iiselect==1,
    tmpf=gcf;
    figure(tmpf), clf,
    plotmany(ois), drawnow,
    tmpin=input('  enter baseline period [i1 i2]: ');
    if isempty(tmpin), tmpin=[1 floor(0.01*length(ois))]; end;
    ii0=tmpin;
    tmpin=input('  enter calibration period [i3 i4]: ');
    if isempty(tmpin), tmpin=[-25 25]+find(ois(:,1)==max(ois(:,1))); end;
    ii1=tmpin;
end

if length(ii0)==2, ii0=[ii0(1):ii0(2)]; end;
if length(ii1)==2, ii1=[ii1(1):ii1(2)]; end;

if ~exist('cbf','var'), cbf=[]; end;

flag_cbfgrubb=0;
flag_onewavelength=0;
if isempty(cbf), flag_cbfgrubb=1; end;
if prod(size(ois))==length(ois), flag_onewavelength=1; end;

if do_iiselect==-1,
  ois1=ois./(ones(size(ois,1),1)*mymode(ois));
else,
  ois1=ois./(ones(size(ois,1),1)*mean(ois(ii0,:),1));
end;

yHb=myOISdecomp(ois1,lambda,[],parms);

if isempty(parms), 
    %parms=[100e-6 0.6 1 1 0.4];
    parms=[70e-6 0.6 1 1 0.4]; 
end;
if length(parms)==2, parms=[parms 1 1 0.4]; end;

cHbT0=parms(1);
S0=parms(2);
gamma_r=parms(3);
gamma_t=parms(4);
grubb=parms(5);

% Grubb CBF estimate
cbf1_grubb=(yHb.yHb_norm(:,3)+1).^(1/grubb);
if isempty(cbf), 
    disp('  using grubb as cbf estimate');
    cbf1=cbf1_grubb; 
end;

if do_iiselect==-1,
  cbf1=cbf(:)/mymode(cbf);
else,
  cbf1=cbf(:)/mean(cbf(ii0));
end;


% Dunn CMRO2 calculations
cmro2a = cbf1.*( 1 + gamma_r*yHb.yHb_norm(:,1) )./( 1 + gamma_t*yHb.yHb_norm(:,3) );

cmro2_dunn_1 = cbf1.*( 1 + gamma_r*yHb.yHb_norm(:,1) )./( 1 + gamma_t*yHb.yHb_norm(:,3) );

% very lame optimization for gamma_r and gamma_t
tmp_gamma_r=[4:-0.01:0.25];
tmp_gamma_t=[4:-0.01:0.25];
for mm=1:length(tmp_gamma_r),
  for nn=1:length(tmp_gamma_t),
    tmp_cmro2=cbf1(:).*(1+tmp_gamma_r(mm)*yHb.yHb_norm(:,1))./(1+tmp_gamma_t(nn)*yHb.yHb_norm(:,3));
    tmp_cmro2_dunn_co2(mm,nn)=mean(tmp_cmro2(ii1));
  end;
end;
tmp_cmro2_min=abs(tmp_cmro2_dunn_co2-1);
[tmp_r,tmp_t]=find(tmp_cmro2_min<0.005); 
if isempty(tmp_r)|isempty(tmp_t),
    warning('  gamma value nowhere near 1, using minimum');
    [tmp_r,tmp_t]=find(tmp_cmro2_min==min(tmp_cmro2_min(:)));
else,
    tmp_r=round(mean(tmp_r));
    tmp_t=round(mean(tmp_t));
end;

% final Dunn CMRO2 calculation
gamma_rr=tmp_gamma_r(tmp_r);
gamma_tt=tmp_gamma_t(tmp_t);

cmro2_dunn_final=cbf1(:).*( 1 + gamma_rr*yHb.yHb_norm(:,1) )./( 1 + gamma_tt*yHb.yHb_norm(:,3) );

% now calculate by calibration

ois620=ois1(:,find(lambda>=620,1));
a620=-log(ois620);
a620_ideal=yHb.yHb_norm(:,1);

k1 = (1/mean(a620(ii1)))*((1+mean(yHb.yHb_norm(ii1,3)))/mean(cbf1(ii1)) -1);
k2 = (1/mean(a620(ii1)))*((mean(cbf1(ii1))^(grubb-1)) -1);


kk=(1/mean(a620(ii1)))*( ((1+mean(yHb.yHb_norm(ii1,3)))./mean(cbf1(ii1))) - 1 );
kk_ideal=(1/mean(a620_ideal(ii1)))*( ((1+mean(yHb.yHb_norm(ii1,3)))./mean(cbf1(ii1))) - 1 );

cmro2_620=(cbf1./(1+yHb.yHb_norm(:,3))).*(1+kk*a620);
cmro2_620_ideal=(cbf1./(1+yHb.yHb_norm(:,3))).*(1+kk_ideal*a620_ideal);

cmro2b = (cbf1./(1+yHb.yHb_norm(:,3))).*( 1 + k1*a620 );

cmro2c = (cbf1.^(1-grubb)).*( 1 + k2*a620 );

if nargout==0,
figure(1), clf,
subplot(311), plot([cbf1(:) cbf1_grubb(:) ois1]), axis tight, grid on,
legend('cbf','cbf grubb','ois in order')
subplot(312), plot(yHb.yHb_norm), axis tight, grid on,
legend('\DeltaHbR norm','\DeltaHbO norm','\DeltaHbT norm')
subplot(313), plot([yHb.yHb(:,1)/yHb.cHbR0  yHb.cHbT/yHb.cHbT0]), axis tight, grid on,
legend('\DeltaHbR/HbR0','\DeltaHbT/HbT0');
figure(2), clf,
subplot(311), plot( [(cbf1./(1+yHb.yHb_norm(:,3))) (1+kk*a620)] ), axis tight, grid on,
legend('term1','term2'),
subplot(312), plot( [(1 + k1*a620(:)) (1 + k2*a620(:))]), axis tight, grid on,
legend('term2a','term2b')
subplot(313), plot([cmro2a(:) cmro2b(:) cmro2c(:)]), axis tight, grid on,
legend('cmro2a','cmro2b','cmro2c')

figure(3), clf,
subplot(211), plot([cmro2_dunn_1(:) cmro2_dunn_final(:)]), axis tight, grid on,
legend('cmro2 dunn 1','cmro2 dunn final')
subplot(212), plot([cmro2_620(:) cmro2_620_ideal(:)]), axis tight, grid on,
legend('cmro2 620','cmro2 620 ideal')
end

y.flag_onewavelength=flag_onewavelength;
y.flag_cbfgrubb=flag_cbfgrubb;
y.ois=ois1;
y.lamba=lambda;
y.parms=parms;
y.ii0=ii0;
y.ii1=ii1;
y.yHb=yHb;
y.cbf=cbf1;
y.cbf_grubb=cbf1_grubb;
y.gamma_r=gamma_rr;
y.gamma_t=gamma_tt;
y.kk=[kk kk_ideal];
y.k12=[k1 k2];
y.cmro2_dunn_0=cmro2_dunn_1;
y.cmro2_dunn_final=cmro2_dunn_final;
y.cmro2_620=cmro2_620;
y.cmro2_620_ideal=cmro2_620_ideal;

