close all
clear all
clc

imageSize = [32 32 3];
datadir = 'D:\RnD\Frameworks\Datasets';
[XTrain,YTrain,XValidation,YValidation,categories] = loadCIFARData(datadir);

Options.snpDensity = 0.01;
Options.gaussMean = 0;
Options.gaussVar = 50/(65025); %Division by 65025(=255*255) is necessary because imnoise by default works on [0 1] scale
Options.med_filt_kernel = [3,3];
Options.wienerFiltKernel = [3,3];
Options.nlmFiltDoS = 3;
Options.bilatFiltDoS = 1100;
Options.bilatFiltVar = 1.1;
Options.filterType = 6; %[0-No Filter, 1-Bilateral, 2- NLM, 3-Wiener, 4-Median, 5-DnCNN, 6-Switching]
net_denoise = denoisingNetwork('DnCNN');

s = size(XValidation);
XValidation_noisy = uint8(zeros(s));
disp('Adding Noise');
disp(' ');

times = zeros(7,1);
imgMetrics = zeros(8,2);

% s(4) = 10;
for i=1:s(4)
    i*100/s(4)

    img = XValidation(:,:,:,i);
%     img = imread('untitled.png');
%     subplot(1,9,1)
%     imshow(img)
%     figure

    imgNoisy = imnoise(img,'salt & pepper', Options.snpDensity);
    imgNoisy = imnoise(imgNoisy,'gaussian',Options.gaussMean,Options.gaussVar);
    [ssimV, psnrV] = calcImgMetrics(imgNoisy,img);
    imgMetrics(1,1) = imgMetrics(1,1) + ssimV;
    imgMetrics(1,2) = imgMetrics(1,2) + psnrV;

%     subplot(1,9,2)
%     imshow(imgNoisy)
% figure
% tic
%     imgNoisy1(:,:,1) =  imbilatfilt(imgNoisy(:,:,1),Options.bilatFiltDoS,Options.bilatFiltVar);
%     imgNoisy1(:,:,2) =  imbilatfilt(imgNoisy(:,:,2),Options.bilatFiltDoS,Options.bilatFiltVar);
%     imgNoisy1(:,:,3) =  imbilatfilt(imgNoisy(:,:,3),Options.bilatFiltDoS,Options.bilatFiltVar);
% 
%     [ssimV, psnrV] = calcImgMetrics(imgNoisy1,img);
%     imgMetrics(2,1) = imgMetrics(2,1) + ssimV;
%     imgMetrics(2,2) = imgMetrics(2,2) + psnrV;
% 
%     times(1) = times(1) + toc;
%     subplot(1,9,3)
%     imshow(imgNoisy1)
%     figure
% 
% tic
%     imgNoisy2(:,:,1) = imnlmfilt(imgNoisy(:,:,1),'DegreeOfSmoothing',Options.nlmFiltDoS);
%     imgNoisy2(:,:,2) = imnlmfilt(imgNoisy(:,:,2),'DegreeOfSmoothing',Options.nlmFiltDoS);
%     imgNoisy2(:,:,3) = imnlmfilt(imgNoisy(:,:,3),'DegreeOfSmoothing',Options.nlmFiltDoS);
% 
%     [ssimV, psnrV] = calcImgMetrics(imgNoisy2,img);
%     imgMetrics(3,1) = imgMetrics(3,1) + ssimV;
%     imgMetrics(3,2) = imgMetrics(3,2) + psnrV;
%     
% %     subplot(1,9,4)
% %     imshow(imgNoisy2)
% %     figure
% 
%     times(2) = times(2) + toc;
% 
% tic
%     imgNoisy3(:,:,1) = wiener2(imgNoisy(:,:,1),Options.wienerFiltKernel);
%     imgNoisy3(:,:,2) = wiener2(imgNoisy(:,:,2),Options.wienerFiltKernel);
%     imgNoisy3(:,:,3) = wiener2(imgNoisy(:,:,3),Options.wienerFiltKernel);
% 
%     [ssimV, psnrV] = calcImgMetrics(imgNoisy3,img);
%     imgMetrics(4,1) = imgMetrics(4,1) + ssimV;
%     imgMetrics(4,2) = imgMetrics(4,2) + psnrV;
%     
%     %     subplot(1,9,5)
% %     imshow(imgNoisy3)
% %     figure
%     
%     times(3) = times(3) + toc;
% 
% tic
%     imgNoisy4(:,:,1) = medfilt2(imgNoisy(:,:,1),Options.med_filt_kernel);
%     imgNoisy4(:,:,2) = medfilt2(imgNoisy(:,:,2),Options.med_filt_kernel);
%     imgNoisy4(:,:,3) = medfilt2(imgNoisy(:,:,3),Options.med_filt_kernel);
% %     subplot(1,9,6)
% %     imshow(imgNoisy4)
% %     figure
%     [ssimV, psnrV] = calcImgMetrics(imgNoisy4,img);
%     imgMetrics(5,1) = imgMetrics(5,1) + ssimV;
%     imgMetrics(5,2) = imgMetrics(5,2) + psnrV;
% 
%     times(4) = times(4) + toc;

%     
    imgNoisy5 = imresize(imgNoisy,[50 50]);
    tic
    imgNoisy5(:,:,1) = denoiseImage(imgNoisy5(:,:,1),net_denoise);
    imgNoisy5(:,:,2) = denoiseImage(imgNoisy5(:,:,2),net_denoise);
    imgNoisy5(:,:,3) = denoiseImage(imgNoisy5(:,:,3),net_denoise);
    times(5) = times(5) + toc;
    imgNoisy5 = imresize(imgNoisy5,[32 32]);
% 
    [ssimV, psnrV] = calcImgMetrics(imgNoisy5,img);
    imgMetrics(6,1) = imgMetrics(6,1) + ssimV;
    imgMetrics(6,2) = imgMetrics(6,2) + psnrV;
    
    %     subplot(1,9,7)
% figure
%     imshow(imgNoisy5)
%     
tic
    imgNoisy6 = SWFilter1(imgNoisy);
    times(6) = times(6) + toc;
%     subplot(1,9,8)
%     imshow(imgNoisy6)
%     figure
%     
    [ssimV, psnrV] = calcImgMetrics(imgNoisy6,img);
    imgMetrics(7,1) = imgMetrics(7,1) + ssimV;
    imgMetrics(7,2) = imgMetrics(7,2) + psnrV;

    tic
    imgNoisy7 = SWFilter(imgNoisy);
    [ssimV, psnrV] = calcImgMetrics(imgNoisy7,img);
    imgMetrics(8,1) = imgMetrics(8,1) + ssimV;
    imgMetrics(8,2) = imgMetrics(8,2) + psnrV;

    times(7) = times(7) + toc;
%     subplot(1,9,9)
%     imshow(imgNoisy7)
    
%     title(YValidation(i))
    
%     pause
%     drawnow
end
times/s(4)

imgMetrics/s(4)


function [ssimV, psnrV] = calcImgMetrics(noisy,img)
    psnrV = psnr(noisy(:,:,1),img(:,:,1)) + psnr(noisy(:,:,2),img(:,:,2)) + psnr(noisy(:,:,3),img(:,:,3));
    psnrV = psnrV/3;

    ssimV = ssim(noisy(:,:,1),img(:,:,1)) + ssim(noisy(:,:,2),img(:,:,2)) + ssim(noisy(:,:,3),img(:,:,3));
    ssimV = ssimV/3;
%     pause
end
