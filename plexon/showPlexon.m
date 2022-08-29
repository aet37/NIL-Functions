function showPlexon(fname,eventCh,lfpCh,durArray)
% Usage ... showPlexon(fname,eventCh,lfpCh,durArray)

for mm=1:length(eventCh),
    tmpch=my_plx_lfp(fname,eventCh,lfpCh(mm),durArray);
    eval(sprintf('plx%02d=tmpch;',mm));
    figure(mm), clf,
    plotmsd4(tmpch.tt,mean(tmpch.ndata,2),std(tmpch.ndata,[],2)),
    drawnow,
    clear tmpch
end

disp(sprintf('save %s fname eventCh lfpCh durArray plx*',fname(1:end-4)));
eval(sprintf('save %s fname eventCh lfpCh durArray plx*',fname(1:end-4)));

