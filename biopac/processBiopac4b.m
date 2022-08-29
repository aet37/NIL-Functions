
tmpfname='MOUSE_THY1CHR2B_20180531_SETUP';
tmpvar='dyn1l1p0a';

if ~exist(tmpvar,'var'),
  eval(sprintf('load %s %s',tmpfname,tmpvar));
end;

thrf=3.5;

tmpflux=dyn1l1p0a.FLUX;
tmptb=dyn1l1p0a.TB;
tmptt=[1:length(tmpflux)]*0.001-5;

ii1=[0 4];
ii0=[-4 -1];
ii2=[-4 8];

tmptb=fermi1d(tmptb,0.5,0.1,-1,0.001);
tmpii1=find((tmptt>ii1(1))&(tmptt<ii1(2)));
tmpii0=find((tmptt>ii0(1))&(tmptt<ii0(2)));
tmpii2=find((tmptt>ii2(1))&(tmptt<ii2(2)));

opt1=optimset('fminsearch');

for mm=1:size(tmpflux,2),
  tmpthr=mean(tmptb(tmpii0,mm))+thrf*std(tmptb(tmpii0,mm));
  if tmpthr<0.5*(mean(tmptb(tmpii0,mm))+max(tmptb(tmpii1,mm))),
    tmpstr=sprintf('  resetting thrf from %.3f ',tmpthr);
    tmpthr=0.5*(mean(tmptb(tmpii0))+max(tmptb(tmpii1)));
    tmpstr=sprintf('%s to %.3f ',tmpthr);
    disp(tmpstr);
  end;

  tmpfix=zeros(size(tmpflux,1),1);
  tmpfixi=find(tmptb(:,mm)>tmpthr);
  tmpfixi=tmpfixi(find((tmpfixi>0.95*tmpii1(1))&(tmpfixi<1.05*tmpii1(end))));
  tmpfix(tmpfixi)=1;

  % try two things, straight fix or use TB waveform
  tmpfix1=tmpfix;
  tmpfix2=tmpfix.*tmptb(:,mm);
  tmpfix3=tmpfix; tmpfix3(tmpfixi)=tmpfixi-tmpfixi(1)+1;

  tmpx0=[0 0 0];
  tmpy0=regFilter1(tmpx0,[tmpfix1 tmpfix2 tmpfix3],tmpx0,[1 2 3]);
  
  tmpx=fminsearch(@regFilter1,tmpx0,opt1,[tmpfix1 tmpfix2 tmpfix3],tmpx0,[1 2 3],tmpflux(:,mm));
 
  tmpflux_1 = tmpflux(:,mm) + a*tmpfix1 + b*tmpfix2 + c*tmpfix3;

end;

% function ee=fixPSflux(x0,f,parms,parms2fit,y)
%   if ~isempty(x0),
%     parms(parms2fit)=x0;
%   end;
%   y1=zeros(size(y));
%   for mm=1:size(f,2),
%     y1=y1+parms(mm)*f(:,mm);
%   end;
%   ee=y-y1;
%   if nargin<5,
%     ee=y1;
%   end;
% end;

