function fout=vefvol(t,fin,parms)
% Usage ... fout=vefvol(t,fin,parms)

% vessel elastic behavior can be approximated by linear system
% for example... step flow-in ->  exp(-t/tau) flow-out
% the physical dynamic behavior being that volume in the compartment
% changes and it in turn changes the out-flow
% fout(t)=[1-exp(-t/tau)]fin(t)
% dv(t)/dt=fin(t)-fout(t)=fin(t)*exp(-t/tau)

% however, this occurs in experimental settings where they have a
% vessel and a controlled input function. we can use the similar
% values, however we want to capture differences from the arterial
% to the venous side so we can probably do this by changing time-
% constants for in and out. 

diff_ifin=diff(fin>1);
stims=find(diff_ifin==1)+1;


