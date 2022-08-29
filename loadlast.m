
mat_files=dir('*.mat');

if isempty(mat_files)
    disp('  no .mat file found');
else
    [~,mat_files_I]=sort(extractfield(mat_files,'datenum'));
    disp(['  load ' mat_files(mat_files_I(end)).name]);
    load(mat_files(mat_files_I(end)).name)
end

clear mat_files mat_files_I

%% old version
%[tmpa,tmpb]=unix('ls -tr1p *.mat | tail -1');
%if tmpa==0,
%  disp(sprintf('  load %s',tmpb));
%  eval(sprintf('  load %s',tmpb));
%else,
%  disp('  no mat file found');
%end;
%clear tmpa tmpb

