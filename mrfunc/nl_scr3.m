
clear
load nl_vis8
stats_m_1=stats_m;
stats_e2_1=stats_e2;
stats_e4_1=stats_e4;
stats_e8_1=stats_e8;
save tmp_1 stats_m_1 stats_e2_1 stats_e4_1 stats_e8_1

clear
load nl_vis9
stats_m_2=stats_m;
stats_e2_2=stats_e2;
stats_e4_2=stats_e4;
stats_e8_2=stats_e8;
save tmp_2 stats_m_2 stats_e2_2 stats_e4_2 stats_e8_2

clear
load nl_vis13
stats_m_3=stats_m;
stats_e2_3=stats_e2;
stats_e4_3=stats_e4;
stats_e8_3=stats_e8;
save tmp_3 stats_m_3 stats_e2_3 stats_e4_3 stats_e8_3

clear
load nl_vis14
stats_m_4=stats_m;
stats_e2_4=stats_e2;
stats_e4_4=stats_e4;
stats_e8_4=stats_e8;
save tmp_4 stats_m_4 stats_e2_4 stats_e4_4 stats_e8_4

clear
load nl_vis19
stats_m_5=stats_m;
stats_e2_5=stats_e2;
stats_e4_5=stats_e4;
stats_e8_5=stats_e8;
save tmp_5 stats_m_5 stats_e2_5 stats_e4_5 stats_e8_5

clear
load tmp_1
load tmp_2
load tmp_3
load tmp_4
load tmp_5
save nl_res

