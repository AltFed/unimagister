function [possib, s, r, isTerminal] = grid1(possib, s, a)
% Ambiente vs avversario random, versione ottimizzata.
    AGENTE = 1; AVVERSARIO = 2;

    [s_after_agent, r_agent, isTerminal, ins_agent] = eseguiMossa(s, a, AGENTE);
    
    if isTerminal, s = s_after_agent; r = r_agent; return; end
    
    possib(ins_agent(2)) = (s_after_agent(1, ins_agent(2)) == 0);
    
    vec = find(possib);
    a_opponent = vec(randi(length(vec)));
    
    [s_final, r_opponent, isTerminal, ins_opp] = eseguiMossa(s_after_agent, a_opponent, AVVERSARIO);
    
    if isTerminal && r_opponent == 1, r = -1;
    elseif isTerminal, r = 0.5; % Pareggio
    else, r = 0;
    end
    s = s_final;
    possib(ins_opp(2)) = (s(1, ins_opp(2)) == 0);
end
