function y=my_plx_fix(plx,ii)
% Usage ... y=my_plx_fix(plx,ii)

[ii(1) ii(end)],

y.freq=plx.freq;
y.adfreq=plx.adfreq;
y.n_old=plx.n;
y.trigid=plx.trigid;
y.n=length(ii);
y.tt=plx.tt(ii);
y.recno=plx.recno(ii);
y.tt1=plx.tt1(ii);
y.tt2=plx.tt2(ii);
y.recno1=plx.recno1(ii);
y.recno2=plx.recno2(ii);
y.lfpch=plx.lfpch;
y.durarray=plx.durarray;

for mm=1:length(ii),
  [mm ii(mm)],
  eval(sprintf('y.data%02d=plx.data%02d; y.rts%02d=plx.rts%02d;',mm,ii(mm),mm,ii(mm)));
end;


tmptt=[y.durarray(1)/1000:1/y.adfreq:y.durarray(2)/1000];
for mm=1:y.n,
  eval(sprintf('tmin(mm)=min(y.rts%02d);',mm));
  eval(sprintf('tmax(mm)=max(y.rts%02d);',mm));
end;
tmpt1=find(tmptt>=max(tmin));
tmpt2=find(tmptt>=min(tmax));
if isempty(tmpt1), tmpt1=1; end;
if isempty(tmpt2), tmpt2=length(tmptt); end;
ntt=tmptt(tmpt1(1):tmpt2(1));
for mm=1:y.n,
  eval(sprintf('ndata(:,mm)=interp1(y.rts%02d(:),y.data%02d(:),ntt(:));',mm,mm));
end;

y.ntt=ntt;
y.ndata=ndata;

