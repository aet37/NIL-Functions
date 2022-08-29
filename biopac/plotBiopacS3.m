function plotBiopacS(b1,b2,b3,b4,b5)
% Usage ... plotBiopacS(b1,b2,b3,...)

if (nargin<1),
  error('Need at least one variable to plot!');
end;

colorstr=['b','g','r','y','c','m','k'];

if (nargin==1),

  [tmp1,tmpi1]=max(b1.LDFfilt);
  tmpi1a=find((b1.tt>=(b1.tt(tmpi1)-1.5))&(b1.tt<=(b1.tt(tmpi1)+1.5)));
  avgmaxLDF=(mean(b1.LDFfilt(tmpi1a))-1)*100;
  [tmp1,tmpi1]=max(b1.pO2Acalfilt);
  tmpi1a=find((b1.tt>=(b1.tt(tmpi1)-1.5))&(b1.tt<=(b1.tt(tmpi1)+1.5)));
  avgmaxpO2A=(mean(b1.pO2Acalfilt(tmpi1a))-1)*100;
  [tmp1,tmpi1]=max(b1.pO2Bcalfilt);
  tmpi1a=find((b1.tt>=(b1.tt(tmpi1)-1.5))&(b1.tt<=(b1.tt(tmpi1)+1.5)));
  avgmaxpO2B=(mean(b1.pO2Bcalfilt(tmpi1a))-1)*100;
  [tmp1,tmpi1]=max(b1.pO2Ccalfilt);
  tmpi1a=find((b1.tt>=(b1.tt(tmpi1)-1.5))&(b1.tt<=(b1.tt(tmpi1)+1.5)));
  avgmaxpO2C=(mean(b1.pO2Ccalfilt(tmpi1a))-1)*100;

  [tmp1,tmpi1]=min(b1.LDFfilt);
  tmpi1a=find((b1.tt>=(b1.tt(tmpi1)-1.5))&(b1.tt<=(b1.tt(tmpi1)+1.5)));
  avgminLDF=(mean(b1.LDFfilt(tmpi1a))-1)*100;
  [tmp1,tmpi1]=min(b1.pO2Acalfilt);
  tmpi1a=find((b1.tt>=(b1.tt(tmpi1)-1.5))&(b1.tt<=(b1.tt(tmpi1)+1.5)));
  avgminpO2A=(mean(b1.pO2Acalfilt(tmpi1a))-1)*100;
  [tmp1,tmpi1]=min(b1.pO2Bcalfilt);
  tmpi1a=find((b1.tt>=(b1.tt(tmpi1)-1.5))&(b1.tt<=(b1.tt(tmpi1)+1.5)));
  avgminpO2B=(mean(b1.pO2Bcalfilt(tmpi1a))-1)*100;
  [tmp1,tmpi1]=min(b1.pO2Ccalfilt);
  tmpi1a=find((b1.tt>=(b1.tt(tmpi1)-1.5))&(b1.tt<=(b1.tt(tmpi1)+1.5)));
  avgminpO2C=(mean(b1.pO2Ccalfilt(tmpi1a))-1)*100;


  subplot(411)
  plot(b1.tt,b1.LDFfilt)
  axis('tight'), grid('on'),
  ylabel('LDF/LDF_0')
  %title(sprintf('Flux= %.2f, pO2ABC= %.3f / %.3f / %.3f, BP= %.1f HR= %.1f, ISO= %.1f, ExCO2= %.1f',b1.LDFfiltbase,b1.pO2Acalfiltbase,b1.pO2Bcalfiltbase,b1.pO2Ccalfiltbase,b1.BPavg,b1.HRavg,b1.ISOavg,b1.CO2avg));
  title(sprintf('Flux= %.2f, pO2ABC= %.1f / %.1f / %.1f, BP= %.1f, ISO= %.1f, ExCO2= %.1f',b1.LDFfiltbase,avgmaxpO2A,avgmaxpO2B,avgmaxpO2C,b1.BPavg,b1.ISOavg,b1.CO2avg));
  subplot(412)
  plot(b1.tt,b1.pO2Acalfilt*b1.pO2Acalfiltbase)
  axis('tight'), grid('on'),
  ylabel('pO2A (mmHg)')
  subplot(413)
  plot(b1.tt,b1.pO2Bcalfilt*b1.pO2Bcalfiltbase)
  axis('tight'), grid('on'),
  ylabel('pO2B (mmHg)')
  subplot(414)
  plot(b1.tt,b1.pO2Ccalfilt*b1.pO2Ccalfiltbase)
  axis('tight'), grid('on'),
  ylabel('pO2C (mmHg)')
  xlabel('Time (s)')

