
clear all

fpath='/usr/users/alberto/data/OIS/20060607rat/';
fname='quick_map_towi1.raw';
ftsam='sample_quick_map_towi1.raw.bin';
fbiop='RAT_JUNE072006_2.txt';

fps=30;

nfa=3;
binsize=1;

biopac_fps=1e3;
biopac_trigCh=12;
biopac_trigSel=1;
biopac_samples=biopac_fps*165;

biopac_data=readBiopac([fpath,fbiop],biopac_trigCh,biopac_trigSel,biopac_samples);

[t_act,t_des]=OISsampling([fpath,ftsam],fps);
[dcim,hdr]=readOIS([fpath,fname]);
t_fin=[1:hdr.nfr/nfa]*(nfa/fps);

t_bio=[1:size(biopac_data_1)]*(1/biopac_fps);
biopac_data_rs=interp1(t_bio,biopac_data,t_des);


