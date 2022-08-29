function dall=disp1d_alt(l1,l2,parms,pivparms)
% Usage ... ldisp=disp1d_alt(l1,l2,parms,pivparms)	
%
% parms=[thrf]  (e.g. [1.25])
% pivparms=[xctype multitype subpixflag]  (e.g. [1 3 0])


bthrf=parms(1);		% 1.25
pparms=pivparms;
linedim=length(l1);
bthr=mean(l1)+bthrf*std(l1);

  % call this default
  tmp1=l1;
  tmp2=l2;
  d0=simple_piv(tmp1,tmp2,pparms);
  
  % lets try some filtering and recompute
  tmpf1=real(smooth1d(tmp1,1));
  tmpf2=real(smooth1d(tmp2,1));
  d0f=simple_piv(tmpf1,tmpf2,pparms);

  % lets binarize and recompute
  tmpb1=double(tmp1>bthr); 
  tmpb2=double(tmp2>bthr);
  if (sum(tmpb1)>0)&(sum(tmpb2)>0)
    d0b=simple_piv(tmpb1,tmpb2,pparms);
  else
    d0b=0;
  end;
  tmpb1=double(tmpf1>bthr);
  tmpb2=double(tmpf2>bthr);
  if (sum(tmpb1)>0)&(sum(tmpb2)>0)
    d0fb=simple_piv(tmpb1,tmpb2,pparms);
  else,
    d0fb=0;
  end;

dall=[d0(:) d0f(:) d0b(:) d0fb(:)];
if (mean(mean(dall))>0.5*linedim),
  dall=linedim-dall;
end;

