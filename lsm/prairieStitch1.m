function stk2=prairieStitch1(stk,dim,overf,wl)
% Usage ... y=PrairieStitch1(stk,dim,overlapfrac,wl)

[rr,cc]=size(stk(:,:,1));
ro=floor(rr*overf);
co=floor(cc*overf);

stk2=0;
tmpcnt=0;
for mm=1:dim(2), for nn=1:dim(1),
  tmpcnt=tmpcnt+1;
  tmpim=(mm-1)*dim(1)+dim(1)-nn+1;
  tmprow=(mm-1)*(rr-2*ro+1);
  tmpcol=(nn-1)*(cc-2*co+1);
  tmploc(tmpcnt)=tmpim;
  stk2([1:rr-2*ro+1]+tmprow,[1:cc-2*co+1]+tmpcol)=stk(ro:end-ro,co:end-co,tmpim);
  %keyboard,
end; end;

if nargout==0,
  tmploc,
  show(stk2,wl)
end;
