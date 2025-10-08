function in_board(M,h,l)    % passare matrice , dimensione della griglia altezza larghezza
% Make a playing board
plot(0,0);
axis equal; % Make the axis equal
hold on
title('Forza 4 Board','Interpreter','latex')
% Set the axis to a hxl
axis([0 h 0 l]);
axis off
DrawBoard(max(h,l))
MakeBoard(M)
end