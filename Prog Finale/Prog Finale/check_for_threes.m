function threes = check_for_threes(s, player)
    % Funzione semplificata che restituisce il numero di tris
    threes = 0;
    % Controllo Orizzontale
    for i = 1:6
        for j = 1:4
            if all(s(i, j:j+2) == player)
                threes = threes + 1;
            end
        end
    end
    % Controllo Verticale
    for i = 1:3
        for j = 1:7
            if all(s(i:i+2, j) == player)
                threes = threes + 1;
            end
        end
    end
end