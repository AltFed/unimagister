function threes = count_threes(s,player)
    % Conta le configurazioni di tre pezzi consecutivi per un giocatore specifico
    threes = 0;
    
    % Conta i tre in fila orizzontali
    for i = 1:size(s, 1)
        row = s(i, :);
        threes = threes + count_consecutive(row, player, 3);
    end
    
    % Conta i tre in fila verticali
    for j = 1:size(s, 2)
        col = s(:, j);
        threes = threes + count_consecutive(col, player, 3);
    end
    
    % Conta i tre in fila diagonali
    for k = -size(s,1)+1:size(s,2)-1
        diag1 = diag(s, k);
        diag2 = diag(flipud(s), k);
        threes = threes + count_consecutive(diag1, player, 3);
        threes = threes + count_consecutive(diag2, player, 3);
    end
threes =dec2bin(threes, 4)- '0';
threes=threes';
end