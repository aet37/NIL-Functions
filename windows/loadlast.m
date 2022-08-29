mat_files=dir('*.mat');

if isempty(mat_files)
    disp('  no .mat file found');
else
    [~,mat_files_I]=sort(extractfield(mat_files,'datenum'));
    disp(['  load ' mat_files(mat_files_I(end)).name]);
    load(mat_files(mat_files_I(end)).name)
end

clear mat_files mat_files_I

