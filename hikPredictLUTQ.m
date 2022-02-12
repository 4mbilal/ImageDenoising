function y = hikPredictLUTQ(x,mdl)
x = round(x*1000 + 2048); %Range: [0 4096]
x(x>4095) = 4095;
B = mdl.B;
T = mdl.T;

sx = size(x);
n = sx(2);
y = zeros(sx(1),1);

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

