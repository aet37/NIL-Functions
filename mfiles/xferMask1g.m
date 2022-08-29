function y=xferMask1g(data,mapStr)
% Usage ... y=xferMask1g(data,mapStr)

y=xferMask1(mapStr.mask,mapStr.bim,data(:,:,1));
