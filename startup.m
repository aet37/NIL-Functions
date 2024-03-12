if isunix
    matpath = [pwd, '/'];

    addpath(matpath);
    addpath(genpath([matpath, 'mfiles/']));
    addpath([matpath, 'mrfunc/']);
    addpath([matpath, 'models/']);
    addpath([matpath, 'lsm/']);
    addpath([matpath, 'vnmr/']);
    addpath([matpath, 'plexon/']);
    addpath([matpath, 'biopac/']);
    addpath([matpath, 'xml_io_tools/']);
    addpath([matpath, 'fastICA_25/']);
    
    addpath(genpath([matpath,'chronux_2_12']))
elseif ispc
    matpath = [pwd, '\'];
    
    addpath(matpath);
    addpath(genpath([matpath, 'mfiles\']));
    addpath([matpath, 'mrfunc\']);
    addpath([matpath, 'models\']);
    addpath([matpath, 'lsm\']);
    addpath([matpath, 'vnmr\']);
    addpath([matpath, 'plexon\']);
    addpath([matpath, 'biopac\']);
    addpath([matpath, 'xml_io_tools\']);
    addpath([matpath, 'fastICA_25\']);
    
    addpath(genpath([matpath,'chronux_2_12']))

    addpath([matpath, 'windows\']);
else
    warning('No functions loaded ... unknown system');
end

clear matpath

