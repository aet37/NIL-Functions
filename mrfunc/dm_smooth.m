function ff=dm_smooth(dmfile,window,outfile)
% Usage ... f=dm_smooth(dmfile,window,outfile)

dmfid=fopen(dmfile,'r');
if (dmfid<3), error('Could not open dm file!'); end;

info=getdmodinfo(dmfid);
nslices=info(7);
nvols=info(8);

disp('dmFile information:');
disp([' volumes= ',int2str(nvols)]);
disp([' slices = ',int2str(nslices)]);
 
window_fft=fft2(window);
window_norm=max(max(abs(window_fft)));

disp('Initializing...');
%f=zeros([info(2) info(3) nvols nslices]);
ff=zeros([info(2) info(3) nvols nslices]);

disp('Reading header...');
fseek(dmfid,0,'bof');
[header,cnt]=fread(dmfid,info(1),'char');
if (cnt~=info(1)), error('Could not read header from dm file!'); end;
disp('Reading data...');
[f,cnt]=fread(dmfid,info(2)*info(3)*nvols*nslices,'int16');
if (cnt~=(info(2)*info(3)*nvols*nslices)), error('Could not read dm data!'); end;
f=reshape(f,info(2),info(3),nvols,nslices);

for m=1:nslices,
  disp(['Smoothing slice ',int2str(m),' ...']);
  for n=1:nvols,
    tmpim=squeeze(f(:,:,n,m));
    tmpim_fft=fft2(tmpim);
    tmpimf=abs(tmpim_fft).*abs(window_fft).*exp(-j*(angle(tmpim_fft)+angle(window_fft)));
    ff(:,:,n,m)=real(fftshift(ifft2((1/window_norm)*tmpimf)));
  end;
end;
clear tmpim tmpim_fft tmpimf f

fclose(dmfid);

dmfid2=fopen(outfile,'wb');
if (dmfid2<3), error('Could not open outfile to write!'); end;

disp('Writing header...');
cnt=fwrite(dmfid2,header,'char');
if (cnt~=info(1)), error('Could not write header to out file!'); end;
disp('Writing data...');
cnt=fwrite(dmfid2,squeeze(ff),'int16');
if (cnt~=(info(2)*info(3)*nvols*nslices)), 
 disp('WARNING: Could not write all data to outfile!');
end;

fclose(dmfid2);

