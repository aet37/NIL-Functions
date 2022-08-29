
clear all
load co2_4vals

ii=[1 2 3 4 5 6 7 9 10];

ii1=[15:30]+1;
ii2=[50:60];

ampC1=[mean(aaaC1(ii1,ii))']; % mean(aaaC1(ii2,ii))'];
ampE1=[mean(aaaE1(ii1,ii))']; % mean(aaaE1(ii2,ii))'];

i2a=[23:25:251,24:25:251,25:25:251,26:25:251]-9;
i2b=[348:25:625,349:25:625,350:25:625,351:25:625]-9;

i3a=[20:22:242,21:22:242,22:22:242,23:22:242]-6;
i3b=[306:22:550,307:22:550,308:22:550,309:22:550]-6;

MM2=calcM(mean(aE2a(i2b))/mean(aE2a(i2a)),mean(aC2a(i2b))/mean(aC2a(i2a)));
MM3=calcM(mean(aE3a(i3b))/mean(aE3a(i3a)),mean(aC3a(i3b))/mean(aC3a(i3a)));
MM=mean([MM2 MM3]);

MM2i=calcM(mean(aE2(i2b,:))./mean(aE2(i2a,:)),mean(aC2(i2b,:))./mean(aC2(i2a,:)));
MM3i=calcM(mean(aE3(i3b,:))./mean(aE3(i3a,:)),mean(aC3(i3b,:))./mean(aC3(i3a,:)));


rCBF=mean(avgC1(ii1));
rBOLD=mean(avgE1(ii1));
rCMRO2=mean(avgO1(ii1));

save co2_4vals -append rCBF rBOLD rCMRO2

