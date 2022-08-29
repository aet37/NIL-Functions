function ynew=tc_outlier_rm3(y,ymin,ymax,ww,nthr)
% Usage ... y=tc_outlier_rm3(y,ymin,ymax,nthr)
%
% Replaces outlier in y if neighborhood is less than nthr
% with yavg spanning +/- ww indeces

ylen=length(y);

tmpi=find((y<ymin)|(y>ymax));
if ~isempty(tmpi),
  ynew=y;
  tmpilen=length(tmpi);
  for mm=1:tmpilen,
    if ((tmpi(mm)-ww)<1), tmpmini=1; else, tmpmini=tmpi(mm)-ww; end;
    if ((tmpi(mm)+ww)>ylen), tmpmaxi=ylen; else, tmpmaxi=tmpi(mm)+ww; end;
    if (mm<tmpilen), if ((tmpi(mm)+ww)>=tmpi(mm+1)), tmpmaxi=tmpi(mm+1)-1; end; end;
    if (mm>1), if ((tmpi(mm)-ww)<=tmpi(mm-1)), tmpmini=tmpi(mm-1)+1; end; end;
    if ((tmpmaxi-tmpmini)<=ww),
      disp(sprintf('  could not fix #%d (%d,%d)',tmpi(mm),tmpmini,tmpmaxi));
    else,
      tmpii=[tmpmini:tmpmaxi];
      ynew(tmpi(mm))=mean(y(tmpii));
    end;
  end;
end;

