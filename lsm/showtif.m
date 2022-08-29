function showtif(ytif,mm)
% Usage ... showtif(ytif,minmax)

if nargin<2, mm=[]; end;
if isempty(mm), mm_flag=0; else, mm_flag=1; end;

if isfield(ytif,'data'),
  % gray-scale display
  tmpim=double(ytif.data);
  if ~mm_flag, 
    mm=[min(min(tmpim)) max(max(tmpim))];
    disp(sprintf('  min/max= %.2f/%.2f',mm(1),mm(2)));
  end;
  show(tmpim,mm)
else,
  if isfield(ytif,'red'),
    if ~isempty(ytif.red),
      tmpim(:,:,1)=double(ytif.red);
    else,
      tmpim(:,:,1)=0;
    end;
  else,
    tmpim(:,:,1)=0;
  end;
  if isfield(ytif,'green'),
    if ~isempty(ytif.green),
      tmpim(:,:,2)=double(ytif.green);
    else,
      tmpim(:,:,2)=0;
    end;
  else,
    tmpim(:,:,2)=0;
  end;
  if isfield(ytif,'blue'),
    if ~isempty(ytif.blue), 
      tmpim(:,:,3)=double(ytif.blue);
    else,
      tmpim(:,:,3)=0;
    end;
  else,
    tmpim(:,:,3)=0;
  end;
  if ~mm_flag,
    mm=[min(min(min(tmpim))) max(max(max(tmpim)))];
    disp(sprintf('  min/max= %.2f/%.2f',mm(1),mm(2)));
  end;
  image(imwlevel(tmpim,mm)), axis('image'),
end;
 

