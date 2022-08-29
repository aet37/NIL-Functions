function [dxy,dxy0]=lsm_linescan_velcalc(fname,parms)
% Usage ... dxy=lsm_linescan_velcalc(fname,parms)
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
  if (~isempty(a.red)),
  for mm=2:a.height,
    [dxy.red(mm-1),dxy.red_res(mm-1)]=urapiv4(double(a.red(:,mm-1)),double(a.red(:,mm)),s2nm,s2nl);
    dxy.red0(mm-1)=simple_piv(double(a.red(:,mm-1)),double(a.red(:,mm)));
  end;
  dxy.redg=g_distance(double(a.red));
  else,
    dxy.red=[];
    dxy.red0=[];
  end;

  if (~isempty(a.green)),
  for mm=2:a.height,
    [dxy.green(mm-1),dxy.green_res(mm-1)]=urapiv4(double(a.green(:,mm-1)),double(a.green(:,mm)),s2nm,s2nl);
    dxy.green0(mm-1)=simple_piv(double(a.green(:,mm-1)),double(a.green(:,mm)));
  end;
  dxy.greeng=g_distance(double(a.green));
  else,
    dxy.green=[];
    dxy.green0=[];
  end;

  if (~isempty(a.blue)),
  for mm=2:a.height,
    [dxy.blue(mm-1),dxy.blue_res(mm-1)]=urapiv4(double(a.blue(:,mm-1)),double(a.blue(:,mm)),s2nm,s2nl);
    dxy.blue0(mm-1)=simple_piv(double(a.blue(:,mm-1)),double(a.blue(:,mm)));
  end;
  dxy.blueg=g_distance(double(a.blue));
  else,
    dxy.blue=[];
    dxy.blue0=[];
  end;

else,

  for mm=2:a.height,
    [dxy.data(mm-1),dxy.data_res(mm-1)]=urapiv4(double(a.data(:,mm-1)),double(a.data(:,mm)),s2nm,s2nl);
    dxy.data0(mm-1)=simple_piv(double(a.data(:,mm-1)),double(a.data(:,mm)));
  end;
  dxy.datag=g_distance(double(a.data));

end;


