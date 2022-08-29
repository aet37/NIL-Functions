function [data_new,pfit]=myUnmix1a(data,um1a_struct,parms)
% Usage ... data_new=myUnmix1a(data,struct,parms)
%
% Simple unmixing by decorrelation. If no im1a_struct is provided
% then the average image is computed and decorrelated. 
% data here can be a t-series
% parms = [ch nord neg_flag]
%
% Ex. myUnmix1a(data,[],[1 1 0])

data=squeeze(data);
datasz=size(data);

if nargin<2, um1a_struct=[]; end;
if nargin<3, parms=[]; end;

if isempty(parms), parms=[1 1 0 0]; end;
if length(parms)==1, parms(2:4)=[1 0 0]; elseif length(parms)==2, parms(3:4)=0; else, parms(4)=0; end;

refch=parms(1);
nord=parms(2);
negflag=parms(3);
fitallflag=parms(4);

if isempty(um1a_struct),
  ch=i2i([1:datasz(3)],'notin',refch);
  disp(sprintf('  computing average image and decorrelating ch%d from refCh%d',ch(1),refch));
  avgim=mean(data,4);
  tmpim1ref=avgim(:,:,refch);
  tmpim1=avgim(:,:,ch);
  pfit=polyfit(tmpim1ref(:),tmpim1(:),nord);
  if nargout==0,
    clf,
    plot(tmpim1ref(:),tmpim1(:),'x',tmpim1ref(:),polyval(pfit,tmpim1ref(:))),
    drawnow, 
    disp('  press enter to continue...'), pause,
  end;
else,
  refch=um1a_struct.ch;
  ch=i2i([1:datasz(3)],'notin',refch);
  disp(sprintf('  decorrelating ch%d from refCh%d',ch(1),refch));
  pfit=um1a_struct.pfit;
end;

data_new=zeros(datasz([1 2 4]));
if fitallflag,
  for mm=1:datasz(4),
    tmpim1ref=data(:,:,refch,mm);
    tmpim1=data(:,:,ch,mm);
    pfit(mm,:)=polyfit(tmpim1ref(:),tmpim1(:),nord);
    data_new(:,:,mm)=data(:,:,ch,mm)-polyval(pfit(mm,:),data(:,:,refch,mm));
  end;
else
  for mm=1:datasz(4),
    data_new(:,:,mm)=data(:,:,ch,mm)-polyval(pfit,data(:,:,refch,mm));
  end;
end


if negflag,
    disp('  setting negative values to zero');
    data_new(find(data_new<0))=0;
end

if nargout==0,
  clf,
  subplot(221), show(avgim),
  subplot(222), show(mean(data(:,:,ch,:),4)),
  subplot(224), show(mean(data_new,3)),
  clear data_new
end

