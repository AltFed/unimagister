function threat_count = count_winning_threats(s, opponent)
% Conta le minacce di vittoria immediate per un dato giocatore.
    threat_count = 0;
    available_actions = find(s(1, :) == 0);
    
    for i = 1:length(available_actions)
        a = available_actions(i);
        temp_s = s;
        ins = [];
        for row = 6:-1:1
            if temp_s(row, a) == 0
                temp_s(row, a) = opponent;
                ins = [row, a];
                break;
            end
        end
        if ~isempty(ins) && checkWin(temp_s, ins) == opponent
            threat_count = threat_count + 1;
        end
    end
end
