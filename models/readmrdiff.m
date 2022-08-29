
% File read-in

fid=fopen(filename,'r');
if (fid<3) error('Could not open file!'); end;

spins_n=fread(fid,1,'int');
perts_n=fread(fid,1,'int');
totalsignal=fread(fid,1,'double');
for i=1:spins_n, 
  spins_space(i,1)=fread(fid,1,'double');
  spins_space(i,2)=fread(fid,1,'double');
  spins_space(i,3)=fread(fid,1,'double');
end;
for i=1:spins_n,
  spins_initspace(i,1)=fread(fid,1,'double');
  spins_initspace(i,2)=fread(fid,1,'double');
  spins_initspace(i,3)=fread(fid,1,'double');
end;
for i=1:spins_n,
  spins_finalspace(i,1)=fread(fid,1,'double');
  spins_finalspace(i,2)=fread(fid,1,'double');
  spins_finalspace(i,3)=fread(fid,1,'double');
end;
for i=1:spins_n, spins_field(i)=fread(fid,1,'double'); end;
for i=1:spins_n, spins_initfield(i)=fread(fid,1,'double'); end;
for i=1:spins_n, spins_finalfield(i)=fread(fid,1,'double'); end;
for i=1:spins_n, spins_totalmag(i)=fread(fid,1,'double'); end;
for i=1:spins_n, spins_totalphs(i)=fread(fid,1,'double'); end;
for i=1:spins_n, spins_class(i)=fread(fid,1,'int'); end;
for i=1:spins_n, spins_initclass(i)=fread(fid,1,'int'); end;
for i=1:spins_n, spins_finalclass(i)=fread(fid,1,'int'); end;
for i=1:perts_n, 
  perts_space(i,1)=fread(fid,1,'double');
  perts_space(i,2)=fread(fid,1,'double');
  perts_space(i,3)=fread(fid,1,'double');
end;
for i=1:perts_n,
  perts_initspace(i,1)=fread(fid,1,'double');
  perts_initspace(i,2)=fread(fid,1,'double');
  perts_initspace(i,3)=fread(fid,1,'double');
end;
for i=1:perts_n,
  perts_finalspace(i,1)=fread(fid,1,'double');
  perts_finalspace(i,2)=fread(fid,1,'double');
  perts_finalspace(i,3)=fread(fid,1,'double');
end;

fclose(fid);
clear fid

% Calculation on simulation data

spins_d=((sum(((spins_finalspace-spins_initspace).^2)')).^(0.5))';
perts_d=((sum(((perts_finalspace-perts_initspace).^2)')).^(0.5))';

signal=abs(sum(spins_totalmag.*exp(j*spins_totalphs)));

