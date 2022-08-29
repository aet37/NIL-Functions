function f=iter_guess(optim,func,guess,sig,opt,grad,p1,p2,p3,p4,p5,p6,p7,p8)
% Usage ... f=iter_guess(optim,func,guess,sig,opt,grad,p1,p2,p3,p4,p5,p6,p7,p8)
%
% Iterates an optimization algorithm function 'optim' until
% a satisfactory fit by the user. The guess vector (ROW) is
% used. At least 6 parameters are required.
% Significance is the signicant digits in the guess.

nparms=nargin-6;

while(1),
  tmpcmd=['x=',optim,'(''',func,''',['];
  for n=1:length(guess),
    tmpcmd=[tmpcmd,num2str(guess(n),sig),' '];
  end;
  tmpcmd=[tmpcmd,'],opt,grad'];
  if nparms>0,
    for n=1:nparms,
      tmpcmd=[tmpcmd,',p',int2str(n)];
    end;
  end;
  tmpcmd=[tmpcmd,');'];
  disp(tmpcmd);
  eval(tmpcmd);
  tmp=input('Satisfactory (0-No,1-Yes): ');
  if ~tmp,
    guess=input('New guess (row vector): ');
    bias=input('New bias (2 element row vector): ');
    if (bias==[])|(bias==0),
      eval(['p',int2str(nparms),'=[bias(1) bias(2)];']);
    end;
  else,
    break;
  end;
end;

f=x;
