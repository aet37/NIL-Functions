function data_blp=EEGblp1(data,fs,blp_range,post_filt,parms)
% Usage ... y=EEGblp1(data,fs,blp_range,post_filt,parms)
%
% Calculate the band-limited power vector from data over blp frequency range
% using a simple filter, rectification and follow-up filter if included in the
% parameters. Parameters are [bin#]
%
% Ex. blp1=EEGblp1(biopacData.EEG,1000,[0.5 4.5],[1]);
%     ldf1=EEGblp1(biopacData.LDF,1000,[0.05 0.2],[0.5]);

do_abs=1;

do_postfilt=0;
if exist('post_filt','var'),
  do_postfilt=1;
end;

if exist('parms','var'),
  bin=parms(1);
  if length(parms)>1, post_fco=parms(2); else, post_fco=post_filt/10; end;
else,
  bin=0;
end;

if length(blp_range)>1,
  %disp(sprintf('  band-pass [%d] [/5]',blp_range));
  data_blp=fermi1d(data,blp_range,blp_range/5,[-1 1],1/fs);
else,
  if blp_range<0,
    data_blp=fermi1d(data,abs(blp_range),abs(blp_range)/5,[-1],1/fs);
  else,
    data_blp=fermi1d(data,blp_range,blp_range/5,[1],1/fs);
  end;
end;

if do_abs,
  %disp('  abs');
  data_blp=abs(data_blp);
else,
  data_blp=data_blp.^2;
end;

if do_postfilt,
  if length(post_filt)>1,
    %disp(sprintf('  band-pass post-filt [%d]',post_filt));
    data_blp=fermi1d(data_blp,post_filt,post_filt/5,[-1 1],1/fs);
  else,
    if post_filt<0,
      %disp(sprintf('  high-pass post-filt [%d]',post_filt));
      data_blp=fermi1d(data_blp,abs(post_filt),abs(post_filt)/10,[-1],1/fs);
    else,
      %disp(sprintf('  low-pass post-filt [%d]',post_filt));
      data_blp=fermi1d(data_blp,post_filt,post_filt/10,[1],1/fs);
    end;
  end;
end;

if bin>0,
  %disp('  do_bin...');
  data_blp=ybin2(data_blp,bin);
end;

if nargout==0,
  figure(1), clf,
  subplot(211), plot(data), axis tight, grid on,
  subplot(212), plot(data_blp), axis tight, grid on,
  clear data_blp
end;

