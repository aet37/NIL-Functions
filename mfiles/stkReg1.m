function y=stkReg1(stk,vec,parms,xparms,sparms)
% Usage ... y=stkReg1(stk,vec,parms,xparms,sparms)
%
% Remove linear contributions of vectors vec from the data in a pixel by
% pixel manner. xpamrs are the vector entries in vec for which cross-terms
% are needed to be included. sparms are terms for which shifted versions
% need to 