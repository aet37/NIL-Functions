function [f,undex_indx,over_indx]=fast_detect(tc,onsetindex,maxfastindex,maxonindex)
% Usage ...[f,undex_indx,over_indx]=fast_detect(tc,onsetindex,maxfastindex,maxonindex)
%
% f is either 0 (not found) or 1 (found).

PREC=3;

baseline=tc(1:onsetindex-1);
base_mean=mean(baseline);
base_std=std(baseline);

tc_tmp=(tc-base_mean)./base_mean;

baseline_tmp=tc_tmp(1:onsetindex-1);
base_mean_tmp=mean(baseline_tmp);
base_std_tmp=std(baseline_tmp);

found1=0;
under_indx=0;
over_indx=0;

for indx=onsetindex:maxfastindex,
  if ((~found1)&(tc_tmp(indx)<0)&(tc_tmp(indx)<(-PREC*base_std_tmp))),
    found1=1;
    under_indx=indx;
  end;
end;

found2=0;

for indx=onsetindex:maxonindex,
  if ((~found2)&(tc_tmp(indx)>0)&(tc_tmp(indx)>(PREC*base_std_tmp))),
    found2=1;
    over_indx=indx;
  end;
end;

f=(found1&found2);

if nargout==0,
  disp(['Under index: ',int2str(under_indx)]);
  disp(['Over index.: ',int2str(over_indx)]);
  plot(tc_tmp);
  text(1,.9*max(tc_tmp),['Mean: ',num2str(base_mean_tmp,4)]);
  text(1,.8*max(tc_tmp),['Stdv: ',num2str(base_std_tmp,4)]);
end;
