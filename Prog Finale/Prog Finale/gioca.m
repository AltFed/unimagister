% ... dentro il ciclo 'while ~isTerminal' in gioca.m ...

    % ---------------------------------
    % TURNO DELL'AGENTE AI (Giocatore 1) - Basato solo sui pesi appresi
    % ---------------------------------
    
    % 1. Calcola le features per lo stato attuale
    Fac = Features(s, 1);
    
    % 2. Calcola i valori Q per tutte le azioni
    Q = w' * Fac;
    
    % 3. Scegli l'azione migliore (greedy) tra quelle possibili
    vec = find(possib); 
    [~, best_action_index] = max(Q(vec));
    a = vec(best_action_index);
    
    fprintf('L''AI sceglie la colonna %d...\n', a);

    % ----------------------------------------------------------------
    % ESECUZIONE DEL TURNO
    % ----------------------------------------------------------------
    [possib, s, r, isTerminal] = grid3(possib, s, a);
    
% ... resto del codice ...
