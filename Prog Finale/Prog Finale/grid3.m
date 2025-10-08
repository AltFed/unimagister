function [possib, s, r, isTerminal] = grid3(possib, s, a)
% Ambiente vs giocatore umano, versione ottimizzata.
    AGENTE = 1; UMANO = 2;

    [s_after_agent, r_agent, isTerminal, ins_agent] = eseguiMossa(s, a, AGENTE);
    
    if isTerminal
        s = s_after_agent; r = r_agent; return;
    end
    
    possib(ins_agent(2)) = (s_after_agent(1, ins_agent(2)) == 0);
    
    clf;
    temp_board = flipud(s_after_agent);
    in_board(temp_board, 7, 6);
    
    a_human = input('\nScegli la colonna (1-7): ');
    
    [s_final, r_human, isTerminal, ins_human] = eseguiMossa(s_after_agent, a_human, UMANO);

    if isTerminal && r_human == 1, r = -1; % Hai vinto
    elseif isTerminal, r = 0.5; % Pareggio
    else, r = 0;
    end
    s = s_final;
    possib(ins_human(2)) = (s(1, ins_human(2)) == 0);
end
