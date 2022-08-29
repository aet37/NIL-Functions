function setxtick(xticklabel,xtick)

if nargin<2,
  xtick=[1:length(xticklabel)];
end;

set(gca,'XTick',xtick)
set(gca,'XTickLabel',xticklabel)

