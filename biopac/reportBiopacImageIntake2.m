function [tData,ttData,dtData,dttData]=ReportBiopacImageIntake2(bname,imChName,trigs,trigwin,biots)
% Usage ... tData=ReportBiopacImageIntake2(bname,imChName,trigs,trigwin,biots)

disp('  loading biopac matlab data');
eval(sprintf('load %s',bname));

trigData=trigLoc(trigs);
ii=[trigLoc(trigs(1))+trigwin(1):trigLoc(trigs(end))+trigwin(2)];
eval(sprintf('chData=biopacData.%s(ii);',imChName));
disp(sprintf('  window= [%d %d] (%d, %d)',ii(1),ii(end),ii(end)-ii(1),trigLoc(trigs(1))));
dchDatai=find(diff(chData)>1)+1;

if (length(trigs)==2),
  iit=trigLoc(trigs(1):trigs(end));
else,
  iit=trigLoc(trigs);
end;
ttData=biots*(iit-iit(1));
dttData=diff(ttData);

tt=biots*(ii-trigLoc(trigs(1)));
tData=tt(dchDatai);
dtData=diff(tData);

clear bipoacData

disp(sprintf('  #ims= %d (%.3f,%.3f)',length(tData),mean(dtData),std(dtData)));

