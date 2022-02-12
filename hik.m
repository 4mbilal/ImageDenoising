function G = hik(U,V)
s1 = size(U);
s2 = size(V);
G = zeros(s1(1),s2(1));

for i=1:s1(1)
    for j=1:s2(1)
        G(i,j) = sum(min(U(i,:),V(j,:)));
    end
end

