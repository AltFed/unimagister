clear all;
close all;
clc;
%% 1. Inizializzazione dei Parametri
A = 7;                          % Numero di azioni
numEpisodes = 10000000;           % Aumentato per un addestramento serio
epsilon = 0.9;                  % Epsilon iniziale alto
gamma = 0.6;                    % Fattore di sconto
lambda = 0.7;                   % Parametro tracce di eligibilità
d = 64;                         % Dimensione corretta
t=0.01;                         % Tasso di apprendimento iniziale

w = zeros(d, A);
w_opponent = w;
Win_Rate = [];
Rate = [0 0 0];

%% 2. Ciclo di Addestramento Principale (Self-Play)
fprintf('Inizio addestramento in Self-Play...\n');
for e = 1:numEpisodes
    
    % Epsilon Decay
    current_epsilon = epsilon * (0.99995^e); 
    if current_epsilon < 0.01, current_epsilon = 0.01; end
    
    % Aggiorna l'avversario
    if mod(e, 1000) == 0
        fprintf('Episodio %d/%d: Aggiornamento policy avversario. Epsilon attuale: %.4f\n', e, numEpisodes, current_epsilon);
        w_opponent = w;
    end
    
    alpha = t * (1 - (e / (numEpisodes + 1)));
    
    s = zeros(6, 7);
    possib = ones(1, 7);
    z = zeros(size(w));
    
    % PRIMA MOSSA
    Fac = Features(s, 1); % <-- VERIFICA CHE SIA (s, 1)
    Q = w' * Fac;
    vec = possibleaction(possib);
    
    if rand < current_epsilon
        a = vec(randi(length(vec)));
    else
        [~, a_idx] = max(Q(vec));
        a = vec(a_idx);
    end
    
    isTerminal = false;
    while ~isTerminal
        [possib_next, sp, r, isTerminal] = gridAuto(possib, s, a, w_opponent);
        
        if isTerminal
            if (r == 1), Rate(1) = Rate(1) + 1; end
            delta = r - w(:, a)' * Fac;
        else
            Facp = Features(sp, 1); % <-- Questa è (sp, 1), corretto
            Qp = w' * Facp;
            vec = possibleaction(possib_next);
            
            if rand < current_epsilon
                ap = vec(randi(length(vec)));
            else
                [~, ap_idx] = max(Qp(vec));
                ap = vec(ap_idx);
            end
            
            delta = r + gamma * Qp(ap) - w(:, a)' * Fac;
        end
        
        z = gamma * lambda * z;
        z(:, a) = z(:, a) + Fac;
        w = w + alpha * delta * z;
        
        if ~isTerminal
            s = sp;
            a = ap;
            Fac = Facp;
            possib = possib_next;
        end
    end
    
    if mod(e, 500) == 0
        current_win_rate = Rate(1) / e;
        Win_Rate = [Win_Rate current_win_rate];
    end
end
fprintf('Addestramento completato!\n');



%% 3. Grafico dei Risultati e Salvataggio
figure(1);
plot(Win_Rate * 100);
title('Winrate Agente in Self-Play');
xlabel('Iterazioni (x100 episodi)');
ylabel('Win Rate %');
grid on;

save('agente_singolo.mat', 'w');
fprintf('Agente salvato in "agente_singolo.mat"\n');
%% 4. Test vs Random
%% ========================================================================
% FASE 4: TEST FINALE vs AVVERSARIO CASUALE (CON GRAFICI DETTAGLIATI)
% =========================================================================
fprintf('\n--- Inizio Test Finale: Agente Allenato vs Random ---\n');
num_test_games = 10000;
Rate_finale = [0 0 0]; % [Vittorie, Sconfitte, Pareggi]
lunghezza_partite_vinte = []; % Vettore per salvare la lunghezza delle partite vinte

