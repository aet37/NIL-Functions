function setfigsize(scalev)
% Usage ... setfigsize(scalev)
%
% ex. setfigsize(2) scales the figure up by 2
% ex. setfigsize([1 2]) scales the y-dim of the figure by 2

if length(scalev)==1, scalev=[scalev scalev]; end;

paperpos = get(gcf,'Position');
newpos = [paperpos(1:2) paperpos(3:4).*scalev];
set(gcf,'Position',newpos);
