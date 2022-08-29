function [z_under,z_over]=fast_detect2(tc,baserange,underrange,overrange)
% Usage ... [z_under,z_over]=fast_detect2(tc,baserange,underrange,overrange)
%
% f is either 0 (not found) or 1 (found).

PREC=3;

baseline=tc(baserange(1):baserange(2));
base_mean=mean(baseline);
base_std=std(baseline);

tc_tmp=(tc-base_mean)./base_mean;

baseline_tmp=tc_tmp(baserange(1):baserange(2));
base_mean_tmp=mean(baseline_tmp);
base_std_tmp=std(baseline_tmp);

z_under=mean(tc_tmp(underrange(1):underrange(2)))/base_std_tmp;

z_over=mean(tc_tmp(overrange(1):overrange(2)))/base_std_tmp;

if nargout==0,
  disp(['z-under: ',int2str(z_under)]);
  disp(['z-over.: ',int2str(z_over)]);
  plot(tc_tmp);
  text(1,.9*max(tc_tmp),['Mean: ',num2str(base_mean_tmp,4)]);
  text(1,.8*max(tc_tmp),['Stdv: ',num2str(base_std_tmp,4)]);
end;
