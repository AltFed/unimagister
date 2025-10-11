% boardToState.m
function state = boardToState(board)
    % Converte la matrice della scacchiera in una stringa per usarla
    % come chiave nella Q-Table (una mappa).
    state = num2str(board(:)');
end
