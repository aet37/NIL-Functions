
for mm=2:length(tt),

  glc_t(mm) = glc_t(mm-1) + dt*( v_glc_m - v_hk_pfk );
  gap_c(mm) = gap_c(mm-1) + dt*( 2*v_hk_pfk - v_pgk );
  peg_c(mm) = peg_c(mm-1) + dt*( v_pgk - v_pk );
  pyr_c(mm) = pyr_c(mm-1) + dt*( v_pk - v_ldh - v_pyr );
  lac_t(mm) = lac_t(mm-1) + dt*( v_ldh - v_lac_m );
  nadh_c(mm) = nadh_c(mm-1) + dt*( v_pgk - v_ldh - v_shuttle );
  nad_c(mm) = n_c_total - nadh_c(mm);
  atp_c(mm) = atp_c(mm-1) + dt*( -2*v_hk_pfk + v_pgk + v_pk + v_atpases - v_pump + v_trans + v_ck )*(1/( 1 - d_amp_d_atp ));
  amp_c(mm) = a_c_total - atp_c(mm) - adp_c;
  adp_c = (atp_c(mm)/2)*( -q_ak + sqrt( q_ak^2 + 4*q_ak*(a_c/atp_c(mm) - 1 )));
  d_amp_d_atp = -1 + q_ak/2 - 0.5*sqrt( q_ak^2 + 4*q_ak*(a_c/atp_c(mm) - 1 )) + (q_ak*a_c/atp_c(mm))/sqrt( q_ak^2 + 4*q_ak*(a_c/atp_c - 1));

end;

