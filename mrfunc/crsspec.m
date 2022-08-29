function [spec,axis]=crsspec(crs1,crs2,fs1,fs2,norm,outpt)
%
% Usage ... [spec,axis]=crsspec(crs1,crs2,fs1,fs2,norm,outpt)
%
%

if ( fs1>fs2 ),
  tmpcrs1=crs1;
  oldtime2=([1:length(crs2)]-1)/fs2;
  newtime2=([1:length(crs1)]-1)/fs1;
  tmpcrs2=interp1(oldtime2,crs2,newtime2);
  fs=fs1;
else,
  tmpcrs2=crs2;
  oldtime1=([1:length(crs1)]-1)/fs1;
  newtime1=([1:length(crs2)]-1)/fs2;
  tmpcrs1=interp1(oldtime1,crs1,newtime1);
  fs=fs2;
end;

if (norm),
  tmpcrs1=(tmpcrs1-mean(tmpcrs1))/mean(tmpcrs1);
  tmpcrs2=(tmpcrs2-mean(tmpcrs2))/mean(tmpcrs2);
else,
  tmpcrs1=tmpcrs1-mean(tmpcrs1);
  tmpcrs2=tmpcrs2-mean(tmpcrs2);
end;

length(crs1)
length(crs2)
length(tmpcrs1)
length(tmpcrs2)

cross=xcorr(tmpcrs1,tmpcrs2);

spec=fft(cross);
axis=[0:length(spec)-1]*(fs/(length(spec)-1));

if ( outpt ),
  figure(1);
  plot(axis,abs(spec));
  xlabel('Frequency (Hz)');
  ylabel('Magnitude');
end;
if ( outpt>1 ),
  figure(2);
  plot([0:length(crs1)-1]*(fs/(length(crs1)-1)),abs(fft(crs1)));
  xlabel('Frequency (Hz)');
  ylabel('Magnitude');
end;
if ( outpt>2 ),
  figure(3);
  plot([0:length(crs2)-1]*(fs/(length(crs2)-1)),abs(fft(crs2)));
  xlabel('Frequency (Hz)');
  ylabel('Magnitude');
end;
