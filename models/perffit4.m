function [z,result]=perffit4(times,data,t_tag,T1a,T1b,M0b,alpha,uptakedt)
% Usage ... [[f dt],dM]=perffit4(uptaketime,data,t_tag,T1a,T1b,M0b,alpha,uptakedt_optional)

if (nargin==8), uptakemethod=0; else, uptakemethod=1; end;

%%  Assumed constants  %%%
FlowScaleFactor = 100 * 60;

% Initial Guesses %%%%%%%%%%
f0 = 0.01;
dt0 = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opt2=optimset('fminbnd');
opt2.TolX=1e-8;
opt2.MaxFunEvals=12000;
opt2.MaxIter=12000;

opt3=optimset('lsqcurvefit');
opt3.MaxFunEvals=12000;
opt3.TolFun=1e-6;
opt3.TolPCG=1e-6;


if (uptakemethod),

  guess0 = [f0 dt0];
  guessLB= [0 0];
  guessUB= [1e10 100];

  guess = lsqcurvefit('FAIR_func4',guess0, times, data, guessLB, guessUB, opt3, t_tag, T1a, T1b, M0b, alpha);
       
  f = guess(1);
  dt = guess(2);
  z=[f dt];

  result=FAIR_func4(z, times, t_tag, T1a, T1b, M0b, alpha);
     
  % Plot the fitted curve on top of the
  % actual data (if requested)

  if (nargout==0),
    disp( 'plotting uptake curve' )
    p=plot(times,result,'r'),xlabel('time (s)'),ylabel('|control-tag|');
    set(p,'LineWidth',2);
    f1=gca;
    set(f1,'FontSize',15,'LineWidth',3);
    %disp('press return to continue')
    %pause    
    hold
    q=plot(times,data,'.');
    set(q,'MarkerSize',20,'MarkerFaceColor','k','MarkerEdgeColor','k');
  end

else,

  % FUNCTIONAL ASL ESTIMATION OF FLOW
  fLB=0;
  fUB=.1;
 
  for m=1:length(times), 
    z(m)=fminbnd('FAIR_func4',fLB,fUB,opt2, times(m), t_tag, T1a, T1b, M0b, alpha, [uptakedt data(m)]);
    dM(m)=FAIR_func4([z(m) uptakedt(2)],uptakedt(1),t_tag,T1a,T1b,M0b,alpha);
    disp(sprintf('data= %f (%f), f= %f, dt= %f',data(m),dM(m),z(m)*6000,uptakedt(2)));
    %faa=rand([1000 1])*.1;
    %for mm=1:length(faa),
    %  zz(mm)=FAIR_func4(faa(mm),times(m),t_tag,T1a,T1b,M0b,alpha,[uptakedt data(m)]);
    %end;
    %[amin,amini]=min(zz);
    %z(m)=faa(amini);
    %plot(faa,zz,'.'),  pause,
  end;

end;

