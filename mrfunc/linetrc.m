function mval = linetrc(mask,coord)
%
% Usage ... mval = linetrc(mask,coord)
%
%

deltay=round(coord(2,2)-coord(1,2));
deltax=round(coord(2,1)-coord(1,1));
idealangle=atan(deltay/deltax);
dist=round(sqrt(abs(deltay*deltay-deltax*deltax)));

tmpx=coord(1,1);
tmpy=coord(1,2);
finx=coord(2,1);
finy=coord(2,2);
if ( finy>tmpy ), incry=1; else, incry=-1; end;
if ( finx>tmpx ), incrx=1; else, incrx=-1; end;

pix(1,:)=[tmpx tmpy];
for n=1:dist,
  tmpx=tmpx+incrx;
  tmpanglex=atan((finy-tmpy)/(finx-tmpx));
  tmpdevx=abs(idealangle-tmpanglex);
  tmpy=tmpy+incry;
  tmpangley=atan((finy-tmpy)/(finx-(tmpx-incrx)));
  tmpdevy=abs(idealangle-tmpangley);
  tmpanglem=atan((finy-tmpy)/(finx-tmpx));
  tmpdevm=abs(idealangle-tmpanglem);
  if ( (tmpdevx<tmpdevy)&(tmpdevx<tmpdevm) ), tmpy=tmpy-incry; end;
  if ( (tmpdevy<tmpdevx)&(tmpdevy<tmpdevm) ), tmpx=tmpx-incrx; end;
  pix(n+1,:)=[tmpx tmpy];
end;
if ( (pix(n+1,1)~=finx)&(pix(n+1,2)~=finy) ),
 pix(n+2,1)=finx; pix(n+2,2)=finy;
end;

for n=1:length(pix),
  val(n)=mask(pix(n,1),pix(n,2));
end;

pixel=pix;
mval=val;
