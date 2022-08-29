function mybioplot1(data,ax,colors,xytitle,oneplot_flag)
% Usage ... mybioplot1(dataxy,ax,colors,xytitle,oneplot_flag)

if ~exist('ax'), ax=[]; end;
if ~exist('colors'), colors=[]; end;
if ~exist('oneplot_flag'), oneplot_flag=0; end;
if ~exist('xytitle'), xytitle=[]; end;

ndata=length(data);
disp(sprintf('n=%d',ndata));

clf,
if oneplot_flag,
  if isempty(colors),
    if ndata==1,
      tmpstr=sprintf('%s plot(data{mm}{1},data{mm}{2}), ',tmpstr);
    elseif mm==1,
      tmpstr=sprintf('%s plot(data{mm}{1},data{mm}{2},',tmpstr);
    elseif mm==ndata,
      tmpstr=sprintf('%sdata{mm}{1},data{mm}{2}), ',tmpstr);
    else,
      tmpstr=sprintf('%sdata{mm}{1},data{mm}{2},',tmpstr);
    end;
  else,
    if ndata==1,
      tmpstr=sprintf('%s plot(data{mm}{1},data{mm}{2},colors{mm}), ',tmpstr);
    elseif mm==1,
      tmpstr=sprintf('%s plot(data{mm}{1},data{mm}{2},colors{mm}, ...\n',tmpstr);
    elseif mm==ndata,
      tmpstr=sprintf('%s data{mm}{1},data{mm}{2},colors{mm}), ',tmpstr);
    else,
      tmpstr=sprintf('%s      data{mm}{1},data{mm}{2},colors{mm}, ...\n',tmpstr);
    end;
  end;

  disp(tmpstr)
  eval(tmpstr)
  axis('tight'), grid('on'),
  if ~isempty(ax), axis(ax), end;
  if ~isempty(xytitle), xlabel(xytitle{1}), ylabel(xytitle{2}), end;

else,

  for mm=1:ndata,
    tmpstr=sprintf('subplot(%d1%d),',ndata,mm);
    if isempty(colors),
      tmpstr=sprintf('%s plot(data{mm}{1},data{mm}{2}), ',tmpstr);
    else,
      tmpstr=sprintf('%s plot(data{mm}{1},data{mm}{2},colors{mm}), ',tmpstr);
    end;
    if length(data{mm})==3, tmpstr=sprintf('%s, legend(data{mm}{3}),',tmpstr);  end;
    disp(tmpstr);
    eval(tmpstr);
    axis('tight'), grid('on'),
    if ~isempty(ax), axis(ax), end;
    if ~isempty(xytitle),
      xlabel(xytitle{1}), ylabel(xytitle{2}), 
      dofontsize(15);
    end;
  end;

end;


