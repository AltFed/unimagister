% plotBoard.m
function plotBoard(board)
    fig = findobj('Tag', 'Connect4GUI');
    if isempty(fig)
        fig = figure('Name', 'Forza 4', 'NumberTitle', 'off', 'Tag', 'Connect4GUI');
    end
    clf(fig);
    rows = 6; cols = 7;
    rectangle('Position', [0, 0, cols, rows], 'FaceColor', [0.1 0.4 0.8], 'EdgeColor', 'k');
    axis equal; axis([0 cols 0 rows]); set(gca, 'XTick', [], 'YTick', []);
    hold on;
    for r = 1:rows
        for c = 1:cols
            player = board(r, c);
            centerX = c - 0.5; centerY = (rows - r) + 0.5;
            if player == 0, color = [1 1 1]; % Bianco
            elseif player == 1, color = [1 0.2 0.2]; % Rosso
            else, color = [1 1 0.2]; end % Giallo
            rectangle('Position', [centerX-0.4, centerY-0.4, 0.8, 0.8], ...
                      'Curvature', [1, 1], 'FaceColor', color, 'EdgeColor', 'k');
        end
    end
    hold off; drawnow;
end
