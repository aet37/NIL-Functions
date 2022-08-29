function out = trlavg(avgtmpp,trialsize,notrials)
%
% Usage ... out = trlavg(avgtmpp,trialsize or full-length,notrials)
%
% This function takes an average of the trials specified
% in the temporal response observed. The output variable
% will be of the size of the trial.
% 
% NOTE: the division between noimages and notrials MUST be
%       an integer value!
%

tmpsum=0;
if ( length(notrials)==1 ),
  noimages=length(avgtmpp);
  trialsize=noimages/notrials;
  for n=1:trialsize,
    for m=1:notrials,
      tmpsum=tmpsum+avgtmpp(n+(m-1)*trialsize);
    end;
    pavg(n)=tmpsum/notrials;
    tmpsum=0;
  end;
else,
  for n=1:trialsize,
    for m=1:length(notrials),
      tmpsum=tmpsum+avgtmpp(n+(m-1)*notrials(m));
    end;
    pavg(n)=tmpsum/length(notrials);
    tmpsum=0;
  end;
end;

out=pavg;
