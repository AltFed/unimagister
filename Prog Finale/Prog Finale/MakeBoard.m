% Draw the board with X and Os
function MakeBoard(A)
temp=size(A);
for i = 1:temp(1)
    for j = 1:temp(2)
        if A(i,j) == 1
            DrawX(j-.5,i-.5)
        elseif A(i,j) == 2
            DrawO(j-.5,i-.5)
        end
    end
end
end