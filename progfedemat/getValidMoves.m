% getValidMoves.m
function validMoves = getValidMoves(board)
    % Restituisce un vettore con gli indici delle colonne non ancora piene.
    % La prima riga (in alto) della scacchiera determina se una colonna è piena.
    validMoves = find(board(1, :) == 0);
end
