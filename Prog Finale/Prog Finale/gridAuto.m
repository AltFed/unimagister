function [possib_next, sp, r, Terminal] = gridAuto(possib, s, a, w_opponent)
% Ambiente per l'addestramento in self-play, versione ottimizzata.
    AGENTE = 1; AVVERSARIO = 2;

    [s_after_agent, r_agent, Terminal, ins_agent] = eseguiMossa(s, a, AGENTE);
    
    if Terminal
        sp = s_after_agent; r = r_agent;
        possib(ins_agent(2)) = (s_after_agent(1, ins_agent(2)) == 0);
        possib_next = possib; return;
    end
    
    possib(ins_agent(2)) = (s_after_agent(1, ins_agent(2)) == 0);
    
    Fac_opp = Features(s_after_agent, AVVERSARIO);
    Qp_opp = w_opponent' * Fac_opp;
    vec = find(possib);
    [~, ap_idx] = max(Qp_opp(vec));
    a_opponent = vec(ap_idx);

    [s_final, r_opponent, Terminal, ins_opp] = eseguiMossa(s_after_agent, a_opponent, AVVERSARIO);
    
    if Terminal && r_opponent == 1, r = -1;
    elseif Terminal, r = 0.5;
    else, r = 0;
    end

    sp = s_final;
    possib(ins_opp(2)) = (s_final(1, ins_opp(2)) == 0);
    possib_next = possib;
end
