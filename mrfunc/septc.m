function [f,g,h]=septc(tc,pixlista,pixlistb,cycles,norm,skip,average,regspan)
% Usage ... [f,g,h]=septc(tc,pixlista,pixlistb,cycles,norm,skip,average,regspan)
% Copies the timecourses (tc) from pixlista to pixlist b.
% If cycles is not zero then areas will be cut
% If norm is not zero then they will be normalized using the mean
%  section described in norm.
% Skip will skip a constant trial from the timecourse source.
% Average will output one averaged timecourse, f, and g will
% contain the quantity of timecourses averaged. Enter a 2 in average
% to subtract any linear trend from the vector on indices regspan.
% Enter a 3 and it will calculate the line according to endpoint avg.
% thru the entire timecourse (no trials) and the tol will be used.
% Note: Function currently set to only remove the same ONE cycle from
% each run.

[rt,ct]=size(tc);
[rpa,cpa]=size(pixlista);
[rpb,cpb]=size(pixlistb);
newtc=zeros([rpb ct]);

if (~exist('skip')), skip=0; end;
if (~exist('average')), average=0; end;

if (rt~=rpa),
  error('Error: pixlist size does not match tc size!');
end;

fnd=0;
for m=1:rpb,
  for n=1:rpa,
    if ((pixlista(n,1)==pixlistb(m,1))&(pixlista(n,2)==pixlistb(m,2))),
      fnd=fnd+1;
      newtc(fnd,:)=tc(n,:);
      if (average==3),
        line=zeros([1 ct]);
        [slp,bint]=lreg([1:ct],newtc(fnd,:));
        if(abs(slp)>regspan), line=slp*[1:ct]+bint; end;
        newtc(fnd,:)=newtc(fnd,:)-line;
      end;
    end;
  end;
end;
if (fnd~=rpb),
  disp(['Warning: Pixels in list b found not to be included in list a']);
end;

if (cycles),
  if (norm(1)),
    clip=matclip(newtc,cycles,0,norm);
  else,
    clip=matclip(newtc,cycles,0,0);
  end;
  newtc=clip;

  if length(skip)==1,
    [nr,nc]=size(newtc);
    if (rem(nr,cycles)),
      disp(['Warning: Can not perform skip, improper timecourses']);
    else,
      for m=1:(nr/cycles),  rmclip(m)=skip+cycles*(m-1); end;
      clip=modclip(newtc,0,rmclip);
      newtc=clip;
    end;
  else,
    rmclip=skip(2:length(skip));
    newtc=modclip(newtc,0,rmclip);
  end;
end;

if (average),
  [nr,nc]=size(newtc);
  g=std(newtc);
  newtc=mean(newtc);
  h=nr; g=g(:); newtc=newtc(:);
  if(average==2),
    [slp,bint]=lreg( [regspan(1):regspan(2)], newtc(regspan(1):regspan(2)) );
    line=slp*[1:length(newtc)]+bint;
    line=line(:);
    newtc=newtc-line;
  end;
  if(average==4),
    mbeg=mean(newtc(1:regscan));
    mend=mean(newtc(length(newtc)-regscan:regscan));
    slp=(mend-mbeg)/length(newtc);
    line=slp*[0:length(newtc)-1]+mbeg;
    line=line(:);
    newtc=newtc-line;
  end;
else,
  g=0;
end;

f=newtc;

if (nargout==0)
  clg
  plot(newtc')
end;
