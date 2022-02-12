function denoisedImg = SWFilter2(imgNoisy)
% Beta = [4.0002    1.4976   -0.5927   -8.2995   10.1135    0.0225    0.0008   -0.2460   -0.0161    0.0199]';
% Bias = [0.233601132059431];
persistent mdl;

if(isempty(mdl))
    mdlfile = 'Mdl_HIK_SW2';
    load(mdlfile)
    disp('model loaded')
end

bilatFiltDoS = 1200;
bilatFiltVar = 1.2;
med_filt_kernel = [3,3];
wienerFiltKernel = [3,3];

s = size(imgNoisy);
denoisedImg = uint8(zeros(s));
K = s(3);
for k=1:K
    imgFeatures = calcFeaturesSWfilter(double(imgNoisy(:,:,k)));
    imgBilat = imbilatfilt(imgNoisy(:,:,k),bilatFiltDoS,bilatFiltVar);
%     imgMed = medfilt2(imgNoisy(:,:,k),med_filt_kernel);
%     imgMed = wiener2(imgNoisy(:,:,k),wienerFiltKernel);
    imgMed = imbilatfilt(imgNoisy(:,:,k),1000,1.0); %86.04 for 1.1

%     imgMask = double((imgFeatures*mdl.Beta + mdl.Bias)>0);
%     imgMask = double(mdl.predict(imgFeatures));
    imgMask = hikPredictLUTQ(imgFeatures,mdl);

    imgMed = double(imgMed(:));
    imgBilat = double(imgBilat(:));
    imgRecTemp = uint8((imgMed.*imgMask)+(double(imgBilat).*(1-imgMask)));
    denoisedImg(:,:,k) = reshape(imgRecTemp,s(1),s(2));
end
