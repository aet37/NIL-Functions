function y=myUnmix1(ims,ch,parms)
% Usage ... y=myUnmix1(ims,ch,parms)
%
% Simple unmixing by maximal decorrelation. This function assumes that
% there is shared informaiton between the channels. Current implementation
% only considers the channel order of influence
%
% Ex. myUnmix1(avgim_motc,[2 1])


% say there are 3 probes ABC (Rhod/mRuby/GFP)
% ch1 has A+B
% ch2 has B+C
% we can generate a new image ABC where B is the shared information between
% ch1+2, or B=corr(1,2) then A=1-B and C=2-B
% the coefficients are importnat

do_fig=0;
if nargout==0, do_fig=1; end;

if ~exist('parms','var'), parms=[]; end;
if isempty(parms), parms=1; end;

nord=parms(1);

imsz=size(ims);
for mm=1:length(ch),
  im{mm}=ims(:,:,ch(mm));
end;

im_new{1}=im{1};
imn_new{1}=imwlevel(im{1},[],1);

im1_fit{1}=[];
for mm=2:length(ch),
  im1_pfit{mm}=polyfit(im{1}(:),im{mm}(:),nord);
  im1_fit{mm}=polyval(im1_pfit{mm},im{1});
  im_new{mm}=im{mm} - im1_fit{mm};
  imn_new{mm}=imwlevel(im_new{mm},[],1);

  if do_fig==2,
    clf,
    subplot(231), show(im{1}),
    subplot(232), show(im1_fit{mm}),
    subplot(233), show(im{mm}),
    subplot(234), plot(im{1}(:),im{mm}(:),'x',im{1}(:),im1_fit{mm}(:)),
    subplot(236), show(im_new{mm}),
    pause,
  end
end

if (length(imsz)==3)&(imsz(3)==2),
  %adding residual image
  disp('  adding residual image');
  tmpim=zeros(imsz(1:2));
  tmpim(find(im_new{2}<0))=-im_new{2}(find(im_new{2}<0));
  im_new{2}(find(im_new{2}<0))=0;
  im_new{3}=tmpim;
end


y=ims;
yn=ims;
for mm=1:length(ch),
  y(:,:,mm)=im_new{ch(mm)};
  yn(:,:,mm)=imn_new{ch(mm)};
end;


if do_fig,
  clf,
  subplot(221), show(ims),
  subplot(222), show(y),
  subplot(224), show(yn),
  clear y
end

if nargout==1,
    disp('  outputting struct');
    tmpy.im=ims;
    tmpy.ch=ch;
    tmpy.parms=parms;
    tmpy.pfit=im1_pfit;
    tmpy.im_new=im_new;
    tmpy.y=y;
    tmpy.yn=yn;
    clear y
    y=tmpy;
    clear tmpy
end

