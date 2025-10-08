function [critical_move, move_type] = find_critical_move(s, player)
% Cerca una mossa di vittoria per 'player' o una mossa di blocco.
    critical_move = [];
    move_type = 'none';
    opponent = 3 - player;
    available_actions = find(s(1, :) == 0);

    % REGOLA 1: Controlla se 'player' può vincere
    for a = available_actions
        temp_s = s;
        ins = [];
        for row = 6:-1:1, if temp_s(row, a) == 0, temp_s(row, a) = player; ins = [row, a]; break; end, end
        if ~isempty(ins) && checkWin(temp_s, ins) == player
            critical_move = a; move_type = 'win'; return;
        end
    end

    % REGOLA 2: Controlla se l'avversario sta per vincere (e blocca)
    for a = available_actions
        temp_s = s;
        ins = [];
        for row = 6:-1:1, if temp_s(row, a) == 0, temp_s(row, a) = opponent; ins = [row, a]; break; end, end
        if ~isempty(ins) && checkWin(temp_s, ins) == opponent
            critical_move = a; move_type = 'block'; return;
        end
    end
end
