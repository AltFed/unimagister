% countOpenThrees.m
function count = countOpenThrees(board, player)
    % Conta il numero di "tris aperti" (sequenze 0-P-P-P-0) per un dato giocatore.
    % Queste sono le minacce di vittoria più forti.
    count = 0;
    [rows, cols] = size(board);
    
    % Definisci la sequenza di minaccia
    threat_sequence = [0, player, player, player, 0];

    % Controlla orizzontale
    for r = 1:rows
        for c = 1:(cols - 4)
            if all(board(r, c:c+4) == threat_sequence)
                count = count + 1;
            end
        end
    end

    % Controlla verticale
    for c = 1:cols
        for r = 1:(rows - 4)
            if all(board(r:r+4, c)' == threat_sequence)
                count = count + 1;
            end
        end
    end

    % Controlla diagonali (entrambe le direzioni)
    for r = 1:(rows - 4)
        for c = 1:(cols - 4)
            diag_fwd = diag(board(r:r+4, c:c+4));
            diag_bwd = diag(fliplr(board(r:r+4, c:c+4)));
            if all(diag_fwd' == threat_sequence)
                count = count + 1;
            end
            if all(diag_bwd' == threat_sequence)
                count = count + 1;
            end
        end
    end
end
