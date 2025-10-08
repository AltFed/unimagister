function [critical_move, move_type] = find_critical_move(s, player)
    % Versione finale e pulita.
    % Cerca una mossa di vittoria per 'player' o una mossa di blocco
    % contro l'avversario.

    critical_move = [];
    move_type = 'none';
    opponent = 3 - player; % Calcola l'avversario (1->2, 2->1)

    % Determina le mosse possibili
    possib = ones(1, 7);
    for j = 1:7
        if s(1, j) ~= 0, possib(j) = 0; end
    end
    available_actions = possibleaction(possib);

    % --- REGOLA 1: Controlla se l'agente (player) può vincere ---
    for i = 1:length(available_actions)
        a = available_actions(i);
        temp_s = s;
        temp_possib = possib;
        ins = [];
        for row = 6:-1:1
            if temp_s(row, a) == 0
                temp_s(row, a) = player;
                ins = [row, a];
                if row == 1, temp_possib(a) = 0; end
                break;
            end
        end
        
        if ~isempty(ins) && checker(temp_possib, temp_s, player, ins) > 0
            critical_move = a;
            move_type = 'win';
            return;
        end
    end

    % --- REGOLA 2: Controlla se l'avversario sta per vincere (e blocca) ---
    for i = 1:length(available_actions)
        a = available_actions(i);
        temp_s = s;
        temp_possib = possib;
        ins = [];
        for row = 6:-1:1
            if temp_s(row, a) == 0
                temp_s(row, a) = opponent;
                ins = [row, a];
                if row == 1, temp_possib(a) = 0; end
                break;
            end
        end
        
        if ~isempty(ins) && checker(temp_possib, temp_s, opponent, ins) > 0
            critical_move = a;
            move_type = 'block';
            return;
        end
    end
end