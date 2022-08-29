function f=ustep(t,t0)
% Usage f=ustep(t,t0)

for m=1:length(t),
  if (t(m)<t0) f(m)=0; else, f(m)=1; end;
end;

