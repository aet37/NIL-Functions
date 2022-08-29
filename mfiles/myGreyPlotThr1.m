function myGreyPlotThr1(x,y,xthr,ythr,hold_flag)
% Usage ... myGreyPlotThr1(x,y,xthr,ythr,hold_flag)
%
% This plotting function grays out lines over x or y thresholds
% indicated in xthr and ythr. Leave empty ([]) if you dont want to use that
% threshold. Hold_flag will also the plot/subplot in hold_flag 

if ~exist('xthr','var'), xthr=[]; end;
if ~exist('ythr','var'), ythr=[]; end;
if ~exist('hold_flag','var'), hold_flag=0; end;

if hold_flag,
    figure(hold_flag),
    lnw=get(gca,'LineWidth');
    hold('on'),
else,
    plot(x,y),
    lnw=0.5;
    hold('on'),
end

xi=[x(1):(x(2)-x(1))/10:x(end)];
yi=interp1(x(:),y,xi(:));

for nn=1:size(y,2),
  if ~isempty(xthr),
    if length(xthr)==1,
      if xthr(1)>0, x1i=find(xi<xthr(1)); else, x1i=find(xi>xthr(1)); end;      
    else,
      x1i=find((xi<xthr(1))|(xi>xthr(2)));
    end
    x1id=find(diff(x1i)>1);
    
    if ~isempty(x1id),
      for pp=1:length(x1id), 
        if pp==1, x1ii{1}=x1i(1:x1id(1));  else, x1ii{pp}=x1i(x1id(pp-1)+1:x1id(pp)); end; 
      end
      x1ii{pp+1}=x1i(x1id(pp)+1:end);
    else,
      x1ii{1}=x1i;
    end
    
    for pp=1:length(x1ii),
      plot(xi(x1ii{pp}),yi(x1ii{pp},nn),'Color',[1 1 1]*0.5,'LineWidth',lnw)
    end
  end

  if ~isempty(ythr),
    if length(ythr)==1,
      if ythr(1)>0, y1i=find(yi(:,nn)<ythr(1)); else, y1i=find(yi(:,nn)>ythr(1)); end;      
    else,
      y1i=find((yi(:,nn)<ythr(1))|(yi(:,nn)>ythr(2)));
    end
    y1id=find(diff(y1i)>1);

    if ~isempty(y1id),
      for pp=1:length(y1id), 
        if pp==1, y1ii{1}=y1i(1:y1id(1));  else, y1ii{pp}=y1i(y1id(pp-1)+1:y1id(pp)); end; 
      end
      y1ii{pp+1}=y1i(y1id(pp)+1:end);
    else,
      y1ii{1}=y1i;
    end
    
    for pp=1:length(y1ii),
      plot(xi(y1ii{pp}),yi(y1ii{pp},nn),'Color',[1 1 1]*0.5,'LineWidth',lnw)
    end

  end
end
    
hold('off'),

