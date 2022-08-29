function y=OISmovie(data,fname,wlev,fps,cropdim,cmap)
% Usage ... OISmovie(data,fname,wlev,fps,cropdim)
% 
% Ex. OISmovie2(map3.adata,'wh2_map3_adata1.avi',[-1 1]*0.007)
%     !myff wh2_map3_adata1.avi

data=squeeze(data);

avispeed=1;
if ~exist('fps','var'), fps=[]; end;
if ~exist('wlev','var'), wlev=[]; end;
if ~exist('cropdim','var'), cropdim=[]; end;
if ~exist('cmap','var'), cmap=[]; end;

if isempty(cmap),
  %cmap=jet(256);
  cmap=gray(256);
end;

avirootname='OISmovie';

datasz=size(data);

if iscell(data),
  nims=length(data);
else,
  nims=datasz(end);
end

if isempty(fps), if nims<300, fps=10; else, fps=30; end; end;

movfig=figure;
colormap(cmap)
set(gcf,'Units','pixels','Position',[100 100 datasz(1:2)])

if isempty(fname), aviname=sprintf('%s_%df_%dx.mp4',avirootname,nims,avispeed); else, aviname=fname; end;
%movavi=avifile(aviname,'FPS',avispeed*fps,'COMPRESSION','None','QUALITY',100,'COLORMAP',gray(256)),

if strcmp(fname(end-2:end),'mp4'),
  disp('  saving mpeg-4 quality=100'); 
  writerObj = VideoWriter(aviname,'MPEG-4');
  writerObj.Quality = 100;
elseif strcmp(fname(end-2:end),'avi'),
  disp('  saving jpeg-avi quality=100'); 
  writerObj = VideoWriter(aviname,'Motion JPEG AVI');
  writerObj.Quality = 90;
else,
  disp('  saving uncompressed avi'); 
  fname=[fname,'.avi'];
  writerObj = VideoWriter(aviname,'Uncompressed AVI');
end

writerObj.FrameRate = fps;
open(writerObj);

for nn=1:nims,
  if iscell(data),
    tmpim=data{nn};
  else,
    if length(datasz)>3, 
      tmpim=data(:,:,:,nn);
      if datasz(3)>=3, tmpim=tmpim(:,:,1:3);
      elseif datasz(3)==2, tmpim(:,:,3)=0;
      end;
    else,
      tmpim=data(:,:,nn); 
    end;
  end;
  
  %tmpim=tmpim';
  %tmpim=imflip(tmpim,'ud');
  
  if length(cropdim)==4,
    tmpim2=tmpim(cropdim(1):cropdim(2),cropdim(3):cropdim(4));
  else,
    tmpim2=tmpim;
  end;
  
  imagesc(imwlevel(tmpim2,wlev,1)),
  axis('image'), title(''), axis('off'), grid('off'),  
  set(gca,'Position',[0 0 1 1]);
  drawnow,
  mov(nn)=getframe;
  writeVideo(writerObj, mov(nn));
end;
%movavi=close(movavi);
close(writerObj);

tmpin=input('Press enter to exit or 1 to display movie...','s');
if ~isempty(tmpin)&strcmp(tmpin(1),'1'),
  movie(mov,2,avispeed*fps)
end;

if strcmp(fname(end-2:end),'avi')|strcmp(fname(end-2:end),'AVI'),
  tmpin=input('  run ffmpeg transcode to mp4? [1=yes]: ');
  if ~isempty(tmpin), if tmpin==1, eval(['!myff last']), end; end;
end