else

  [tmp1,tmpi1]=max(b1.LDFfilt);
  tmpi1a=find((b1.tt>=(b1.tt(tmpi1)-1.5))&(b1.tt<=(b1.tt(tmpi1)+1.5)));
  avgmaxLDF=(mean(b1.LDFfilt(tmpi1a))-1)*100;
  [tmp1,tmpi1]=max(b1.pO2Acalfilt);
  tmpi1a=find((b1.tt>=(b1.tt(tmpi1)-1.5))&(b1.tt<=(b1.tt(tmpi1)+1.5)));
  avgmaxpO2A=(mean(b1.pO2Acalfilt(tmpi1a))-1)*100;
  [tmp1,tmpi1]=max(b1.pO2Bcalfilt);
  tmpi1a=find((b1.tt>=(b1.tt(tmpi1)-1.5))&(b1.tt<=(b1.tt(tmpi1)+1.5)));
  avgmaxpO2B=(mean(b1.pO2Bcalfilt(tmpi1a))-1)*100;
  [tmp1,tmpi1]=max(b1.pO2Ccalfilt);
  tmpi1a=find((b1.tt>=(b1.tt(tmpi1)-1.5))&(b1.tt<=(b1.tt(tmpi1)+1.5)));
  avgmaxpO2C=(mean(b1.pO2Ccalfilt(tmpi1a))-1)*100;

  [tmp1,tmpi1]=min(b1.LDFfilt);
  tmpi1a=find((b1.tt>=(b1.tt(tmpi1)-1.5))&(b1.tt<=(b1.tt(tmpi1)+1.5)));
  avgminLDF=(mean(b1.LDFfilt(tmpi1a))-1)*100;
  [tmp1,tmpi1]=min(b1.pO2Acalfilt);
  tmpi1a=find((b1.tt>=(b1.tt(tmpi1)-1.5))&(b1.tt<=(b1.tt(tmpi1)+1.5)));
  avgminpO2A=(mean(b1.pO2Acalfilt(tmpi1a))-1)*100;
  [tmp1,tmpi1]=min(b1.pO2Bcalfilt);
  tmpi1a=find((b1.tt>=(b1.tt(tmpi1)-1.5))&(b1.tt<=(b1.tt(tmpi1)+1.5)));
  avgminpO2B=(mean(b1.pO2Bcalfilt(tmpi1a))-1)*100;
  [tmp1,tmpi1]=min(b1.pO2Ccalfilt);
  tmpi1a=find((b1.tt>=(b1.tt(tmpi1)-1.5))&(b1.tt<=(b1.tt(tmpi1)+1.5)));
  avgminpO2C=(mean(b1.pO2Ccalfilt(tmpi1a))-1)*100;


  BPstr=sprintf('BP= %.1f',b1.BPavg);
  %HRstr=sprintf('HR= %.1f',b1.HRavg);
  ISOstr=sprintf('ISO= %.2f',b1.ISOavg);
  CO2str=sprintf('ExCO2= %.2f',b1.CO2avg);
  legLDFstr=sprintf('lh=legend(''%.3f''',b1.LDFfiltbase);
  legpO2Astr=sprintf('lh=legend(''%.1f''',avgmaxpO2A);
  legpO2Bstr=sprintf('lh=legend(''%.1f''',avgmaxpO2B);
  legpO2Cstr=sprintf('lh=legend(''%.1f''',avgmaxpO2C);

  subplot(411)
  plot(b1.tt,b1.LDFfilt,'b')
  hold('on');
  subplot(412)
  plot(b1.tt,(b1.pO2Acalfilt-1)*b1.pO2Acalfiltbase)
  hold('on');
  subplot(413)
  plot(b1.tt,(b1.pO2Bcalfilt-1)*b1.pO2Bcalfiltbase)
  hold('on');
  subplot(414)
  plot(b1.tt,(b1.pO2Ccalfilt-1)*b1.pO2Ccalfiltbase)
  hold('on');

  for mm=2:nargin,
    eval(sprintf('[tmp1,tmpi1]=max(b%d.LDFfilt);',mm));
    eval(sprintf('tmpi1a=find((b%d.tt>=(b%d.tt(tmpi1)-1.5))&(b%d.tt<=(b%d.tt(tmpi1)+1.5)));',mm,mm,mm,mm));
    eval(sprintf('avgmaxLDF(mm)=(mean(b%d.LDFfilt(tmpi1a))-1)*100;',mm));
    eval(sprintf('[tmp1,tmpi1]=max(b%d.pO2Acalfilt);',mm));
    eval(sprintf('tmpi1a=find((b%d.tt>=(b%d.tt(tmpi1)-1.5))&(b%d.tt<=(b%d.tt(tmpi1)+1.5)));',mm,mm,mm,mm));
    eval(sprintf('avgmaxpO2A(mm)=(mean(b%d.pO2Acalfilt(tmpi1a))-1)*100;',mm));
    eval(sprintf('[tmp1,tmpi1]=max(b%d.pO2Bcalfilt);',mm));
    eval(sprintf('tmpi1a=find((b%d.tt>=(b%d.tt(tmpi1)-1.5))&(b%d.tt<=(b%d.tt(tmpi1)+1.5)));',mm,mm,mm,mm));
    eval(sprintf('avgmaxpO2B(mm)=(mean(b%d.pO2Bcalfilt(tmpi1a))-1)*100;',mm));
    eval(sprintf('[tmp1,tmpi1]=max(b%d.pO2Ccalfilt);',mm));
    eval(sprintf('tmpi1a=find((b%d.tt>=(b%d.tt(tmpi1)-1.5))&(b%d.tt<=(b%d.tt(tmpi1)+1.5)));',mm,mm,mm,mm));
    eval(sprintf('avgmaxpO2C(mm)=(mean(b%d.pO2Ccalfilt(tmpi1a))-1)*100;',mm));

    eval(sprintf('[tmp1,tmpi1]=min(b%d.LDFfilt);',mm));
    eval(sprintf('tmpi1a=find((b%d.tt>=(b%d.tt(tmpi1)-1.5))&(b%d.tt<=(b%d.tt(tmpi1)+1.5)));',mm,mm,mm,mm));
    eval(sprintf('avgminLDF(mm)=(mean(b%d.LDFfilt(tmpi1a))-1)*100;',mm));
    eval(sprintf('[tmp1,tmpi1]=min(b%d.pO2Acalfilt);',mm));
    eval(sprintf('tmpi1a=find((b%d.tt>=(b%d.tt(tmpi1)-1.5))&(b%d.tt<=(b%d.tt(tmpi1)+1.5)));',mm,mm,mm,mm));
    eval(sprintf('avgminpO2A(mm)=(mean(b%d.pO2Acalfilt(tmpi1a))-1)*100;',mm));
    eval(sprintf('[tmp1,tmpi1]=min(b%d.pO2Bcalfilt);',mm));
    eval(sprintf('tmpi1a=find((b%d.tt>=(b%d.tt(tmpi1)-1.5))&(b%d.tt<=(b%d.tt(tmpi1)+1.5)));',mm,mm,mm,mm));
    eval(sprintf('avgminpO2B(mm)=(mean(b%d.pO2Bcalfilt(tmpi1a))-1)*100;',mm));
    eval(sprintf('[tmp1,tmpi1]=min(b%d.pO2Ccalfilt);',mm));
    eval(sprintf('tmpi1a=find((b%d.tt>=(b%d.tt(tmpi1)-1.5))&(b%d.tt<=(b%d.tt(tmpi1)+1.5)));',mm,mm,mm,mm));
    eval(sprintf('avgminpO2C(mm)=(mean(b%d.pO2Ccalfilt(tmpi1a))-1)*100;',mm));

    eval(sprintf('BPstr=[BPstr,'' / '',num2str(b%d.BPavg,3)];',mm));
    %eval(sprintf('HRstr=[HRstr,'' / '',num2str(b%d.HRavg,1)];',mm));
    eval(sprintf('ISOstr=[ISOstr,'' / '',num2str(b%d.ISOavg,3)];',mm));
    eval(sprintf('CO2str=[CO2str,'' / '',num2str(b%d.CO2avg,3)];',mm));

    tmpstr=eval(sprintf('num2str(b%d.LDFfiltbase,4)',mm));     legLDFstr=[legLDFstr,',''',tmpstr,''''];
    tmpstr=eval(sprintf('num2str(avgmaxpO2A(%d),3)',mm)); legpO2Astr=[legpO2Astr,',''',tmpstr,''''];
    tmpstr=eval(sprintf('num2str(avgmaxpO2B(%d),3)',mm)); legpO2Bstr=[legpO2Bstr,',''',tmpstr,''''];
    tmpstr=eval(sprintf('num2str(avgmaxpO2C(%d),3)',mm)); legpO2Cstr=[legpO2Cstr,',''',tmpstr,''''];
    %eval(sprintf('legpO2Cstr=[legpO2Cstr,'', '' '',num2str(b%d.pO2Ccalfiltbase,3),'' '' ''];',mm));

    subplot(411)
    eval(sprintf('plot(b%d.tt,b%d.LDFfilt,''%s'');',mm,mm,colorstr(mm)));
    subplot(412)
    eval(sprintf('plot(b%d.tt,(b%d.pO2Acalfilt-1)*b%d.pO2Acalfiltbase,''%s'');',mm,mm,mm,colorstr(mm)));
    subplot(413)
    eval(sprintf('plot(b%d.tt,(b%d.pO2Bcalfilt-1)*b%d.pO2Bcalfiltbase,''%s'');',mm,mm,mm,colorstr(mm)));
    subplot(414)
    eval(sprintf('plot(b%d.tt,(b%d.pO2Ccalfilt-1)*b%d.pO2Ccalfiltbase,''%s'');',mm,mm,mm,colorstr(mm)));

  end;

  subplot(411)
  hold('off');
  axis('tight'); grid('on');
  ylabel('LDF/LDF_0');
  eval([legLDFstr,');']);
  set(lh,'FontSize',8);
  eval(sprintf('title(''%s  %s  %s'');',BPstr,ISOstr,CO2str));
  %eval(sprintf('title(''%s  %s  %s  %s'');',BPstr,HRstr,ISOstr,CO2str));
  subplot(412)
  hold('off');
  axis('tight'); grid('on');
  ylabel('\DeltapO2A (mmHg)')
  eval([legpO2Astr,');']);
  set(lh,'FontSize',8);
  subplot(413)
  hold('off');
  axis('tight'); grid('on');
  ylabel('\DeltapO2B (mmHg)')
  eval([legpO2Bstr,');']);
  set(lh,'FontSize',8);
  subplot(414)
  hold('off');
  axis('tight'); grid('on');
  ylabel('\DeltapO2C (mmHg)')
  xlabel('Time (s)')
  eval([legpO2Cstr,');']);
  set(lh,'FontSize',8);

  [avgmaxLDF;avgmaxpO2A;avgmaxpO2B;avgmaxpO2C]
  [avgminLDF;avgminpO2A;avgminpO2B;avgminpO2C]

end;

