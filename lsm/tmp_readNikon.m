function y=tmp_readNikon(froot,nn,cc,parms)
% Usage ... y=tmp_readNikon(froot,nn,cc,parms)

if ~exist('parms','var'), parms(1)=length(num2str(max(nn))); end;

if length(nn)==2, nn=[nn(1):nn(2)]; end;

for mm=1:length(nn),
  if parms(1)==3,
    tmpname=sprintf('%sT%03dC%d.tif',froot,nn(mm),cc);
  else,
    tmpname=sprintf('%sT%04dC%d.tif',froot,nn(mm),cc);
  end;
  %disp(sprintf('  accessing %s',tmpname));
  y(:,:,mm)=imread(tmpname);
  %y(:,:,mm)=readOIS3(tmpname);
end;

