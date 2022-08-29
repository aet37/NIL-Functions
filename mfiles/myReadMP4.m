function [data,info]=myReadMP4(fname,sname,parms,crop_parms,roi_parms)
% Usage ... [data,info]=myReadMP4(fname,sname,parms,crop_parms,roi_parms)
%
% sname is the saveid, crop_parms is indeces or 'select'
% roi_parms is not yet functional 
% parms=[gray imadjust]
%
% Ex. myReadMP4('g43f_rest2_pi1.mp4',[],[1 1],[201 300 120 241]);
%     myReadMP4('g43f_rest2_pi1.mp4',[],[1 1],'select');
%     roiIms1=myReadMP4('g43f_rest2_pi1.mp4',[],[1 1],'select');

do_display=0;
if nargout==0, do_display=0; end;

if ~exist('roi_parms','var'), roi_parms=[]; end;
if ~exist('crop_parms','var'), crop_parms=[]; end;
if ~exist('parms','var'), parms=[]; end;

do_roi=0;
if ~isempty(roi_parms), do_roi=1; end;
if isempty(parms), 
    disp('  defaulting to rgb2gray=1 and imadjust=0');
    parms=[1 0]; 
end;

if do_display,
  figure(1), clf,
end;

vr=VideoReader(fname);
if nargin<2, parms=[0 0]; crop_parms=[]; roi_parms=[]; end;
if length(parms)==1, parms(2)=0; end;

do_grayscale=parms(1);
do_imadjust=parms(2);

numFrames_est=floor(vr.FrameRate*vr.Duration);

cnt=0;
while hasFrame(vr),
  cnt=cnt+1;
  if rem(cnt,300)==0, disp(sprintf('  reading fr# %04d/%04d',cnt,numFrames_est)); end;
  tmpFrame=readFrame(vr);

  if cnt==1,
    if isempty(crop_parms),
      ii=[1 size(tmpFrame,1) 1 size(tmpFrame,2)];
    else,
      if ischar(crop_parms),
        if strcmp(crop_parms,'select'),
          tmpok=0;
          while(~tmpok),
            clf, image(tmpFrame), axis image, 
            title('Select Crop Locations (2)'),
            xlabel([fname,': Frame #1']),
            tmpii=ginput(2);
            tmpin=input('  re-select or continue [0=select, 1/enter=cont]: ');
            if isempty(tmpin), tmpin=1; end;
            if tmpin, tmpok=1; end;
          end;
          tmpii=round(tmpii);
          ii=[min(tmpii(:,2)) max(tmpii(:,2)) min(tmpii(:,1)) max(tmpii(:,1))];
        else,
          disp('  unrecognized crop option, using whole image...');
          ii=[1 size(tmpFrame,1) 1 size(tmpFrame,2)];
        end;
      else,
        ii=crop_parms;
      end;
    end;
    clf, image(tmpFrame(ii(1):ii(2),ii(3):ii(4),:)), axis image, 
    tmpFrame2=tmpFrame(ii(1):ii(2),ii(3):ii(4),:);
  end;
  
  if do_grayscale,
    if cnt==1,
      data=single(zeros(size(tmpFrame2,1),size(tmpFrame2,2),numFrames_est));
    end;
    tmpFrame=rgb2gray(tmpFrame);
  else,
    if cnt==1,
      data=single(zeros(size(tmpFrame,1),size(tmpFrame,2),size(tmpFrame,3),numFrames_est));
    end;
  end;
  if do_imadjust,
    tmpFrame=imadjust(tmpFrame);
  end;

  if do_grayscale,
    data(:,:,cnt)=single(tmpFrame(ii(1):ii(2),ii(3):ii(4)));
  else,
    data(:,:,:,cnt)=single(tmpFrame(ii(1):ii(2),ii(3):ii(4)));
  end;
  
  if do_display,
    figure(1),
    if do_grayscale,
      show(data(:,:,cnt)),
      drawnow,
    else,
      image(data(:,:,:,cnt)), axis image,
      drawnow,
    end;
  end;
end;

info.fname=vr.Name;
info.path=vr.Path;
info.duration=vr.Duration;
info.currentTime=vr.CurrentTime;
info.width=vr.Width;
info.height=vr.Height;
info.frameRate=vr.FrameRate;
info.bitsPerPixel=vr.BitsPerPixel;
info.videoFormat=vr.VideoFormat;
info.numFrames_est=numFrames_est;
info.numFrames_act=cnt;

info.ii=ii;
info.parms=parms;

if nargout==0,
  if isempty(sname), sname=fname(1:end-4); end;
  avgim_raw=mean(data,length(size(data)));
  stdim_raw=std(data,[],length(size(data)));
  avgtc_raw=squeeze(mean(mean(data,1),2));
  disp(sprintf('save %s_res.mat -v7.3 data info parms do_* *_raw fname sname',sname));
  eval(sprintf('save %s_res.mat -v7.3 data info parms do_* *_raw fname sname',sname));
end;

