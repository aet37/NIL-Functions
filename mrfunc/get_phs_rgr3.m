function [new_re_data,new_im_data,A,re,im,ind]=gt_phs_rgr3(phs,shot,nphs,npmult,spirals,filename,slc,skp,fsize,re,im)
% Usage ... [re,im,re,im]=phs_rgr(phs,shot,nphs,npmult,spirals,filename,slice,skip,framesize,real,imaginary)
%
% Returns real and imaginary parts in individual variables
% of the entire data. This routine processes one shot at a time.

if strcmp(filename,'')&exist('re')&exist('im')
  % Everything OK
  disp(['Raw data provided...']);
else
  fid=fopen(filename,'r');
  if fid<3 error('Could not open file!'); end;

  o=0;
  re=zeros([nphs*npmult fsize-skp]);
  im=zeros([nphs*npmult fsize-skp]);
  disp(['Reading raw data (FIDs)...']);
  for n=1:nphs*npmult,
    if ~rem(n-1,nphs) o=o+1; end;
    k=(n-1)*spirals+o+(shot-1);
    ind(n)=k;
    [tmp,r,i]=fidread(fid,'sf9',slc,k); r=r'; i=i';
    re(n,:)=r(skp+1:fsize); im(n,:)=i(skp+1:fsize);
    clear tmp r i
  end;
  disp(['Done...']);

  fclose(fid);
end;

disp(['Initiating Analysis...']);
A=[ones([length(phs) 1]) cos(2*1*pi*phs(:)) sin(2*1*pi*phs(:)) cos(2*2*pi*phs(:)) sin(2*2*pi*phs(:))];
D=ones(size(A)); M=mean(A); M(1)=0;
for m=1:size(A,2), D(:,m)=M(m)*D(:,m); end;
A=A-D; %size(A)

x=(1:(nphs*npmult)).';

new_re_data=zeros([nphs*npmult (fsize-skp)]);
new_im_data=zeros([nphs*npmult (fsize-skp)]);

for m=1:(fsize-skp),

 	
  pr=polyfit(x,re(:,m),2);
  pi=polyfit(x,im(:,m),2);

  det_re = re(:,m) - polyval(pr,x);
  det_im = im(:,m) - polyval(pi,x);

  coeff_re=A\det_re; %size(coeff_re)
  coeff_im=A\det_im; %size(coeff_im)

  new_re_data(:,m)=re(:,m) - A*coeff_re;
  new_im_data(:,m)=im(:,m) - A*coeff_im;
end;

disp(['Done...']);

if nargout==0
  % Everything OK so far
end;
