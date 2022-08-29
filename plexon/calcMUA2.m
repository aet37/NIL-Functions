function [yb,tb,ds,yid]=calcMUA(data,tt,thr,bsize,nobins)
% Usage ... [yb,tb,ds,yid]=calcMUA(data,time,thr,binsize,nobins)
%
% data and time need to be arranged in row vectors

if isstruct(data),
  many_flag=2;
  if exist('bsize'), nobins=bsize; end;
  bsize=thr;
  thr=tt;
elseif prod(size(data))~=length(data),
  many_flag=1;
else,
  many_flag=0;
end;

thrin=thr;

if ~exist('bsize'), bsize=[]; end;
if isempty(bsize), bsize=50e-3; end;

if exist('nobins'),
  do_nobins=1;
  yno=zeros(1,length(tt));
  for mm=1:floor(length(nobins)/2),
    tmpynoii=find((tt>=nobins(2*mm-1))&(tt<=nobins(2*mm)));
    if ~isempty(tmpynoii), yno(tmpynoii)=1; end;
  end;
  noii=find(yno);
else,
  do_nobins=0;
end;

nno=0;
%disp(sprintf('  nobins= %d  many= %d',do_nobins,many_flag));
if many_flag==0,
  data=data(:).';
  tt=tt(:).';
  ds(1)=mean(data); ds(2)=std(data);
  if isstr(thrin),
    % thr in string, factor of std in both directions
    if isstr(thr), thr=str2num(thr); end;
    y1=(data>=ds(1)+thr*ds(2));
    disp(sprintf('  actual thr= [%.4e,%.4e]',ds(1)-thr*ds(2),ds(1)+thr*ds(2)))
  else,
    if length(thr)==2,
      % two-entry thr taken as core thresholds in both directions
      y1=((data<=thr(1))|(data>=thr(2)));
    elseif (length(thr)==1)&(thr(1)>0),
      if thr>10, 
        y1=data>=thr; 
      else, 
        y1=data>=(ds(1)+thr*ds(2)); 
        disp(sprintf('  actual thr= [%.4e]',ds(1)+thr*ds(2)))
      end;
    elseif (length(thr)==1)&(thr(1)<0),
      if thr<-10, 
        y1=data<=thr; 
      else, 
        y1=data<=(ds(1)+thr*ds(2)); 
        disp(sprintf('  actual thr= [%.4e]',ds(1)+thr*ds(2)))
      end;
    end;
  end;
  y1i=find(y1);
  if isempty(y1i),
    disp('  No hits, try a different threshold');
    nbins=floor((tt(end)-tt(1))/bsize);
    bt0=floor(tt(1)/bsize)*bsize;
    tb=[0:nbins-1]*bsize+bt0;
    yb=zeros(length(t1),1);
    return;
  end;
  if do_nobins,
    y1(noii)=0;
    y1i=find(y1);
  end;

  y2i=diff(y1i);
  y2di=find(y2i>1);
  if isempty(y2di),
    y2di=[y1i(1)];
  else,
    ydi=[y1i(1) y1i(y2di+1)];
  end;

  y3=zeros(size(tt));
  y3(ydi)=1;
  t3=tt(ydi);
  
  nbins=floor((tt(end)-tt(1))/bsize);
  bt0=floor(tt(1)/bsize)*bsize;
  t1=[0:nbins-1]*bsize+bt0;
  t2=t1+bsize;
  yid=y3(:);

  for mm=1:nbins,
    tmp=find((t3>=t1(mm))&(t3<t2(mm)));
    yb(mm)=length(tmp);
  end;

