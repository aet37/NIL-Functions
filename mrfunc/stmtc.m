function out=stmtc(headeroff,on,tailoff,deadoff,cycles)
%
% Usage ... out=stmtc(headeroff,on,tailoff,deadoff,cycles)
%
% Writes a time course of the input stimuli as 0 for off
% periods and 1 for on periods.
%

n=0;
lstm=(headeroff+on+tailoff)*cycles +deadoff;
period=(headeroff+on+tailoff);
tmpstm=zeros(lstm,1);

for m=1:cycles,
for n=1:period,
  if ( n>(headeroff) & n<(on+headeroff) ),
    tmpstm(n+(m-1)*period)=1;
  end; 
end; tmpstm(n+(m-1)*period)=0.5; end;

out=tmpstm;
  
