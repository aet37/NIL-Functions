function y=volzAdj1(vol,adj_env,adj_type,adj_parms)
% Usage ... y=volzAdj1(vol,adj_vec,adj_type)
%
% Volume adjust intensity as a function of volume#
% Currently only supports 4-dim volumes
% adj_types are 1-linear, 2-exp, 3-qtile
% adj_parms = [factor/order factor2 norm minthr maxthr extras] 
%
% Ex. volzAdj1(data,[],1,[4 6]);
%     showProj(volzAdj1(data,[],1,[4 6]))
%     showProj(volzAdj1(data,[],1,[4 6 0 0.4 4.0]))
%     showProj(volzAdj1(data,[],2,[4 4 0 0.4 4.0]))
%

if nargin<4, adj_parms=[]; end;
if nargin<3, adj_type=[]; end;
if nargin<2, adj_env=[]; end;

vol=squeeze(vol);
vdim=size(vol);

if ~isempty(adj_env),
  if length(vdim)==4,
    for mm=1:vdim(4), for nn=1:vdim(3), y(:,:,nn,mm)=vol(:,:,nn,mm)*adjVec(mm,nn); end; end;   
  else,
    for nn=1:vdim(3), y(:,:,nn)=vol(:,:,nn)*adjVec(nn); end;   
  end
  return,
end

do_norm=0;

if isempty(adj_type), adj_type=1; end;
if isempty(adj_parms),
  if adj_type==3,
      adj_parms=[4 0 0 0.4 4.0]; 
  elseif adj_type==2,
      adj_parms=[6 4 0 0.4 4.0]; 
  else,               
      adj_parms=[1 0 0 0.4 4.0]; 
  end
else,
  if length(adj_parms)==2, adj_parms(3:5)=[0 -1 -1]; end;
end
ap1=adj_parms(1);
ap2=adj_parms(2);
do_norm=adj_parms(3);
adj_minmax=adj_parms(4:5);


qtiles=[.025 .25 .50 .75 .975];

