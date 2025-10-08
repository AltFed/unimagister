function A = Board(A,x,y,i)
j1 = ceil(x);
j2 = ceil(y);
    if i == 1
        A(j2,j1) = 1; % associa a 1 la X 
    else
        A(j2,j1) = 2; % associo a 2 la O
    end
end