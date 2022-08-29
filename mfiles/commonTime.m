function ys=commonTime(tt,y1,t1,y2,t2,parms)
% Usage ... ys=commonTime(tt,y1,t1,y2,t2,parms);
%
% Linearly interpolate y1 and y2 to be in time tt
% Use parameters parms = [int_type trig_flag]
% 
% Ex. ys=commonTime(tt_ldf,ldf,tt_ldf,ois,tt_ois);
% Ex. ys=commonTime(tt_ldf,cam_data,cam_trig,ldf,tt_ldfraw,[1 1]);


if nargin<6, parms=[]; end;
if isempty(parms), parms=[1 0]; end;

int_type=parms(1);
trig_flag=parms(2);
trig_flag=1;

if isempty(tt),
  mint=min([t1(:);t2(:)]);
  maxt=max([t2(:);t2(:)]);
  dt=mean([diff(t1(:));diff(t2(:))]);
  tt=[mint:dt:maxt];
  tt=tt(:);
end;

if (length(t1)==length(t2))&(length(y1)~=length(y2))&(trig_flag),
  tmpii=getTrigLoc(t1,3,1,1);
  tmpii=cell2mat(tmpii);
  t1=t2(tmpii(1:length(y1)));
end;

if length(t1)~=length(y1),
  disp('  warning: unequal lengths for y1, adjusting t1...');
  t1=t1(1:length(y1));
end;
if length(t2)~=length(y2),
  disp('  warning: unequal lengths for y2, adjusting t2...');
  t2=t2(1:length(y2));
end;

if int_type==1,
  if prod(size(y1))>length(y1),
    for nn=1:size(y1,2),
      y1i(:,nn)=interp1(t1(:),y1(:,nn),tt(:));
      y2i(:,nn)=interp1(t2(:),y2(:,nn),tt(:));
    end;
  else,
    y1i=interp1(t1(:),y1(:),tt(:));
    y2i=interp1(t2(:),y2(:),tt(:));
  end;
end;

n1=find(isnan(y1i));
n2=find(isnan(y2i));

% need to complete
if (length(n1)>0)|(length(n2)>0),
  disp('  warning: NaNs found');
  nni=sum(isnan(y1i)+isnan(y2i),2);
  y1i=y1i(find(nni==0),:);
  y2i=y2i(find(nni==0),:);
  tt=tt(find(nni==0));
  disp(sprintf('          %d of %d remain',length(tt),length(nni)));
  %if n1(1)==1,
  %  n1d=diff(n1);
  %  n1di=find(n1d>1);
  %  if isempty(n1di),
  %    %
  %  else,
  %    %
  %  end;
  %end;
end;

ys.y1=y1i;
ys.y2=y2i;
ys.tt=tt;
ys.y1_orig=y1;
ys.t1_orig=t1;
ys.y2_orig=y2;
ys.t2_orig=t2;
ys.not_i={n1,n2};
