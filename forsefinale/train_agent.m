% train_agent.m
% Versione con la correzione del bug sull'aggiornamento di rewardHistory.
clear; clc; close all;

%% Parametri
params = struct(...
    'learningRate', 0.1, ...
    'discountFactor', 0.9, ...
    'epsilon', 0.9, ...
    'epsilonDecay', 0.99995, ...
    'minEpsilon', 0.01);

episodes = 5000000; % Numero di partite di addestramento vs. Random

% Inizializzazione Q-Table (come struct) e storico
QTable = struct();
rewardHistory = zeros(1, episodes);

%% Ciclo di Addestramento
fprintf('--- Inizio Addestramento per %d episodi ---\n', episodes);
tic;
for episode = 1:episodes
    board = createBoard();
    done = false;

    while ~done
        % --- Turno dell'Agente (Giocatore 1) ---
        state_key = boardToState_struct(board);
        validMoves = getValidMoves(board);
        if ~isfield(QTable, state_key), QTable.(state_key) = single(zeros(1, 7)); end
        
        if rand() < params.epsilon
            action = validMoves(randi(length(validMoves)));
        else
            q_values = QTable.(state_key);
            valid_q = -inf(1,7,'single');
            valid_q(validMoves) = q_values(validMoves);
            [~, action] = max(valid_q);
        end
        [board, winner, done] = makeMove(board, action, 1);
        
        % Calcolo Ricompensa
        if winner == 1, reward = 100;
        elseif done, reward = -10;
        else
            reward = -1;
            % Turno Avversario Casuale
            oppValidMoves = getValidMoves(board);
            if ~isempty(oppValidMoves)
                oppAction = oppValidMoves(randi(length(oppValidMoves)));
                [board, winner, done] = makeMove(board, oppAction, 2);
                if winner == 2, reward = -100; end
            else
                done = true; reward = -10; 
            end
        end

        % Aggiornamento Q-Table
        next_state_key = boardToState_struct(board);
        if ~isfield(QTable, next_state_key), QTable.(next_state_key) = single(zeros(1, 7)); end
        max_next_q = ifthen(done, 0, max(QTable.(next_state_key)));
        current_q = QTable.(state_key);
        current_q(action) = current_q(action) + params.learningRate * (reward + params.discountFactor * max_next_q - current_q(action));
        QTable.(state_key) = current_q;
        
        % === RIGA CORRETTA ===
        % Registra la ricompensa finale del turno per l'analisi.
        % La complessa condizione 'if' è stata rimossa perché non necessaria.
        rewardHistory(episode) = reward;
        % =====================
    end
    params.epsilon = max(params.minEpsilon, params.epsilon * params.epsilonDecay);
    if mod(episode, 1000) == 0, fprintf('Episodio: %d/%d\n', episode, episodes); end
end
fprintf('Addestramento completato in %.2f minuti.\n', toc/60);

%% Grafici e Salvataggio
figure('Name', 'Ricompensa Media');
plot(smoothdata(rewardHistory, 'movmean', 1000));
title('Ricompensa Media Mobile'); xlabel('Episodio'); ylabel('Ricompensa'); grid on;
save('q_table.mat', 'QTable');
fprintf('Q-Table (struct) addestrata e salvata in "q_table.mat"\n');

%% --- Funzioni Locali ---
function state_key = boardToState_struct(board)
    state_key = ['s' sprintf('%d', board(:))];
end
function result = ifthen(condition, true_val, false_val)
    if condition, result = true_val; else, result = false_val; end
end