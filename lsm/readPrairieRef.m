function y=readPrairieRef(fname)
% Usage ... y=readPrairieRef(foldername)

tmpdir=dir([fname,filesep,'References']);

tmpcnt=0;
if ~isempty(tmpdir),
    for mm=1:length(tmpdir),
        if strcmp(tmpdir(mm).name,'.')|strcmp(tmpdir(mm).name,'..'),
            % skip
        else
            tmpcnt=tmpcnt+1;
            tmpdir2(tmpcnt)=tmpdir(mm);
        end
    end
end

if tmpcnt==0,
    error('empty, References folder not found in fname');
end

for mm=1:length(tmpdir2),
    disp(sprintf('  reading %s',tmpdir2(mm).name));
    y.fname{mm}=tmpdir2(mm).name;
    y.im{mm}=imread([tmpdir2(mm).folder,filesep,tmpdir2(mm).name]);
end
