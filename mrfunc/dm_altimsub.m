function [f,g]=dm_altimsub(dmfile,slc,avg_flag,sections,norm_flag)
% Usage ... f=dm_altimsub(dmfile,slice,avg_flag,sections,norm_flag)
%
% This function takes images in an alternating sequence and
% subtracts them. If the average flag is on the function will
% return the average subtraction, if not it returns the time
% evolution of the subtractions. Sections is used to only
% incorporate those images between the sections. The norm flag
% will normalize the subtraction with respect to the initial
% one.

dmfid=fopen(dmfile,'r');
if dmfid<3, error('Could not open file!'); end;

dminfo=getdmodinfo(dmfid);
if nargin<5, norm_flag=0; end;
if nargin<4, sections=[1 dminfo(8)]; end;

disp('Initiating subtractions...');
cnt=1;
for m=1:length(sections)/2,
  for n=1:(sections(2*m)-sections(2*m-1)+1)/2,
    im1=getdmodim(dmfid,2*n-1+sections(2*m-1)-1,slc);
    im2=getdmodim(dmfid,2*n+sections(2*m-1)-1,slc);
    if (norm_flag),
      dim(:,:,cnt)=(im1-im2)./im1;
      dim(:,:,cnt)=dim(:,:,cnt).*(~isinf(dim(:,:,cnt)));
    else, 
      dim(:,:,cnt)=im1-im2;
    end;
    disp(['Subtracting images ',int2str(2*n-1+sections(2*m-1)-1),' - ',int2str(2*n+sections(2*m-1)-1)]);
    cnt=cnt+1;
  end;
end;

fclose(dmfid);

if (avg_flag),
  disp('Averaging...');
  for m=1:dminfo(2), for n=1:dminfo(3),
    f(m,n)=mean(dim(m,n,:));
    g(m,n)=std(dim(m,n,:));
  end; end;
else,
  f=dim;
  clear dim
end;

