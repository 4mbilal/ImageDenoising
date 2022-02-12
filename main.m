close all
clear all
clc

imageSize = [32 32 3];
datadir = 'D:\RnD\Frameworks\Datasets';
[XTrain,YTrain,XValidation,YValidation,categories] = loadCIFARData(datadir);
load('baselineMdl_cifar10.mat','net');
% getAccuracyOriginal(XTrain,YTrain,XValidation,YValidation,categories);
Options.snpDensity = 0.02;
Options.gaussMean = 0;
Options.gaussVar = 150/(65025); %Division by 65025(=255*255) is necessary because imnoise by default works on [0 1] scale
Options.med_filt_kernel = [3,3];
Options.wienerFiltKernel = [3,3];
Options.nlmFiltDoS = 3;
Options.bilatFiltDoS = 1100;
Options.bilatFiltVar = 1.1;
Options.filterType = 6; %[0-No Filter, 1-Bilateral, 2- NLM, 3-Wiener, 4-Median, 5-DnCNN, 6-Switching]

s = size(XValidation);
XValidation_noisy = uint8(zeros(s));
disp('Adding Noise');
disp(' ');

if(Options.filterType==5)
    net_denoise = denoisingNetwork('DnCNN');
else
    net_denoise = [];
end

for i=1:s(4)
%     if(rem(i,100)==0)
        fprintf('\b\b\b\b\b\b\b: %3.2f',i*100/s(4))
%     end
    img = XValidation(:,:,:,i);
    imgNoisy = imnoise(img,'salt & pepper', Options.snpDensity);
    imgNoisy = imnoise(imgNoisy,'gaussian',Options.gaussMean,Options.gaussVar);
    close all
    imshow(imgNoisy)
    figure

    switch Options.filterType
        case {0}
            
        case {1}
            imgNoisy(:,:,1) =  imbilatfilt(imgNoisy(:,:,1),Options.bilatFiltDoS,Options.bilatFiltVar);
            imgNoisy(:,:,2) =  imbilatfilt(imgNoisy(:,:,2),Options.bilatFiltDoS,Options.bilatFiltVar);
            imgNoisy(:,:,3) =  imbilatfilt(imgNoisy(:,:,3),Options.bilatFiltDoS,Options.bilatFiltVar);
        case {2}
            imgNoisy(:,:,1) = imnlmfilt(imgNoisy(:,:,1),'DegreeOfSmoothing',Options.nlmFiltDoS);
            imgNoisy(:,:,2) = imnlmfilt(imgNoisy(:,:,2),'DegreeOfSmoothing',Options.nlmFiltDoS);
            imgNoisy(:,:,3) = imnlmfilt(imgNoisy(:,:,3),'DegreeOfSmoothing',Options.nlmFiltDoS);
        case {3}
            imgNoisy(:,:,1) = wiener2(imgNoisy(:,:,1),Options.wienerFiltKernel);
            imgNoisy(:,:,2) = wiener2(imgNoisy(:,:,2),Options.wienerFiltKernel);
            imgNoisy(:,:,3) = wiener2(imgNoisy(:,:,3),Options.wienerFiltKernel);
        case {4}
            imgNoisy(:,:,1) = medfilt2(imgNoisy(:,:,1),Options.med_filt_kernel);
            imgNoisy(:,:,2) = medfilt2(imgNoisy(:,:,2),Options.med_filt_kernel);
            imgNoisy(:,:,3) = medfilt2(imgNoisy(:,:,3),Options.med_filt_kernel);
        case {5}
            imgNoisy = imresize(imgNoisy,[50 50]);
            imgNoisy(:,:,1) = denoiseImage(imgNoisy(:,:,1),net_denoise);
            imgNoisy(:,:,2) = denoiseImage(imgNoisy(:,:,2),net_denoise);
            imgNoisy(:,:,3) = denoiseImage(imgNoisy(:,:,3),net_denoise);
            imgNoisy = imresize(imgNoisy,[32 32]);
        case {6}
%             imgNoisy = SwitchingFilter(imgNoisy);
%             imgNoisy = SWFilter1(imgNoisy);
            imgNoisy = SWFilter(imgNoisy);
        case {7}
            imgNoisy = DCTdenoiser(imgNoisy);
    end

    XValidation_noisy(:,:,:,i) = uint8(imgNoisy);
    imshow(imgNoisy)
    pause
    drawnow
end

disp('Classifying');
[YPredTest_Noisy,probsTest_Noisy] = classify(net,XValidation_noisy);
validationError_Noisy = mean(YPredTest_Noisy ~= YValidation);
disp("Validation Accuracy (Noisy): " + (1-validationError_Noisy)*100 + "%")

