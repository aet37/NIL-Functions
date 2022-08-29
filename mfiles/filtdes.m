%  m file for DTS computer #1, 1994
%    digital signal processing

%********** Start of Illustration of aliasing *************

%while(0)   % #1
%  create sampled wave

T = 0.01;    % fast sampling
t = [0:T:1.0-T];

ef = 3.2*sin(4*2*pi*t + 30*pi/180) + 2.1*cos(13*2*pi*t - 48*pi/180) ...
   + 5.7*cos(31*2*pi*t + 11*pi/180);
clg
plot(t,ef)
grid
xlabel('time in seconds')
ylabel('signal')
title('Fast sampled signal')
keyboard

Ef = fft(ef);
ff = [0:1/T/length(ef):(1.0-T)/T];
subplot(2,1,1)
plot(ff,abs(Ef),'o')
xlabel('frequency in Hz')
ylabel('magnitude')
title('Fast sampling')
grid
subplot(2,1,2)
ph_Ef = angle(Ef)*180/pi;
for i = 1:length(Ef)
  if abs(Ef(i)) < 1e-8
    ph_Ef(i) = 0;
  end
end
plot(ff,ph_Ef,'o')
xlabel('frequency in Hz')
ylabel('phase in degrees')
grid
keyboard

T = 0.02;    % slow sampling
t = [0:T:1.0-T];

es = 3.2*sin(4*2*pi*t + 30*pi/180) + 2.1*cos(13*2*pi*t - 48*pi/180) ...
   + 5.7*cos(31*2*pi*t + 11*pi/180);

clg
plot(t,es)
grid
xlabel('time in seconds')
ylabel('signal')
title('Slow sampled signal')
keyboard

Es = fft(es);
fs = [0:1/T/length(es):(1.0-T)/T];
subplot(2,1,1)
plot(fs,abs(Es),'o')
xlabel('frequency in Hz')
ylabel('magnitude')
title('Slow sampling')
grid
subplot(2,1,2)
ph_Es = angle(Es)*180/pi;
for i = 1:length(Es)
  if abs(Es(i)) < 1e-8
    ph_Es(i) = 0;
  end
end
plot(fs,ph_Es,'o')
xlabel('frequency in Hz')
ylabel('phase in degrees')
grid
keyboard

%end % while(0) #1

%********** End of Illustration of aliasing *************

%  create sampled wave for a longer duration

T = 0.01;    % fast sampling
t = [0:T:10.0-T];

ef = 3.2*sin(4*2*pi*t + 30*pi/180) + 2.1*cos(13*2*pi*t - 48*pi/180) ...
   + 5.7*cos(31*2*pi*t + 11*pi/180);

%***********   Start passing the signal thru a LTI discrete system **********

%while(0)     % # 2
%  a 1st order DTS 
num = 1; den = [1 -0.6];

% plot frequency response

dbode(num,den,T);
keyboard

% simulate system response given input ef
y = dlsim(num,den,ef);
yp = y(901:1000);
Yp = fft(yp);

clg
plot(t(1:100),yp)
grid
xlabel('time in seconds')
ylabel('signal')
title('LTI system output signal')
keyboard

ff = [0:1/T/100:(1.0-T)/T];
subplot(2,1,1)
plot(ff,abs(Yp),'o')
xlabel('frequency in Hz')
ylabel('magnitude')
title('DTS response')
grid
subplot(2,1,2)
ph_Yp = angle(Yp)*180/pi;
for i = 1:length(Yp)
  if abs(Yp(i)) < 1e-8
    ph_Yp(i) = 0;
  end
end
plot(ff,ph_Yp,'o')
xlabel('frequency in Hz')
ylabel('phase in degrees')
grid
keyboard

%end  %while(0) # 2

%*********** End passing the signal thru a LTI discrete system **********

%******** Start FIR design ********

%while(0) % #3 
%  low pass FIR filter with Hamming window

n = 20;
cutoff = 20/(1/(2*T));
b = fir1(n,cutoff);
a = zeros(size(b)); a(1) = 1;

%  FIR filter frequency response
dbode(b,a,T);
hold on
subplot(2,1,1)
title('frequency response of LP FIR filter')
hold off
keyboard

%  passing signal thru low pass FIR filter

y = conv(b,ef);
yfirlp = y(901:1000);
Yfirlp = fft(yfirlp);

clg
plot(t(1:100),yfirlp)
grid
xlabel('time in seconds')
ylabel('signal')
title('LP FIR filtered signal')
keyboard

