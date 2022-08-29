function [f,g]=an_altvolsub(file,tdim,avg_flag,sections,norm_flag)
% Usage ... f=an_altimsub(file,tdim,avg_flag,sections,norm_flag)
%
% This function takes images in an alternating sequence and
% subtracts them. If the average flag is on the function will
% return the average subtraction, if not it returns the time
% evolution of the subtractions. Sections is used to only
% incorporate those images between the sections. The norm flag
% will normalize the subtraction with respect to the initial
% one.

hdrfile=sprintf('%s_0001.hdr',file);

info=getanalyzeinfo(hdrfile);
if nargin<6, norm_flag=0; end;
if nargin<5, sections=[1 tdim]; end;

disp('Initiating subtractions...');
dim=zeros([info(1:3)' info(4)/2]);
cnt=1;
for m=1:length(sections)/2,
  for n=1:(sections(2*m)-sections(2*m-1)+1)/2,
    im1=getanalyzevol(file,2*n-1+sections(2*m-1)-1);
    im2=getanalyzevol(file,2*n+sections(2*m-1)-1);
    if (norm_flag),
      dim(:,:,:,cnt)=(im1-im2)./im1;
      dim(:,:,:,cnt)=dim(:,:,:,cnt).*(~isinf(dim(:,:,:,cnt)));
    else, 
      dim(:,:,:,cnt)=im1-im2;
    end;
    disp(['Subtracting images ',int2str(2*n-1+sections(2*m-1)-1),' - ',int2str(2*n+sections(2*m-1)-1)]);
    cnt=cnt+1;
  end;
end;

if (avg_flag),
  disp('Averaging...');
  for m=1:info(1), for n=1:info(2), for o=1:info(3),
    f(m,n,o)=mean(dim(m,n,o,:));
    g(m,n,o)=std(dim(m,n,o,:));
  end; end; end;
else,
  f=dim;
  clear dim
end;

