function [St,Sti,phsi]=velspoil(t,v,r0,G)
% Usage ... s=velspoil(t,v,r0,G)
%
% Units: t (s), v (m/s), r0 (m), G (G/cm)

showfig=1;
nspins=size(v,1);

% select certain spins
vmag=((sum((v.^2)')).^(0.5))';
if ((sum(vmag)==0)|((sum(vmag)/nspins)==vmag(1))),
  ii=[1 2 3];
else,
  [vmax,vmaxi]=max(vmag);
  [vmin,vmini]=min(vmag);
  tmp=find(vmag>=((vmax-vmin)/2+vmin));
  vmidi=tmp(1);
  vmid=vmag(vmidi);
  ii=[vmini vmidi vmaxi];
end;

for m=1:nspins,
  xx=movspin(t,100*ones([length(t) 1])*v(m,:),100*ones([length(t) 1])*r0(m,:));
  if (m==ii(1)), xxi(:,:,1)=xx;
  elseif (m==ii(2)), xxi(:,:,2)=xx;
  elseif (m==ii(3)), xxi(:,:,3)=xx;
  end;
  phs1(:,m)=movspinphs(G,xx,t);
  fprintf('\r%d/%d',m,nspins)
end;
St=(1/nspins)*real( sum( exp(i*phs1') ) );
phsi=phs1(:,ii);
Sti=real( exp(i*phsi) );

clear phs1 xx

if ((nargout==0)|(showfig)),
  subplot(311)
  plot(t,St)
  xlabel('Time'),ylabel('Signal')
  subplot(325)
  plot(t,phsi)
  xlabel('Time'),ylabel('Signal')
  subplot(312)
  plot(t,G)
  xlabel('Time'),ylabel('Gradient Amplitude')
  subplot(326)
  plot(t,xxi(:,:,1),t,xxi(:,:,2),t,xxi(:,:,3))
  xlabel('Time'), ylabel('Position')
end;

