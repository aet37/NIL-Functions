function y=maskLabel1up(maskstr,im)
% Usage ... y=maskLabel1up(maskstr,ims)


nVa=0; nVc=0; nVv=0;
iVa=[]; iVc=[]; iVv=[];
typeVa=[]; typeVc=[]; typeVv=[];

for mm=1:length(maskstr),
  tmpfound=0; tmpA=0; tmpC=0; tmpV=0;
  while(~tmpfound),
    [tmp1,tmp2]=getRectImGrid(im(:,:,1),maskstr(mm));
    im_overlay4(im(:,:,1),tmp2), xlabel(num2str(mm)), drawnow, pause(0.4),
    if size(im,3)>1,
      for nn=1:2,
        %im_overlay4(im(:,:,2),tmp2), xlabel(num2str(mm)), drawnow, pause(0.5),
        %im_overlay4(im(:,:,1),tmp2), xlabel(num2str(mm)), drawnow, pause(0.5),
        show(im(:,:,2)), xlabel(num2str(mm)), drawnow, pause(0.4),
        show(im(:,:,1)), xlabel(num2str(mm)), drawnow, pause(0.4),
      end;
      im_overlay4(im(:,:,1),tmp2), xlabel(num2str(mm)), drawnow,
    end; 
    tmpin=input('  type (a,c,v)= ','s');
    tmpfound=1;
    if strcmp(tmpin,'a'),
      nVa=nVa+1; tmpA=1;
    elseif strcmp(tmpin,'c'),
      nVc=nVc+1; tmpC=1;
    elseif strcmp(tmpin,'v'),
      nVv=nVv+1; tmpV=1;
    else,
      tmpfound=0;
    end;
  end;

  tmpfound=0; tmpN=0; tmpG=0;
  while(~tmpfound),
    [tmp1,tmp2]=getRectImGrid(im(:,:,1),maskstr(mm));
    im_overlay4(im(:,:,1),tmp2), xlabel(num2str(mm)), drawnow,
    if size(im,3)>1,
      for nn=1:2,
        show(im(:,:,2)), drawnow, pause(0.4),
        show(im(:,:,1)), drawnow, pause(0.4),
      end;
      im_overlay4(im(:,:,1),tmp2), xlabel(num2str(mm)), drawnow,
    end; 
    tmpin=input('  type (N,A)= ','s');
    tmpfound=1;
    if strcmp(tmpin,'N'),
      tmpN=1;
    elseif strcmp(tmpin,'n'),
      tmpN=1;
    elseif strcmp(tmpin,'A'),
      tmpG=1;
    elseif strcmp(tmpin,'a'),
      tmpG=1;
    elseif strcmp(tmpin,'G'),
      tmpG=1;
    elseif strcmp(tmpin,'g'),
      tmpG=1;
    else,
      tmpfound=0;
    end;
  end;

  if tmpA, iVa{nVa}=mm; typeVa{nVa}=tmpN+2*tmpG; disp(sprintf('  added ART (%d) type %d',nVa,typeVa{nVa})); end;
  if tmpC, iVc{nVc}=mm; typeVc{nVc}=tmpN+2*tmpG; disp(sprintf('  added CAP (%d) type %d',nVc,typeVc{nVc})); end;
  if tmpV, iVv{nVv}=mm; typeVv{nVv}=tmpN+2*tmpG; disp(sprintf('  added VEN (%d) type %d',nVv,typeVv{nVv})); end;
end;

y.a=nVa;
y.c=nVc;
y.v=nVv;
y.ai=iVa;
y.ci=iVc;
y.vi=iVv;
y.atype=typeVa;
y.ctype=typeVc;
y.vtype=typeVv;
