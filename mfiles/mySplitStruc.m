function y=mySplitStruc(x,ii)
% Usage ... y=mySplitStruc(x,ii)

tmpname=fieldnames(x);
for mm=1:length(tmpname),
  eval(sprintf('tmpvar=x.%s;',tmpname{mm}));
  tmpdim=size(tmpvar);
  if (tmpdim(1)==prod(tmpdim))|(tmpdim(2)==prod(tmpdim)),
    eval(sprintf('y.%s=tmpvar(ii(1):ii(2));',tmpname{mm}));
  elseif (length(tmpdim)==2),
    eval(sprintf('y.%s=tmpvar(ii(1):ii(2),:);',tmpname{mm}));
  elseif (length(tmpdim)==3),
    eval(sprintf('y.%s=tmpvar(ii(1):ii(2),:,:);',tmpname{mm}));
  else,
    disp(sprintf('  skipping %s, unsupported dimmension...',tmpname{mm}));
  end;
end;

  

