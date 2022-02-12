function denoisedImg = SwitchingFilter(imgNoisy)
Beta = [4.0676         0         0   -6.9078    8.4756   -0.0306   -0.0385   -0.2234]';
Bias = [0.394352918334846];

bilatFiltDoS = 1100;
bilatFiltVar = 1.1;
med_filt_kernel = [3,3];
wienerFiltKernel = [3,3];

s = size(imgNoisy);
denoisedImg = uint8(zeros(s));
K = s(3);
for k=1:K
    [f1,f2,f3,f4,f5,f6,f7,f8] = calcFeatures1(double(imgNoisy(:,:,k)));
    imgFeatures = [f1(:),f2(:),f3(:),f4(:),f5(:),f6(:),f7(:),f8(:)];
    imgBilat = imbilatfilt(imgNoisy(:,:,k),bilatFiltDoS,bilatFiltVar);
%     imgWiener = wiener2(imgNoisy(:,:,k),wienerFiltKernel);
    imgMed = medfilt2(imgNoisy(:,:,k),med_filt_kernel);
    %         imgMask = double(mdl.predict(imgFeatures));
    imgMask = double((imgFeatures*Beta + Bias)>0);
    imgMed = double(imgMed(:));
    imgBilat = double(imgBilat(:));
    imgRecTemp = uint8((imgMed.*imgMask)+(double(imgBilat).*(1-imgMask)));
    denoisedImg(:,:,k) = reshape(imgRecTemp,s(1),s(2));
end
end

function [f1,f2,f3,f4,f5,f6,f7,f8] = calcFeatures1(img)
    f1 = abs(filter2([-1, -1, -1;-1, 8, -1;-1, -1, -1],img)/2040); %Laplacian
%     f1 = medfilt2(img,[5 5])/255;   %median in 5x5 area
    f2 = filter2(ones(3)/9,img)/255;%mean in 3x3 area
    f3 = medfilt2(img,[3 3])/255;   %median in 3x3 area
    f4 = (f2-img)./(img+1);                     %difference between mean and pixel
    f5 = (f3-img)./(img+1);                     %difference between median and pixel
    f6 = filter2([-1, 0, 1],img)/255; %Horiz. Gradient
    f7 = filter2([-1; 0; 1],img)/255; %Vert. Gradient
    f8 = abs(f6) + abs(f7);            %Grad. Mag. approx
%     f8 = img/255;
%     f1 = zeros(size(img));
    f2 = zeros(size(f1));
    f3 = zeros(size(f1));
%     f4 = zeros(size(f1));
%     f5 = zeros(size(f1));
%     f6 = zeros(size(f1));
%     f7 = zeros(size(f1));
%     f8 = zeros(size(f1));
end
