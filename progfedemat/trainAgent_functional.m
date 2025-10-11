% trainAgent_struct.m
% Versione finale che utilizza STRUCT per la massima efficienza e stabilità.
clear; clc; close all;

%% Parametri di Addestramento
learningRate = 0.1;
discountFactor = 0.9;
epsilon = 0.9;
epsilonDecay = 0.99995;
minEpsilon = 0.01;
episodesRandom = 100000;

% Parametri per il Reward Shaping
offensive_bonus = 5;
defensive_penalty = 10;

% Inizializzazione Q-Table (come struct) e storico
QTable = struct();
rewardHistory = zeros(1, episodesRandom);

%% Fase 1: Addestramento contro Avversario Casuale
fprintf('--- Inizio Addestramento vs. Random per %d episodi (usando struct) ---\n', episodesRandom);
tic;
for episode = 1:episodesRandom
    board = createBoard();
    done = false;

    while ~done
        % --- Turno dell'Agente (Giocatore 1) ---
        state_key = boardToState_struct(board); % Usa la funzione per struct
        validMoves = getValidMoves(board);

        % --- LOGICA STRUCT ---
        if ~isfield(QTable, state_key), QTable.(state_key) = single(zeros(1, 7)); end

        if rand() < epsilon
            action = validMoves(randi(length(validMoves))); % Esplorazione
        else
            q_values = QTable.(state_key); % Accesso ai campi dello struct
            valid_q = -inf(1,7,'single');
            valid_q(validMoves) = q_values(validMoves);
            [~, action] = max(valid_q); % Sfruttamento (robusto)
        end

        [board, winner, done] = makeMove(board, action, 1);
        
        % --- Calcolo della Ricompensa ---
        if winner == 1, reward = 100;
        elseif done, reward = -10;
        else
            agent_threes = countOpenThrees(board, 1);
            opponent_threes = countOpenThrees(board, 2);
            shaping_reward = (agent_threes * offensive_bonus) - (opponent_threes * defensive_penalty);
            reward = -1 + shaping_reward;
            
            % --- Turno dell'Avversario Casuale (Giocatore 2) ---
            oppValidMoves = getValidMoves(board);
            oppAction = oppValidMoves(randi(length(oppValidMoves)));
            [board, winner, done] = makeMove(board, oppAction, 2);
            if winner == 2, reward = -100; end
        end

        % --- Aggiornamento Q-Table (Struct) ---
        next_state_key = boardToState_struct(board);
        if ~isfield(QTable, next_state_key), QTable.(next_state_key) = single(zeros(1, 7)); end
        
        max_next_q = ifthen(done, 0, max(QTable.(next_state_key)));
        
        current_q_values = QTable.(state_key);
        current_q_values(action) = current_q_values(action) + learningRate * (reward + discountFactor * max_next_q - current_q_values(action));
        QTable.(state_key) = current_q_values;
        
        rewardHistory(episode) = reward;
    end
    
    epsilon = max(minEpsilon, epsilon * epsilonDecay);
    if mod(episode, 1000) == 0
        fprintf('Episodio: %d/%d, Epsilon: %.4f\n', episode, episodesRandom, epsilon);
    end
end
fprintf('Addestramento completato in %.2f minuti.\n', toc/60);

%% Fase 2: Test e Calcolo Win Rate
fprintf('\n--- Inizio Fase di Test ---\n');
testGames = 1000; wins = 0; draws = 0; losses = 0;
for i = 1:testGames
    board = createBoard(); done = false;
    while ~done
        state_key = boardToState_struct(board); valid