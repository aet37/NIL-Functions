function out=mskpixls(mask,conval)
%
% Usage ... out=mskpixls(mask,conval)
%
% Makes an nx3 matrix containing all of the pixels
% contained in a mask. The condition value specifies
% any particular pixel value to include in mask.
% A 0 in this entry will choose all with their weights,
% 1 will only include those pixels with weight of 1. 
% A different entry will only select those pixels weighted
% equally or above the condition value in a scale (0,1].
%

isize=length(mask);
ll=1; mm=0; m=0;

if ( conval==0 ),
  for mm=1:isize, for m=1:isize,
    if ( mask(mm,m)~=0 ), tmplocs(ll,1)=mm; tmplocs(ll,2)=m;
      tmplocs(ll,3)=mask(mm,m); ll=ll+1;
    end;
  end; end;
else
  for mm=1:isize, for m=1:isize,
    if ( mask(mm,m)>=conval ), tmplocs(ll,1)=mm; tmplocs(ll,2)=m;
      tmplocs(ll,3)=mask(mm,m); ll=ll+1;
    end;
  end; end;
end;

out=tmplocs;
