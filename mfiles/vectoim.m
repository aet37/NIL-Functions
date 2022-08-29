function y=vectoim(a,f)
% usage .. vectoim(a,f);
% displays matrix "a" is a string that names the input file
% and "f" is the row size - default is sqrt(length(a))

h = length(a);
if exist('f') == 0, 
  f = floor(sqrt(h));
end
g = floor(h/f);
y = zeros([f g]);
for lp=1:g,
  y(:,lp) = a(((lp-1)*f + 1):(lp*f));
end
