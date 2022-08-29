function y=lsik(im,neig)
% Usage ... y=lsik(im,neig)
%
% generate laser speckle contrast image using neighborhood neig

if length(neig)==1,
  neig=ones(neig);
end;
neigsum=sum(neig(:));

y=single(zeros(size(im)));
for mm=1:size(im,3),
  tmpim=double(im(:,:,mm));
  tmpims=stdfilt(tmpim,neig);
  tmpima=conv2(tmpim,neig,'same')/neigsum;
  y(:,:,mm)=single(tmpims./tmpima);
end;

if nargout==0,
  show(y(:,:,1))
  clear y
end

