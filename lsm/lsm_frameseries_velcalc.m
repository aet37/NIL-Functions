function [dxy,dxy0]=lsm_frameseries_velcalc(fname,parms)
% Usage ... dxy=lsm_frameseries_velcalc(fname,parms)
%
% parms=[s2nl]

if isstr(fname),
  disp(sprintf('  reading %s',fname));
  a=tiffread2c(fname);
else,
  a=fname;
end;

s2nm=2;
s2nl=parms;

if (~exist('a.data')),
  if (~isempty(a(1).red)),
  for mm=2:length(a),
    [dxy.red(mm-1),dxy.red_res(mm-1,:)]=urapiv3(double(a(mm-1).red),double(a(mm).red),s2nm,s2nl);
  end;
  else,
    dxy.red=[];
  end;

  if (~isempty(a(1).green)),
  for mm=2:length(a),
    [dxy.green(mm-1),dxy.green_res(mm-1,:)]=urapiv3(double(a(mm-1).green),double(a(mm).green),s2nm,s2nl);
  end;
  else,
    dxy.green=[];
  end;

  if (~isempty(a(1).blue)),
  for mm=2:length(a),
    [dxy.blue(mm-1),dxy.blue_res(mm-1,:)]=urapiv3(double(a(mm-1).blue),double(a(mm).blue),s2nm,s2nl);
  end;
  else,
    dxy.blue=[];
  end;

else,

  for mm=2:length(a),
    [dxy.data(mm-1),dxy.data_res(mm-1,:)]=urapiv3(double(a.data(:,mm-1)),double(a.data(:,mm)),s2nm,s2nl);
  end;

end;


