clear all;
close all;
clc;
%% 1. Inizializzazione dei Parametri
A = 7;                          % Numero di azioni
numEpisodes = 200000;           % Numero di episodi per l'addestramento
epsilon = 0.9;                  % Epsilon iniziale alto
gamma = 0.9;                    % Fattore di sconto
lambda = 0.8;                   % Parametro tracce di eligibilità
d = 17;                         % Dimensione corretta del vettore delle features
t = 0.01;                       % Tasso di apprendimento iniziale

w = zeros(d, A);
w_opponent = w;
Win_Rate = [];
Rate = [0 0 0];

%% 2. Ciclo di Addestramento Principale (Self-Play con Q-Learning)
fprintf('Inizio addestramento in Self-Play...\n');
for e = 1:numEpisodes
    
    % Epsilon Decay (riduzione graduale dell'esplorazione)
    current_epsilon = epsilon * (0.99995^e); 
    if current_epsilon < 0.01, current_epsilon = 0.01; end
    
    % Aggiorna l'avversario ogni 100 episodi per un apprendimento più dinamico
    if mod(e, 100) == 0
        fprintf('Episodio %d/%d: Aggiornamento policy avversario. Epsilon attuale: %.4f\n', e, numEpisodes, current_epsilon);
        w_opponent = w;
    end
    
    % Learning Rate Decay (riduzione graduale del tasso di apprendimento)
    alpha = t * (1 - (e / (numEpisodes + 1)));
    
    s = zeros(6, 7);
    possib = ones(1, 7);
    z = zeros(size(w)); % Inizializzazione tracce di eligibilità
    
    % PRIMA MOSSA
    Fac = Features(s, 1);
    Q = w' * Fac;
    vec = find(possib);
    
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
            Facp = Features(sp, 1);
            Qp = w' * Facp;
            vec = find(possib_next); %% <-- MODIFICA 1: Usato find() al posto di possibleaction()
            
            if rand < current_epsilon
                ap = vec(randi(length(vec)));
            else
                [~, ap_idx] = max(Qp(vec));
                ap = vec(ap_idx);
            end
            
            %% <-- MODIFICA 2: Implementato l'aggiornamento di Q-LEARNING
            % Invece di usare il valore Q della prossima mossa scelta (SARSA),
            % usiamo il massimo valore Q possibile dal nuovo stato.
            max_q_value = max(Qp(vec));
            delta = r + gamma * max_q_value - w(:, a)' * Fac;
        end
        
        % Aggiornamento dei pesi con le tracce di eligibilità
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
        current_win_rate = Rate(1) / 500; % Win rate sugli ultimi 500 episodi
        Win_Rate = [Win_Rate current_win_rate];
        Rate(1) = 0; % Resetta il contatore
    end
end
fprintf('Addestramento completato!\n');

%% 3. Grafico dei Risultati e Salvataggio
figure(1);
plot(Win_Rate * 100);
title('Winrate Agente in Self-Play (media mobile su 500 episodi)');
xlabel('Iterazioni (x500 episodi)');
ylabel('Win Rate %');
grid on;

save('agente_singolo.mat', 'w');
fprintf('Agente salvato in "agente_singolo.mat"\n');

%% 4. Test vs Random (Nessuna modifica necessaria qui, 'find' era già usato)
fprintf('\n--- Inizio Test Finale: Agente Allenato vs Random ---\n');
num_test_games = 10000;
Rate_finale = [0 0 0]; % [Vittorie, Sconfitte, Pareggi]

for e = 1:num_test_games
    if mod(e, 1000) == 0, fprintf('Partita di test %d/%d\n', e, num_test_games); end
    s = zeros(6, 7);
    possib = ones(1, 7);
    isTerminal = false;
    
    Fac = Features(s, 1);
    Q = w' * Fac;
    vec = find(possib);
    [~, a_idx] = max(Q(vec));
    a = vec(a_idx);
    
    while ~isTerminal
        [possib, s, r, isTerminal] = grid1(possib, s, a);
        if isTerminal
            if (r == 1), Rate_finale(1) = Rate_finale(1) + 1;
            elseif (r == -1), Rate_finale(2) = Rate_finale(2) + 1;
            else, Rate_finale(3) = Rate_finale(3) + 1;
            end
        else
            Facp = Features(s, 1);
            Qp = w' * Facp;
            vec = find(possib);
            [~, a_idx] = max(Qp(vec));
            a = vec(a_idx);
        end
    end
end

win_rate_finale = (Rate_finale(1) / num_test_games) * 100;
fprintf('\n--- Risultati del Test vs Random ---\n');
fprintf('WIN RATE FINALE: %.2f%%\n\n', win_rate_finale);


%% 5. Gioca contro l'agente allenato (Tu vs. AI)
fprintf('--- Inizia la partita contro l''AI ---\n');
s = zeros(6,7);
possib = ones(1,7);
isTerminal = false;

while ~isTerminal
    % TURNO DELL'AGENTE AI
    Fac = Features(s, 1);
    Q = w' * Fac;
    vec = find(possib);
    [~, best_action_index] = max(Q(vec));
    a = vec(best_action_index);
    fprintf('L''AI sceglie la colonna %d...\n', a);

    % ESECUZIONE DEL TURNO (AI + UMANO) TRAMITE grid3.m
    [possib, s, r, isTerminal] = grid3(possib, s, a);
    
    % Mostra la scacchiera aggiornata dopo la tua mossa
    clf;
    temp_board = flipud(s); %% <-- MODIFICA 3: Usato flipud() al posto di swapRows()
    in_board(temp_board, 7, 6);
    
    % Controlla l'esito della partita
    if isTerminal
        if r == 1, disp('L''AI ha vinto!');
        elseif r == -1, disp('Hai vinto! Complimenti!');
        else, disp('Pareggio!');
        end
    end
end
