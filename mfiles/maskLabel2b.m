function y=maskLabel2b(iNA,tc1,iV,rr,nV)
% Usage ... y=maskLabel2b(iNA,tc1,iV,rr,nV)
%
% Specific function that returns overall average time series
% associated with each particular vessel label from maskLabel2

% the number of id'ed vessels are nV.a+nV.c+nV+.v or length(iNA.nX)
% the particular vessel type are ordered in nV.Xi

for mm=1:length(iNA.nN1),
  if iNA.nN1(mm)>0,
    tcN1all{mm}=tc1(:,iNA.iN1{mm});
    tcN1{mm}=mean(tc1(:,iNA.iN1{mm}),2);
  else,
    tcN1{mm}=[];
  end;
end;
if ~exist('tcN2all'), tcN1all=[]; end;

for mm=1:length(iNA.nN2),
  if iNA.nN2(mm)>0,
    tcN2all{mm}=tc1(:,iNA.iN2{mm});
    tcN2{mm}=mean(tc1(:,iNA.iN2{mm}),2);
  else,
    tcN2{mm}=[];
  end;
end;
if ~exist('tcN2all'), tcN2all=[]; end;

for mm=1:length(iNA.nA1),
  if iNA.nA1(mm)>0,
    tcA1all{mm}=tc1(:,iNA.iA1{mm});
    tcA1{mm}=mean(tc1(:,iNA.iA1{mm}),2);
  else,
    tcA1{mm}=[];
  end;
end;
if ~exist('tcA1all'), tcA1all=[]; end;

for mm=1:length(iNA.nA2),
  if iNA.nA2(mm)>0,
    tcA2all{mm}=tc1(:,iNA.iA2{mm});
    tcA2{mm}=mean(tc1(:,iNA.iA2{mm}),2);
  else,
    tcA2{mm}=[];
  end;
end;
if ~exist('tcA2all'), tcA2all=[]; end;

if nargin>3,
if length(iV.a)>0,
  for mm=1:length(iV.a),
    rr_a_all{mm}=rr(:,iV.a{mm});
    rr_a{mm}=mean(rr(:,iV.a{mm}),2);
  end;
else,
  rr_a_all{mm}=[];
  rr_a{mm}=[];
end; 

if length(iV.c)>0,
  for mm=1:length(iV.c),
    rr_c_all{mm}=rr(:,iV.c{mm});
    rr_c{mm}=mean(rr(:,iV.c{mm}),2);
  end;
else,
  rr_c_all{mm}=[];
  rr_c{mm}=[];
end;

if length(iV.v)>0,
  for mm=1:length(iV.v),
    rr_v_all{mm}=rr(:,iV.v{mm});
    rr_v{mm}=mean(rr(:,iV.v{mm}),2);
  end;
else,
  rr_v_all{mm}=[];
  rr_v{mm}=[];
end;
end;

