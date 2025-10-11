% boardToState.m (Versione 2.0 - Efficiente)
function state = boardToState(board)
    % Converte la matrice della scacchiera in una stringa compatta, senza spazi.
    % Esempio: [0, 1, 2] diventa '012' invece di '  0   1   2'
    state = sprintf('%d', board(:));
end