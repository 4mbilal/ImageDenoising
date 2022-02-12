clear all
close all
clc
% c = clock;
% rng(round(c(6)));
% Notes:
% 1- Train using higher density of SnP e.g. 0.3 and then test on either higher or lower. 
% 2- Tune SVM box constraint parameter.

datadir = 'D:\RnD\Frameworks\Datasets';
[XTrain,YTrain,XValidation,YValidation,categories] = loadCIFARData(datadir);
s = size(XTrain);

Options.snpDensity = 0.3;
Options.gaussMean = 0;
Options.gaussVar = 50/(65025); %Division by 65025(=255*255) is necessary because imnoise by default works on [0 1] scale
Options.bilatFiltDoS = 1100;
Options.bilatFiltVar = 1.1;
Options.med_filt_kernel = [3,3];
Options.wienerFiltKernel = [3,3];

Options.mdl = 'Mdl_SVM_SW1';
X = [];
Y = [];

for i=1:2:s(4)
    if(rem(i-1,100)==0)
        fprintf('\n: %3.2f',i*100/s(4))
    end
    img = XTrain(:,:,:,i);
    img = rgb2gray(img);
    imgNoisy = imnoise(img,'salt & pepper', Options.snpDensity);
    imgNoisy = imnoise(imgNoisy,'gaussian',Options.gaussMean,Options.gaussVar);

    [imgFeatures, labels] = calcFeaturesLabels(img,imgNoisy,Options);
    X = [X;imgFeatures];
    Y = [Y;labels(:)];
%     imshow(imgNoisy)
%     pause
%     drawnow
end

mdl = fitcsvm(X,Y,'KernelFunction','linear', 'BoxConstraint',0.1,'ClassNames',[0,1]);
YY=double((X*mdl.Beta + mdl.Bias)>0);

%  mdl = fitcsvm(X,Y,'KernelFunction','hik', 'BoxConstraint',2,'ClassNames',[0,1]);
%  [T,B] = buildLUT(mdl);
%  mdl = [];
% mdl.T = T;
% mdl.B = B;
% YY = hikPredictLUTQ(X,mdl);

%     mdl = fitcsvm(X,Y,'KernelFunction','rbf', 'BoxConstraint',1,'ClassNames',[0,1]);
% YY=mdl.predict(X);

e = abs(YY-Y);
1-sum(e)/length(Y)
delete([Options.mdl,'.mat']);
save(Options.mdl,'mdl');

function [f, labels] = calcFeaturesLabels(img,imgNoisy,Options)
    img = double(img);
    imgNoisy = double(imgNoisy);
    features = calcFeaturesSWfilter(imgNoisy);
    imgBilat = double(imbilatfilt(imgNoisy,Options.bilatFiltDoS,Options.bilatFiltVar));
    imgMed = double(medfilt2(imgNoisy,Options.med_filt_kernel));

    diffBilat = abs(img-imgBilat)./img;
    diffMed = abs(img-imgMed)./img;
    lab = double(diffMed<(diffBilat)); %1-Median ,0-Bilateral
    lab = lab(:);
    l1 = find(lab);
    l1 = l1(randi(length(l1)));
    l2 = find(1-lab);
    l2 = l2(randi(length(l2)));

    labels = [lab(l1);lab(l2)];
    f = [features(l1,:);features(l2,:)];
%     keyboard
end



