function [y,yn,thr,cthr]=volthr2(vol,thr,cthr,select_flag)
% Usage ... y=volthr2(vol,thr,cthr)
%
% thr is the intensity threshold, cthr=[min_#pix max_#pix]
% Ex. maskP=volthr2(data,'select');
%     maskP=volthr2(data,0.5,100);
%     maskP=volthr2(data,0.5,[100 8000],'select');
%
%     for mm=1:size(data,3), show(im_super(vol(:,:,mm),maskP(:,:,mm),1)), drawnow, pause, end;

vol=squeeze(vol);

do_select=0;

if exist('select_flag','var'),
  if ischar(select_flag), if strcmp(select_flag,'select'),
    do_select=1;
  end; end;
end;

if ischar(thr), if strcmp(thr,'select'),
  do_select=1; thr=[]; cthr=[];
end; end;

if do_select,
  vol_orig=vol;
  vavg=mean(vol_orig(:));
  vstd=std(vol_orig(:));
  if isempty(thr), thr=vavg+2*vstd; end;
  if isempty(cthr), cthr=[3*3*3 round(sqrt(size(vol,1)*size(vol,2)*size(vol,3))/8)]; end;
  
  tmpok=0;
  while(~tmpok),
    if length(cthr)==2,
      disp(sprintf('  t=%.1f, c=[%d %d], (avg=%.2f, std=%.2f)',thr,cthr(1),cthr(2),vavg,vstd));
    else,
      disp(sprintf('  t=%.1f, c=[%d], (avg=%.2f, std=%.2f)',thr,cthr(1),vavg,vstd));
    end;
    
    if thr<0, 
      y=vol<thr;
    else,
      y=vol>thr;
    end;

    if ~isempty(cthr),
      y=bwlabeln(y);
      y_rp=regionprops(y);
      y_ar=[y_rp(:).Area];
      %tmpny=max(y(:));
      disp(sprintf('  initially %d regions',length(y_ar))); 

      if length(cthr)==2,
        tmpi=find((y_ar>=cthr(1))&(y_ar<=cthr(2)));
        tmpi0=find((y_ar<cthr(1))|(y_ar>cthr(2)));
        if ~isempty(tmpi),
          disp(sprintf('  now %d regions',length(tmpi))); 
          y2=zeros(size(y));
          for mm=1:length(tmpi), 
            y2(find(y==tmpi(mm)))=mm; 
            %if rem(mm,round(length(tmpi)/10))==0, disp(sprintf('  %.1f percent done',round(100*mm/length(tmpi)))); end; 
          end;
          y=y2;
          clear y2
        else,
          disp('  warning: no more regions');
        end;
      else,
        tmpi=find(y_ar>=cthr(1));
        tmpi0=find(y_ar<cthr(1));
        if ~isempty(tmpi),
          disp(sprintf('  now %d regions',length(tmpi))); 
          y2=zeros(size(y));
          for mm=1:length(tmpi), 
            y2(find(y==tmpi(mm)))=mm; 
            %if rem(mm,round(length(tmpi)/10))==0, disp(sprintf('  %.1f percent done',round(100*mm/length(tmpi)))); end; 
          end;
          y=y2;
          clear y2
        else,
          disp('  warning: no more regions');
        end;
      end;
      
      % relabel
      y=bwlabeln(y>0);
      y_rp=regionprops(y);
      y_ar=[y_rp(:).Area];
      disp(sprintf('  final %d regions',length(y_ar)));
      yn=y_ar;
    else,
      yn=[];
    end;
    
    figure(1),
    showProj(y),
    colormap jet, drawnow,
    
    if length(cthr)==2,
      disp(sprintf('  t=%.1f, c=[%d %d], (avg=%.2f, std=%.2f)',thr,cthr(1),cthr(2),vavg,vstd));
    else,
      disp(sprintf('  t=%.1f, c=[%d], (avg=%.2f, std=%.2f)',thr,cthr(1),vavg,vstd));
    end;

    tmpin=input('select: t[thr], c/C[min#], x[max#], flat, Flash, enter[accept]: ','s');
    if isempty(tmpin),
      tmpok=1;
    else,
      if strcmp(tmpin(1),'F'),
        for mm=1:4,
            showProj(vol), colormap gray, drawnow, pause(0.5),
            showProj(y), colormap jet, drawnow, pause(0.5),
        end;
      elseif strcmp(tmpin(1),'S'),
        showStack(vol,'overlay',y);
      elseif strcmp(tmpin(1),'W'),
        vol=volwlevel(vol,'imminmax');
        vavg=mean(vol(:));
        vstd=std(vol(:));
        thr=vavg+2*vstd;         
      elseif length(tmpin)<2,
        tmpin2=input(sprintf('  enter %s value: ',tmpin));
      else,
        tmpin2=str2num(tmpin(2:end));
      end;
      if strcmp(tmpin(1),'t'),
        thr=tmpin2;
      elseif strcmp(tmpin(1),'s'),
        thr=vavg+tmpin2*vstd;
      elseif strcmp(tmpin(1),'c'),
        cthr(1)=tmpin2;
      elseif strcmp(tmpin(1),'C'),
        cthr=tmpin2;
      elseif strcmp(tmpin(1),'x'),
        cthr(2)=tmpin2;
      elseif strcmp(tmpin(1),'f'),
        fthr=tmpin2;
        for mm=1:size(vol,3), vol(:,:,mm)=homocorOIS(vol(:,:,mm),fthr); end;
        vavg=mean(vol(:));
        vstd=std(vol(:));
        thr=vavg+2*vstd; 
        cthr=[3*3*3 round(sqrt(size(vol,1)*size(vol,2)*size(vol,3))/8)];
      elseif strcmp(tmpin(1),'r'),
        vol=vol_orig;
        vavg=mean(vol(:));
        vstd=std(vol(:));
        thr=vavg+2*vstd; 
        cthr=[3*3*3 round(sqrt(size(vol,1)*size(vol,2)*size(vol,3))/8)];
      end;
    end;
  end;
else,    
  if thr<0, 
    y=vol<thr;
  else,
    y=vol>thr;
  end;

  if ~isempty(cthr),
    y=bwlabeln(y);
    tmpny=max(y(:));
    disp(sprintf('  initially %d regions',tmpny));

    for mm=1:tmpny,
      tmpi=find(y==mm);
      if length(tmpi)<cthr(1),
        y(tmpi)=0;
      end;
      if length(cthr)>1, if length(tmpi)>cthr(2),
        y(tmpi)=0;
      end; end;
    end;
    y=bwlabeln(y>0);
    disp(sprintf('  final %d regions',max(y(:))));

    for mm=1:max(y(:)),
      yn(mm)=length(find(y==mm));
    end; 
  else,
    yn=[];
  end;
end;

if nargout==0,
  showProj(y)
  colormap jet
  clear y yn
end;

