function showspec(tt,ff,yy,tmpclim,parms)
% Usage ... showspec(tt,ff,yy,tmpclim,parms)
%
% parms=[use_log use_cbar]
%
% Ex. showspec(eeg1.tts,eeg1.ffs,abs(eeg1.spec)')
%     showspec(eeg1.tts,eeg1.ffs,abs(eeg1.spec)',[1e-10 1e-7])
%     showspec(eeg1.tts,eeg1.ffs,abs(eeg1.spec)',[-9.2 -7.2],[1 1])
%     showspec(eeg1.mt_tt,eeg1.mt_ff,eeg1.mt_spec,[-4 -1],[1 1]), ylim([0 30]),


if isstruct(tt),
  if exist('ff','var'), tmpclim=ff; clear ff , end;
  if exist('yy','var'), parms=yy; clear yy, end;
  %disp('str')
  if isfield(tt,'spec'),
    ff=tt.ffs(:);
    yy=abs(tt.spec).';
    tt=tt.tts(:);
  else,
    ff=tt.fim;
    yy=tt.yim;
    tt=tt.t;
  end;    
  if nargin>1, parms=ff; else, parms=[0]; end;
end;

if ~exist('parms','var'), parms=[0]; end;
if ~exist('tmpclim','var'), tmpclim=[]; end;

use_pcolor=1;
use_log=parms(1);

if length(size(yy))>2, yy=mean(squeeze(yy),3); yy=squeeze(yy); end;
if use_log, disp('  plotted log10 scale'); yy=log10(yy); end;

if use_pcolor,
  %size(tt), size(ff), size(yy),
  pcolor(tt,ff,double(yy')),
  view(2), colormap jet,
  shading interp,
  axis tight,      
else,
  mesh(tt,ff,double(yy')),
  view(2),
  shading interp,
  axis tight,
end;
xlabel('Time'), ylabel('Frequency'),
if isempty(tmpclim),
  tmpclim=get(gca,'CLim');
end;
set(gca,'CLim',tmpclim);
title(sprintf('%.3e/%.3e',tmpclim(1),tmpclim(2)));
colorbar,

