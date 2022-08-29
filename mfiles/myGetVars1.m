function myGetVars1(fnames,outVars,inVars,sname)
% Usage ... myGetVars1(fnames,outVars,inVars,sname)
%
% Ex. myGetVars1(fnames_all,label_all,{'maks*','tc*','rad*'})
%

if nargin<4, sname='tmp_var_summ'; end;
if exist([sname,'.mat'],'file'),
  tmpin=input(sprintf('  file %s.mat exists [1/enter=load/cont, 2=rewrite, 0/enter=exit]: ',sname));
  if isempty(tmpin), tmpin=1; end;
  if tmpin==1,
    fnames_orig=fnames;
    outVars_orig=outVars;
    inVars_orig=inVars;
    sname_orig=sname;
    disp('  loading file and continuing...');
    load(sname);
    fnames_file=fnames; fnames=fnames_orig;
    outVars_file=outVars; outVars=outVars_orig;
    inVars_file=inVars; inVars=inVars_orig;
    sname_file=sname; sname=sname_orig;
  elseif tmpin==2,
    disp('  deleting file and continuing...');
    eval(sprintf('!rm %s.mat',sname));
  else,
    disp('  exiting...');
    return,
  end;
end;

loadvar_str=[];
for mm=1:length(inVars),
  eval(sprintf('loadvar_str=[loadvar_str,'' %s''];',inVars{mm})); 
end;

for mm=1:length(fnames),
  for nn=1:length(inVars),
    clear tmpwho
    eval(sprintf('clear %s',inVars{nn}));
    eval(sprintf('load %s %s',fnames{mm},inVars{nn}));
    eval(sprintf('tmpwho=who(''%s'');',inVars{nn}));
    if ~isempty(tmpwho),
      for oo=1:length(tmpwho),
        eval(sprintf('%s.%s=%s;',outVars{mm},tmpwho{oo}));
      end;
    end;
    eval(sprintf('clear %s',inVars{nn}));
  end;
end;

disp(sprintf('  saving %s...',sname));
save(sname);

