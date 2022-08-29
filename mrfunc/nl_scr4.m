clear
load nl_res

stats_m_m(:,1)=mean([stats_m_1(:,1) stats_m_2(:,1) stats_m_3(:,1) stats_m_4(:,1) stats_m_5(:,1)]')';
stats_m_s(:,1)=std([stats_m_1(:,1) stats_m_2(:,1) stats_m_3(:,1) stats_m_4(:,1) stats_m_5(:,1)]')';
stats_m_m(:,2)=mean([stats_m_1(:,2) stats_m_2(:,2) stats_m_3(:,2) stats_m_4(:,2) stats_m_5(:,2)]')';
stats_m_s(:,2)=std([stats_m_1(:,2) stats_m_2(:,2) stats_m_3(:,2) stats_m_4(:,2) stats_m_5(:,2)]')';
stats_m_m(:,3)=mean([stats_m_1(:,3) stats_m_2(:,3) stats_m_3(:,3) stats_m_4(:,3) stats_m_5(:,3)]')';
stats_m_s(:,3)=std([stats_m_1(:,3) stats_m_2(:,3) stats_m_3(:,3) stats_m_4(:,3) stats_m_5(:,3)]')';
stats_m_m(:,4)=mean([stats_m_1(:,4) stats_m_2(:,4) stats_m_3(:,4) stats_m_4(:,4) stats_m_5(:,4)]')';
stats_m_s(:,4)=std([stats_m_1(:,4) stats_m_2(:,4) stats_m_3(:,4) stats_m_4(:,4) stats_m_5(:,4)]')';

stats_e2_m(:,1)=mean([stats_e2_1(:,1) stats_e2_2(:,1) stats_e2_3(:,1) stats_e2_4(:,1) stats_e2_5(:,1)]')';
stats_e2_s(:,1)=std([stats_e2_1(:,1) stats_e2_2(:,1) stats_e2_3(:,1) stats_e2_4(:,1) stats_e2_5(:,1)]')';
stats_e2_m(:,2)=mean([stats_e2_1(:,2) stats_e2_2(:,2) stats_e2_3(:,2) stats_e2_4(:,2) stats_e2_5(:,2)]')';
stats_e2_s(:,2)=std([stats_e2_1(:,2) stats_e2_2(:,2) stats_e2_3(:,2) stats_e2_4(:,2) stats_e2_5(:,2)]')';

stats_e4_m(:,1)=mean([stats_e4_1(:,1) stats_e4_2(:,1) stats_e4_3(:,1) stats_e4_4(:,1) stats_e4_5(:,1)]')';
stats_e4_s(:,1)=std([stats_e4_1(:,1) stats_e4_2(:,1) stats_e4_3(:,1) stats_e4_4(:,1) stats_e4_5(:,1)]')';
stats_e4_m(:,2)=mean([stats_e4_1(:,2) stats_e4_2(:,2) stats_e4_3(:,2) stats_e4_4(:,2) stats_e4_5(:,2)]')';
stats_e4_s(:,2)=std([stats_e4_1(:,2) stats_e4_2(:,2) stats_e4_3(:,2) stats_e4_4(:,2) stats_e4_5(:,2)]')';
stats_e4_m(:,3)=mean([stats_e4_1(:,3) stats_e4_2(:,3) stats_e4_3(:,3) stats_e4_4(:,3) stats_e4_5(:,3)]')';
stats_e4_s(:,3)=std([stats_e4_1(:,3) stats_e4_2(:,3) stats_e4_3(:,3) stats_e4_4(:,3) stats_e4_5(:,3)]')';

stats_e8_m(:,1)=mean([stats_e8_1(:,1) stats_e8_2(:,1) stats_e8_3(:,1) stats_e8_4(:,1) stats_e8_5(:,1)]')';
stats_e8_s(:,1)=std([stats_e8_1(:,1) stats_e8_2(:,1) stats_e8_3(:,1) stats_e8_4(:,1) stats_e8_5(:,1)]')';
stats_e8_m(:,2)=mean([stats_e8_1(:,2) stats_e8_2(:,2) stats_e8_3(:,2) stats_e8_4(:,2) stats_e8_5(:,2)]')';
stats_e8_s(:,2)=std([stats_e8_1(:,2) stats_e8_2(:,2) stats_e8_3(:,2) stats_e8_4(:,2) stats_e8_5(:,2)]')';
stats_e8_m(:,3)=mean([stats_e8_1(:,3) stats_e8_2(:,3) stats_e8_3(:,3) stats_e8_4(:,3) stats_e8_5(:,3)]')';
stats_e8_s(:,3)=std([stats_e8_1(:,3) stats_e8_2(:,3) stats_e8_3(:,3) stats_e8_4(:,3) stats_e8_5(:,3)]')';
stats_e8_m(:,4)=mean([stats_e8_1(:,4) stats_e8_2(:,4) stats_e8_3(:,4) stats_e8_4(:,4) stats_e8_5(:,4)]')';
stats_e8_s(:,4)=std([stats_e8_1(:,4) stats_e8_2(:,4) stats_e8_3(:,4) stats_e8_4(:,4) stats_e8_5(:,4)]')';

save nl_res
