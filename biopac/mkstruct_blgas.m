function bloodgas=mkstruct_blgas(expdate,exptime,temp,pH,pCO2,pO2,SO2,Hct,Hb,pETCO2)
% Usage ... y=mkstruct_blgas(expdate,exptime,temp,pH,pCO2,pO2,SO2,Hct,Hb,pETCO2)
%
% Use pH corrected values if possible

if nargin<10, pETCO2=[]; end;

bloodgas.date=expdate;
bloodgas.time=exptime;
bloodgas.temp=temp;
bloodgas.pH=pH;
bloodgas.pCO2=pCO2;
bloodgas.pO2=pO2;
bloodgas.SO2=SO2;
bloodgas.Hct=Hct;
bloodgas.Hb=Hb;
bloodgas.pETCO2=pETCO2;

