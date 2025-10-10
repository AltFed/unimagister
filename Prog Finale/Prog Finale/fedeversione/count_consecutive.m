function count = count_consecutive(array, player, len)
    % Conta il numero di sequenze consecutive di lunghezza len per il giocatore specificato
    count = 0;
    consecutive = 0;
    
    for i = 1:length(array)
        if array(i) == player
            consecutive = consecutive + 1;
            if consecutive == len
                count = count + 1;
                consecutive = 0; % o len-1 se vuoi contare le sovrapposizioni
            end
        else
            consecutive = 0;
        end
    end
end