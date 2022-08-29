function dvol=analyze_diff(droot,froot,nvols,info)
% Usage ... y=calcdiff(droot,froot,nvols,info)

dvol=zeros([info(1:3)]);

for m=1:nvols,
  disp(sprintf('Calculating pair # %d',m));
  vol1=getanalyzevol([droot,'/',froot],m,info);
  vol2=getanalyzevol([droot,'diff/',froot],m,info);
  dvol=dvol+(vol1-vol2);
end;
dvol=(1/nvols)*dvol;

