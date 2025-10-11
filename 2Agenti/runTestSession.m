% runTestSession.m
% Versione 5: Selezione dell'agente (1 o 2) e rispetto del ruolo specializzato.
clear; clc; close all;

%% --- FASE 1: Scelta e Caricamento dell'Agente ---
agent_choice = input('Quale agente vuoi testare? (1 per il primo giocatore, 2 per il secondo): ');

if agent_choice == 1
    agent_role = 1;
    q_table_file = 'q_table_agent1_specialized.mat';
    fprintf('Hai scelto l''Agente 1 (specialista della prima mossa).\n');
elseif agent_choice == 2
    agent_role = 2;
    q_table_file = 'q_table_agent2_specialized.mat';
    fprintf('Hai scelto l''Agente 2 (specialista della seconda mossa).\n');
else
    error('Scelta non valida');
end

try
    load(q_table_file, 'QTable');
    fprintf('Q-Table "%s" caricata con successo!\n', q_table_file);
catch
    error('File Q-Table "%s" non trovato', q_table_file);
end

%% --- FASE 2: Loop Principale della Sessione ---
winHistory_vs_Random = [];
rewardHistory_vs_Random = [];
gameCount_vs_Random = 0;

while true
    prompt = '\nScrivi "me" per giocare, un numero (es. 1000) per simulare, "next" per una partita vs Random, o "stop": ';
    userInput = input(prompt, 's');
    numGames_sim = str2double(userInput);
    
    if strcmpi(userInput, 'stop'), break; end
        
    if strcmpi(userInput, 'me')
        % --- Modalità Utente vs. Agente ---
        fprintf('\n--- Inizia la partita contro l''agente! ---\n');
        playAgainstHuman(QTable, agent_role); % Passa il ruolo dell'agente
        fprintf('\n--- Partita terminata. Torno al menu principale. ---\n');
        
    elseif ~isnan(numGames_sim) && numGames_sim > 0
        % --- Modalità Simulazione Automatica (Agente vs. Random) ---
        fprintf('\nAvvio simulazione automatica per %d partite. Attendere...\n', numGames_sim);
        tic;
        for i = 1:numGames_sim
            [sim_winner, ~] = playSingleGame(QTable, agent_role); % Passa il ruolo dell'agente
            
            % Aggiorna le statistiche in base al ruolo
            if sim_winner == agent_role
                winHistory_vs_Random(end+1) = 1;
                rewardHistory_vs_Random(end+1) = 100;
            elseif sim_winner == 0
                winHistory_vs_Random(end+1) = 0;
                rewardHistory_vs_Random(end+1) = -10;
            else % L'agente ha perso
                winHistory_vs_Random(end+1) = 0;
                rewardHistory_vs_Random(end+1) = -100;
            end
        end
        elapsedTime = toc;
        fprintf('--- Simulazione Completata in %.2f secondi ---\n', elapsedTime);
        break; % Esce dal loop e va ai grafici
        
    else % "next"
        % --- Modalità Interattiva (Agente vs. Random) ---
        gameCount_vs_Random = gameCount_vs_Random + 1;
        [winner, finalBoard] = playSingleGame(QTable, agent_role); % Passa il ruolo
        
        plotBoard(finalBoard);
        if winner == agent_role
            resultMsg = 'Agente ha VINTO';
            winHistory_vs_Random(end+1) = 1;
            rewardHistory_vs_Random(end+1) = 100;
        elseif winner == 0
            resultMsg = 'PAREGGIO';
            winHistory_vs_Random(end+1) = 0;
            rewardHistory_vs_Random(end+1) = -10;
        else
            resultMsg = 'Agente ha PERSO';
            winHistory_vs_Random(end+1) = 0;
            rewardHistory_vs_Random(end+1) = -100;
        end
        fprintf('Risultato Partita #%d vs Random: %s\n', gameCount_vs_Random, resultMsg);
        title(sprintf('Partita #%d vs Random: %s', gameCount_vs_Random, resultMsg));
    end
end

%% --- FASE 3: Grafici e Statistiche Finali ---
fprintf('\n--- Sessione Terminata ---\n');
if ~isempty(winHistory_vs_Random)
    totalGamesPlayed = length(winHistory_vs_Random);
    totalWins = sum(winHistory_vs_Random);
    winRate = (totalWins / totalGamesPlayed) * 100;
    
    fprintf('Statistiche finali delle partite Agente vs. Random:\n');
    fprintf('Agente testato: Agente %d\n', agent_role);
    fprintf('Partite totali giocate: %d\n', totalGamesPlayed);
    fprintf('Vittorie totali: %.2f%% <<\n', winRate);
    
    generatePlots(winHistory_vs_Random, rewardHistory_vs_Random, agent_role);
