function [xy,xy_rep]=mycentroid(im)
% Usage ... xy=mycentroid(im)

bin_im=abs(im)>0;
[ii,jj]=find(bin_im);
%iii=find(bin_im);
if (sum(sum(im))~=sum(sum(bin_im))),
  %ww=abs(im(iii));
  %ii_w=ii.*ww;
  %jj_w=jj.*ww;
  %xy=[sum(ii) sum(jj)]/sum(ww);
  wc=100;
  imamax=max(max(abs(im)));
  ii_origlen=length(ii);
  wcnt2=0;
  for mm=1:ii_origlen,
    wcnt=round(wc*abs(im(ii(mm),jj(mm)))/imamax);
    %disp(sprintf(' (%d,%d): %f %f %d',mm,ii_origlen,abs(im(ii(mm),jj(mm))),imamax,wcnt));
    wcnt2=wcnt2+wcnt;
    if (wcnt>0),
      ii(mm)=ii(mm)*wcnt;
      jj(mm)=jj(mm)*wcnt;
    end;
  end;
  xy=[sum(ii) sum(jj)]/(ii_origlen+wcnt2);
  %disp(sprintf('  calculated centroid by weighting (%d,%d,%d,%d)',wc,ii_origlen,length(ii),wc2));
else,
  xy=[mean(ii) mean(jj)];
end;
cen_im=zeros(size(bin_im));
cen_im(round(xy(1)),round(xy(2)))=1;

testi=find((cen_im+bin_im)==2);
inobject_flag=0;
if isempty(testi)&inobject_flag,
  dd=sqrt((ii-xy(1)).^2 + (jj-xy(2)).^2);
  [dd_min,dd_mini]=min(dd);
  xy_rep=[ii(dd_mini) jj(dd_mini)];
  disp(sprintf('  warning: centroid outside object, replacing ([%.2f,%.2f] to [%.2f,%.2f])',xy(1),xy(2),xy_rep(1),xy_rep(2)));
  xy=xy_rep;
else,
  xy_rep=xy;
end;

