function [s_next, reward, isTerminal, ins] = eseguiMossa(s, colonna, giocatore)
% Esegue una mossa per un giocatore e ne determina l'esito.
    s_next = s;
    ins = [];
    for riga = 6:-1:1
        if s_next(riga, colonna) == 0
            s_next(riga, colonna) = giocatore;
            ins = [riga, colonna];
            break;
        end
    end
    
    if isempty(ins)
        reward = -10; % Mossa impossibile (colonna piena)
        isTerminal = true;
        return;
    end

    stato_partita = checkWin(s_next, ins);
    isTerminal = true;
    
    if stato_partita == giocatore
        reward = 1;
    elseif stato_partita == 3
        reward = 0.5; % Pareggio
    elseif stato_partita == 0
        reward = 0;
        isTerminal = false;
    else
        reward = -1;
    end
end
