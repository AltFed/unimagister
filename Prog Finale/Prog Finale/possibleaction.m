function a=possibleaction(possib)
a=[];
temp=size(possib);
for i=1:temp(2)
    if(possib(i) ~= 0)
        a=[a i];
    end
end




