% Draw initial Board for game start
function  DrawBoard(n)
%
%   Draw a Board
%
    for i = 1:n-1
        plot([0 n],[i i],'k')
        plot([i i],[0 n],'k')
    end
end