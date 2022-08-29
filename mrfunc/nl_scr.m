
clear
load nl_vis8

%t=0.96*[1:64]+2*0.96;
%ti(19)=t(19);
%for m=20:64, ti(m)=ti(m-1)+1; end;
%for m=18:-1:1, ti(m)=ti(m+1)-1; end;
%x=[1 2 4 8];
%norm=[7 18];
%pos_act=[19 40];

%[c_1,m_1,s_1]=mat_clip(tc_1,5,norm);
%[c_2,m_2,s_2]=mat_clip(tc_2,5,norm);
%[c_4,m_4,s_4]=mat_clip(tc_4,5,norm);
%[c_8,m_8,s_8]=mat_clip(tc_8,5,norm);

%d_1=lin_regr(c_1,[1:64],[norm 56 64]);
%d_2=lin_regr(c_2,[1:64],[norm 56 64]);
%d_4=lin_regr(c_4,[1:64],[norm 56 64]);
%d_8=lin_regr(c_8,[1:64],[norm 56 64]);

%i_1=interp1(t(:),d_1,ti(:));
%i_2=interp1(t(:),d_2,ti(:));
%i_4=interp1(t(:),d_4,ti(:));
%i_8=interp1(t(:),d_8,ti(:));

%clear d_1 d_2 d_4 d_8
%clear m_1 m_2 m_4 m_8 s_1 s_2 s_4 s_8

%d_1=m_1; d_2=m_2; d_4=m_4; d_8=m_8;

%m_1=mean(i_1'); s_1=std(i_1');
%m_2=mean(i_2'); s_2=std(i_2');
%m_4=mean(i_4'); s_4=std(i_4');
%m_8=mean(i_8'); s_8=std(i_8');

% Further detrend of exponential term here

clear e_1_2 e_1_4 e_1_8 e_2_4 e_2_8 e_4_8 m

e_1_2=d_1+vshift(d_1,-1);
e_1_4=d_1+vshift(d_1,-1)+vshift(d_1,-2)+vshift(d_1,-3);
e_1_8=d_1+vshift(d_1,-1)+vshift(d_1,-2)+vshift(d_1,-3)+vshift(d_1,-4)+vshift(d_1,-5)+vshift(d_1,-6)+vshift(d_1,-7);

e_2_4=d_2+vshift(d_2,-2);
e_2_8=d_2+vshift(d_2,-2)+vshift(d_2,-4)+vshift(d_2,-6);

e_4_8=d_4+vshift(d_4,-4);

save nl_vis8

clear
load nl_vis9

%t=0.96*[1:64]+2*0.96;
%ti(19)=t(19);
%for m=20:64, ti(m)=ti(m-1)+1; end;
%for m=18:-1:1, ti(m)=ti(m+1)-1; end;
%x=[1 2 4 8];
%norm=[7 18];
%pos_act=[19 40];

%[c_1,m_1,s_1]=mat_clip(tc_1,5,norm);
%[c_2,m_2,s_2]=mat_clip(tc_2,5,norm);
%[c_4,m_4,s_4]=mat_clip(tc_4,5,norm);
%[c_8,m_8,s_8]=mat_clip(tc_8,5,norm);

%d_1=lin_regr(c_1,[1:64],[norm 56 64]);
%d_2=lin_regr(c_2,[1:64],[norm 56 64]);
%d_4=lin_regr(c_4,[1:64],[norm 56 64]);
%d_8=lin_regr(c_8,[1:64],[norm 56 64]);

%i_1=interp1(t(:),d_1,ti(:));
%i_2=interp1(t(:),d_2,ti(:));
%i_4=interp1(t(:),d_4,ti(:));
%i_8=interp1(t(:),d_8,ti(:));

%clear d_1 d_2 d_4 d_8
%clear m_1 m_2 m_4 m_8 s_1 s_2 s_4 s_8

%d_1=m_1; d_2=m_2; d_4=m_4; d_8=m_8;

%m_1=mean(i_1'); s_1=std(i_1');
%m_2=mean(i_2'); s_2=std(i_2');
%m_4=mean(i_4'); s_4=std(i_4');
%m_8=mean(i_8'); s_8=std(i_8');

