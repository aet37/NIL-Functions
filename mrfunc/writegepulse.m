function f=writegepulse(filename,pulse)
% Usage ... f=writegepulse(filename,pulse)

plotpulse=0;

% get stuff in right order
MAX_SHORT=32766;
if ((max(pulse)>MAX_SHORT)|(max(pulse)<=1.0)),
  disp(' fixing pulse for ge scanner...');
  pulse=2*round(pulse*MAX_SHORT/(2*max(pulse)));
  disp(' adding odd number at end ');
  pulse(end+1)=pulse(end)+1;
  plotpulse=1;
end;

fid=fopen(filename,'w','b');
if (fid<3),
  error('Could not open file for writing!');
end;
fwrite(fid,pulse,'short');
fclose(fid);

if plotpulse,
  plot(pulse)
end;
 
