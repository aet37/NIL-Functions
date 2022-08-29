function p31s=p31spec(x,t,B0,mlist,R2,nsplits,splitfreq,phi01)
% Usage ... f=p31spec(x,t,B0,metlist,R2,nsplits,splitfreq,phi01)
%
% This function returns the typical 31P MRS spectrum
% in the piglet brain. B0 must be in Tesla.
% metabolite list: 1-PCr, 2-gATP, 3-aATP, 4-Pi, 5-PME, 6-PDE, 7-NADH, 8-gATP

% Assumptions
% 1- NotUsed- Overall intensities of a,b,g-ATP are identical
% 2- g,a-ATP are doublets while b-ATP is a triplet
% 3- a,b,g-ATP T2s are identical (30-40ms)
% 4- a,b,g=ATP dws are identical where dw=J (~20-25Hz)
% 5- all phases are equal

p31gamma=17.235;	% MHz/T (31P/1H sensitivity= 0.06)

% 31P Name definition, default splits and splitfrequency
p31spec=['PCr ';'gATP';'aATP';'Pi  ';'PME ';'PDE ';'NADH';'bATP'];
p31nsplits=[0;0;0;0;0;0;0;0];
p31splitppms=[0.0;0.3;0.3;0.0;0.0;0.0;0.0;0.3];

% Chemical Shifts for 31P MRS metabolites
%  PME and PDE shifts are estimated... need to find true shifts
p31ppm=[+0.00 -2.48 -7.52 +5.02 +6.75 +3.00 -8.30 -16.26];
p31f=p31ppm*p31gamma*B0; 		% Hz
p31df=p31splitppms*p31gamma*B0;		% Hz

% T1 for 31P MRS metabolites
%  PME and NADH are estimated... need to find true T1s
p31R1_15T=1./[3.2 0.6 0.8 1.7 2.1 1.7 1.0 1.0];

% T2 for 31P MRS metabolites
%  all are estimated... need to find true T2s
p31R2_15T=1./[100e-3 35e-3 35e-3 100e-3 100e-3 100e-3 100e-3 35e-3];
p31R2=p31R2_15T;

% 31P Relative Amplitudes
p31ramp=[10.0 10.0 5.0 2.0 5.0 2.5 2.5 5.0];

% 31P Phases
p31phis=[0 0;0 0;0 0;0 0;0 0;0 0;0 0;0 0];


if nargin<4, mlist=[1:8]; end;
if nargin<5, R2=-10*ones([1 length(mlist)]); end;
if nargin<6, nsplits=-10*ones([1 length(mlist)]); end;
if nargin<7, phi01=-10*ones([length(mlist) 2]); end;
if isempty(x), 
  
end;

p31s=0;
for m=1:length(mlist),
  if mlist(m)==1,
    if R2(m)~=-10, p31R2(1)=R2(m); end;
    if nsplits(m)~=-10, p31nsplits(1)=nsplits(m); end;
    if phi01(m,1)~=-10, p31phis(1,:)=phi01(m,:); end;
    if x(2*m-1)~=-1, p31ramp(1)=x(2*m-1); p31f(1)=x(2*m); end;
  elseif mlist(m)==2,
    if R2(m)~=-10, p31R2(2)=R2(m); end;
    if nsplits(m)~=-10, p31nsplits(2)=nsplits(m); end;
    if phi01(m,1)~=-10, p31phis(2,:)=phi01(m,:); end;
    if x(2*m-1)~=-1, p31ramp(2)=x(2*m-1); p31f(2)=x(2*m); end;
  elseif mlist(m)==3,
    if R2(m)~=-10, p31R2(3)=R2(m); end;
    if nsplits(m)~=-10, p31nsplits(3)=nsplits(m); end;
    if phi01(m,1)~=-10, p31phis(3,:)=phi01(m,:); end;
    if x(2*m-1)~=-1, p31ramp(3)=x(2*m-1); p31f(3)=x(2*m); end;
  elseif mlist(m)==4,
    if R2(m)~=-10, p31R2(4)=R2(m); end;
    if nsplits(m)~=-10, p31nsplits(4)=nsplits(m); end;
    if phi01(m,1)~=-10, p31phis(4,:)=phi01(m,:); end;
    if x(2*m-1)~=-1, p31ramp(4)=x(2*m-1); p31f(4)=x(2*m); end;
  elseif mlist(m)==5,
    if R2(m)~=-10, p31R2(5)=R2(m); end;
    if nsplits(m)~=-10, p31nsplits(5)=nsplits(m); end;
    if phi01(m,1)~=-10, p31phis(5,:)=phi01(m,:); end;
    if x(2*m-1)~=-1, p31ramp(5)=x(2*m-1); p31f(5)=x(2*m); end;
  elseif mlist(m)==6,
    if R2(m)~=-10, p31R2(6)=R2(m); end;
    if nsplits(m)~=-10, p31nsplits(6)=nsplits(m); end;
    if phi01(m,1)~=-10, p31phis(6,:)=phi01(m,:); end;
    if x(2*m-1)~=-1, p31ramp(6)=x(2*m-1); p31f(6)=x(2*m); end;
  elseif mlist(m)==7,
    if R2(m)~=-10, p31R2(7)=R2(m); end;
    if nsplits(m)~=-10, p31nsplits(7)=nsplits(m); end;
    if phi01(m,1)~=-10, p31phis(7,:)=phi01(m,:); end;
    if x(2*m-1)~=-1, p31ramp(7)=x(2*m-1); p31f(7)=x(2*m); end;
  elseif mlist(m)==8,
    if R2(m)~=-10, p31R2(8)=R2(m); end;
    if nsplits(m)~=-10, p31nsplits(8)=nsplits(m); end;
    if phi01(m,1)~=-10, p31phis(8,:)=phi01(m,:); end;
    if x(2*m-1)~=-1, p31ramp(8)=x(2*m-1); p31f(8)=x(2*m); end;
  end;
  p31s=p31s+nmrspec([p31ramp(mlist(m)) p31f(mlist(m))],t,p31R2(mlist(m)),p31phis(mlist(m),:),p31nsplits(mlist(m)),p31df(mlist(m)));
end;

