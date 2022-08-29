function [po2mmHg,po2mmHg2]=po2cal2(po2curr,o2,o2curr,po2tc)
% Usage ... [po2mmHg]=po2cal2(po2curr,o2,o2curr,po2tc)

% should account for probe solution vs. medium solution (K)
% also for temperature differences and water vapor pressure in solution

%o2=[0 20.8 100];
%o2curr=[0.082 0.347 1.256];

if nargin<4,
  po2deconv_flag=0;
else,
  po2deconv_flag=1;
end;

p_atm=761;
p_wvapor=47;

o2mm=(o2/100)*(p_atm-p_wvapor);
o2fit=polyfit(o2curr,o2mm,1);

o2des=[25 40 60 75];
po2des=polyval(o2fit,o2des);

if (length(po2curr)==prod(size(po2curr))),
  po2mmHg=polyval(o2fit,po2curr);
else,
  for mm=1:size(po2curr,2),
    po2mmHg(:,mm)=polyval(o2fit,po2curr(:,mm));
  end;
end;

if po2deconv_flag,
  if length(po2tc)>2,
    ts=po2tc(2); fnco=po2tc(3); 
    po2fn=round(fnco*length(po2mmHg)*ts);
  elseif length(po2tc)>1,
    ts=po2tc(2); fnco=[]; po2fn=[];
  else,
    ts=0.001; fnco=5;
    po2fn=round(fnco*length(po2mmHg)*ts);
  end;
  po2hh=([1:length(po2mmHg)]-1)*ts;
  po2hh=exp(-(po2hh-po2hh(1))/po2tc(1));
  disp(sprintf('  deconvolving temporal response: tau= %f, fNco= %f',po2tc(1),po2fn));
  if (length(po2curr)==prod(size(po2curr))),
    po2bb=po2mmHg(1);
    if (size(po2curr,2)==1), po2hh=po2hh(:); end;
    po2mmHgdeconv=fdeconv(po2mmHg-po2bb,po2hh,po2fn)+po2bb;
  else,
    for mm=1:size(po2curr,2),
      po2bb(mm)=po2mmHg(1,mm);
      po2mmHgdeconv(:,mm)=fdeconv(po2mmHg(:,mm)-po2bb(mm),po2hh(:),po2fn)+po2bb(mm);
    end;
  end;
end;


if (nargout==0),
  if (po2deconv_flag),
    %plot([po2mmHg(:) po2mmHgdeconv(:)])
    plot([po2mmHgdeconv(:)])
    po2mmHg2=po2mmHg;
    po2mmHgdeconv=po2mmHg;
  else,
    plot([po2mmHg(:)])
  end;
  ylabel('Calc. pO2 (mmHg)'),
  clear po2mmHg
  [o2des(:) po2des(:)],
else,
  if po2deconv_flag,
    po2mmHg2=po2mmHg;
    po2mmHg=po2mmHgdeconv;
  end;
end;

