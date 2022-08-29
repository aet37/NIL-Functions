function y=maskrelabel(x,n_min)
% Usage ... y=maskrelabel(x,n_min)
%
% Relabels the labeled mask x to have contigous labels and eliminating
% labels that have less then n_min members

if nargin==1, nmin=2; end;

y=x;
for mm=1:max(x(:)), x_n(mm)=sum(x(:)==mm); end;

tmpi=find(x_n<n_min);
if ~isempty(tmpi),
  tmpi=tmpi(end:-1:1);
  for mm=1:length(tmpi),
    for nn=tmpi(mm):max(x(:))-1,
       y(find(y==(nn+1)))=nn;
    end;
  end;
end;