if nargin>4,
  nv=nV.a+nV.c+nV.v;
  nv2=length(iNA.nN1);
  if nv~=nv2, warning('  problem matching the labeled vessels with their number...'); end;
  tmpsum1=0; tmpsum2=0; tmpsum3=0; tmpsum4=0;
  tmpcnt1=0; tmpcnt2=0; tmpcnt3=0; tmpcnt4=0;
  tcN1_a=[]; tcN2_a=[]; tcA1_a=[]; tcA2_a=[];
  for mm=1:length(nV.ai),
    if ~isempty(tcN1{nV.ai{mm}}), tcN1_a=[tcN1_a tcN1{nV.ai{mm}}]; end;
    if sum(tcN1{nV.ai{mm}})>0, tmpsum1=tmpsum1+tcN1{nV.ai{mm}}; tmpcnt1=tmpcnt1+1; end;
    if ~isempty(tcN2{nV.ai{mm}}), tcN2_a=[tcN2_a tcN2{nV.ai{mm}}]; end;
    if sum(tcN2{nV.ai{mm}})>0, tmpsum2=tmpsum2+tcN2{nV.ai{mm}}; tmpcnt2=tmpcnt2+1; end;
    if ~isempty(tcA1{nV.ai{mm}}), tcA1_a=[tcA1_a tcA1{nV.ai{mm}}]; end;
    if sum(tcA1{nV.ai{mm}})>0, tmpsum3=tmpsum3+tcA1{nV.ai{mm}}; tmpcnt3=tmpcnt3+1; end;
    if ~isempty(tcA2{nV.ai{mm}}), tcA2_a=[tcA2_a tcA2{nV.ai{mm}}]; end;
    if sum(tcA2{nV.ai{mm}})>0, tmpsum4=tmpsum4+tcA2{nV.ai{mm}}; tmpcnt4=tmpcnt4+1; end;
  end;
  if tmpcnt1, tcN1_a_avg=tmpsum1/tmpcnt1; else, tcN1_a_avg=0; end;
  if tmpcnt2, tcN2_a_avg=tmpsum2/tmpcnt2; else, tcN2_a_avg=0; end;
  if tmpcnt3, tcA1_a_avg=tmpsum3/tmpcnt3; else, tcA1_a_avg=0; end;
  if tmpcnt4, tcA2_a_avg=tmpsum4/tmpcnt4; else, tcA2_a_avg=0; end;
  tmpsum1=0; tmpsum2=0; tmpsum3=0; tmpsum4=0;
  tmpcnt1=0; tmpcnt2=0; tmpcnt3=0; tmpcnt4=0; 
  tcN1_c=[]; tcN2_c=[]; tcA1_c=[]; tcA2_c=[];
  for mm=1:length(nV.ci),
    if ~isempty(tcN1{nV.ci{mm}}), tcN1_c=[tcN1_c tcN1{nV.ci{mm}}]; end;
    if sum(tcN1{nV.ci{mm}})>0, tmpsum1=tmpsum1+tcN1{nV.ci{mm}}; tmpcnt1=tmpcnt1+1; end;
    if ~isempty(tcN2{nV.ci{mm}}), tcN2_c=[tcN2_c tcN2{nV.ci{mm}}]; end;
    if sum(tcN2{nV.ci{mm}})>0, tmpsum2=tmpsum2+tcN2{nV.ci{mm}}; tmpcnt2=tmpcnt2+1; end;
    if ~isempty(tcA1{nV.ci{mm}}), tcA1_c=[tcA1_c tcA1{nV.ci{mm}}]; end;
    if sum(tcA1{nV.ci{mm}})>0, tmpsum3=tmpsum3+tcA1{nV.ci{mm}}; tmpcnt3=tmpcnt3+1; end;
    if ~isempty(tcA2{nV.ci{mm}}), tcA2_c=[tcA2_c tcA2{nV.ci{mm}}]; end;
    if sum(tcA2{nV.ci{mm}})>0, tmpsum4=tmpsum4+tcA2{nV.ci{mm}}; tmpcnt4=tmpcnt4+1; end;
  end;
  if tmpcnt1, tcN1_c_avg=tmpsum1/tmpcnt1; else, tcN1_c_avg=0; end;
  if tmpcnt2, tcN2_c_avg=tmpsum2/tmpcnt2; else, tcN2_c_avg=0; end;
  if tmpcnt3, tcA1_c_avg=tmpsum3/tmpcnt3; else, tcA1_c_avg=0; end;
  if tmpcnt4, tcA2_c_avg=tmpsum4/tmpcnt4; else, tcA2_c_avg=0; end;
  tmpsum1=0; tmpsum2=0; tmpsum3=0; tmpsum4=0;
  tmpcnt1=0; tmpcnt2=0; tmpcnt3=0; tmpcnt4=0;
  tcN1_v=[]; tcN2_v=[]; tcA1_v=[]; tcA2_v=[];
  for mm=1:length(nV.vi),
    if ~isempty(tcN1{nV.vi{mm}}), tcN1_v=[tcN1_v tcN1{nV.vi{mm}}]; end;
    if sum(tcN1{nV.vi{mm}})>0, tmpsum1=tmpsum1+tcN1{nV.vi{mm}}; tmpcnt1=tmpcnt1+1; end;
    if ~isempty(tcN2{nV.vi{mm}}), tcN2_v=[tcN2_v tcN2{nV.vi{mm}}]; end;
    if sum(tcN2{nV.vi{mm}})>0, tmpsum2=tmpsum2+tcN2{nV.vi{mm}}; tmpcnt2=tmpcnt2+1; end;
    if ~isempty(tcA1{nV.vi{mm}}), tcA1_v=[tcA1_v tcA1{nV.vi{mm}}]; end;
    if sum(tcA1{nV.vi{mm}})>0, tmpsum3=tmpsum3+tcA1{nV.vi{mm}}; tmpcnt3=tmpcnt3+1; end;
    if ~isempty(tcA2{nV.vi{mm}}), tcA2_v=[tcA2_v tcA2{nV.vi{mm}}]; end;
    if sum(tcA2{nV.vi{mm}})>0, tmpsum4=tmpsum4+tcA2{nV.vi{mm}}; tmpcnt4=tmpcnt4+1; end;
  end;
  if tmpcnt1, tcN1_v_avg=tmpsum1/tmpcnt1; else, tcN1_v_avg=0; end;
  if tmpcnt2, tcN2_v_avg=tmpsum2/tmpcnt2; else, tcN2_v_avg=0; end;
  if tmpcnt3, tcA1_v_avg=tmpsum3/tmpcnt3; else, tcA1_v_avg=0; end;
  if tmpcnt4, tcA2_v_avg=tmpsum4/tmpcnt4; else, tcA2_v_avg=0; end;
  clear tmp*
end;

y.tcN1=tcN1;
y.tcN2=tcN2;
y.tcA1=tcA1;
y.tcA2=tcA2;
y.tcN1_all=tcN1all;
y.tcN2_all=tcN2all;
y.tcA1_all=tcA1all;
y.tcA2_all=tcA2all;

if nargin>2,
y.rr_a=rr_a;
y.rr_c=rr_c;
y.rr_v=rr_v;
y.rr_a_all=rr_a_all;
y.rr_c_all=rr_c_all;
y.rr_v_all=rr_v_all;
end;

if nargin>4,
y.tcN1_a=tcN1_a;
y.tcN1_c=tcN1_c;
y.tcN1_v=tcN1_v;
y.tcN2_a=tcN2_a;
y.tcN2_c=tcN2_c;
y.tcN2_v=tcN2_v;
y.tcA1_a=tcA1_a;
y.tcA1_c=tcA1_c;
y.tcA1_v=tcA1_v;
y.tcA2_a=tcA2_a;
y.tcA2_c=tcA2_c;
y.tcA2_v=tcA2_v;
y.tcN1_a_avg=tcN1_a_avg;
y.tcN1_c_avg=tcN1_c_avg;
y.tcN1_v_avg=tcN1_v_avg;
y.tcN2_a_avg=tcN2_a_avg;
y.tcN2_c_avg=tcN2_c_avg;
y.tcN2_v_avg=tcN2_v_avg;
y.tcA1_a_avg=tcA1_a_avg;
y.tcA1_c_avg=tcA1_c_avg;
y.tcA1_v_avg=tcA1_v_avg;
y.tcA2_a_avg=tcA2_a_avg;
y.tcA2_c_avg=tcA2_c_avg;
y.tcA2_v_avg=tcA2_v_avg;
end;

