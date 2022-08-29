function t=corr2t(cor,df)
% Usage ... t=corr2t(cor,ft)

t=cor*sqrt(df-2);
t=t./((1-cor.*cor).^(0.5));

ii=find(isinf(t));
if (~isempty(ii)),
  ii2=find(~isinf(t));
  t(ii)=2*max(max(t(ii2)));
  disp(sprintf('  warning: inf detected, substituted with 2*max(t)'));
end;


