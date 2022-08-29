function yprime=bold2(t,y)
% BOLD model as described by Hathout, et al.
% Mass-balance approach to modeling of changes of
% venous oxyhemoglobin concentrations, based on
% CBF (F), CBV (V) and regional oxygen consumption (Cp).

% Arterial oxygen inflow distributed to tissue consumption
% or to venous outflow. Arterial oxygen concentrations are
% assumed constant (max saturation). 

% Flow, F, is a given waveform
% Initial conditions CpoO2, Fo, ko are known

k=-1*log(1-((CpO2/CpoO2)/(F/Fo))*(1-exp(-ko)));
CpO2=F*O2a*(1-exp(-k));
O2v=O2vo*(exp(-k)/exp(-ko));

intgrl1=exp(wo*trapz((F(1:t_indx)/Fo)./(V(1:t_indx)/Vo),t_vec(1:t_indx)));
intgrl2=trapz(intgrl1*(F(1:t_indx)/Fo).*(O2pv(1:t_indx)/O2vo));
O2v=O2vo*(wo*intgrl2+1)/((V/Vo)*intgrl1)l

% Figure this into differential form for MATLAB.


