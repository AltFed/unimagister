function QTable = train_agent_core(num_episodes, starting_QTable, opponent, agent_player_id, params,phase)
    % Estrai i parametri dalla struct
    learningRate = params.learningRate;
    discountFactor = params.discountFactor;
    epsilon = params.epsilon; % Epsilon iniziale
    epsilonDecay = params.epsilonDecay;
    minEpsilon = params.minEpsilon;

    QTable = starting_QTable;

    % Ciclo di addestramento
    for episode = 1:num_episodes
        board = createBoard();
        done = false;
        if(mod(episode,1000)== 0)
            clc;
            fprintf("Episodio numero %d, phase: %d \n",episode,phase);
        end 
        % Determina chi inizia
        if agent_player_id == 1
            players = [1, 2]; % Agente, Avversario
        else
            players = [2, 1]; % Avversario, Agente
        end

        turn = 1;
        while ~done
            currentPlayer = players(mod(turn-1, 2) + 1);
            
            if currentPlayer == agent_player_id
                % --- Turno dell'Agente che si sta allenando ---
                state = boardToState(board);
                validMoves = getValidMoves(board);
                if ~isKey(QTable, state), QTable(state) = zeros(1, 7); end
                
                if rand() < epsilon
                    action = validMoves(randi(length(validMoves)));
                else
                    q_vals = QTable(state); valid_q = -inf(1,7);
                    valid_q(validMoves) = q_vals(validMoves);
                    [~, action] = max(valid_q);
                end
                [board, winner, done] = makeMove(board, action, currentPlayer);
                
                % Calcolo ricompensa parziale
                if winner == agent_player_id, reward = 100;
                elseif done, reward = -10;
                else, reward = -1; end % Piccola penalità per ogni mossa

            else
                % --- Turno dell'Avversario ---
                validMoves_opp = getValidMoves(board);
                if isa(opponent, 'containers.Map') % Avversario Agente
                    state_opp = boardToState(board);
                    if isKey(opponent, state_opp) && rand() > 0.05
                        q_vals_opp = opponent(state_opp); valid_q_opp = -inf(1,7);
                        valid_q_opp(validMoves_opp) = q_vals_opp(validMoves_opp);
                        [~, action_opp] = max(valid_q_opp);
                    else, action_opp = validMoves_opp(randi(length(validMoves_opp))); end
                else % Avversario 'random'
                    action_opp = validMoves_opp(randi(length(validMoves_opp)));
                end
                [board, winner, done] = makeMove(board, action_opp, currentPlayer);
                
                % Aggiorna la ricompensa se l'agente ha perso
                if winner ~= 0, reward = -100; end
            end
            
            % Aggiornamento Q-Table (solo dopo la mossa dell'agente)
            if currentPlayer == agent_player_id
                nextState = boardToState(board);
                if ~isKey(QTable, nextState), QTable(nextState) = zeros(1, 7); end
                max_next_q = ifthen(done, 0, max(QTable(nextState)));
                current_q = QTable(state);
                current_q(action) = current_q(action) + learningRate * (reward + discountFactor * max_next_q - current_q(action));
                QTable(state) = current_q;
            end

            turn = turn + 1;
        end
        epsilon = max(minEpsilon, epsilon * epsilonDecay);
        if mod(episode, 100000) == 0
            fprintf('... episodio %d/%d (epsilon: %.4f)\n', episode, num_episodes, epsilon);
        end
    end
end
function result = ifthen(condition, true_val, false_val)
    if condition, result = true_val; else, result = false_val; end
end