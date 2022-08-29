function y=getTrigTime(yTrig,tTrig,tVector,tdist)
% Usage ... y=getTrigTime(yTrig,tTrig,tVector)
%
% Matches the index or trigger location of yTrig to the each time point in
% tVector. This function can be used to match timeEvents in tVector to
% trigger hits in variable yTrig with time vector tTrig. tDist is the
% distance tolerance to match the time (forward, default is 1). yTrig can 
% be the output of getTrigLoc and in that case tTrig is the a reasonable 
% time vector for it. If tTrig has only one value, it will be the time 
% sampling of yTrig.
%
% Ex. ii=getTrigLoc(biopacData.MainCam);
%     iicam=getTrigTime(ii,0.001,eeg1sleep.ts1);


if ~exist('tdist','var'), tdist=1; end;

if nargin==2,
    tVector=tTrig;
    if iscell(yTrig), 
        tmpTrig=cell2mat(yTrig); 
        tTrig=[1:max(tmpTrig(:))];
        clear tmpTrig
    else,
        tTrig=[1:max(yTrig)];
    end;
elseif length(tTrig)==1.
    if iscell(yTrig),
        tmpTrig=[];
        for nn=1:length(yTrig),
            tmpTrig=[tmpTrig; yTrig{nn}(:)];
        end
        tTrig=[1:max(tmpTrig(:))]*tTrig;
        clear tmpTrig
    else,
        tTrig=[1:max(yTrig)]*tTrig;
    end;    
end
    
for oo=1:length(tVector),

if iscell(yTrig),
  tmpii=[];
  tmpim=[];
  tmpfound=0;
  for mm=1:length(yTrig),
    tmpii=find( (tTrig(yTrig{mm})>=tVector(oo))&(tTrig(yTrig{mm})<(tVector(oo)+tdist)), 1);
    if (~isempty(tmpii))&(~tmpfound), 
      y(oo,:)=[tmpii(1) mm];
      tmpfound=1;    
    end;
  end
elseif length(yTrig)~=length(tTrig),
    tTrig=[1:max(yTrig)];
    tmpii=find( (tTrig(yTrig)>=tVector(oo))&(tTrig(yTrig)<(tVector(oo)+tdist)), 1);  
else,
    tmpii=find( (tTrig(yTrig)>=tVector(oo))&(tTrig(yTrig)<(tVector(oo)+tdist)), 1);
    if ~isempty(tmpii), y(oo)=tmpii; end;  
end

end

y(find(y==0))=nan;
