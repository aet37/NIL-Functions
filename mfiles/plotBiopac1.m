function plotBiopac1(data)
% Usage ... plotBiopac1(data)

myFields=fieldnames(data);
nfields=length(myFields);

clf,
for mm=1:nfields,
    subplot(nfields,1,mm),
    eval(sprintf('plot(data.%s), axis tight, grid on, ylabel(''%s''),',myFields{mm},deblank(myFields{mm})))
end
drawnow,