for e = 1:num_test_games
    if mod(e, 1000) == 0, fprintf('Partita di test %d/%d\n', e, num_test_games); end
    
    s = zeros(6, 7);
    possib = ones(1, 7);
    isTerminal = false;
    turni_partita = 0; % Contatore per i turni di ogni partita
    
    % L'agente allenato fa la prima mossa (non c'è esplorazione, epsilon=0)
    Fac = Features(s, 1);
    Q = w' * Fac;
    vec = possibleaction(possib);
    [~, a_idx] = max(Q(vec));
    a = vec(a_idx);
    
    while ~isTerminal
        turni_partita = turni_partita + 1; % Ogni ciclo del while è un turno completo (AI + Random)
        
        [possib, s, r, isTerminal] = grid1(possib, s, a); % Usa grid1 per avversario random
        
        if isTerminal
            if (r == 1)
                Rate_finale(1) = Rate_finale(1) + 1;
                % Se l'agente ha vinto, salviamo la durata della partita
                lunghezza_partite_vinte = [lunghezza_partite_vinte, turni_partita];
            elseif (r == -1)
                Rate_finale(2) = Rate_finale(2) + 1;
            else
                Rate_finale(3) = Rate_finale(3) + 1;
            end
        else
            % L'agente sceglie la mossa successiva in modo greedy
            Facp = Features(s, 1);
            Qp = w' * Facp;
            vec = possibleaction(possib);
            [~, a_idx] = max(Qp(vec));
            a = vec(a_idx);
        end
    end
end

win_rate_finale = (Rate_finale(1) / num_test_games) * 100;
fprintf('\n--- Risultati del Test vs Random ---\n');
fprintf('Partite giocate: %d\n', num_test_games);
fprintf('Vittorie: %d\n', Rate_finale(1));
fprintf('Sconfitte: %d\n', Rate_finale(2));
fprintf('Pareggi: %d\n', Rate_finale(3));
fprintf('WIN RATE FINALE: %.2f%%\n\n', win_rate_finale);

%% ========================================================================
% GRAFICI SULLE MODALITÀ DI VITTORIA
% =========================================================================

% --- Grafico a Torta: Ripartizione dei Risultati ---
figure('Name', 'Ripartizione Risultati');
labels = {sprintf('Vittorie (%d)', Rate_finale(1)), ...
          sprintf('Sconfitte (%d)', Rate_finale(2)), ...
          sprintf('Pareggi (%d)', Rate_finale(3))};
pie(Rate_finale, labels);
title('Ripartizione dei Risultati vs Giocatore Casuale');

% --- Istogramma: Durata delle Partite Vinte ---
figure('Name', 'Durata Partite Vinte');
histogram(lunghezza_partite_vinte);
title('Distribuzione della Durata delle Partite Vinte');
xlabel('Numero di Turni per Vincere');
ylabel('Frequenza (Numero di Partite)');
grid on;
%% 5. Gioca contro l'agente allenato (Tu vs. AI)
fprintf('--- Inizia la partita contro l''AI ---\n');
fprintf('Tu sei il giocatore O (rosso), l''AI è il giocatore X (nero).\n');
fprintf('L''AI farà la prima mossa.\n');

% Assicurati di avere il file 'grid3.m' nella stessa cartella.

% Inizializzazione della partita
s = zeros(6,7);
possib = ones(1,7);
isTerminal = false;

while ~isTerminal
    % ---------------------------------
    % TURNO DELL'AGENTE AI (Giocatore 1)
    % ---------------------------------
    
    % Calcola le features per lo stato attuale
    Fac = Features(s, 1);
    
    % Calcola i valori Q per tutte le azioni
    Q = w' * Fac;
    
    % Scegli l'azione migliore (greedy, senza esplorazione)
    vec = possibleaction(possib);
    [~, best_action_index] = max(Q(vec));
    a = vec(best_action_index);
    
    fprintf('L''AI sceglie la colonna %d...\n', a);

    % ----------------------------------------------------------------
    % ESECUZIONE DEL TURNO (AI + UMANO) TRAMITE grid3.m
    % Questa funzione gestisce la mossa dell'AI, mostra la scacchiera,
    % e attende l'input della tua mossa da tastiera.
    % ----------------------------------------------------------------
    [possib, s, r, isTerminal] = grid3(possib, s, a);
    
    % Mostra la scacchiera aggiornata dopo la tua mossa
    clf;
    temp_board = swapRows(s);
    in_board(temp_board, 7, 6);
    
    % Controlla l'esito della partita
    if isTerminal
        if r == 1
            disp('L''AI ha vinto!');
        elseif r == -1
            disp('Hai vinto! Complimenti!');
        else
            disp('Pareggio!');
        end
    end
end