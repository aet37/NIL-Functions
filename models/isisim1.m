
% this script simulates the behavior of fmri contrast
% with respect to the stimulus spacing (ISI)
% ISI= 2,4,6,8,10,12,16,20 s
% TR=1000ms

% generate the data using a gamma function as the response and
% a square wave as the reference waveform... the parameters for
% the gamma function are... see gammafun defaults...

t=[1:1:200]';
tt=t(length(t));
tc=0.25;                        % correction term to avoid overweigth

isi=[20 12 10 8 6 4];	% includes the stimulus duration

a=1;
w=2.0;
d=6.0;				% originally 2.0, but 6.0 is optimal for ref
dd=w/2;
an=0.2*a;
noise=an*randn(size(t));
noise=zeros(size(t));

rw=isi(1);
sw=2.0;
sd=6.0+t(1);			% consider t(1)!=0 and input at t(1)'s

ref_x=rect(t-tc,rw,rw+rw/2);
for n=2:tt/(2*rw),
  ref_x=ref_x+rect(t-tc,rw,n*2*rw-rw/2);
end;
h=gammafun(t);
ref_y=myconv(ref_x,h)';
ref_v=rect(t-tc,rw,rw+rw/2+d);
for n=2:tt/(2*rw),
  ref_v=ref_v+rect(t-tc,rw,n*2*rw-rw/2+d);
end;
ref_v=ref_v-mean(ref_v);
ref_y=ref_y+noise;
tmp=corrcoef(ref_y,ref_v)
ref_r=tmp(:,1);

%subplot(211)
%plot(t,ref_x,t,ref_v)
%subplot(212)
%plot(t,h,t,ref_y)

for m=1:length(isi),

  x(:,m)=zeros([length(t) 1]);
  v(:,m)=zeros([length(t) 1]);
  y(:,m)=zeros([length(t) 1]);
  for n=1:tt/isi(m),
    tmpx=rect(t-tc,w,(n-1)*isi(m)+dd);
    tmpv=rect(t-tc,sw,(n-1)*isi(m)+sd);
    tmpy=myconv(tmpx,h)';
    x(:,m)=x(:,m)+tmpx;
    v(:,m)=v(:,m)+tmpv;
    y(:,m)=y(:,m)+a*tmpy./max(tmpy);
  end;
  v(:,m)=v(:,m)-mean(v(:,m));
  y(:,m)=y(:,m)+noise;
  tmp=corrcoef(y(:,m),v(:,m))
  r(:,m)=tmp(:,1);

end;

