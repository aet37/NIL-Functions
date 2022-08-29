function out=asgnrctv(mask,value)
%
% Usage ... out=asgnrctv(mask,value)
%
% Assign a rectangle value to an image by clicking on
% both extreme coordinates where the value will be 
% assigned. The new mask will be returned;
%
%

show(mask);
xlabel('Click two rectangle coordinates');

true=1;

while (true),
x=round(ginput(2));
for n=x(1,2):x(2,2), for m=x(1,1):x(2,1),
  mask(n,m)=value;
end; end;
show(mask);
true=input('Assign another rectangle value (0-exit): ');
end;

out=mask;

