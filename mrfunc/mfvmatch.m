function fout=mfvmatch(y)
% Usage ... fout=mfvmatch(y)
%
% Matches the inflow by a volume to flow relationship
% to determine the outflow.

% Temporary fix for now
%fout=4.*fin-3;	% Linear
fout=(1/100)*(10.^((y(:,2)-1)/.2)-1)+1;	% Exponential
%fout=hister1(y(2),tau,amplitude,vmax,in_out);	% Nonlinear

  
