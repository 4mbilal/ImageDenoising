function y = hikPredict(x,mdl)

SVs = mdl.SupportVectors;
Alpha = mdl.Alpha;
Labels = mdl.SupportVectorLabels;
B = mdl.Bias;

s = size(SVs);
m = s(1);
n = s(2);
sx = size(x);
y = zeros(sx(1),1);

for k=1:sx(1)
    temp = 0;
    for i=1:n
        for j=1:m
            temp = temp + Alpha(j)*min(x(k,i),SVs(j,i))*Labels(j);      %HIK
%             temp = temp + Alpha(j)*(x(k,i)*SVs(j,i))*Labels(j);     %Linear
        end
    end
    y(k) = temp + B;
    if(y(k)>0)
        y(k) = 1;
    else
        y(k) = 0;
    end
end

