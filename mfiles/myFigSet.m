function myFigSet(fh,p1,p2,p3,p4,p5,p6)
% Usage ... myFigSet(fh,p1,p2,p3,p4,p5,p6)
% 
% Runs figure settings on all axis or subplots
%
% Ex. myFitSet(2,'xlim',[100 1100])

figure(fh),
tmph=gcf;

nplots=length(tmph.Children);

nargs=nargin-1;

for mm=1:nargs-1,
    eval(sprintf('thisvar=p%d;',mm));
    if mm<=(nargs-1), eval(sprintf('thisvar2=p%d;',mm+1)); else, thisvar2=[]; end;
    if ischar(thisvar),
        for nn=1:nplots,
        if isempty(thisvar2), 
            set(tmph.Children(nn),thisvar); 
        else
            set(tmph.Children(nn),thisvar,thisvar2);
        end;
        end
    end
end
