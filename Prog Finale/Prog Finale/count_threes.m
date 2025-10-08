function threes = count_threes(s, player)
% Conta le configurazioni di tre pezzi consecutivi per un giocatore specifico.
    threes = 0;
    for i = 1:size(s, 1)
        threes = threes + count_consecutive(s(i, :), player, 3);
    end
    for j = 1:size(s, 2)
        threes = threes + count_consecutive(s(:, j), player, 3);
    end
    for k = -size(s,1)+1:size(s,2)-1
        threes = threes + count_consecutive(diag(s, k), player, 3);
        threes = threes + count_consecutive(diag(flipud(s), k), player, 3);
    end
end
