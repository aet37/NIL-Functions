clear

zer=get_zeros('/home/vazquez/bin/zeros.scott.P16896',32,4,4,[5 3],2200);
filt=[zeros(1,42) hanning(50)' zeros(1,327) hanning(50)' zeros(1,43)];
phs=get_phs(zer,filt,32,4,4);

[re1,im1]=phs_rgr(phs(:,1),1,32,4,4,'/disk/crunch/doug/scott/P16896',3,50,2200);
out_dat(re1,im1,32,4,50,2200,'/disk/coqui/towi/vis_3T_1/scott/crsmp1.dat');
clear re1 im1

[re2,im2]=phs_rgr(phs(:,2),2,32,4,4,'/disk/crunch/doug/scott/P16896',3,50,2200);
out_dat(re2,im2,32,4,50,2200,'/disk/coqui/towi/vis_3T_1/scott/crsmp2.dat');
clear re2 im2

[re3,im3]=phs_rgr(phs(:,3),3,32,4,4,'/disk/crunch/doug/scott/P16896',3,50,2200);
out_dat(re3,im3,32,4,50,2200,'/disk/coqui/towi/vis_3T_1/scott/crsmp3.dat');
clear re3 im3

[re4,im4]=phs_rgr(phs(:,4),4,32,4,4,'/disk/crunch/doug/scott/P16896',3,50,2200);
out_dat(re4,im4,32,4,50,2200,'/disk/coqui/towi/vis_3T_1/scott/crsmp4.dat');
clear re4 im4

