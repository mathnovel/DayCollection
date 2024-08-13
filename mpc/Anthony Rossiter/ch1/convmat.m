function [C]=convmat(A,B)
[na,ma]=size(A);[nb,mb]=size(B);orda=ma/nb;ordb=mb/na;
mat = [];
for i=1:orda;
    s = zeros(nb,((orda-1)*na+mb));
    s(:,(i-1)*na+1:(i-1)*na+mb) = B;
    mat = [mat;s];
end;
C=A*mat;

