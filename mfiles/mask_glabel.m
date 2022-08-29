function y=mask_glabel(mask)
% Usage ... y=mask_glabel(mask)

tmpmask=mask;
tmpcnt=1;

tmpok=0;
while(~tmpok),
  clf, show(mask), drawnow,
  tmpin=input('  enter [a=add, r=reset, l=label#, enter=done]: ','s');
  if isempty(tmpin),
    tmpok=1;
  else,
    if strcmp(tmpin,'a'),
      tmproi=roipoly;
      tmpii=find((tmpmask>0)&(tmproi));
      if length(tmpii)>0, 
        tmpmask(tmpii)=tmpcnt; 
        disp(sprintf('  assigned %d',tmpcnt)); 
        tmpcnt=tmpcnt+1;
      end;
    elseif strcmp(tmpin,'r'),
      tmpmask=mask;
    elseif strcmp(tmpin,'l'),
      tmpcnt=str2num(tmpin(2:end));
    elseif strcmp(tmpin,'x'),
      tmpok=1;
    end;
  end;
end;

y=tmpmask;

