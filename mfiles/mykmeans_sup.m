function y=mykmeans_sup(ks,data,labelim,tthr)
% Usage ... y=mykmeans_sup(ks,data,labelim,tthr)

do_tthr=0;
if exist('tthr'), do_tthr=1; end;

data=squeeze(data);

if length(size(data))==2,
  disp('  currently not available to 2D data sets');
  %if length(ks)==1,
  %  for mm=1:size(ks.xm,2),
  %    cntin=0; cntout=0;
  %    tmpcc=corr(data,ks.xm(:,1)); 
else,
  if length(ks)==1,
    for mm=1:size(ks.xm,2),
      cntin=0; cntout=0;
      tmprim=OIS_corr2(data,ks.xm(:,mm));
      tmpdof=length(ks.xm(:,mm))-length(ks.ki{mm})-2;  %tmpdof=(size(data,3)-2)/length(ks.ki{mm});
      if tmpdof<=3, if length(ks.ki)>3, tmpdof=length(ks.ki); else, tmpdof=3; end; end;
      rim(:,:,mm)=tmprim;
      for nn=1:max(labelim(:)),
        rav(nn,mm)=mean(tmprim(find(labelim==nn)));
        tav(nn,mm)=r2t(rav(nn,mm),tmpdof);
        tmpi=find(ks.ki{mm}==nn);
        if isempty(tmpi),
          cntout=cntout+1;
          kr_out{mm}(cntout)=rav(nn,mm);
          kt_out{mm}(cntout)=tav(nn,mm);
        else,
          cntin=cntin+1;
          kr_in{mm}(cntin)=rav(nn,mm);
          kt_in{mm}(cntin)=tav(nn,mm);
        end;
      end;
      if do_tthr,
        ktf_in(mm)=sum(kt_in{mm}>tthr)/length(kt_in{mm});
        ktf_out(mm)=sum(kt_out{mm}>tthr)/length(kt_out{mm});
      end;
    end;

    y.rim=rim;
    y.rval=rav;
    y.kr_in=kr_in;
    y.kr_out=kr_out;
    y.tval=tav;
    y.kt_in=kt_in;
    y.kt_out=kt_out;
    if do_tthr,
      y.ktf_in=ktf_in;
      y.ktf_out=ktf_out;
    end;

  else,
    
    for nk=1:length(ks),  
      for mm=1:size(ks{nk}.xm,2),
        cntin=0; cntout=0;
        tmprim=OIS_corr2(data,ks{nk}.xm(:,mm));
        rim(:,:,mm)=tmprim;
        tmpdof=length(ks{nk}.xm(:,mm))-length(ks{nk}.ki{mm})-2;  % tmpdof=(size(data,3)-2)/length(ks{nk}.ki{mm});
        if tmpdof<=3, if length(ks{nk}.ki)>3, tmpdof=length(ks{nk}.ki); else, tmpdof=3; end; end;

        if size(labelim,3)>1, tmplabelim=labelim(:,:,nk); else, tmplabelim=labelim; end;  % check mykdecomp
        for nn=1:max(tmplabelim(:)),
          rav(nn,mm)=mean(tmprim(find(tmplabelim==nn)));
          tav(nn,mm)=r2t(rav(nn,mm),tmpdof);
          tmpi=find(ks{nk}.ki{mm}==nn);
          if isempty(tmpi),
            cntout=cntout+1;
            kr_out{mm}(cntout)=rav(nn,mm);
            kt_out{mm}(cntout)=tav(nn,mm);
          else,
            cntin=cntin+1;
            kr_in{mm}(cntin)=rav(nn,mm);
            kt_in{mm}(cntin)=tav(nn,mm);
          end;
        end;
        if do_tthr,
          ktf_in(mm)=sum(kt_in{mm}>tthr)/length(kt_in{mm});
          ktf_out(mm)=sum(kt_out{mm}>tthr)/length(kt_out{mm});
        end;
      end;

      y{nk}.rim=rim;
      y{nk}.rval=rav;
      y{nk}.kr_in=kr_in;
      y{nk}.kr_out=kr_out;
      y{nk}.tval=tav;
      y{nk}.kt_in=kt_in;
      y{nk}.kt_out=kt_out;
      if do_tthr,
        y{nk}.ktf_in=ktf_in;
        y{nk}.ktf_out=ktf_out;
      end;
    
      clear rim rav tmpi tmpdof kr* kt* ktf*
    end;
  end; 
end;

if (nargout==0)&(length(size(data))>2),
  for mm=1:length(ks),
    figure(1), clf,
    tile3d(y{mm}.rim)
    xlabel(num2str(mm))
    drawnow,
    figure(2), clf,
    plot(ks{mm}.xm)
    xlabel(num2str(mm))
    drawnow,
    pause,
  end;
end;

