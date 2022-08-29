
clear all
clc
close all

mdir='/Volumes/PhysRAID/towi/data/ad/20171201_appMRI1_APP_mouse_2_R_6.0.1/20171201_095550_APP_mouse_2_R_1_1'; % main directory where data is stored on your computer


%% 

%%% RARE
% mrid=22:25; % folder number

%%% DTI EPI
% mrid=26;

%%% FcFLASH Angio
% mrid=[36];

%%% FLASH
% mrid=[16 37 39];

%%% EPI
% mrid=[40 43];

%%% CASL EPI
% mrid=[29:32 34 41 44]; % 

%%% Fair EPI
% mrid=[42 45];

%%% All
mrid=[16 18:20 22:26 29:32 34 36 37 39:45];

%%
load_fmri(mrid,mdir); 