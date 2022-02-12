function getAccuracyOriginal(XTrain,YTrain,XValidation,YValidation,categories)
if(~exist('predResults_Orig.mat','file'))
    [YPredTest_Orig,probsTest_Orig] = classify(net,XValidation);
    [YPredTrain_Orig,probsTrain_Orig] = classify(net,XTrain);
    save('predResults_Orig','YPredTest_Orig','YPredTrain_Orig','probsTest_Orig','probsTrain_Orig');
else
    load('predResults_Orig');
end
validationError_Orig = mean(YPredTest_Orig ~= YValidation);
trainError_Orig = mean(YPredTrain_Orig ~= YTrain);
disp("Training Accuracy (original): " + (1-trainError_Orig)*100 + "%")
disp("Validation Accuracy (original): " + (1-validationError_Orig)*100 + "%")
figure('Units','normalized','Position',[0.2 0.2 0.4 0.4]);
cm = confusionchart(YValidation,YPredTest_Orig);
cm.Title = 'Confusion Matrix for Validation Data (Original)';
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
end