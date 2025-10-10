function [possib_next, sp, r, Terminal] = gridAuto(possib, s, a, w_opponent)
% Ambiente per l'addestramento in self-play con REWARD SHAPING.
% L'agente riceve piccoli premi/penalità per guidare l'apprendimento.

    % --- PARAMETRI DELLO SHAPING (puoi modificarli per sperimentare) ---
    REWARD_ATTACK = 0.1;    % Premio per aver creato un proprio tris
    PENALTY_DEFENSE = -0.2; % Penalità per aver concesso un tris all'avversario
    
    % --- COSTANTI GIOCATORI ---
    AGENTE = 1;
    AVVERSARIO = 2;

    % Inizializza la ricompensa di shaping per questo turno a zero
    reward_shaping = 0;

    % --- 1. MOSSA DELL'AGENTE ---
    
    % Contiamo quanti tris aveva l'agente PRIMA della sua mossa
    num_threes_agent_prima = count_threes(s, AGENTE);
    
    % L'agente esegue la sua mossa 'a'
    [s_after_agent, r_agent, Terminal, ins_agent] = eseguiMossa(s, a, AGENTE);

    % Contiamo i tris dell'agente DOPO la sua mossa
    num_threes_agent_dopo = count_threes(s_after_agent, AGENTE);
    
    % Se il numero di tris è aumentato, diamo un premio!
    if num_threes_agent_dopo > num_threes_agent_prima
        reward_shaping = reward_shaping + REWARD_ATTACK;
    end
    
    % Se la mossa dell'agente ha terminato la partita (vittoria/pareggio)
    if Terminal
        sp = s_after_agent;
        r = r_agent + reward_shaping; % La ricompensa finale include lo shaping
        possib(ins_agent(2)) = (s_after_agent(1, ins_agent(2)) == 0);
        possib_next = possib;
        return;
    end
    
    % Aggiorna le colonne disponibili
    possib(ins_agent(2)) = (s_after_agent(1, ins_agent(2)) == 0);

    % --- 2. MOSSA DELL'AVVERSARIO ---
    
    % Contiamo i tris dell'avversario PRIMA della sua mossa
    num_threes_opp_prima = count_threes(s_after_agent, AVVERSARIO);
    
    % L'avversario sceglie la sua mossa migliore (greedy)
    Fac_opp = Features(s_after_agent, AVVERSARIO);
    Qp_opp = w_opponent' * Fac_opp;
    vec = find(possib);
    
    % Controllo di sicurezza nel caso non ci siano più mosse disponibili
    if isempty(vec)
        sp = s_after_agent; r = 0.5; Terminal = true; possib_next = possib; return;
    end

    [~, ap_idx] = max(Qp_opp(vec));
    a_opponent = vec(ap_idx);

    % L'avversario esegue la sua mossa
    [s_final, r_opponent, Terminal, ins_opp] = eseguiMossa(s_after_agent, a_opponent, AVVERSARIO);

    % Contiamo i tris dell'avversario DOPO la sua mossa
    num_threes_opp_dopo = count_threes(s_final, AVVERSARIO);
    
    % Se il numero di tris dell'avversario è aumentato, diamo una penalità all'agente!
    if num_threes_opp_dopo > num_threes_opp_prima
        reward_shaping = reward_shaping + PENALTY_DEFENSE;
    end

    % --- 3. RICOMPENSA FINALE DEL TURNO ---
    
    % La ricompensa base del gioco è 0, a meno che la partita non finisca qui
    r_game = 0;
    if Terminal % Se la mossa dell'avversario ha terminato la partita
        if r_opponent == 1      % L'avversario ha vinto
            r_game = -1;
        else                    % Pareggio
            r_game = 0.5;
        end
    end
    
    % La ricompensa totale che l'agente riceve è la somma di quella di gioco e dello shaping
    r = r_game + reward_shaping;

    % Aggiorna lo stato finale e le colonne disponibili per il prossimo turno
    sp = s_final;
    possib(ins_opp(2)) = (s_final(1, ins_opp(2)) == 0);
    possib_next = possib;
end
