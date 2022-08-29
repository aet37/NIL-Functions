function y=showProjRot(stk,ang,type,ww)
% Usage y=showProjRot(stk,angles,type,weight)
%
% angles= vector in degrees, convention is negative ([0:-5:-180])
% type= proj type (max, min, etc.)
% weight= user defined or trapezoidal ([centeri, ramp-size])

rtype=1;

do_ww=0; do_max=0;
if nargin==4, rtype=2; do_ww=1; do_max=1; end;
if nargin==3, rtype=2; do_max=1; ww=[]; end;
if do_ww, if length(ww)==0; rtype=2; do_ww=0; end; end;


if rtype==1,
  tmprad=radon(stk(:,:,1),0);
  y=zeros(size(tmprad,1),size(stk,3),length(ang));
end;

for nn=1:length(ang),
  for mm=1:size(stk,3),
    if rtype==1,
      % radon
      y(:,mm,nn)=radon(stk(:,:,mm),ang(nn));
    else,
      % rot
      tmpim=imrotate(stk(:,:,mm),ang(nn),'bilinear','crop');
      if do_ww,
        if length(ww)==size(tmpim,1),
          wim1=ww(:).';
        else,
          wim1=mytrapezoid3([1:size(tmpim,1)],ww(1),0,[ww(2) ww(2)]);
        end;
        wim=wim1'*ones(1,size(tmpim,2));
        %wim=ones(size(tmpim,2),1)*wim1;
        tmpim=tmpim.*wim;
      end;
      if do_max,
        if strcmp(type,'max'), y(:,mm,nn)=max(tmpim,[],1)';
        elseif strcmp(type,'min'), y(:,mm,nn)=min(tmpim,[],1)';
        else, y(:,mm,nn)=sum(tmpim,1)'./sum(tmpim~=0,1)';
        end;
      else,
        y(:,mm,nn)=sum(tmpim,1)'./sum(tmpim~=0,1)';
      end;
      %subplot(211), show(tmpim), drawnow,
      %subplot(212), plot(y(:,mm,nn)), drawnow,
    end;
  end;
end;
y(find(isnan(y)))=0;

if nargout==0,
  clf,
  for mm=1:size(y,3),
    %if do_ww,
    %  subplot(212),
    %  plot(wim1), axis tight,
    %  subplot(211),
    %end;
    show(y(:,:,mm)',[min(y(:)) max(y(:))]),
    xlabel(sprintf('%d deg',ang(mm))),
    drawnow, pause(0.1),
  end;
  clear y
end;

