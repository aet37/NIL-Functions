function y=imtovec(a,f)
% usage .. imtovec(a,f);
% takes matrix "a" and outputs a column vector

[f g] = size(a);
h = f*g;
y = zeros([h 1]);
for lp=1:g,
  y(((lp-1)*f + 1):(lp*f)) = a(:,lp);
end
