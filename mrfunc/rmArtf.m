function y=rmArtf(data,tt,trigch,trigwid,ts,irange,ord,bsize,muaf)
% Usage y=rmArtf(data,tt,trigch,trigsep,ts,irange,ord,bsize)
%
% trigsep: approx time betweeen triggers, has to be less than the actual
%   trigger separation
% timewin: time to look and regress out artifact (defined as the mean
%   signal of all the data), the second entry if included is the time
%   before trigger onset to keep. the time window needs to be longer than
%   the pulse duration or the artifact duration
% ex: y=rmArt(mua_lfp_ch10.ndata,mua_lfp_ch10.ntt,mua_lfp_ch15.ndata,50e-3,1/20e3,[50e-3 5e-3],1,50e-3);
% 

% finds the first index of each trigger
ii=getTrigLoc(trigch/(0.1*max(trigch(:)),trigwid,ts);
irange=[1:round(timewin(1)/ts)]-round(timewin(2)/ts);
y.ii=ii;
y.irange=irange;

% parses the data and sets the regressor as the mean
for nn=1:size(data,2), for mm=1:length(ii), 
  tmpdata(:,mm,nn)=data(irange+ii{mm},nn);
end; end;
tmpreg=mean(mean(tmpdata,2),3);
y.reg=tmpreg;
figure, plot(tmpreg), title('Regressor'), 
drawnow,

% regresses out the component tmpreg by order ord
tmpdata2=tmpdata;
for nn=1:size(data,2), for mm=1:length(ii), 
  tmpfit=polyval(polyfit(tmpreg,tmpdata(:,mm,nn),ord),tmpreg); 
  tmpdata2(:,mm,nn)=tmpdata(:,mm,nn)-tmpfit+mean(tmpfit);
end; end;
plot([squeeze(mean(tmpdata,2)) squeeze(mean(tmpdata2,2))]),
figure, title('Comparison of original data (blue) and regressed data (green)'),
drawnow,

% replace regressed data into newdata
newdata=data;
for nn=1:size(data,2), for mm=1:length(ii), 
  newdata(irange+ii{mm},nn)=tmpdata2(:,mm,nn);
end; end;
y.newdata=newdata;

% calculcate mua
othr=mean(std(data,[],1))*muaf;
nthr=mean(std(newdata,[],1))*muaf;
[origmua,tmpt]=calcMUA(data',tt,othr,bsize);
[newmua,tmpt]=calcMUA(newdata',tt,nthr,bsize);
y.tmua=tmpt;
y.orig_mua=origmua;
y.orig_thr=othr;
y.new_mua=newmua;
y.new_thr=nthr;

figure, 
subplot(211), plot(tmpt,mean(origmua,2)), title('Original MUA'),
subplot(212), plot(tmpt,mean(newmua,2)), title('New MUA (regressed)'),
drawnow,

%% save into original data structure
%mua_lfp_ch10.newdata=y.newdata;
%mua_lfp_ch10.orig_mua=y.orig_mua;
%mua_lfp_ch10.new_mua=y.new_mua;
%mua_lfp_ch10.new_tmua=y.tmua;
%save matname -append mua_lfp_ch10

