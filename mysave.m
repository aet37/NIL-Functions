
if exist('sname','var'),
  tmpin=input(sprintf('  saving %s proceed [0=no, 1/enter=yes]: ',sname));
  if isempty(tmpin), tmpin=1; end;
  if tmpin, eval(sprintf('save %s -v7.3',sname)); end;
  clear tmpin
end
