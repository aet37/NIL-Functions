function [recon_stackDB,evals,evecs,coeffs]=pcaimdenoise(stack16,recon_keep,transp_flag,mean_flag)
% Usage ... [recon_stackDB,evals,evecs,coeffs]=pcaimdenoise(imgdata,recon_keep,transpose_flag,mean_flag)
%
% Economy-based PCA denoising
% default is transp_flag=1 and mean_flag=1
%
% Ex. data2=pcaimdenoise(single(data(1:100,1:100,:)),'select',1,1);
%     data2=pcaimdenoise(data(1:100,1:100,:),40,1,1);
%     data2=pcaimdenoise(single(volbin(data,[2 2 2])),0.8);
%     data2=pcaimdenoise(data(1:100,1:100,:),[4 [6:200]]);

% based on jeffimdenoise

stack16=squeeze(stack16);

if nargin<4, mean_flag=1; end;
if nargin<3, transp_flag=1; end;

stksize=size(stack16);
width=stksize(1);
height=stksize(2);
frames=stksize(3);

if prod(stksize)>170e6, error('  data too large'); end;

%in order to process the movie we must convert it to vectors, as discussed.
vectordataDB=reshape(double(stack16), width*height, frames);
if mean_flag,
  mean_fr=mean(vectordataDB,2); 
  vectordataDB=vectordataDB-mean_fr*ones(1,frames);
end;

%calculate the SVD
if transp_flag,
    [evecs,evals,coeffs]=svd(vectordataDB',0);
else
    [evecs,evals,coeffs]=svd(vectordataDB,0);    
end;
evals=diag(evals);

%we don't need the original data anymore
clear stack16 vectordataDB;

%figure;
%semilogy(evals(2:50));

%choose the number of singular values for the reconstructed movie
if ischar(recon_keep),
  recon_keep=0.8;
  tmpev=cumsum(evals.^2); tmpev=tmpev/tmpev(end);
  recon_keep=find(tmpev>recon_keep,1);
  if recon_keep>80, 
      disp(sprintf('  limiting to %d from %d (%d)',80,recon_keep,size(evecs,2))); 
      recon_keep=80; 
  end;

  figure(1), 
  clf, showmany(reshape(coeffs(:,1:recon_keep),[stksize(1:2) recon_keep])), 
  figure(2), 
  clf, plotmany(evecs(:,1:recon_keep)),
  figure(3),
  clf, plot(cumsum(evals.^2)/sum(evals.^2))
  
  recon_keep=input('  select components to keep: ');
end

if ~exist('recon_keep'), recon_keep=0.8; end;
if length(recon_keep)==1, 
  if recon_keep<1,
    tmpev=cumsum(evals.^2); tmpev=tmpev/tmpev(end);
    recon_keep=find(tmpev>recon_keep,1);
  end;
  recon_keep=[1:recon_keep]; 
end;
disp(sprintf('  keeping %d of %d components...',length(recon_keep),size(evecs,2)));


%reconstruct the movie by adding up these modes, singular values and
%coefficients:
recondataDB = evecs(:,recon_keep) * diag(evals(recon_keep)) * coeffs(:,recon_keep)';

if transp_flag, recondataDB=recondataDB'; end;
if mean_flag, recondataDB=recondataDB+mean_fr*ones(1,frames); end;

%The data is still in vector format; reshape it back to movie frames
recon_stackDB=reshape(recondataDB,width,height,frames);

evals=diag(evals);
coeffs=coeffs(:,recon_keep);

