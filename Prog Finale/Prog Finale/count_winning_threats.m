function threats_bin = count_winning_threats(s, opponent)
    threat_count = 0;
    
    % Determina le colonne disponibili
    possib = ones(1, 7);
    for j = 1:7
        if s(1, j) ~= 0
            possib(j) = 0;
        end
    end
    
    available_actions = possibleaction(possib);
    
    % Per ogni mossa possibile dell'avversario...
    for i = 1:length(available_actions)
        a = available_actions(i);
        temp_s = s; % Crea una scacchiera temporanea
        
        % ...simula la sua mossa in quella colonna
        ins = [];
        for row = 6:-1:1
            if temp_s(row, a) == 0
                temp_s(row, a) = opponent;
                ins = [row, a];
                break;
            end
        end
        
        % ...e controlla se con quella mossa vince
        if ~isempty(ins)
            if checker(possib, temp_s, opponent, ins) > 0
                threat_count = threat_count + 1;
            end
        end
    end
    
    % Converte il numero di minacce in un vettore binario a 4 bit
    % per mantenere la stessa dimensione delle features precedenti.
    threats_bin = dec2bin(threat_count, 4) - '0';
    threats_bin = threats_bin';
end