
% test of methods to measure slope of lines in an image
% 1. SVD
% 2. Proj STDEV
% 3. Proj FT
% 4. Radon transform


vel1(:,1)=lineScan_velEstRot3(lineimwn,[80 20 240 1 40],[dxy(2) dt],1,-11,-1);
vel1(:,2)=lineScan_velEstRot3(lineimwn,[80 20 240 1 40],[dxy(2) dt],2,-11,-1);
vel1(:,3)=lineScan_velEstRot3(lineimwn,[80 20 240 1 40],[dxy(2) dt],3,-11,-1);
vel1(:,4)=lineScan_velEstRot3(lineimwn,[80 20 240 1 40],[dxy(2) dt],4,-11,-1);

vel2(:,1)=lineScan_velEstRot3(lineimwn,[40 10 240 1 40],[dxy(2) dt],1,-11,-1);
vel2(:,2)=lineScan_velEstRot3(lineimwn,[40 10 240 1 40],[dxy(2) dt],2,-11,-1);
vel2(:,3)=lineScan_velEstRot3(lineimwn,[40 10 240 1 40],[dxy(2) dt],3,-11,-1);
vel2(:,4)=lineScan_velEstRot3(lineimwn,[40 10 240 1 40],[dxy(2) dt],4,-11,-1);

vel3(:,1)=lineScan_velEstRot3(lineimwn,[80 20 240 3 62],[dxy(2) dt],1,-11,-1);
vel3(:,2)=lineScan_velEstRot3(lineimwn,[80 20 240 3 62],[dxy(2) dt],2,-11,-1);
vel3(:,3)=lineScan_velEstRot3(lineimwn,[80 20 240 3 62],[dxy(2) dt],3,-11,-1);
vel3(:,4)=lineScan_velEstRot3(lineimwn,[80 20 240 3 62],[dxy(2) dt],4,-11,-1);

[mean(vel1);mean(vel2);mean(vel3)],
[std(vel1);std(vel2);std(vel3)],



