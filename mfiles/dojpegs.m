
exam=1511;
series=[4 5 9];
nims=[5 1 60];

for m=1:length(series),
  for n=1:nims(m),
    tmpcmd1=sprintf('a=readge(''e%ds%di%d'',[256 256],8432);',exam,series(m),n);
    eval(tmpcmd1);
    tmpcmd2=sprintf('mywrtjpg(a,''e%ds%di%03d.jpg'');',exam,series(m),n);
    eval(tmpcmd2);
  end;
end;

clear all

