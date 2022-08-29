function f=mlfilt(x,tc,parmlist)
% usage ... f=mlfilt(x,tc,parmlist)
%

tc=tc(:);
x_sol=multreg(x,tc);
parmlist=parmlist(:);

f=0;
for m=1:length(parmlist),
  f=f+tc-x_sol(parmlist(m))*x(m,:);
end;

