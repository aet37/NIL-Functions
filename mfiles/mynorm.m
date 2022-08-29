function y=mynorm(x)

nrows=size(x,1);

y=x-repmat(nanmean(x,1),[nrows,1]);
y=y./repmat(nanstd(y,0,1),[nrows,1]);