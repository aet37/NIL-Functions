function DI = linearmorphinterp(D1,D2,n)
% DI = linearmorphinterp(D1,D2,n)
%
% Performs a linear morphing interpolation between binary images D1 and D2.
% n is the number of planes to insert.
%

% save time and memory - just use the boundary
B1 = bwperim(D1);
B2 = bwperim(D2);

[x1,y1] = find(B1);
[x2,y2] = find(B2);
[XX1,XX2] = meshgrid(single(x1),single(x2));
[YY1,YY2] = meshgrid(single(y1),single(y2));
DI = repmat(D1,[1 1 n]); DI(:) = 0;
BI = D1; 
for i=1:n
    xi = uint16(XX1(:)*(1-i/(n+1))+XX2(:)*i/(n+1));
    yi = uint16(YY1(:)*(1-i/(n+1))+YY2(:)*i/(n+1));
    % eliminate duplicates
    funnyset = double(xi)+double(yi)/100000;
    nodupeset = unique(funnyset);
    yuni = round((nodupeset-round(nodupeset))*100000);
    xuni = round(nodupeset-yuni/100000);
    BI(:) = 0;
    for j=1:length(xuni)
        BI(xuni(j),yuni(j)) = 1;
    end
    % fill holes
    DI(:,:,i) = imfill(BI,'holes');
end


