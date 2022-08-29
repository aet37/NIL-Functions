
lnim=lineim;

[vv4,nl4,snr4]=lineScan_velEstRot3(lnim,[200 40 2000 1 64 0],[12 1 0.5 1],[dxy(2) dt(1)],4);
[vv3,nl3,snr3]=lineScan_velEstRot3(lnim,[200 40 2000 1 64 0],[12 1 0.5 1],[dxy(2) dt(1)],3,-16,0);
[vv2,nl2,snr2]=lineScan_velEstRot3(lnim,[200 40 2000 1 64 0],[12 1 0.5 1],[dxy(2) dt(1)],2,-16,0);
[vv1,nl1,snr1]=lineScan_velEstRot3(lnim,[200 40 2000 1 64 0],[12 1 0.5 1],[dxy(2) dt(1)],1,-16,0);

lnim=lineimwn;

[vv4wn,nl4wn,snr4wn]=lineScan_velEstRot3(lnim,[200 40 2000 1 64 0],[12 1 0.5 1],[dxy(2) dt(1)],4);
[vv3wn,nl3wn,snr3wn]=lineScan_velEstRot3(lnim,[200 40 2000 1 64 0],[12 1 0.5 1],[dxy(2) dt(1)],3,-16,0);
[vv2wn,nl2wn,snr2wn]=lineScan_velEstRot3(lnim,[200 40 2000 1 64 0],[12 1 0.5 1],[dxy(2) dt(1)],2,-16,0);
[vv1wn,nl1wn,snr1wn]=lineScan_velEstRot3(lnim,[200 40 2000 1 64 0],[12 1 0.5 1],[dxy(2) dt(1)],1,-16,0);

