
% pre-processing commands
myOISscr1_new('20190319mouse_pv11_2p5x_rcamp_wh1S.stk','pv11_wh1S','do_load',[1:3350],'do_bin',[2 2 1],'do_binfirst','do_motc','do_maskreg',mask_reg,'do_intc',[1 1],'do_saveraw')

myOISscr1_new('20190319mouse_pv11_2p5x_rcamp_dyn4l0p5bS.stk','pv11_dyn4l0p5bS','do_load',[1:3350],'do_bin',[2 2 1],'do_binfirst','do_motc','do_maskreg',mask_reg,'do_realign',2,'do_intc',[1 1],'do_saveraw')

map1=myOISmap1b(data,[ntr nimtr noff nkeep],[20 51 1],'x0.5');
map2=myOISmap1b(data,[ntr nimtr noff nkeep],[20 64 1],'x0.5');

