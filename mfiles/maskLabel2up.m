function y=maskLabel2up(labelstr,maxtc)
% Usage ... y=maskLabel2up(labelstr,maxtc)

if labelstr.a>0,
  for mm=1:labelstr.a,
    tc_a(:,:,mm)=squeeze(maxtc(:,labelstr.ai{mm},:));
    tc_atype(mm)=labelstr.atype{mm};
  end;
  tmpii=find(tc_atype==1);
  if ~isempty(tmpii), tc_a_n=tc_a(:,:,tmpii); else, tc_a_n=[]; end;
  tmpii=find(tc_atype==2);
  if ~isempty(tmpii), tc_a_g=tc_a(:,:,tmpii); else, tc_a_g=[]; end;
else,
  tc_a=[]; tc_a_n=[]; tc_a_g=[];
end;

if labelstr.c>0,
  for mm=1:labelstr.c,
    tc_c(:,:,mm)=squeeze(maxtc(:,labelstr.ci{mm},:));
    tc_ctype(mm)=labelstr.ctype{mm};
  end;
  tmpii=find(tc_ctype==1);
  if ~isempty(tmpii), tc_c_n=tc_c(:,:,tmpii); else, tc_c_n=[]; end;
  tmpii=find(tc_ctype==2);
  if ~isempty(tmpii), tc_c_g=tc_c(:,:,tmpii); else, tc_c_g=[]; end;
else,
  tc_c=[]; tc_c_n=[]; tc_c_g=[];
end;

if labelstr.v>0,
  for mm=1:labelstr.v,
    tc_v(:,:,mm)=squeeze(maxtc(:,labelstr.vi{mm},:));
    tc_vtype(mm)=labelstr.vtype{mm};
  end;
  tmpii=find(tc_vtype==1);
  if ~isempty(tmpii), tc_v_n=tc_v(:,:,tmpii); else, tc_v_n=[]; end;
  tmpii=find(tc_vtype==2);
  if ~isempty(tmpii), tc_v_g=tc_v(:,:,tmpii); else, tc_v_g=[]; end;
else,
  tc_v=[]; tc_v_n=[]; tc_v_g=[];
end;
    
y.tcNa=tc_a_n;
y.tcAa=tc_a_g;
y.tcNc=tc_c_n;
y.tcAc=tc_c_g;
y.tcNv=tc_v_n;
y.tcAv=tc_v_g;