% Further detrend of exponential term here

clear e_1_2 e_1_4 e_1_8 e_2_4 e_2_8 e_4_8 m

e_1_2=d_1+vshift(d_1,-1);
e_1_4=d_1+vshift(d_1,-1)+vshift(d_1,-2)+vshift(d_1,-3);
e_1_8=d_1+vshift(d_1,-1)+vshift(d_1,-2)+vshift(d_1,-3)+vshift(d_1,-4)+vshift(d_1,-5)+vshift(d_1,-6)+vshift(d_1,-7);

e_2_4=d_2+vshift(d_2,-2);
e_2_8=d_2+vshift(d_2,-2)+vshift(d_2,-4)+vshift(d_2,-6);

e_4_8=d_4+vshift(d_4,-4);

save nl_vis9

clear
load nl_vis13

%t=0.96*[1:64]+2*0.96;
%ti(19)=t(19);
%for m=20:64, ti(m)=ti(m-1)+1; end;
%for m=18:-1:1, ti(m)=ti(m+1)-1; end;
%x=[1 2 4 8];
%norm=[7 18];
%pos_act=[19 40];

%[c_1,m_1,s_1]=mat_clip(tc_1,5,norm);
%[c_2,m_2,s_2]=mat_clip(tc_2,5,norm);
%[c_4,m_4,s_4]=mat_clip(tc_4,5,norm);
%[c_8,m_8,s_8]=mat_clip(tc_8,5,norm);

%d_1=lin_regr(c_1,[1:64],[norm 56 64]);
%d_2=lin_regr(c_2,[1:64],[norm 56 64]);
%d_4=lin_regr(c_4,[1:64],[norm 56 64]);
%d_8=lin_regr(c_8,[1:64],[norm 56 64]);

%i_1=interp1(t(:),d_1,ti(:));
%i_2=interp1(t(:),d_2,ti(:));
%i_4=interp1(t(:),d_4,ti(:));
%i_8=interp1(t(:),d_8,ti(:));

%clear d_1 d_2 d_4 d_8
%clear m_1 m_2 m_4 m_8 s_1 s_2 s_4 s_8

%d_1=m_1; d_2=m_2; d_4=m_4; d_8=m_8;

%m_1=mean(i_1'); s_1=std(i_1');
%m_2=mean(i_2'); s_2=std(i_2');
%m_4=mean(i_4'); s_4=std(i_4');
%m_8=mean(i_8'); s_8=std(i_8');

% Further detrend of exponential term here

clear e_1_2 e_1_4 e_1_8 e_2_4 e_2_8 e_4_8 m

e_1_2=d_1+vshift(d_1,-1);
e_1_4=d_1+vshift(d_1,-1)+vshift(d_1,-2)+vshift(d_1,-3);
e_1_8=d_1+vshift(d_1,-1)+vshift(d_1,-2)+vshift(d_1,-3)+vshift(d_1,-4)+vshift(d_1,-5)+vshift(d_1,-6)+vshift(d_1,-7);

e_2_4=d_2+vshift(d_2,-2);
e_2_8=d_2+vshift(d_2,-2)+vshift(d_2,-4)+vshift(d_2,-6);

e_4_8=d_4+vshift(d_4,-4);

save nl_vis13

clear
load nl_vis14

%t=0.96*[1:64]+2*0.96;
%ti(19)=t(19);
%for m=20:64, ti(m)=ti(m-1)+1; end;
%for m=18:-1:1, ti(m)=ti(m+1)-1; end;
%x=[1 2 4 8];
%norm=[7 18];
%pos_act=[19 40];

%[c_1,m_1,s_1]=mat_clip(tc_1,5,norm);
%[c_2,m_2,s_2]=mat_clip(tc_2,5,norm);
%[c_4,m_4,s_4]=mat_clip(tc_4,5,norm);
%[c_8,m_8,s_8]=mat_clip(tc_8,5,norm);

