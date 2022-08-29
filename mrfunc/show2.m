function out = show(a,windfact)
% usage .. show(a,f);
% displays matrix "a" as a greyscale image in the matlab window
% and "f" is the optional window factors [min,max]

if exist('windfact') == 0, 
  amin = min(min(a));
  amax = max(max(a));
  minmax = [amin,amax];
  a = (a  - amin);
else
  amin = windfact(1);
  amax = windfact(2);
  minmax = windfact;
  a = (a  - amin);
  a = a .* (a > 0);
end

colormap(gray);
imagesc(a);
colorbar,
axis('image');
axis('on');
grid on;

if nargout==0,
  disp(['min/max= ',num2str(minmax(1)),' / ',num2str(minmax(2))]);
end;
