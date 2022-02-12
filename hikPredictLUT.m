function y = hikPredictLUT(x,mdl)

SVs = mdl.SupportVectors;
Alpha = mdl.Alpha;
Labels = mdl.SupportVectorLabels;
B = mdl.Bias;

s = size(SVs);
m = s(1);
n = s(2);
sx = size(x);
y = zeros(sx(1),1);
T = zeros(n,1000);

for i=1:n
    for k=1:1000
        for j=1:m
            T(i,k) = T(i,k) + Alpha(j)*min(k,SVs(j,i))*Labels(j);
        end
    end
end

for k=1:sx(1)
    temp = 0;
    for i=1:n
        temp = temp + T(i,x(k,i));
    end
    y(k) = temp + B;
    if(y(k)>0)
        y(k) = 1;
    else
        y(k) = 0;
    end
end

