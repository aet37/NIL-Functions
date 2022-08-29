function [xx,yc]=lineMotCorr1(im,parms)
% Usage ... y=lineMotCorr1(im,parms)

verbose_flag=0;
ups=parms(1);
smw=parms(2);
mfw=parms(3);
l1=parms(4);

imsize=size(im); tmp1=1;
for mm=l1+1:imsize(1),
  clear line1 line2
  line1=im(mm-1,:);
  line2=im(mm,:);
  line1=line1(:);
  line2=line2(:);
  if mfw>0, line1=medfilt2(line1,[mfw 1]); line2=medfilt2(line2,[mfw 1]); end;
  if smw>0, line1=smooth1d(line1,smw); line2=smooth1d(line2,smw); end;
  [xx(mm),yc(:,mm)]=mydftreg_1d(line1,line2,parms);
  disp(sprintf('  %02d: %.2f',mm,xx(mm)));
  if tmp1, xx(mm-1)=0; yc(:,mm)=line1; tmp1=0; end;
end;


if l1>1,
  for mm=l1-1:-1:1,
    clear line1 line2
    line1=im(mm+1,:);
    line2=im(mm,:);
    line1=line1(:);
    line2=line2(:);
    if mfw>0, line1=medfilt2(line1,[mfw 1]); line2=medfilt2(line2,[mfw 1]); end;
    if smw>0, line1=smooth1d(line1,smw); line2=smooth1d(line2,smw); end;
    [xx(mm),yc(:,mm)]=mydftreg_1d(line1,line2,parms);
    if verbose_flag, disp(sprintf('  %02d: %.2f',mm,xx(mm))); end;
  end;  
end;

yc=yc';

