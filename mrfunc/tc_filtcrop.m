function [y,yf,t]=tc_filtcrop(tc,ff,ncrop)
% Usage ... [y,yf]=tc_filtcrop(tc,ff,ncrop)
%
% Data must be in vectors


if ((2*ncrop)>length(ff)),
  ncrop=floor(length(ff)/2);
end;


if (size(tc,2)>1),

  for mm=1:size(tc,2),
    tcavg=mean(tc(:,mm));
    yy=real(ifft(fft(tc(:,mm)).*ff));
    yyf=fft(yy);
    yf(:,mm)=yyf(1:ncrop);
    yyfc=yyf([[1:ncrop] length(ff)-[1:ncrop]+1]);
    yy2=ifft(yyfc);
    y(:,mm)=real(yy2);
    if (abs(mean(y(:,mm))-tcavg)>(0.2*tcavg)),
      y(:,mm)=y(:,mm)+tcavg;
    end;
  end;

else,

  tcavg=mean(tc);
  yy=real(ifft(fft(tc).*ff));
  yyf=fft(yy);
  yf=yyf(1:ncrop);
  yyfc=yyf([[1:ncrop] length(ff)-[1:ncrop]+1]);
  yy2=ifft(yyfc);
  y=real(yy2);
  if (abs(mean(yy)-tcavg)>0.2*tcavg),
    y=y+tcavg;
  end;

end;

tt=[1:length(tc)];
t=[1:length(y)]*(length(tc)/length(y));

if (nargout==0),
  plot(tt,tc,t,y)
end;

