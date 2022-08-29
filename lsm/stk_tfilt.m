function y=stk_tfilt(stk,fco,fbw,fdt,famp)
% Usage ... y=stk_tfilt(stk,fco,fbw,fdt,famp)

if nargin<5, famp=[]; end;
if nargin<4, fdt=[]; end;

if isempty(famp), famp=1.0; end;
if isempty(fdt), fdt=1; end;

y=stk;
for mm=1:size(stk,1), for nn=1:size(stk,2),
  tmptc=squeeze(stk(mm,nn,:));
  tmpfilt=fermi1d(tmptc(:),fco,fbw,famp,fdt);
  y(mm,nn,:)=tmpfilt;
  clear tmpfilt
end; end;

%y=single(y);

