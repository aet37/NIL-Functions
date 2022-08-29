function f=tri(t,w,lag)
% Function f=tri(t,w,lag) = Tri((t-lag)/w)
%
% w is the triangle waveform width
% lag is the center location of the triangle
% if lag is a vector, multiple triangles will be generated

f=zeros(size(t));
for mm=1:length(lag),
  f=f+(1-abs((t-lag(mm))/w)).*rect(t,2*w,lag(mm));
end;  

if nargout==0,
  plot(t,f)
end;
