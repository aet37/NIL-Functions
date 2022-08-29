function [a,b,c,d,e]=multregdmtc(dmfilename,slc,x)
% Usage ... [a,b,..]=multregdmtc(dmfilename,slice,x)
%
% Uses time course data from dm file

[xr,xc]=size(x);
if (xr>xc) x=x'; end;
[xr,xc]=size(x);

info=getdmodinfo(dmfilename);
fid=fopen(dmfilename,'r');

for m=1:info(2),
  for n=1:info(3),
    tc=getdmodtc(fid,'all',slc,[m n]);
    x_sol=multreg(x,tc);
    for o=1:length(x_sol),
      if o==1, a(m,n)=x_sol(1);
      elseif o==2, b(m,n)=x_sol(2);
      elseif o==3, c(m,n)=x_sol(3);
      elseif o==4, d(m,n)=x_sol(4);
      elseif o==5, e(m,n)=x_sol(5);
      end;
    end;
  end;
end;

fclose(fid);
