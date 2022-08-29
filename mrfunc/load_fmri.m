function load_fmri(mrid,direct1)

%% Define Folders

direct2=direct1;

%% fMRI
for mm=1:length(mrid)
    
%%% Load parameters for fMRI data      
    tmpname=[direct1,'/',num2str(mrid(:,mm))];   
    disp(mrid(:,mm));
    
    f.tr = getACQP('ACQ_repetition_time', [tmpname,'/acqp'])/1000;     % tr (in s)
    f.te  = getACQP('ACQ_echo_time', [tmpname,'/acqp']);     % te (in ms)
    f.fov = getACQP('ACQ_fov', [tmpname,'/acqp'])*10; % fov in mm
    f.thk = getACQP('ACQ_slice_thick', [tmpname,'/acqp']);
    f.pul_prog = getACQP('PULPROG', [tmpname,'/acqp']);
    
    
    matrix =  getMETHOD( 'PVM_Matrix', [tmpname,'/method']);
    f.np = matrix(1); f.nv = matrix(2);
    if length(matrix)==3
        f.ns=matrix(3);
    else
        f.ns  = getACQP('NSLICES', [tmpname,'/acqp']);
    end
    
    
    f.ns_offset  = getACQP('ACQ_slice_offset', [tmpname,'/acqp']);
    f.nt  = getACQP('NR', [tmpname,'/acqp']);
    
    f.pos  = getACQP('ACQ_patient_pos', [tmpname,'/acqp']);     % FOV orientation
    f.ns_orient =  getMETHOD( 'PVM_SPackArrSliceOrient', [tmpname,'/method']);% number of EPI segments
    f.read_dir =  getMETHOD( 'PVM_SPackArrReadOrient', [tmpname,'/method']);% number of EPI segments
    
    
    %% Load Functional Images
    
    
    fid=fopen([tmpname,'/pdata/1/2dseq']);
    raw.fmri=fread(fid,[1 f.np*f.nv*f.ns*f.nt],'uint16');
    raw.fmri=reshape(raw.fmri,f.np,f.nv,f.ns,f.nt);
    
    
    raw.mean=mean(raw.fmri,4);
    
    svfname=strcat(direct2,'/',sprintf('%02d',mrid(:,mm)),'.mat');
    if exist(svfname,'file')==2
        save(svfname,'f','raw','-append');
    else
        save(svfname,'f','raw');
    end
    
        figure; imagesc(reshape(raw.mean,f.np,f.nv*f.ns)); axis image; colormap gray;
        title(strcat(num2str(mrid(mm)),f.pul_prog))
    
    clear f raw tmpname
    
end