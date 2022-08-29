function im=mask2im(mask,val)
% Usage ... im=mask2im(mask,val)
%
% Assigns val(i) to mask entry i

if max(mask(:))==1,
  mask_orig=mask;
  mask=double(mask);
  mask(find(mask(:)))=[1:length(find(mask(:)))];
  %clf, show(mask), pause,
  disp(sprintf('  assigning index entries to mask using find (%d)',max(mask(:))));
end;

val=val(:);

im=zeros(size(mask));
for mm=1:max(mask(:)),
  tmpii=find(mask==mm);
  if ~isempty(tmpii),
    im(tmpii)=val(mm);
  end;
end;

if nargout==0,
  subplot(121), show(mask),
  subplot(122), show(im),
  clear im
end;

