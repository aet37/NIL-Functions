function [out,meanr]=matclip(timecourse,cycles,piece,normind)
% Usage ... [out,meanr]=matclip(timecourse,cycles,piece,normind)
%
% Concatinates portions of variables into a matrix
% Arranges data in rows
% Piece works by only including pieces of the timecourse
%  if piece has only one element it assumes from index 1
%  to index piece, if piece has 2 elements, the first is
%  start and the second is finish.
% Normind is a parameter for normalization of data

if nargin<4, normind=0; end;
if nargin<3, piece=0; end

if ( length(piece)==1 ), 
  strt=1; endp=piece;
  if ( piece==0 ), endp=length(timecourse)/cycles; end;
else, 
  strt=piece(1); endp=piece(2);
end;
lpiece=endp-strt;
ltc=length(timecourse)/cycles;
stc=size(timecourse);

ii=1;
for aa=1:stc(1), for bb=0:cycles-1,
  %[strt+ltc*bb endp+ltc*bb]
  tmp(ii,:)=timecourse(aa,strt+ltc*bb:endp+ltc*bb);
  tmpmean(ii)=mean(timecourse(aa,strt+ltc*bb:endp+ltc*bb));
  ii=ii+1;
end; end;

norm=0;
if ( length(normind)==1 ),
  if ( normind~=0),
    strtn=1; endpn=normind; norm=1; 
  end;
elseif ( length(normind)==2 ), 
  strtn=normind(1); endpn=normind(2); norm=1;
else, 
  norm=0;
end;

tmptotsize=size(tmp);
if (norm),
  for n=1:tmptotsize(1),
    tmpmean(n)=mean(tmp(n,strtn:endpn));
    tmp(n,:)=(tmp(n,:)-tmpmean(n))/tmpmean(n);
  end;
end;

out=tmp;
meanr=tmpmean;

