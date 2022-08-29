function y=mykmeans_sup2(ks,tthr,rthr)
% Usage ... y=mykmeans_sup2(ks,tthr,rthr)

do_rthr=0;
do_tthr=1;
if isempty(tthr), do_tthr=0; end;
if exist('rthr','var'), do_rthr=1; end;

if iscell(tthr),
  tmp_pvals=tthr{1};
  tmp_datalen=tthr{2};
  if iscell(ks), tmp_nk=size(ks{1}.rim,3); else, tmp_nk=size(ks.rim,3); end;
  clear tthr
  for mm=1:length(tmp_pvals),
    tthr(mm)=abs(tinv(tmp_pvals(mm)/sqrt(tmp_datalen-2),tmp_nk));
    disp(sprintf('  new t-val %.2f',tthr(mm)));
  end;
end;

for nk=1:length(ks),
  nnk(nk)=size(ks{nk}.rval,2);
  for nn=1:length(tthr),
    for mm=1:length(ks{nk}.kt_in),
      tmpktfin(mm)=sum(ks{nk}.kt_in{mm}>tthr(nn))/length(ks{nk}.kt_in{mm});
      tmpktfout(mm)=sum(ks{nk}.kt_out{mm}>tthr(nn))/length(ks{nk}.kt_out{mm});
      %keyboard,
    end;
    ktf_in(nk,nn).vals=tmpktfin;
    ktf_out(nk,nn).vals=tmpktfout;
    ktf_in_avg(nk,nn)=mean(tmpktfin);
    ktf_out_avg(nk,nn)=mean(tmpktfout);
    ktf_in_std(nk,nn)=std(tmpktfin);
    ktf_out_std(nk,nn)=std(tmpktfout);
    clear tmp*
  end;
  if do_rthr, for nn=1:length(rthr),
    for mm=1:length(ks{nk}.kt_in),
      tmpkrfin(mm)=sum(ks{nk}.kr_in{mm}>rthr(nn))/length(ks{nk}.kr_in{mm});
      tmpkrfout(mm)=sum(ks{nk}.kr_out{mm}>rthr(nn))/length(ks{nk}.kr_out{mm});
      %keyboard,
    end;
    krf_in(nk,nn).vals=tmpkrfin;
    krf_out(nk,nn).vals=tmpkrfout;
    krf_in_avg(nk,nn)=mean(tmpkrfin);
    krf_out_avg(nk,nn)=mean(tmpkrfout);
    krf_in_std(nk,nn)=std(tmpkrfin);
    krf_out_std(nk,nn)=std(tmpkrfout);
    clear tmp*
  end; end;
end;


if do_rthr,
  if do_tthr==0,
    ktf_in=krf_in;
    ktf_out=krf_out;
    ktf_in_avg=krf_in_avg;
    ktf_out_avg=krf_out_avg;
    ktf_in_std=krf_in_std;
    ktf_out_std=krf_out_std;
  end;
  y.krf_in=krf_in;
  y.krf_out=krf_out;
  y.krf_in_avg=krf_in_avg;
  y.krf_out_avg=krf_out_avg;
  y.krf_in_std=krf_in_std;
  y.krf_out_std=krf_out_std;
end;

y.ktf_in=ktf_in;
y.ktf_out=ktf_out;
y.ktf_in_avg=ktf_in_avg;
y.ktf_out_avg=ktf_out_avg;
y.ktf_in_std=ktf_in_std;
y.ktf_out_std=ktf_out_std;


if nargout==0,
  figure(1), clf,
  subplot(211)
  plot(nnk,ktf_in_avg,'b')
  grid('on'),
  xlabel('# k-clusters'), ylabel('Avg Fraction Correct'),
  subplot(212)
  plot(nnk,ktf_out_avg,'r')
  xlabel('# k-clusters'), ylabel('Avg Fraction NOT Correct'),
  grid('on'),

  figure(2), clf,
  tmpx=[min(ktf_out_avg):0.05:max(ktf_out_avg)];
  tmpp=polyfit(ktf_out_avg,ktf_in_avg,2),
  tmpy=polyval(tmpp,tmpx);
  plot(ktf_out_avg,ktf_in_avg,'b-o',tmpx,tmpy,'r--',tmpx(1:end-1),diff(tmpy),'k--')
  xlabel('Avg Fraction NOT Correct'), ylabel('Avg Fraction Correct'),
  axis('tight'), grid('on'),
  title(sprintf('y-int= %.2f (80percent=%.2f)',-tmpp(2)/(2*tmpp(1)),-0.8*tmpp(2)/(2*tmpp(1))));

  %for nn=1:length(tthr),
  %figure(nn), clf,
  %for mm=1:nk,
  %  [tmps,tmpi]=sort(ktf_in(mm,nn).vals);
  %  plot(ktf_out(mm,nn).vals(tmpi),ktf_in(mm,nn).vals(tmpi)),
  %  if mm==1, hold('on'), end;
  %end;
  %hold('off'),
  %setlinecolor(colormap(jet(nk))),
  %end;
end;

