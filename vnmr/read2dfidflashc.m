function AAA=read2dfidflashc(directorypath)
%   function out=read3darray(directorypath)
%%%
%%% M-file to process High Resolution BOLD Venography (HRBV) Data
%%%

newpath=[directorypath '2D.fid'];
if ~(strcmp(directorypath(end-3:end),'.fid')|strcmp(directorypath(end-4:end),'.fid/')),
  dirpath=[directorypath '.fid'];
else,
  dirpath=[directorypath];
end;

%np = 128*2;
np = getPPV('np', [dirpath '/procpar']);
%nv = 128;
nv = getPPV('nv', [dirpath '/procpar']);
ns = getPPV('ns', [dirpath '/procpar']);
pss = getPPV('pss', [dirpath '/procpar']);

%fn = 128*2;
%fn1 = 128*2;
%fn2 = 64*2;
%fn2 = 32*2;
fn = getPPV('fn', [dirpath '/procpar']);
fn1 = getPPV('fn1', [dirpath '/procpar']);

ppe = getPPV('ppe', [dirpath '/procpar']);
lpe = getPPV('lpe', [dirpath '/procpar']);

%ne = 1;
ne = getPPV('ne', [dirpath '/procpar']);

petable = getPPV('petable', [dirpath '/procpar']);

main_hdr = 32;
block_hdr = 28;

%dp = 2; % 1 : single precision, 2 : double precision
dp = getPPV('dp', [dirpath '/procpar']);

%array_leng = 22;
%array_leng = 31;
%array_leng = 12;
arraydim = getPPV('arraydim', [dirpath '/procpar']);
array_leng = arraydim/nv;

fid = fopen([dirpath '/fid'],'r','ieee-be');
status = fseek(fid,main_hdr,'bof');
A = zeros(np,nv,ns,array_leng);
if dp == 1
  for n=1:array_leng
    for i=1:ns
        for m=1:nv
%            offset = main_hdr+block_hdr+(np*2+block_hdr)*ne*(i-1)+(block_hdr+np*2)*ne*ns*(m-1)+(block_hdr+np*2)*ne*ns*nv*array_leng*(n-1);
            offset = main_hdr+block_hdr+np*ne*2*(i-1)+(np*2*ns*ne+block_hdr)*array_leng*(m-1)+(np*2*ns*ne+block_hdr)*(n-1);
%            offset = main_hdr+block_hdr+(np*2+block_hdr)*ne*(i-1)+(np*2+block_hdr)*ne*ns*array_leng*(m-1)+(np*2+block_hdr)*ne*ns*(n-1);
            status = fseek(fid,offset,'bof');
            [A(:,m,i,n),count] = fread(fid,np,'int16');
        end
    end
  end
else
  for n=1:array_leng
    for i=1:ns
        for m=1:nv
%            offset = main_hdr+block_hdr+(np*4+block_hdr)*ne*(i-1)+(np*4+block_hdr)*ne*ns*(m-1)+(np*4+block_hdr)*ne*ns*nv*(n-1);
            offset = main_hdr+block_hdr+np*ne*4*(i-1)+(np*4*ns*ne+block_hdr)*array_leng*(m-1)+(np*4*ns*ne+block_hdr)*(n-1);
%            offset = main_hdr+block_hdr+np*ne*4*(i-1)+(np*ne*4*ns)*(m-1)+(block_hdr+np*ne*4*ns*nv)*(n-1);
            status = fseek(fid,offset,'bof');
            [A(:,m,i,n),count] = fread(fid,np,'int32');
        end
    end
  end
end
fclose(fid);

disp('data reading finished');

AA2 = A(1:2:np,:,:,:) + sqrt(-1)*A(2:2:np,:,:,:);
disp('making complex number finished');

clear A;

if( ns ~= length(pss) )
    AA2 = reshape(AA2,[np/2 nv length(pss) array_leng/length(pss)]);
    ns = length(pss);
    array_leng = array_leng / length(pss);
end

sz=size(AA2);
if( length(sz) <= 2 )
    sz(3) = 1;
    sz(4) = 1;
end
if( length(sz) <= 3 )
    sz(4) = 1;
end
%if( length(sz) <= 3 )	sz(4) = 1;	end;
dcCorr=1;
if( dcCorr == 1 )
	dcleng=6;
	for i=1:array_leng
		for j=1:ns
        		dcArea=AA2(sz(1)-dcleng+1:sz(1),sz(2)-dcleng+1:sz(2),j,i);
        		dc = sum(sum(dcArea));
        		AA2(:,:,j,i) = AA2(:,:,j,i)-dc/(dcleng^2);
		end
	end
end

%AAA = fftshift( fftn(AA2,[fn/2 fn1/2 fn2/2]) );
AA2_shift = fftshift( fft(AA2,fn/2,1), 1 );

clear AA2;

peShift_flag = 1;
if( peShift_flag )
peShift = zeros(fn/2,sz(2),sz(3),sz(4));
peShiftLine = exp( sqrt(-1)*2*pi*ppe*(-sz(2)/2:1:sz(2)/2-1)/lpe);
for n=1:sz(4)
    for i=1:sz(3)
        for m=1:fn/2
           peShift(m,:,i,n) = peShiftLine;
       end
   end
end
AAA = fftshift( fft(AA2_shift.*peShift,fn1/2,2),2 );
clear AA2_shift;
else
AAA = fftshift( fft(AA2_shift,fn1/2,2),2 );
end

disp('FT finished');
    
%matName = [directorypath '.mat'];
%save(matName,'AAA');
