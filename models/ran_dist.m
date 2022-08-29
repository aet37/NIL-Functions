function [y,cdf_y]=ran_dist(pdf_y,udist)
% Usage ...  y=ran_dist(pdf_y,udist)
% 
% Generates a random distribution using uniform distribution (n entries)
% with the following premise: a uniform random x has a distribution
% pdf with corresponds to the value y that has fraction x of the
% cdf of y. Numerical integration of y(x) is performed to find the
% new distribution. If y contains only 1 column then unit step is
% assumed, otherwise include [x y].

if size(pdf_y,2)==1,
  pdf_y=pdf_y/sum(pdf_y); 
  dpdf=pdf_y(2,1)-pdf_y(1,1);
  lenpdf=length(pdf_y); find_tol=1e-2*dpdf;
  pdf_y=[[1/lenpdf:1/lenpdf:1]' pdf_y];
  cdf_y=cumsum(pdf_y(:,2));
else,
  dpdf=pdf_y(2,1)-pdf_y(1,1);
  pdf_y(:,1)=(pdf_y(:,1)-pdf_y(1,1))/(pdf_y(end,1)-pdf_y(1,1));
  pdf_y(:,2)=dpdf*pdf_y(:,2)/trapz(pdf_y(:,1),pdf_y(:,2));
  find_tol=1e-2*dpdf;
  disp('Calculating cdf...');
  cdf_y(1)=pdf_y(1,2)*dpdf;
  for m=2:size(pdf_y,1),
    cdf_y(m)=(1/dpdf)*trapz(pdf_y(1:m,1),pdf_y(1:m,2));
  end;
end; 

disp('Calculating distribution...');
for m=1:length(udist),
  
  tmp=find( cdf_y >= udist(m) );
  if (isempty(tmp)),
    disp(sprintf('Warning: could not match value (%f)...',udist(m))); 
    y(m)=0;
  else,
    %disp(sprintf('Found %d !',m));
    y(m)=pdf_y(tmp(1),1);
  end;
end;

y=y(:);

if (nargout==0),
  subplot(221)
  plot(pdf_y(:,1),pdf_y(:,2))
  ylabel('PDF')
  subplot(222)
  plot(pdf_y(:,1),cdf_y)
  ylabel('CDF')
  axis([0 1 0 1])
  subplot(212)
  hist(y,ceil(0.02*length(y)))
end;

