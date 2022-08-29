function [t,df]=myttest2(a,b)
% Usage ... [t,df]=myttest2(a,b)
%
% mean and variance will be estimated from the last dimmension

if nargin==1,
  if iscell(a),
    if length(a{1})==3,
      for mm=1:length(a),
        am(mm)=a{mm}(1);
        as(mm)=a{mm}(2);
        an(mm)=a{mm}(3);
      end;
    else,
      for mm=1:length(a),
        am(mm)=mean(a{mm});
        as(mm)=std(a{mm});
        an(mm)=length(a{mm});
      end;
    end;
  else,
    lastdim=length(size(a));
    am=mean(a,lastdim);
    as=std(a,[],lastdim);
    an=sum(~isnan(a),lastdim);
  end;
  for mm=1:length(a), for nn=1:length(a),
    sab(mm,nn)=sqrt(as(mm)*as(mm)/an(mm) + as(nn)*as(nn)/an(nn));
    t(mm,nn)=(am(mm)-am(nn))/sab(mm,nn);
    df(mm,nn)=(as(mm)*as(mm)/an(mm) + as(nn)*as(nn)/an(nn)).^2;
    df(mm,nn)=df(mm,nn)/( ((as(mm)*as(mm)/an(mm))^2)/(an(mm)-1) + ((as(nn)*as(nn)/an(nn))^2)/(an(nn)-1) );
    pv(mm,nn)=1-tcdf(abs(t(mm,nn)),df(mm,nn));
  end; end;
else,
  lastdim=length(size(a));
  am=mean(a,lastdim);
  bm=mean(b,lastdim);
  as=std(a,[],lastdim);
  bs=std(b,[],lastdim);
  an=size(a,lastdim);
  bn=size(b,lastdim);

  sab=sqrt(as.*as/an + bs.*bs/bn);
  t=(am-bm)./sab;

  df=(as.*as/an + bs.*bs/bn).^2;
  df=df./( ((as.*as/an).^2)/(an-1) + ((bs.*bs/bn).^2)./(bn-1) );
end;

if nargout==0,
  t, df, pv,
  clf,
  subplot(321), show(am)
  subplot(322), show(as)
  if exist('b','var'), subplot(323), show(bm), end;
  if exist('b','var'), subplot(324), show(bs), end;
  subplot(325), show(t)
  subplot(326), show(df)
  disp(sprintf('  t= %.3f, df=%.2f',t(1),df(1)));
  clear all
end;

