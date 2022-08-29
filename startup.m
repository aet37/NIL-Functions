
cd ~
matpath=[pwd,'/matlab/'];
%matpath=[pwd,'/Documents/MATLAB/'];

addpath([matpath,'mfiles/']);
%addpath([matpath,'control/']);
addpath([matpath,'mrfunc/']);
addpath([matpath,'models/']);
addpath([matpath,'lsm/']);
addpath([matpath,'vnmr/']);
addpath([matpath,'plexon/']);
addpath([matpath,'biopac/']);
addpath([matpath,'xml_io_tools/']);
addpath([matpath,'fastICA_25/']);
%addpath([matpath,'tmp/']);

addpath(genpath([matpath,'chronux_2_12']))

%setenv( 'FSLDIR', '/usr/local/fsl' );
%fsldir = getenv('FSLDIR');
%fsldirmpath = sprintf('%s/etc/matlab',fsldir);
%path(path, fsldirmpath);
%clear fsldir fsldirmpath;

%set(0,'defaultLineLineWidth',1.5)
%set(0,'defaultAxesFontSize',12)
%set(0,'defaultFigureColormap',gray(64));

clear matpath

