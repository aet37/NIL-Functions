function f=detrend_tc(time,tc,cycles,guess,options,range,type,out)
% Usage ... f=detrend_tc(time,tc,cycles,guess,options,range,type,out)

tc=tc(:);

tmp_clip=matclip(tc',cycles);
tmp_mean=mean(tmp_clip');
for m=1:length(tmp_mean),
  tmp_clip(n,:)=(tmp_clip(n,:)-tmp_mean(n))/tmp_mean(n);
end;

for n=1:cycles,
  tmp_clip(n,:) = (tmp_clip(n,:)-mean(tmp_clip(n,:)))/mean(tmp_clip(n,:));
  tmp_parms(n,:) = leastsq('mydtren',guess,options,[],time,tmp_clip(n,:),range,type);
  if exist('out'), if out==1,
    inp=1;
    while (inp),
      inp=input('Enter new range (0-Done): ');
      if ~inp,
        disp('Next...');
        break;
        disp('Next...');
      else,
        disp(inp);
        tmp_parms(n,:) = leastsq('mydtren',guess,options,[],time,tmp_clip(n,:),inp,type);    
      end;
    end;
  end; end;
  tmp_det(n,:) = mydtren(tmp_parms(n,:),time,tmp_clip(n,:),range,type*11)';
  tmp_det(n,:) = tmp_det(n,:)*tmp_mean(n)+tmp_mean(n);
end;

f=tmp_det(1,:);
if cycles>1,
  for n=2:cycles,
    f=[f tmp_det(n,:)];
  end;
end;

if exist('out')
  if out==2,
    f=mean(tmp_det);
  end;
end;

f=f(:);

if nargout==0
  plot(time,f)
end;