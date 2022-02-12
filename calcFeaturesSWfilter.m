function f = calcFeaturesSWfilter(img)
    f1 = abs(filter2([-1, -1, -1;-1, 8, -1;-1, -1, -1],img)/2040); %Laplacian
%     f1 = medfilt2(img,[5 5])/255;   %median in 5x5 area
    f2 = filter2(ones(3)/9,img)/255;%mean in 3x3 area
    f3 = medfilt2(img,[3 3])/255;   %median in 3x3 area
    f4 = (f2-img)./(img+1);                     %difference between mean and pixel
    f5 = (f3-img)./(img+1);                     %difference between median and pixel
    f6 = filter2([-1, 0, 1],img)/255; %Horiz. Gradient
    f7 = filter2([-1; 0; 1],img)/255; %Vert. Gradient
    f8 = abs(f6) + abs(f7);            %Grad. Mag. approx
    f9 = filter2([-1, -1, 0, 1, 1],img)/255; %Horiz. Gradient 2
    f10 = filter2([-1; -1; 0; 1; 1],img)/255; %Vert. Gradient 2
    f11 = (abs(f9) + abs(f10))/2;
    f12 = abs(filter2([-1, 1, -1, 1, -1],img))/255;
    f13 = abs(filter2([-1; 1; -1; 1; -1],img))/255;
%     f8 = img/255;
%     f1 = zeros(size(img));
%     f2 = zeros(size(f1));
%     f3 = zeros(size(f1));
%     f4 = zeros(size(f1));
%     f5 = zeros(size(f1));
%     f6 = zeros(size(f1));
%     f7 = zeros(size(f1));
%     f8 = zeros(size(f1));
f = [f1(:),f2(:),f3(:),f4(:),f5(:),f6(:),f7(:),f8(:),f9(:),f10(:),f11(:),f12(:),f13(:)];
end



