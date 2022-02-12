function denoisedImg = SWFilter(imgNoisy)

persistent mdl;

if(isempty(mdl))
    mdlfile = 'Mdl_SVM_SW1';
    load(mdlfile)
    disp('model loaded')
end

bilatFiltDoS = 1100;
bilatFiltVar = 1.1;
med_filt_kernel = [3,3];

s = size(imgNoisy);
denoisedImg = uint8(zeros(s));
K = s(3);

imgSWFilter2 = SWFilter2(imgNoisy);

for k=1:K
    imgFeatures = calcFeaturesSWfilter(double(imgNoisy(:,:,k)));
%     imgBilat = imbilatfilt(imgNoisy(:,:,k),bilatFiltDoS,bilatFiltVar);
    imgBilat = imgSWFilter2(:,:,k);
    imgMed = medfilt2(imgNoisy(:,:,k),med_filt_kernel);

    imgMask = double((imgFeatures*mdl.Beta + mdl.Bias)>0.3);

    imgMed = double(imgMed(:));
    imgBilat = double(imgBilat(:));
    imgRecTemp = uint8((imgMed.*imgMask)+(double(imgBilat).*(1-imgMask)));
    denoisedImg(:,:,k) = reshape(imgRecTemp,s(1),s(2));
end
