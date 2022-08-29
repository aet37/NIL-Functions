function [rat,pos,neg,all]=rarea(t,inp,resp)
% Usage ... [rat,pos,neg,all]=rarea(t,inp,resp)
% Calculates the ratio of the positive area over the
% negative area and the complete area. Each individual
% area is normalized.
% All vectors must be of same area, if resp is a matrix
% the results will be vectors for each set.

ACT=.10;
RISE=4;

t=t(:);
[rr,rc]=size(resp);

fs=1/(t(2)-t(1));

if ( (rr>1)&(rc>1) ),
  mult=1;
  if (rc>rr) inp=inp'; resp=resp'; end;
else,
  mult=0;
end;

[rr,rc]=size(resp);
[ir,ic]=size(inp);

all=trapz(t,resp);

for n=1:length(inp),
  if ( inp(n)>0 ),
    start=n;
    break;
  end;
end;

if (mult),
  PREC=ACT*max(max(resp));
  for n=1:rc,
    for m=start+round(RISE*fs):rr,
      if ( (resp(m,n)<=PREC)&(resp(m+1,n)>=-PREC) ),
	bk=m+1;
	break;
      end;
    end;
    bkpnt(n)=bk;
    pos(n)=trapz(t(start:bk),resp(start:bk,n))/all(n);
    neg(n)=trapz(t(bk:rr),resp(bk:rr,n))/all(n);
  end;
else,
  PREC=ACT*max(resp);
  for m=start+round(RISE*fs):length(resp),
    if ( (resp(m)<=PREC)&(resp(m+1)>=-PREC) ),
      bk=m+1;
      break;
    end;
  end;
  bkpnt=bk;
  pos=trapz(t(start:bk),resp(start:bk))/all;
  neg=trapz(t(bk:length(resp)),resp(bk:length(resp)))/all;
end;

pos=pos(:);
neg=neg(:);
all=all(:);
rat=pos./neg;

if (nargout==0),
  for m=1:length(bkpnt), tbkpnt(m)=t(bkpnt(m)); bkpnt(m)=resp(bkpnt(m),m); end;
  plot(t,resp,t,zeros([1 length(resp)]),tbkpnt,bkpnt,'o');
end;