% set up envelopes
if length(vdim)==4,
  if adj_type==3,
    volqtiles=quantile(reshape(vol,[vdim(1)*vdim(2) vdim(3) vdim(4)]),qtiles,1); 
    volqtiles=permute(volqtiles,[3 1 2]);
    for mm=1:size(volqtiles,2), 
      for nn=1:size(volqtiles,3),
        fitqtiles(:,mm,nn)=polyval(polyfit([1:vdim(4)]',volqtiles(:,mm,nn),ap1), [1:vdim(4)]');
      end
    end,
    fitqtiles1=squeeze(fitqtiles(:,4,:)-fitqtiles(:,2,:));
    fitqtiles1=fitqtiles1./(ones(size(fitqtiles,1),1)*mean(fitqtiles1,1));
    adjVec=1./fitqtiles1;
    
  elseif adj_type==2,
    adjVec=exp(ap1*([0:vdim(end)-1]'/(vdim(end)-1)))-1;
    adjVec=ap2*(adjVec/max(adjVec(:)))+1;
    avgSig=squeeze(mean(mean(vol,1),2));
    if length(vdim)==4, 
      avgSig=avgSig'; 
      avgSig1=mean(avgSig,1); 
      avgSig1=avgSig1/mean(avgSig1);
      adjVec=adjVec*ones(1,vdim(3));
    end;
    if (length(vdim)==4)&(length(adj_parms)>5),
      %avgSig1,
      for mm=1:vdim(3), adjVec(:,mm)=adjVec(:,mm)*adj_parms(mm+5); end;
    end;

  else,
    adjVec=[0:vdim(end)-1]'/(vdim(end)-1);
    adjVec=adjVec+ap2*([0:vdim(end)-1]'/(vdim(end)-1)).^2;
    adjVec=adjVec/max(adjVec(:));
    avgSig=squeeze(mean(mean(vol,1),2));
    if length(vdim)==4, 
      avgSig=avgSig'; 
      avgSig1=mean(avgSig,1); 
      avgSig1=avgSig1/mean(avgSig1);
      adjVec=adjVec*ones(1,vdim(3));
    else,
      adjVec=avgSig;      
    end;
    if (length(vdim)==4)&(length(adj_parms)>5),
      %avgSig1,
      for mm=1:vdim(3), adjVec(:,mm)=adjVec(:,mm)*adj_parms(mm+5); end;
    end;
    adjVec=ap1*adjVec+1;

  end
else,
  if adj_type==3,
    volqtiles=quantile(reshape(vol,[vdim(1)*vdim(2) vdim(3)]),qtiles,1)';
    for mm=1:size(volqtiles,2), 
      fitqtiles(:,mm)=polyval(polyfit([1:vdim(3)]',volqtiles(:,mm),4),[1:vdim(3)]');
    end, 
    fitqtiles1=fitqtiles(:,4)-fitqtiles(:,2);
    fitqtiles1=fitqtiles1/mean(fitqtiles1);
    adjVec=1./fitqtiles1;
  end
  
end


if adj_minmax(1)==-1, adj_minmax(1)=0; end;
if adj_minmax(2)==-1, adj_minmax(2)=max(adjVec(:)); end;

adjVec(find(adjVec<adj_minmax(1)))=adj_minmax(1);
adjVec(find(adjVec>adj_minmax(2)))=adj_minmax(2);


% apply envelopes
y=vol;
if length(vdim)==4,
  for mm=1:vdim(4), for nn=1:vdim(3), 
    if (adj_type==3)&do_norm,
      y(:,:,nn,mm)=(vol(:,:,nn,mm)-fitqtiles(mm,1,nn))/(fitqtiles(mm,5,nn)-fitqtiles(mm,1,nn));
    end  
    y(:,:,nn,mm)=y(:,:,nn,mm)*adjVec(mm,nn);
  end; end;
else,
  for nn=1:vdim(3), y(:,:,nn)=vol(:,:,nn)*adjVec(nn); end;   
end

%vdim,
%size(adjVec)

% last
if nargout==0,
  figure(1), clf,
  if adj_type==3,
    subplot(311), plot([1:vdim(end)],volqtiles(:,:,1),[1:vdim(end)],fitqtiles(:,:,1)), axis tight, grid on,
    subplot(312), plot([1:vdim(end)],volqtiles(:,4,1)-volqtiles(:,2,1),[1:vdim(end)],fitqtiles(:,4,1)-fitqtiles(:,2,1)), axis tight, grid on,
    subplot(313), plot([1:vdim(end)],adjVec), grid on,
  else,
    subplot(311), plot([1:vdim(end)],avgSig), axis tight, grid on,
    subplot(312), plot([1:vdim(end)],adjVec), axis tight, grid on,
    subplot(313), plot([1:vdim(end)],avgSig.*adjVec), axis tight, grid on,
  end
  figure(2), clf, showProj(y),
  clear y
end


% 
% vol_z_int=squeeze(mean(mean(vol,1),2));
% 
% 
% if nargin<3, env=ones(vdim(end),1); end;
% 
% if length(env)==1,
%   env=(1-[1:vdim(end)]/(vdim(end)/env));
%   plot(env)
% elseif length(env)==2,
%   tmpenv=(1-[1:vdim(end)]/(vdim(end)/env(1)));
%   tmpenv=exp(tmpenv*env(2));
%   env=tmpenv;
%   plot(env);
% end;
% 
% if ischar(adjv),
%   if strcmp(adjv,'mean')|strcmp(adjv,'avg'),
%     adjv=1./mean(vol,length(vdim));
%   elseif strcmp(adjv,'max'),
%     adjv=1./max(vol,[],length(vdim));
%   elseif strcmp(adjv,'min'),
%     adjv=1./min(vol,[],length(vdim));
%   else,
%     adjv=ones(vdim(end),1);
%   end;
% end;
% 
% if prod(size(adjv))==length(adjv),
%   if length(vdim)==4, adjv=repmat(adjv,[1 vdim(3)]); end;
% end;
% 
% if length(vdim)==4,
%   for mm=1:vdim(4), for nn=1:vdim(3),
%     vol(:,:,nn,mm)=vol(:,:,nn,mm)*adjv(mm,nn);
%   end; end;
% else,
%   for mm=1:vdim(3),
%     vol(:,:,mm)=vol(:,:,mm)*adjv(mm)*env(mm);
%   end;
% end;
% vol_adj_z_int=squeeze(mean(mean(vol,1),2));
% 
% if nargout==0,
%   clf,
%   subplot(211), plot([vol_z_int(:)]),
%   subplot(212), plot([vol_adj_z_int(:)]),
%   clear vol
% end;
% 
