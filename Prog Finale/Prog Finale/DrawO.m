
% Draw an O
function DrawO(xc,yc)
    % make a circle
    t = linspace(0,2*pi,100);
    x = xc + .4*cos(t);
    y = yc + .4*sin(t);
    plot(x,y,'r','LineWidth',4)
end