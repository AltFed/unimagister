% trainAgent_functional.m
% Versione completa e corretta
clear; clc; close all;

%% Parametri di Addestramento
learningRate = 0.1;         % Tasso di apprendimento (quanto "pesa" la nuova informazione)
discountFactor = 0.9;       % Fattore di sconto (importanza delle ricompense future)
epsilon = 0.9;              % Probabilità iniziale di esplorazione (mossa casuale)
epsilonDecay = 0.99995;      % Tasso di decadimento di epsilon (per ridurre l'esplorazione nel tempo)
minEpsilon = 0.01;          % Valore minimo di epsilon

episodesRandom = 100000;     % Numero di partite contro un avversario casuale
episodesSelfPlay = 0;   % Numero di partite contro sé stesso
totalEpisodes = episodesRandom + episodesSelfPlay;

% Inizializzazione della Q-Table (mappa per flessibilità) e storico ricompense
QTable = containers.Map('KeyType', 'char', 'ValueType', 'any');
rewardHistory = zeros(1, totalEpisodes);

%% Fase 1: Addestramento contro Avversario Casuale
fprintf('Inizio Fase 1: Addestramento contro avversario casuale...\n');
for episode = 1:episodesRandom
    board = createBoard();
    currentPlayer = 1;
    done = false;

    while ~done
        % --- Turno dell'Agente (Giocatore 1) ---
        state = boardToState(board);
        validMoves = getValidMoves(board);

        % Inizializza i Q-valori per un nuovo stato se non è mai stato visto
        if ~isKey(QTable, state)
            QTable(state) = zeros(1, 7);
        end

        % Politica Epsilon-Greedy: scegli tra esplorazione e sfruttamento
        if rand() < epsilon
            action = validMoves(randi(length(validMoves))); % Mossa casuale (Esplorazione)
        else
            q_values = QTable(state);
            [~, idx] = max(q_values(validMoves)); % Mossa migliore (Sfruttamento)
            action = validMoves(idx);
        end

        % Esegui la mossa dell'agente e ottieni il risultato
        [board, winner, done] = makeMove(board, action, currentPlayer);
        
        % Assegna la ricompensa in base al risultato della mossa dell'agente
        if winner == 1 % L'agente ha vinto
            reward = 100;
        elseif done % Pareggio
            reward = -10;
        else
            % Se la partita non è finita, tocca all'avversario
            currentPlayer = 2;
            % --- Turno dell'Avversario Casuale (Giocatore 2) ---
            oppValidMoves = getValidMoves(board);
            oppAction = oppValidMoves(randi(length(oppValidMoves)));
            [board, winner, done] = makeMove(board, oppAction, currentPlayer);
            intermediate_reward = 0;
if winner == 0 % Calcola solo se la partita non è già vinta
    % Bonus per aver creato una minaccia (tris aperto)
    agent_threats = countOpenThrees(board, 1);
    intermediate_reward = agent_threats * 5; % Diamo un bonus di +5 per ogni minaccia
end
            if winner == 2 % L'agente ha perso
                reward = -100+ intermediate_reward;
            else
                reward = -1 + intermediate_reward;
            end
            currentPlayer = 1; % Ritorna il turno all'agente
        end

        % --- Aggiornamento della Q-Table (Formula di Bellman) ---
        nextState = boardToState(board);
        if ~isKey(QTable, nextState)
            QTable(nextState) = zeros(1, 7);
        end
        
        % === BLOCCO DI CODICE CORRETTO ===
        % Calcola il massimo Q-valore per lo stato successivo
        if done 
            % Se la partita è finita, non c'è valore futuro
            max_next_q = 0;
        else
            % Altrimenti, trova il massimo Q-valore possibile dallo stato successivo.
            % Questo è l'approccio robusto che evita l'errore di indicizzazione.
            max_next_q = max(QTable(nextState));
        end
        % ================================

        % Applica la formula di aggiornamento del Q-Learning
        current_q_values = QTable(state);
        current_q_values(action) = current_q_values(action) + learningRate * (reward + discountFactor * max_next_q - current_q_values(action));
        QTable(state) = current_q_values;
        
        rewardHistory(episode) = rewardHistory(episode) + reward;
    end
    
    % Riduci gradualmente epsilon per favorire lo sfruttamento
    epsilon = max(minEpsilon, epsilon * epsilonDecay);
    if mod(episode, 1000) == 0
        fprintf('Episodio (Random): %d/%d, Epsilon: %.4f\n', episode, episodesRandom, epsilon);
    end
end

%% Fase 2: Addestramento Self-Play
fprintf('Inizio Fase 2: Addestramento Self-Play...\n');
for episode = episodesRandom + 1 : totalEpisodes
    board = createBoard();
    currentPlayer = 1;
    done = false;
    
    while ~done
        state = boardToState(board);
        validMoves = getValidMoves(board);
        
        if ~isKey(QTable, state)
            QTable(state) = zeros(1, 7);
        end
        
        if rand() < epsilon
            action = validMoves(randi(length(validMoves)));
        else
            q_values = QTable(state);
            [~, idx] = max(q_values(validMoves));
            action = validMoves(idx);
        end
        
        [board, winner, done] = makeMove(board, action, currentPlayer);
        
        % Calcolo della ricompensa
        if winner ~= 0
            reward = 100; % Ricompensa per la vittoria
        elseif done
            reward = -10; % Penalità per il pareggio
        else
            reward = -1; % Penalità per mossa
        end
        
        % Aggiornamento della Q-Table
        nextState = boardToState(board);
        if ~isKey(QTable, nextState)
            QTable(nextState) = zeros(1, 7);
        end
        
        if done
            max_next_q = 0;
        else
            max_next_q = max(QTable(nextState));
        end
        
        current_q_values = QTable(state);
        % L'aggiornamento qui considera la mossa dell'avversario (minimax)
        current_q_values(action) = current_q_values(action) + learningRate * (reward + discountFactor * (-max_next_q) - current_q_values(action));
        QTable(state) = current_q_values;
        
        rewardHistory(episode) = rewardHistory(episode) + reward;
        currentPlayer = 3 - currentPlayer; % Cambia giocatore
    end
    
    epsilon = max(minEpsilon, epsilon * epsilonDecay);
    if mod(episode, 1000) == 0
        fprintf('Episodio (Self-Play): %d/%d, Epsilon: %.4f\n', episode-episodesRandom, episodesSelfPlay, epsilon);
    end
end

%% Fase 3: Test e Calcolo Win Rate
fprintf('Inizio Fase 3: Test delle performance...\n');
testGames = 1000;
wins = 0; draws = 0; losses = 0;

for i = 1:testGames
    board = createBoard();
    currentPlayer = 1;
    done = false;
    while ~done
        % Turno dell'agente (giocatore 1, politica puramente greedy)
        state = boardToState(board);
        validMoves = getValidMoves(board);

        if isKey(QTable, state) && ~isempty(validMoves)
            q_values = QTable(state);
            [~, idx] = max(q_values(validMoves));
            action = validMoves(idx);
        else
            % Se lo stato è sconosciuto, fa una mossa casuale
            action = validMoves(randi(length(validMoves)));
        end
        [board, winner, done] = makeMove(board, action, currentPlayer);

        if winner == 1
            wins = wins + 1;
        elseif done
            draws = draws + 1;
        else
            currentPlayer = 2;
            % Turno dell'avversario casuale
            oppValidMoves = getValidMoves(board);
            [~, ~, done] = makeMove(board, oppValidMoves(randi(length(oppValidMoves))), currentPlayer);
            if done
                losses = losses + 1;
            end
            currentPlayer = 1;
        end
    end
end

winRate = wins / testGames * 100;
drawRate = draws / testGames * 100;
lossRate = losses / testGames * 100;

fprintf('Risultati su %d partite di test:\n', testGames);
fprintf('Vittorie: %d (%.2f%%)\n', wins, winRate);
fprintf('Pareggi: %d (%.2f%%)\n', draws, drawRate);
fprintf('Sconfitte: %d (%.2f%%)\n', losses, lossRate);

%% Fase 4: Grafici e Salvataggio
% Grafico del Win Rate
figure('Name', 'Performance Agente', 'NumberTitle', 'off');
bar_data = [winRate, drawRate, lossRate];
b = bar(bar_data, 'FaceColor', 'flat');
b.CData(1,:) = [0.4 0.8 0.4]; % Verde per vittorie
b.CData(2,:) = [0.9 0.9 0.4]; % Giallo per pareggi
b.CData(3,:) = [0.9 0.4 0.4]; % Rosso per sconfitte
xticks([1 2 3]);
xticklabels({'Vittorie', 'Pareggi', 'Sconfitte'});
ylabel('Percentuale (%)');
title(sprintf('Performance Agente vs Random su %d Partite', testGames));
grid on;
ylim([0 100]);

% Grafico delle ricompense durante l'addestramento
figure('Name', 'Ricompensa Cumulativa per Episodio', 'NumberTitle', 'off');
plot(smoothdata(rewardHistory, 'movmean', 500)); % Media mobile più ampia per un grafico più liscio
title('Ricompensa Media Mobile per Episodio durante l''Addestramento');
xlabel('Episodio');
ylabel('Ricompensa Cumulativa Media');
grid on;
xline(episodesRandom, '--r', 'Fine Addestramento vs Random', 'LineWidth', 2);

% Grafico surf per uno stato specifico (es. scacchiera vuota)
initialState = boardToState(createBoard());
if isKey(QTable, initialState)
    q_initial = QTable(initialState);
    figure('Name', 'Valori Q per Stato Iniziale', 'NumberTitle', 'off');
    bar(q_initial);
    title('Valori Q per ogni mossa dalla scacchiera vuota');
    xlabel('Colonna (Azione)');
    ylabel('Valore Q Stimato');
    grid on;
    xlim([0 8]);
end

% Salva la Q-Table per poterla usare in seguito
save('q_table_connect4.mat', 'QTable');
fprintf('Q-Table addestrata salvata in q_table_connect4.mat\n');