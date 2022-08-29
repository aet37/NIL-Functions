function dtlng = out_dat(cr_re,cr_im,nphs,npmult,skp,fsize,filename);
% Usage ... status = out_dat(cr_re, cr_im, sphs,npmult, skip, framesize, filename
%
% Outputs the corrected real and imag. matrices to an output file 
% that can be read by the modified gsp14 recon program, gsmdin.
% This routine processes one arm at a time.


dtlng1 = zeros([nphs*npmult*(fsize-skp) 2]);
for k=1:(nphs*npmult)
  dtlng1((k-1)*(fsize-skp)+1:k*(fsize-skp),1) = cr_re(k,:).';
  dtlng1((k-1)*(fsize-skp)+1:k*(fsize-skp),2) = cr_im(k,:).';
end;

tmp_cmd=['save ',filename,' -ascii dtlng1'];
disp(tmp_cmd);
eval(tmp_cmd);

