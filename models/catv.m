function [new]=catv(old1,old2,old3,old4,old5,old6,old7)
% Usage ... [new]=catv(old1,old2,old3,old4,...)
% Concatinates old vectors into one.

new=0;
tmplen=0;

for m=1:nargin,
  tmpcmd=['for n=1:length(old',int2str(m),'), '];
  tmpcmd=[tmpcmd,'new(n+tmplen)=old',int2str(m),'(n); end;'];
  eval(tmpcmd);
  tmplen=length(new);
end;
