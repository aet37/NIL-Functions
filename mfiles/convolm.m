function   H = convolm(x, num_zeros, pad)
%CONVOLM    Make convolution matrix, optionally padded with zeros
%-------
%   Usage:   H = convolm(X, P, <'pad'>)
%
%         H :  convolution matrix with P columns
%                H = [ h(i,j) ], where h(i,j) = x(p+i-j)
%   <'pad'> :  3rd arg is OPTIONAL string argument:
%      '<'  : pad with p-1 zeros at the beginning of x
%      '>'  : pad with p-1 zeros at the end of x
%      '<>' : pad both ends of the signal x with p-1 zeros
%
%  see also HANKEL, CIRCULANT, CONVMTX

%---------------------------------------------------------------
% copyright 1994, by C.S. Burrus, J.H. McClellan, A.V. Oppenheim,
% T.W. Parks, R.W. Schafer, & H.W. Schussler.  For use with the book
% "Computer-Based Exercises for Signal Processing Using MATLAB"
% (Prentice-Hall, 1994).
%---------------------------------------------------------------

N = length(x);
x = x(:);
if nargin == 3                 %-- 3rd argument is optional
   z = zeros(num_zeros-1,1);
   if pad == '<>'
      N = N + 2*(num_zeros-1);  t = [ z; x; z ];
   elseif pad == '<'
      N = N + num_zeros-1;      t = [ z; x ];
   elseif pad == '>'
      N = N + num_zeros-1;      t = [ x; z ];
   end
else
   t = x;
end
H = zeros(N-num_zeros+1,num_zeros);    %--- allocate [ H ]
for i=1:num_zeros
   H(:,i) = t(num_zeros-i+1:N-i+1);
end
