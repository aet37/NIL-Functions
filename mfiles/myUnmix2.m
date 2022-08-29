function data_new=myUnmix2(data,refch,parms,refno,scalef)
% Usage ... y=myUnmix2(data,refch,parms,refimno,scalef)
%
% Simple unmix by decorrelation of a z-stack
% refch is the channel to decorrelate
% parms=[pord minmax_type[0-none,1-nonneg,2-minmax,3-norm]
% refno=reference image number (default is middle image)
% scalef=scale factors to enhance (empty=select)
%
% Ex. data2=myUnmix2(data,1,[2 2],20);
%     data2=myUnmix2(data,1,[2 2],20,[1 2]);

if ~exist('refno','var'), refno=[]; end;
if ~exist('parms','var'), parms=[1 0]; end;
if ~exist('scalef','var'), scalef=[]; end;

datasz=size(data);
pord=parms(1);
myminmax=parms(2);
do_fig=0;

datamm=[min(data(:)) max(data(:))];
if isempty(refno), refno=floor(datasz(end)/2); end;
if isempty(scalef), do_fig=1; scalef=ones(datasz(3),1); end;

for mm=1:datasz(3),
  im{mm}=data(:,:,mm,refno);
  refim(:,:,mm)=im{mm};
end;
for mm=1:datasz(3),
  if mm==refch, pp{mm}=[0 0]; else, pp{mm}=polyfit(im{refch}(:),im{mm}(:),pord); end;
end;
for mm=1:datasz(3),
   tmpim=im{mm}-polyval(pp{mm},im{refch});
   if myminmax==1,
       tmpim(find(tmpim<0))=0;
   elseif myminmax==2,
       tmpim=imwlevel(tmpim,datamm,0);
   elseif myminmax==3,
       tmpim=imwlevel(tmpim,datamm,1);
   end;
  refim_new1(:,:,mm)=tmpim;
  refim_new(:,:,mm)=scalef(mm)*tmpim;
end;
if do_fig,
    tmph=gcf;
    figure(tmph), clf,
    subplot(121), show(refim),
    subplot(122), show(refim_new),
    tmpin=input('  press enter to continue or enter scalef: ');
    if ~isempty(tmpin),
        tmpok=0;
        if length(tmpin)==datasz(3), tmpscale=tmpin; else, tmpscale=ones(datasz(3),1); end;
        while(~tmpok),
            for mm=1:datasz(3), refim_new(:,:,mm)=tmpscale(mm)*refim_new1(:,:,mm); end;
            subplot(121), show(refim),
            subplot(122), show(refim_new),
            tmpin2=input('  enter scale for each channel [x1 x2 ...] or <enter> to exit: ');
            if isempty(tmpin2), tmpok=1; else, tmpscale=tmpin2; end;
        end
        if length(tmpscale)>1, scalef=tmpscale; end;
    end     
end
    
data_new=zeros(size(data));
for mm=1:datasz(4), for nn=1:datasz(3),
   tmpim=data(:,:,nn,mm)-polyval(pp{nn},data(:,:,refch,mm));
   if myminmax==1,
       tmpim(find(tmpim<0))=0;
   elseif myminmax==2,
       tmpim=imwlevel(tmpim,datamm,0);
   elseif myminmax==3,
       tmpim=imwlevel(tmpim,datamm,1);
   end;
   data_new(:,:,nn,mm)=scalef(nn)*tmpim;
end; end;

if nargout==0,
    showStack(data_new)
    clear data_new
end
