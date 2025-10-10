function won = checkWin(board, lastMove)
% Controlla se l'ultima mossa è vincente.
% Ritorna: 1 o 2 (vincitore), 3 (pareggio), 0 (partita in corso).
    player = board(lastMove(1), lastMove(2));
    if player == 0, won = 0; return; end

    directions = [ -1, 0; 0, 1; -1, 1; -1,-1]; % Verticale, Orizzontale, 2 Diagonali

    for i = 1:size(directions, 1)
        dir = directions(i, :);
        count = 1 + countInDirection(board, lastMove, player, dir) + ...
                    countInDirection(board, lastMove, player, -dir);
        if count >= 4
            won = player;
            return;
        end
    end

    if ~any(board(1, :) == 0)
        won = 3; % Pareggio
    else
        won = 0; % Partita in corso
    end
end
