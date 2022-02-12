function [T,B] = buildLUT(mdl)
SVs = mdl.SupportVectors;
Alpha = mdl.Alpha;
Labels = mdl.SupportVectorLabels;
B = mdl.Bias;

s = size(SVs);
m = s(1);
n = s(2);
T = zeros(n,4096);

for i=1:n
    for k=1:4096
        for j=1:m
            T(i,k) = T(i,k) + Alpha(j)*min((k-2048)/1000,SVs(j,i))*Labels(j);
        end
    end
end