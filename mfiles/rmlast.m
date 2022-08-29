
[tmpa,tmpb]=unix('ls -tr1p *.mat | tail -1');
if tmpa==0,
  tmpin=input(sprintf('  rm %s: [1/enter=yes, 0=no]: ',tmpb(1:end-1)));
  if tmpin~=0, eval(sprintf('  !rm %s',tmpb)); end;
else,
  disp('  no mat file found');
end;
clear tmpa tmpb

