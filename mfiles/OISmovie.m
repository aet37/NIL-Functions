function y=OISmovie(fname,fps,nfa,nims,wlev,avispeed,cropdim)
% Usage ... OISmovie(fname,fps,nfa,nims,wlev,avispeed,cropdim)

if nargin<7,
  cropdim=[];
end;
if nargin<6,
  avispeed=1;
end;
if nargin<5,
  wlev=[];
end;

avirootname=fname(1:end-4);
cmap=gray(256);

movfig=figure;
colormap(cmap)
set(movfig,'DoubleBuffer','on');
set(gca,'NextPlot','replace','Visible','off');

aviname=sprintf('%s_%df_%dx.avi',avirootname,nims,avispeed),
movavi=avifile(aviname,'FPS',avispeed*fps/nfa,'COMPRESSION','None','QUALITY',100,'COLORMAP',gray(256)),

disp('  press enter to start loading frames...'); pause;

for nn=1:nims,
  tmpim=getOISim(fname,nn);
  tmpim=tmpim';
  %tmpim=imflip(tmpim,'ud');
  if (length(cropdim)==4),
    tmpim2=tmpim(cropdim(1):cropdim(2),cropdim(3):cropdim(4));
  else,
    tmpim2=tmpim;
  end;
  if isempty(wlev),
    showim2(tmpim2)
  else,
    showim2(tmpim2,wlev)
  end;
  title(''), axis('off'), grid('off'), axis('image'),
  drawnow;
  mov(nn)=getframe;
  movavi=addframe(movavi,mov(nn));
end;
movavi=close(movavi);

disp('  press enter to display movie (or ctrl-C to exit)...'); pause;
movie(mov,2,avispeed*fps/nfa)

