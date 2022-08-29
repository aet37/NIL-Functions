function [z,y]=B1homfit(x,fadata)

maxfa=x(1)*(pi/180);
farate=x(2);
amp=x(3);

datalen=length(fadata);
fax=[0:datalen-1]*maxfa/(datalen-1); fax=fax(:);
y=amp*abs(sin(fax)).*exp(fax*farate);

z=(y-fadata);

