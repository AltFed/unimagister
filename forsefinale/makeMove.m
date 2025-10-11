% makeMove.m
% Versione completa e corretta
function [newBoard, winner, isDone] = makeMove(board, column, player)
    newBoard = board;
    winner = 0;
    isDone = false;

    % Trova la prima riga libera partendo dal basso
    row = find(newBoard(:, column) == 0, 1, 'last');
    if isempty(row)
        % Questa colonna è piena, mossa non valida
        return;
    end
    
    newBoard(row, column) = player;

    % Controlla se la mossa è vincente
    if checkWin(newBoard, row, column, player)
        winner = player;
        isDone = true;
    % Controlla se la scacchiera è piena (pareggio)
    elseif isempty(getValidMoves(newBoard))
        isDone = true;
    end
end

% --- Funzione di supporto (locale a makeMove) con logica di controllo corretta ---
function isWin = checkWin(board, r, c, player)
    isWin = false;
    
    % Controlla orizzontale (-)
    for j = 1:4 % j è la colonna di partenza della sequenza di 4
        if all(c >= j & c < j + 4) % Controlla solo le sequenze che includono la nuova pedina
            if all(board(r, j:j+3) == player)
                isWin = true; return;
            end
        end
    end

    % Controlla verticale (|)
    for i = 1:3 % i è la riga di partenza della sequenza di 4
        if all(r >= i & r < i + 4)
            if all(board(i:i+3, c) == player)
                isWin = true; return;
            end
        end
    end

    % Controlla diagonale discendente (\)
    for i = 1:3 % Riga di partenza
        for j = 1:4 % Colonna di partenza
            % Controlla se la nuova pedina fa parte di questa diagonale
            if any(r == i:(i+3) & c == j:(j+3)) && all( (r-(i-1)) == (c-(j-1)) )
                if board(i,j) == player && board(i+1,j+1) == player && board(i+2,j+2) == player && board(i+3,j+3) == player
                    isWin = true; return;
                end
            end
        end
    end

    % Controlla diagonale ascendente (/)
    for i = 1:3 % Riga di partenza
        for j = 4:7 % Colonna di partenza
            % Controlla se la nuova pedina fa parte di questa anti-diagonale
            if any(r == i:(i+3) & c == j:(-1):(j-3)) && all( (r-(i-1)) == -(c-(j+1)) )
                 if board(i,j) == player && board(i+1,j-1) == player && board(i+2,j-2) == player && board(i+3,j-3) == player
                    isWin = true; return;
                 end
            end
        end
    end
end