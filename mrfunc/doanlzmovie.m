function f=doanlzmovie(name,slno,tpts)
% Usage ...  f=doanlzmovie(filename,slno,tpts)

if length(tpts)==1,
  i1=1; iend=tpts;
else,
  i1=tpts(1); iend=tpts(2);
end;

disp('getting(showing) images...');
for m=i1:iend,
  show(getanalyzeim(name,m,slno)')
  MOV(m)=getframe;
end;
disp('displaying movie...');
movie(MOV)

if nargout==0, f=1; else, f=MOV; clear MOV ; end;
