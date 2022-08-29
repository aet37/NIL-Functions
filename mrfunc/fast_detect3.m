function [z_map_under,z_map_over,base,basestd,under,over]=fast_detect3(f1,slc,baserange,underrange,overrange,norm,f2,f3,f4,f5,f6)
% Usage ... [zmap_under,zmap_over]=fast_detect3(file,slc,baserng,underrng,overrng,norm,f2,...)
%
% Calculated the z-maps normalizing the images over the baseline
%

nfiles=nargin-5;

if nfiles<1, 
  error('Invalid number of input arguments!');
end;

for m=1:nfiles,
  tmpcmd=['dmfid(',int2str(m),')=fopen(f',int2str(m),',''r'');'];
  eval(tmpcmd);
end;

if (length(baserange)~=length(underrange))|(length(baserange)~=length(overrange)),
  error('Invalid ranges!');
end;
if rem(length(baserange),2),
  error('Ranges must be paired!');
end;

nsections=length(baserange)/2;

disp('Calculating Baseline Mean map...');
base=0;
cnt=0;
for m=1:nfiles,
  for n=1:nsections,
  for o=baserange(2*n-1):baserange(2*n),
    base=base+getdmodim(dmfid(m),o,slc);
    cnt=cnt+1;
  end; end;
end;
base=(1/cnt)*base;

disp('Calculating Baseline Std map...');
if (norm),
  basestd=zeros(size(base)); cnts=0; cntt=0;
  new_mat=zeros([nsections baserange(2)-baserange(1)+1]);
  for n=1:nsections, new_mat(n,:)=[baserange(2*n-1):baserange(2*n)]; end;
  for n=1:size(new_mat,2),
    tmp=0; cntt=0;
    for o=1:size(new_mat,1),
      for m=1:nfiles,   
        tmp=tmp+getdmodim(dmfid(m),new_mat(o,n),slc);
        cntt=cntt+1;
      end;
    end;
    tmp=(1/cntt)*tmp;
    basestd=basestd+((tmp-base).^2);
    cnts=cnts+1;
  end;
  basestd=((1/(cnts-1))*(basestd)).^(0.5);
else,
  basestd=0;
  for m=1:nfiles,
    for n=1:nsections,
    for o=baserange(2*n-1):baserange(2*n),
      basestd=basestd+((getdmodim(dmfid(m),o,slc)-base).^2);
    end; end;
  end;
  basestd=((1/(cnt-1))*(basestd)).^(0.5);
end;

disp('Calculating Over/Under maps...');
over=0; under=0; cnto=0; cntu=0;
for m=1:nfiles,
  for n=1:nsections,
    for o=underrange(2*n-1):underrange(2*n),
      under=under+getdmodim(dmfid(m),o,slc);
      cntu=cntu+1; 
    end;
    for o=overrange(2*n-1):overrange(2*n),
      over=over+getdmodim(dmfid(m),o,slc);
      cnto=cnto+1;
    end;
  end;
end;
under=(1/cntu)*under;
over=(1/cnto)*over;

z_map_under=zeros(size(basestd));
z_map_over=zeros(size(basestd));
for m=1:size(basestd,1),
  for n=1:size(basestd,2),
    if basestd(m,n)==0,
      z_map_under(m,n)=0;
      z_map_over(m,n)=0;
    else,
      z_map_under(m,n)=(under(m,n)-base(m,n))/basestd(m,n);
      z_map_over(m,n)=(over(m,n)-base(m,n))/basestd(m,n);
    end;
  end;
end;

disp('Done...');

for m=1:nfiles,
  fclose(dmfid(m));
end;

if nargout==0,
  figure(1); show(base')
  figure(2); show(basestd')
  figure(3); subplot(211); show(under'); subplot(212); show(over');
  figure(4); subplot(211); show(z_map_under'); subplot(212); show(z_map_over');
end;
