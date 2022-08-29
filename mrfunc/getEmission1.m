function [ye,yx,y2]=getEmission1(ename, band)
% Usage [yEm,yEx,yEx2p]=getEmission1(name, wavelength_band)
%
% name is the molecule name in lower case and no dashes or special symbols
% wavelength is the single number to obtain the relative emission, it can 
% also have 2 entries to indicate the band, or a vector or cell with the 
% different band ranges
% the following are currently supported: fluorescein, rhodamine, fitc,
% rhodamineb, rhodamine6g, methoxy, sr101, cfp, gfp,egfp, yfp, eyfp,
% mruby, mapple, mcherry, texasred, ...

nbands=1;
if iscell(band),
    
load AV1_FPbase_Spectra
exemNames=AV1fpbasespectra.Properties.VariableNames;

tmpxi=[]; tmpei=[]; tmp2i=[];
for mm=1:length(EmEx),
  if strcmp(exemNames{mm},ename)|strcmp([exemNames{mm},'Ex'],ename), tmpxi=mm; end;
  if strcmp(exemNames{mm},ename)|strcmp([exemNames{mm},'Em'],ename), tmpei=mm; end;
  if strcmp(exemNames{mm},ename)|strcmp([exemNames{mm},'2p'],ename), tmp2i=mm; end;
end
if isempty(tmpii), error([ename,' not found']); end

tmplambda=AV1fpbasespectra.wavelength;

for nn=1:nbands,
  if ~isempty(tmpxi),
      eval(sprintf('tmpdata=AV1fpbasespectra.%s;',exemNames{tmpxi}));
      yx{nn}=[band(:) interp1(tmplambda,tmpdata,band(:))];
  else,
      yx{nn}=[];
  end
  if ~isempty(tmpei),
      eval(sprintf('tmpdata=AV1fpbasespectra.%s;',exemNames{tmpei}));
      ye{nn}=[band(:) interp1(tmplambda,tmpdata,band(:))];
  else,
      ye{nn}=[];
  end
  if ~isempty(tmpei),
      eval(sprintf('tmpdata=AV1fpbasespectra.%s;',exemNames{tmp2i}));
      y2{nn}=[band(:) interp1(tmplambda,tmpdata,band(:))];
  else,
      y2{nn}=[];
  end
  clear tmpdata
end


