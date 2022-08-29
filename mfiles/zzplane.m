function  zzplane(z, p, zmax)
%ZZPLANE      plot zeros (O) and poles (X) in z-plane
%-------
%   Usage:   zzplane( Zeros, Poles, RadiusMax )
%
%        Zeros : vector of zeros
%        Poles : vector of poles  (OPTIONAL)
%                 (can be [], if 3rd arg is needed)
%    RadiusMax : size of plot for scaling  (OPTIONAL)
%                 (disables auto scaling calculations)
%
%  NOTE: used the name ZZPLANE to avoid conflict with
%          ZPLANE in version 3 of Sig Proc Toolbox

%---------------------------------------------------------------
% copyright 1994, by C.S. Burrus, J.H. McClellan, A.V. Oppenheim,
% T.W. Parks, R.W. Schafer, & H.W. Schussler.  For use with the book
% "Computer-Based Exercises for Signal Processing Using MATLAB"
% (Prentice-Hall, 1994).
%---------------------------------------------------------------

if( nargin == 1 )
   p = [ ];
end
rmax = max( [ abs(z(:)); abs(p(:)) ] );
rmin = min( [ abs(z(:)); abs(p(:))] );
if( rmax/rmin > 100 )
   disp('***** WARNING: DYNAMIC RANGE of ROOTS is > 100 *****' )
   disp('     ===> may need to replot to see them all <===' )
end
if( nargin < 3 )   %--- need to figure out the scaling
   zmax = 2;
   if( rmax > 50 )
      zmax = 10*ceil( ceil( rmax )/10 );
   elseif( rmax > 2 )
      zmax = 5*ceil( ceil( rmax )/5 );
   elseif( rmax < 0.09 )
      zmax = 10 .^ fix( log10(rmax) );
   end
elseif( rmax > zmax )
   disp('*** WARNING: some roots are too big to fit on plot ***')
end
axis( zmax*[-1 1 -1 1])
plot( [-zmax;zmax],[0;0],':w', [0;0],[-zmax;zmax],':w')
hold on
if( zmax <= 20 )        %--- then put a UNIT CIRCLE on the plot
   plot( sin(0:.01:2*pi),cos(0:.01:2*pi),'w:' )
end
   pcross( z, zmax/40, 'zero' )     %-- zeros are o's
   if( ~isempty(p) )
      pcross( p, zmax/50 )   %-- poles are x's
   end
   xlabel('REAL PART');  ylabel('IMAGINARY PART')
   axis('equal')
   axis('square')
hold off


