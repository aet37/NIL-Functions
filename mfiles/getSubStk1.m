function ysi=getSubStk1(data,loc,sz,parms)
% Usage ysi=getSubStk1(data,loc,sz,parms)
%
% Extract the sub-stack from data centered on position loc with size sz. This sub-stack
% can be filtered based on parameters parms. loc=[x1 y1] or 'select'. 
% sz can be specified or default to 10% of sz.
% parms = [type p1 p2 p3], default is 1=pca, 40=nkeep

data=squeeze(data);
imsz=size(data);

if ~exist('sz','var'), sz=[]; end;
if ~exist('parms','var'), parms,[]; end;
if ~exist('loc','var'), loc='select'; end;

if isempty(sz), sz=round(ceil(0.08*imsz(1:2)*2)/2); end;
if isempty(parms), parms=[1 40]; end;

if ischar(loc),
  if strcmp(loc,'select'),
    tmpim=mean(data,3);
    tmploc=[];
    tmpok=0; tmpupdate=0;
    while(~tmpok),
      figure(1), clf,
      show(tmpim), dranwow,
      [tmpy,tmpx,tmpbut]=ginput(1);
      tmpx=round(tmpx); tmpy=round(tmpy);
      if isempty(tmpbut),
        tmpok=1;
      elseif ((tmpx<1)|(tmpx>imsz(1)|(tmpy<1)|(tmpy>imsz(2))),
        tmpok=1;
        tmpupdate=0;
        tmpok=1;
      elseif tmpbut==29,
        tmploc(1)=tmploc(1)+1;
        tmpupdate=1;
      elseif tmpbut==28,
        tmploc(1)=tmploc(1)-1;
        tmpupdate=1;
      elseif tmpbut==31,
        tmploc(2)=tmploc(2)+1;
        tmpupdate=1;
      elseif tmpbut==30,
        tmploc(2)=tmploc(2)-1;
        tmpupdate=1;
      else,
        loc=[tmpy tmpx];
        tmpupdate=1;
      end;
      if tmpok, loc=tmploc; end;
      if tmpupdate,
        if ~isempty(tmploc),
          tmpi1=[0:sz(1)-1]-round(sz(1)/2)+tmploc(1);
          tmpi2=[0:sz(2)-1]-round(sz(2)/2)+tmploc(2);
          tmpi1=find(tmpi1>=1); tmpi1=find(tmpi1<=sz(1));
          tmpi2=find(tmpi2>=1); tmpi2=find(tmpi2<=sz(2));
          figure(2), clf,
          show(tmpim(tmpi1,tmpi2)), drawnow,
        end;
      end;
    end;    
  end;
end;

if isempty(loc),
  disp('  empty location, exiting');
  ysi=[];
  return;
end;

tmpi1=[0:sz(1)-1]-round(sz(1)/2)+loc(1);
tmpi2=[0:sz(2)-1]-round(sz(2)/2)+loc(2);
tmpi1=find(tmpi1>=1); tmpi1=find(tmpi1<=sz(1));
tmpi2=find(tmpi2>=1); tmpi2=find(tmpi2<=sz(2));

ysi=data(tmpi1,tmpi2,:);

if parms(1)==1,
  nkeep=parms(2);
  ysi=pcaimdenoise(ysi,nkeep,1,1);
end;

