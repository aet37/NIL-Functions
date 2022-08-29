function out = show_d(a,windfact)
% usage .. show_d(a,f);
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
  a = (a  - amin);
  a = a .* (a > 0);
end

colormap(gray);
image((a)./(amax-amin).*64);
axis('xy');
axis('on');
xlabel('Time');
ylabel('Frequency');
grid off;

if nargout==0,
  disp(['min/max= ',num2str(minmax(1)),' / ',num2str(minmax(2))]);
end;