else
    fprintf('Nessuna partita Agente vs. Random è stata giocata.\n');
end
fprintf('\nScript terminato.\n');

%% --- Funzioni Locali Modificate ---

function [winner, board] = playSingleGame(QTable, agent_role)
    % Gioca una partita Agente vs. Random rispettando il ruolo.
    board = createBoard();
    done = false;
    turn = 1;
    
    while ~done
        % Determina chi gioca in questo turno
        if mod(turn, 2) == 1, currentPlayer = 1; else, currentPlayer = 2; end
        
        if currentPlayer == agent_role
            % --- Turno dell'Agente ---
            state = boardToState(board);
            validMoves = getValidMoves(board);
            if isKey(QTable, state) && ~isempty(validMoves)
                q_values = QTable(state);
                valid_q = -inf(1,7); valid_q(validMoves) = q_values(validMoves);
                [~, action] = max(valid_q);
            else, action = validMoves(randi(length(validMoves))); end
        else
            % --- Turno del Giocatore Random ---
            validMoves = getValidMoves(board);
            action = validMoves(randi(length(validMoves)));
        end
        
        [board, winner, done] = makeMove(board, action, currentPlayer);
        turn = turn + 1;
    end
end

function playAgainstHuman(QTable, agent_role)
    % Gestisce una partita Utente vs. Agente rispettando il ruolo.
    board = createBoard();
    done = false;
    turn = 1;

    % Assegna i ruoli in base alla scelta iniziale, senza chiederlo di nuovo
    if agent_role == 1
        agentPlayer = 1; humanPlayer = 2;
        fprintf('L''agente è specializzato per la prima mossa, quindi inizierà lui.\n');
    else
        agentPlayer = 2; humanPlayer = 1;
        fprintf('L''agente è specializzato per la seconda mossa, quindi inizierai tu.\n');
    end
    
    while ~done
        plotBoard(board);
        if mod(turn, 2) == 1, currentPlayer = 1; else, currentPlayer = 2; end
        
        if currentPlayer == humanPlayer
            title("Tocca a te!");
            validMoves = getValidMoves(board);
            action = -1;
            while ~ismember(action, validMoves)
                prompt = sprintf('Scegli una colonna (Opzioni: %s): ', num2str(validMoves));
                action = input(prompt);
            end
        else % Turno dell'agente
            title("L'agente sta pensando..."); pause(1);
            state = boardToState(board);
            validMoves = getValidMoves(board);
            if isKey(QTable, state) && ~isempty(validMoves)
                q_values = QTable(state);
                valid_q = -inf(1,7); valid_q(validMoves) = q_values(validMoves);
                [~, action] = max(valid_q);
            else, action = validMoves(randi(length(validMoves))); end
        end
        
        [board, winner, done] = makeMove(board, action, currentPlayer);
        turn = turn + 1;
    end
    
    plotBoard(board);
    if winner == humanPlayer, msgbox('Hai vinto!', 'Congratulazioni');
    elseif winner == agentPlayer, msgbox('Hai perso. L''agente ha vinto.', 'Peccato');
    else, msgbox('Pareggio!', 'Partita Finita'); end
end

function generatePlots(winHistory, rewardHistory, agent_role)
    % Crea i grafici finali
    gameCount = length(winHistory);
    figure('Name', 'Ricompensa per Partita', 'NumberTitle', 'off');
    plot(rewardHistory, 'b.-');
    title(sprintf('Andamento Ricompensa (Agente %d vs. Random)', agent_role));
    xlabel('Partita'); ylabel('Ricompensa'); grid on;
    
    windowSize = min(50, gameCount);
    movingAvgWinRate = movmean(winHistory, windowSize) * 100;
    
    figure('Name', 'Percentuale di Vittoria', 'NumberTitle', 'off');
    plot(movingAvgWinRate, 'r-', 'LineWidth', 2);
    title(sprintf('Percentuale Vittoria Agente %d vs. Random (Media Mobile)', agent_role));
    xlabel('Partita'); ylabel('Vittoria (%)'); grid on; ylim([0 105]);
end