%d_1=lin_regr(c_1,[1:64],[norm 56 64]);
%d_2=lin_regr(c_2,[1:64],[norm 56 64]);
%d_4=lin_regr(c_4,[1:64],[norm 56 64]);
%d_8=lin_regr(c_8,[1:64],[norm 56 64]);

%i_1=interp1(t(:),d_1,ti(:));
%i_2=interp1(t(:),d_2,ti(:));
%i_4=interp1(t(:),d_4,ti(:));
%i_8=interp1(t(:),d_8,ti(:));

%clear d_1 d_2 d_4 d_8
%clear m_1 m_2 m_4 m_8 s_1 s_2 s_4 s_8

%d_1=m_1; d_2=m_2; d_4=m_4; d_8=m_8;

%m_1=mean(i_1'); s_1=std(i_1');
%m_2=mean(i_2'); s_2=std(i_2');
%m_4=mean(i_4'); s_4=std(i_4');
%m_8=mean(i_8'); s_8=std(i_8');

% Further detrend of exponential term here

clear e_1_2 e_1_4 e_1_8 e_2_4 e_2_8 e_4_8 m

e_1_2=d_1+vshift(d_1,-1);
e_1_4=d_1+vshift(d_1,-1)+vshift(d_1,-2)+vshift(d_1,-3);
e_1_8=d_1+vshift(d_1,-1)+vshift(d_1,-2)+vshift(d_1,-3)+vshift(d_1,-4)+vshift(d_1,-5)+vshift(d_1,-6)+vshift(d_1,-7);

e_2_4=d_2+vshift(d_2,-2);
e_2_8=d_2+vshift(d_2,-2)+vshift(d_2,-4)+vshift(d_2,-6);

e_4_8=d_4+vshift(d_4,-4);

save nl_vis14

clear
load nl_vis19

%t=0.96*[1:64]+2*0.96;
%ti(19)=t(19);
%for m=20:64, ti(m)=ti(m-1)+1; end;
%for m=18:-1:1, ti(m)=ti(m+1)-1; end;
%x=[1 2 4 8];
%norm=[7 18];
%pos_act=[19 40];

%[c_1,m_1,s_1]=mat_clip(tc_1,5,norm);
%[c_2,m_2,s_2]=mat_clip(tc_2,5,norm);
%[c_4,m_4,s_4]=mat_clip(tc_4,5,norm);
%[c_8,m_8,s_8]=mat_clip(tc_8,5,norm);

%d_1=lin_regr(c_1,[1:64],[norm 56 64]);
%d_2=lin_regr(c_2,[1:64],[norm 56 64]);
%d_4=lin_regr(c_4,[1:64],[norm 56 64]);
%d_8=lin_regr(c_8,[1:64],[norm 56 64]);

%i_1=interp1(t(:),d_1,ti(:));
%i_2=interp1(t(:),d_2,ti(:));
%i_4=interp1(t(:),d_4,ti(:));
%i_8=interp1(t(:),d_8,ti(:));

%clear d_1 d_2 d_4 d_8
%clear m_1 m_2 m_4 m_8 s_1 s_2 s_4 s_8

%d_1=m_1; d_2=m_2; d_4=m_4; d_8=m_8;

%m_1=mean(i_1'); s_1=std(i_1');
%m_2=mean(i_2'); s_2=std(i_2');
%m_4=mean(i_4'); s_4=std(i_4');
%m_8=mean(i_8'); s_8=std(i_8');

% Further detrend of exponential term here

clear e_1_2 e_1_4 e_1_8 e_2_4 e_2_8 e_4_8 m

e_1_2=d_1+vshift(d_1,-1);
e_1_4=d_1+vshift(d_1,-1)+vshift(d_1,-2)+vshift(d_1,-3);
e_1_8=d_1+vshift(d_1,-1)+vshift(d_1,-2)+vshift(d_1,-3)+vshift(d_1,-4)+vshift(d_1,-5)+vshift(d_1,-6)+vshift(d_1,-7);

e_2_4=d_2+vshift(d_2,-2);
e_2_8=d_2+vshift(d_2,-2)+vshift(d_2,-4)+vshift(d_2,-6);

e_4_8=d_4+vshift(d_4,-4);

save nl_vis19
