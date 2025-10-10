% Draw an X
function  DrawX(x,y)
%
%   Draw an X 
%
    plot([x-.4 x+.4],[y-.4 y+.4],'k','LineWidth',4)
    plot([x-.4 x+.4],[y+.4 y-.4],'k','LineWidth',4)
end