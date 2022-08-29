function yi=getyenv(x,thr,interp_flag)
% Usage ... y=getyenv(x,thr,interp_flag)

if nargin<3, interp_flag=0; end;

x=x(:);
yii=find(x>thr);
yi2=[1;find(diff(yii)>1)+1;length(yii)];
cnt=0;
for mm=1:length(yi2)-1,
  tmpx=x(yii(yi2(mm)):yii(yi2(mm+1)-1));
  if ~isempty(tmpx),
    cnt=cnt+1;
    tmpxi(mm,:)=[yi2(mm) yi2(mm+1)-1]; 
    [tmpe,tmpei]=max(tmpx);
    ye(cnt)=tmpe; yei(cnt)=yii(yi2(mm)+tmpei-1);
  end;
end;

if interp_flag,
  yi=interp1(yei,ye,[1:length(x)]);
else,
  yi=[ye(:) yei(:)];
end;

if nargout==0,
  plot(yei,ye)
end;

