function vname=chkvarname(cstr)
% Usage ... vname=chkvarname(str)
%
% Checks the string str and returns a string of characters that can be used
% as a matlab variable

tmpi=[];
tmpi=[tmpi strfind(cstr,'(')];
tmpi=[tmpi strfind(cstr,')')];
tmpi=[tmpi strfind(cstr,'[')];
tmpi=[tmpi strfind(cstr,']')];
tmpi=[tmpi strfind(cstr,'<')];
tmpi=[tmpi strfind(cstr,'>')];
tmpi=[tmpi strfind(cstr,'+')];
tmpi=[tmpi strfind(cstr,'-')];
tmpi=[tmpi strfind(cstr,'*')];
tmpi=[tmpi strfind(cstr,'/')];
tmpi=[tmpi strfind(cstr,'%')];
tmpi=[tmpi strfind(cstr,'$')];
tmpi=[tmpi strfind(cstr,'#')];
tmpi=[tmpi strfind(cstr,'!')];
tmpi=[tmpi strfind(cstr,'@')];
tmpi=[tmpi strfind(cstr,'^')];
tmpi=[tmpi strfind(cstr,'&')];
if ~isempty(tmpi),
  tmpcnt=0;
  %disp(sprintf('  replacing %d',length(tmpi))); tmpi,
  for mm=1:length(cstr),
    if isempty(find(tmpi==mm)),
      tmpcnt=tmpcnt+1;
      vname(tmpcnt)=cstr(mm);
    end;
  end;
else,
  vname=cstr;
end;

tmpchk=str2num(vname(1));
if ~isempty(tmpchk), vname=vname(2:end); end;
tmpchk=str2num(vname(1));
if ~isempty(tmpchk), vname(1)='X'; end;

%vname=genvarname(vname);