elseif many_flag==2,
  
  for nn=1:size(data.ndata,2),
    eval(sprintf('tmpdata=data.data%02d;',nn));
    eval(sprintf('tmptt=data.rts%02d;',nn));
    %tmpdata=data.ndata(:,nn);
    %tmptt=data.ntt;
    if do_nobins,
      yno=zeros(size(tmpdata,1));
      for mm=1:floor(length(nobins)/2),
        tmpynoii=find((tmptt>=nobins(2*mm-1))&(tmptt<=nobins(2*mm)));
        if ~isempty(tmpynoii), yno(tmpynoii)=1; end;
      end;
      noii=find(yno);
    end;
    ds(nn,1)=mean(tmpdata); ds(nn,2)=std(tmpdata);

    if isstr(thrin),
      % thr in string, factor of std in both directions
      if isstr(thr), thr=str2num(thr); end;
      y1=(tmpdata>=ds(nn,1)+thr*ds(nn,2));
      disp(sprintf('  actual thr= [%.4e,%.4e]',ds(nn,1)-thr*ds(nn,2),ds(nn,1)+thr*ds(nn,2)))
    else,
      if length(thr)==2,
        % two-entry thr taken as core thresholds in both directions
        y1=((tmpdata<=thr(1))|(tmpdata>=thr(2)));
      elseif (length(thr)==1)&(thr(1)>0),
        if thr>10, 
          y1=tmpdata>=thr; 
        else, 
          y1=tmpdata>=(ds(nn,1)+thr*ds(nn,2)); 
          disp(sprintf('  actual thr= [%.4e]',ds(nn,1)+thr*ds(nn,2)))
        end;
      elseif (length(thr)==1)&(thr(1)<0),
        if thr<-10, 
          y1=tmpdata<=thr; 
        else, 
          y1=tmpdata<=(ds(nn,1)+thr*ds(nn,2)); 
          disp(sprintf('  actual thr= [%.4e]',ds(nn,1)+thr*ds(nn,2)))
        end;
      end;
    end;
    y1i=find(y1);

    if isempty(y1i),
      nno=nno+1;
      %disp(sprintf('  No hits in %d, may want to try a different threshold',nn));
      if nn==1,
        nbins=floor((tmptt(end)-tmptt(1))/bsize);
        bt0=floor(tmptt(1)/bsize)*bsize;
        t1=[0:nbins-1]*bsize+bt0;
        t2=t1+bsize;
      end;    
      yb(:,nn)=zeros(length(t1),1);
    else,
      if do_nobins,
        y1(noii)=0;
        y1i=find(y1);
      end;
      y2i=diff(y1i);
      y2di=find(y2i>1);
      ydi=[y1i(1) y1i(y2di+1)];
      y3=zeros(size(tmptt));
      y3(ydi)=1;
      t3=tmptt(ydi);
      if nn==1,
        nbins=floor((tmptt(end)-tmptt(1))/bsize);
        bt0=floor(tmptt(1)/bsize)*bsize;
        t1=[0:nbins-1]*bsize+bt0;
        t2=t1+bsize;
      end;    
      yid{nn}=y3(:);
      for mm=1:nbins,
        tmp=find((t3>=t1(mm))&(t3<t2(mm)));
        yb(mm,nn)=length(tmp);
      end;
    end;
  end;

else,

  for nn=1:size(data,1),
    tmpdata=data(nn,:);
    tmptt=tt;
    if do_nobins,
      yno=zeros(size(tmpdata,1));
      for mm=1:floor(length(nobins)/2),
        tmpynoii=find((tmptt>=nobins(2*mm-1))&(tmptt<=nobins(2*mm)));
        if ~isempty(tmpynoii), yno(tmpynoii)=1; end;
      end;
      noii=find(yno);
    end;
    ds(nn,1)=mean(tmpdata); ds(nn,2)=std(tmpdata);
    
    if isstr(thrin),
      % thr in string, factor of std in both directions
      if isstr(thr), thr=str2num(thr); end;
      y1=(tmpdata>=ds(nn,1)+thr*ds(nn,2));
      disp(sprintf('  actual thr= [%.4e,%.4e]',ds(nn,1)-thr*ds(nn,2),ds(nn,1)+thr*ds(nn,2)))
    else,
      if length(thr)==2,
        % two-entry thr taken as core thresholds in both directions
        y1=((tmpdata<=thr(1))|(tmpdata>=thr(2)));
      elseif (length(thr)==1)&(thr(1)>0),
        if thr>10, 
          y1=tmpdata>=thr; 
        else, 
          y1=tmpdata>=(ds(nn,1)+thr*ds(nn,2)); 
          disp(sprintf('  actual thr= [%.4e]',ds(nn,1)+thr*ds(nn,2)))
        end;
      elseif (length(thr)==1)&(thr(1)<0),
        if thr<-10, 
          y1=tmpdata<=thr; 
        else, 
          y1=tmpdata<=(ds(nn,1)+thr*ds(nn,2)); 
          disp(sprintf('  actual thr= [%.4e]',ds(nn,1)+thr*ds(nn,2)))
        end;
      end;
    end;
    y1i=find(y1);

    if isempty(y1i),
      nno=nno+1; 
      %disp(sprintf('  No hits in %d, may want to try a different threshold',nn));
      if nn==1,
        nbins=floor((tmptt(end)-tmptt(1))/bsize);
        bt0=floor(tmptt(1)/bsize)*bsize;
        t1=[0:nbins-1]*bsize+bt0;
        t2=t1+bsize;
      end;
      yb(:,nn)=zeros(length(t1),1);
    else,
      if do_nobins,
        y1(noii)=0;
        y1i=find(y1);
      end;
      if length(y1i)>1,
        y2i=diff(y1i);
        y2di=find(y2i>1);
        ydi=[y1i(1) y1i(y2di+1)];
      else,
        ydi=y1i;
      end;
      y3=zeros(size(tmptt));
      y3(ydi)=1;
      t3=tmptt(ydi);
      if nn==1,
        nbins=floor((tmptt(end)-tmptt(1))/bsize);
        bt0=floor(tmptt(1)/bsize)*bsize;
        t1=[0:nbins-1]*bsize+bt0;
        t2=t1+bsize;
      end;
      yid{nn}=y3(:);
      for mm=1:nbins,
        tmp=find((t3>=t1(mm))&(t3<t2(mm)));
        yb(mm,nn)=length(tmp);
      end;
    end;
  end;

end;

if nno,
  disp(sprintf('  No hits in %d, may want to try a different threshold',nno));
end;

tb=t1;

if nargout==0,
  plot(tb,yb)
end;