ff = [0:1/T/100:(1.0-T)/T];
subplot(2,1,1)
plot(ff,abs(Yfirlp),'o')
xlabel('frequency in Hz')
ylabel('magnitude')
title('LP FIR filtered response')
grid
subplot(2,1,2)
ph_Yfirlp = angle(Yfirlp)*180/pi;
for i = 1:length(Yfirlp)
  if abs(Yfirlp(i)) < 1e-8
    ph_Yfirlp(i) = 0;
  end
end
plot(ff,ph_Yfirlp,'o')
xlabel('frequency in Hz')
ylabel('phase in degrees')
grid
keyboard

%  high pass FIR filter with Hamming window

n = 20;
cutoff = 20/(1/(2*T));
b = fir1(n,cutoff,'high');
a = zeros(size(b)); a(1) = 1;

%  FIR filter frequency response
dbode(b,a,T);
hold on
subplot(2,1,1)
title('frequency response of HP FIR filter')
hold off
keyboard

%  passing signal thru high pass FIR filter

y = conv(b,ef);
yfirhp = y(901:1000);
Yfirhp = fft(yfirhp);

clg
plot(t(1:100),yfirhp)
grid
xlabel('time in seconds')
ylabel('signal')
title('HP FIR filtered signal')
keyboard

ff = [0:1/T/100:(1.0-T)/T];
subplot(2,1,1)
plot(ff,abs(Yfirhp),'o')
xlabel('frequency in Hz')
ylabel('magnitude')
title('HP FIR filtered response')
grid
subplot(2,1,2)
ph_Yfirhp = angle(Yfirhp)*180/pi;
for i = 1:length(Yfirhp)
  if abs(Yfirhp(i)) < 1e-8
    ph_Yfirhp(i) = 0;
  end
end
plot(ff,ph_Yfirhp,'o')
xlabel('frequency in Hz')
ylabel('phase in degrees')
grid
keyboard

%end   % while(0)  #3

%********** End FIR design **************

%********** Start IIR design **********

%  low pass butterworth filter 

n = 6;
cutoff = 20/(1/(2*T));
[b,a] = butter(n,cutoff);

%  IIR filter frequency response
dbode(b,a,T);
hold on
subplot(2,1,1)
title('frequency response of LP IIR filter')
hold off
keyboard

%  passing signal thru low pass IIR filter

y = dlsim(b,a,ef);
yiirlp = y(901:1000);
Yiirlp = fft(yiirlp);

clg
plot(t(1:100),yiirlp)
grid
xlabel('time in seconds')
ylabel('signal')
title('LP IIR filtered signal')
keyboard

ff = [0:1/T/100:(1.0-T)/T];
subplot(2,1,1)
plot(ff,abs(Yiirlp),'o')
xlabel('frequency in Hz')
ylabel('magnitude')
title('LP IIR filtered response')
grid
subplot(2,1,2)
ph_Yiirlp = angle(Yiirlp)*180/pi;
for i = 1:length(Yiirlp)
  if abs(Yiirlp(i)) < 1e-8
    ph_Yiirlp(i) = 0;
  end
end
plot(ff,ph_Yiirlp,'o')
xlabel('frequency in Hz')
ylabel('phase in degrees')
grid
keyboard

%  high pass butterworth IIR filter 

n = 6;
cutoff = 20/(1/(2*T));
[b,a] = butter(n,cutoff,'high');

%  IIR filter frequency response
dbode(b,a,T);
hold on
subplot(2,1,1)
title('frequency response of HP IIR filter')
hold off
keyboard

%  passing signal thru high pass IIR filter

y = conv(b,ef);
yiirhp = y(901:1000);
Yiirhp = fft(yiirhp);

clg
plot(t(1:100),yiirhp)
grid
xlabel('time in seconds')
ylabel('signal')
title('HP IIR filtered signal')
keyboard

ff = [0:1/T/100:(1.0-T)/T];
subplot(2,1,1)
plot(ff,abs(Yiirhp),'o')
xlabel('frequency in Hz')
ylabel('magnitude')
title('HP IIR filtered response')
grid
subplot(2,1,2)
ph_Yiirhp = angle(Yiirhp)*180/pi;
for i = 1:length(Yiirhp)
  if abs(Yiirhp(i)) < 1e-8
    ph_Yiirhp(i) = 0;
  end
end
plot(ff,ph_Yiirhp,'o')
xlabel('frequency in Hz')
ylabel('phase in degrees')
grid
keyboard

%********** End IIR design **************

