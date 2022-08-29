function [t,y,step]=modstep(funoff,funon,t0,tfinal,y0,tstep,order,tol,trace)
% Usage ... [t,y,step]=modstep(funoff,funon,t0,tfinal,y0,tstep,order,tol,trace)
%
% This function models the output of a step input which is on
% according to function file funon.m and off according to funoff.m
% for the time span specified in tstep (tstep=[ton toff]). The
% remaining parameters are used in function ode23 or ode45,
% according to the order, 1 or 2, respectively.
% Note: the amplitude of the input and the parameters needs to be
%  specified in the m-file.

tmpcmd=[];
if (order==2), ordfun='ode45'; else ordfun='ode23'; end;

if (tstep(1)==t0),
  tmpcmd=['[t1,y1]=',ordfun,'(''',funon,''',t0,tstep(2),y0,tol,trace);'];
  disp(tmpcmd);
  eval(tmpcmd);
else,
  tmpcmd=['[t1,y1]=',ordfun,'(''',funoff,''',t0,tstep(1)-tol,y0,tol,trace);'];
  disp(tmpcmd);
  eval(tmpcmd);
end;

t1len=length(t1);
if (t1(t1len)<=tstep(1)),
  tmpcmd=['[t2,y2]=',ordfun,'(''',funon,''',tstep(1),tstep(2),y1(t1len,:),tol,trace);'];
  disp(tmpcmd);
  eval(tmpcmd);
elseif (t1(t1len)<=tstep(2)),
  tmpcmd=['[t2,y2]=',ordfun,'(''',funoff,''',tstep(2),tfinal,y1(t1len,:),tol,trace);'];
  disp(tmpcmd);
  eval(tmpcmd);
end;

t2len=length(t2);
if (t2(t2len)<=tstep(2)),
  tmpcmd=['[t3,y3]=',ordfun,'(''',funoff,''',tstep(2),tfinal,y2(t2len,:),tol,trace);'];
  disp(tmpcmd);
  eval(tmpcmd);
else,
  t3=t2(t2len); y3=y2(t2len);
end;

for m=1:t1len,
  t(m)=t1(m);
  y(m,:)=y1(m,:);
end;
for m=1:t2len,
  t(m+t1len)=t2(m);
  y(m+t1len,:)=y2(m,:);
end;
for m=1:length(t3),
  t(m+t1len+t2len)=t3(m);
  y(m+t1len+t2len,:)=y3(m,:);
end;
for m=1:t1len+t2len+length(t3),
  if ( (t(m)>=tstep(1))&(t(m)<=tstep(2))), step(m)=0.2*max(max(y));
  else step(m)=0; end;
end;
