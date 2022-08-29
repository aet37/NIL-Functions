function [newii,newii2]=i2i(ii,ii_map,nanflag,p1)
% Usage [new_ii,new_ii2]=i2i(ii,ii_map)
%
% provides new_ii that maps indeces of ii from ii_map
% in other words, it returns the indeces for the elements of ii in ii_map
% i2i([1:2:9],[3 6 5]) returns [2 3] and [1 2]
%
% This syntax can also be used:
%   ii=i2i(i1,'in',i2);
%   ii=i2i(i1,'notin',i2);
%   

verbose_flag=1;

if ischar(ii_map), 
    ii_crel=ii_map; 
    ii_map=nanflag; 
    if exist('p1','var'), nanflag=p1; end;
end;

if ~exist('nanflag','var'), nanflag=1; end;

for mm=1:length(ii_map),
  tmpi=find(ii_map(mm)==ii,1);
  if isempty(tmpi),
    newii(mm)=nan;
  else,
    newii(mm)=tmpi;
  end;
end;

if nanflag,
    newii_orig=newii;
    newii2_orig=find(isnan(newii_orig));
    newii1_orig=find(~isnan(newii_orig)); 
    newii=newii(find(~isnan(newii))); 
end;

if ~isempty(newii),
  for mm=1:length(newii),
    tmpi=find(ii_map==ii(newii(mm)),1);
    newii2(mm)=tmpi;
  end;
  if length(newii2)~=length(ii_map),
    disp('  warning: record new_ii2...');
  end;
end;


if exist('ii_crel','var'),
  if strcmp(ii_crel,'notin'),
    
    newiinot=[];
    for mm=1:length(ii),
      tmpi=find(ii(mm)==ii_map,1);
      if isempty(tmpi),
        newiinot(mm)=nan;
      else,
        newiinot(mm)=tmpi;
      end;
    end;
    
    newii=find(isnan(newiinot));
    newii2=ii(newii);
  end;
end;

if nargout==0,
  %ii(:)', ii_map(:)', 
  newii(:)', newii2(:)',
  clear newii newii2
end;

%if verbose_flag,
%  disp(sprintf('  %d in i_map is %d',ii_map(1),newii(1)));
%end;
