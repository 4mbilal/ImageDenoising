% mdl = fitcsvm(X,Y,'KernelFunction','linear', 'BoxConstraint',1,'ClassNames',[0,1]);
        mdl = fitcsvm(X,Y,'KernelFunction','hik', 'BoxConstraint',10,'ClassNames',[0,1]);
%     mdl = fitcsvm(X,Y,'KernelFunction','rbf', 'BoxConstraint',15,'ClassNames',[0,1]);
%         YY=mdl.predict(X);
% YY=double((X*mdl.Beta + mdl.Bias)>0);

 [T,B] = buildLUT(mdl);
 mdl = [];
mdl.T = T;
mdl.B = B;
YY = hikPredictLUTQ(X,mdl);

e = abs(YY-Y);
1-sum(e)/length(Y)