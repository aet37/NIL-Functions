function [newclip,rmclip]=modclip(origclip,func,rclip)
%
% usage .. [newclip,rmclip]=modclip(origclip,func,rclip)
%
% Functions: 0- remove row(s) specified in rclip
%            1- add row(s) rclip to end
%            2- in place one of func vector replace row(s) with rclip
%

matsize=size(origclip);
rclipsize=size(rclip);
n=0; ii=1; jj=1;

if ( length(func)==1 ),
 if ( func==0 ),
  rclip=sort(rclip); rclip(length(rclip)+1)=0;
  for n=1:matsize(1),
    if ( n==rclip(jj) ), rmclip(jj,:)=origclip(n,:); jj=jj+1; 
    else, tmpclip(ii,:)=origclip(n,:); ii=ii+1;
    end;
  end;
 elseif ( func==1 ),
  tmpclip=origclip;
  rmclip=0;
  ii=matsize(1);
  for n=1:rclipsize(1), tmpclip(ii+n,:)=rclip(n,:); end;
 end;
else,
 if ( func(1)==2 ),
  tmpclip=origclip;
  for n=2:length(func),
    rmclip(n-1,:)=tmpclip(func(n),:);
    tmpclip(func(n),:)=rclip(n-1,:);
  end;
 end;
end;

newclip=tmpclip;
