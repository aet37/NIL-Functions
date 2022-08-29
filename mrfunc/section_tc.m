function [g,f,h]=section_tc(tc,cycles,norm,mult,sections)
% Usage ... [g,f,h]=section_tc(tc,cycles,norm,mult,sections)
%
% Returns the full set, mean and standard deviation
% Accomodate multiple TCs in adjacent columns
% g - Mean TC (Sectioned)
% f - Individual TCs (sectioned) Row-derected matrix
% h - Stdev of TCs

if mult,
  %disp('Multiple TC use...');
  ntcs=size(tc,2);
else,
  %disp('Single TC use...');
  ntcs=size(tc,2);
  tc=tc(:);
end;

nsections=length(sections)/2;
if nsections~=cycles,
  error('Invalid sections or cycles!');
end;

if ~exist('sections'),
  piece_length=length(tc)/cycles;
  sections=[1 piece_length];
  for m=2:cycles,
    sections=[sections (m-1)*piece_length+1 m*piece_length];
  end;
end;

count=0;
for n=1:ntcs,
  for m=1:nsections,
    count=count+1;
    tmp=tc(sections(2*m-1):sections(2*m),n)';
    f(count,:)=tmp;
  end;
end;

g=mean(f);
h=std(f);

if norm,
  if length(norm)==2,
    tmp_mean=mean(g(norm(1):norm(2)));
    g=(g-tmp_mean)./tmp_mean;
  else,
    g=(g-mean(g))/mean(g);
  end;
end;

if nargout==0,
  figure(2);
  plot(f');
  figure(1);
  subplot(211); plot(g);
  subplot(212); plot(h);
end;