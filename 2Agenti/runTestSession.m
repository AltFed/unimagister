% runTestSession.m
% Versione 7: Corretto il bug nel caricamento della Q-Table.
clear; clc; close all;

%% --- FASE 1: Scelta e Caricamento dell'Agente ---
prompt = 'Cosa vuoi fare? (1: Test Agente 1, 2: Test Agente 2, 3: Confronto automatico di entrambi): ';
agent_choice = input(prompt);

if agent_choice == 1
    agent_role = 1;
    q_table_file = 'q_table_agent1_specialized.mat'; % O q_table_agent1_specialized.mat se non hai ancora la versione final
elseif agent_choice == 2
    agent_role = 2;
    q_table_file = 'q_table_agent2_specialized.mat'; % O q_table_agent2_specialized.mat
else
    % La scelta 3 viene gestita dopo, qui prepariamo per 1 o 2
    agent_role = 0; % Valore sentinella
end

% --- Logica principale basata sulla scelta ---
if agent_role == 1 || agent_role == 2
    % --- Modalità Test Singolo Agente ---
    fprintf('Hai scelto l''Agente %d (specialista della mossa %d).\n', agent_role, agent_role);

    % === BLOCCO DI CARICAMENTO CORRETTO ===
    try
        loaded_data = load(q_table_file); % Carica l'intero contenuto del file in una struct
        field_names = fieldnames(loaded_data); % Trova i nomi delle variabili nel file (dovrebbe essercene solo una)
        QTable = loaded_data.(field_names{1}); % Estrai la prima (e unica) variabile: questa è la nostra Q-Table
        fprintf('Q-Table "%s" caricata con successo!\n', q_table_file);
    catch ME
        fprintf('Errore durante il caricamento del file: %s\n', ME.message);
        error('File Q-Table "%s" non trovato o corrotto. Assicurati di aver completato l''addestramento.', q_table_file);
    end
    % ======================================
    
    % Loop Interattivo
    runInteractiveSession(QTable, agent_role);

elseif agent_choice == 3
    % --- Modalità Confronto Automatico ---
    runComparison();

else
    error('Scelta non valida. Esegui di nuovo e scegli 1, 2, o 3.');
end

fprintf('\nScript terminato.\n');


%% --- Funzioni Locali (invariate) ---

function runInteractiveSession(QTable, agent_role)
    % Gestisce il loop interattivo per un singolo agente
    winHistory_vs_Random = [];
    rewardHistory_vs_Random = [];
    gameCount_vs_Random = 0;

    while true
        prompt = '\nScrivi "me" per giocare, un numero (es. 1000) per simulare, "next" per una partita, o "stop": ';
        userInput = input(prompt, 's');
        numGames_sim = str2double(userInput);

        if strcmpi(userInput, 'stop'), break; end

        if strcmpi(userInput, 'me')
            fprintf('\n--- Inizia la partita contro l''agente! ---\n');
            playAgainstHuman(QTable, agent_role);
            fprintf('\n--- Partita terminata. Torno al menu principale. ---\n');
        elseif ~isnan(numGames_sim) && numGames_sim > 0
            fprintf('\nAvvio simulazione per %d partite...\n', numGames_sim);
            tic;
            for i = 1:numGames_sim
                [sim_winner, ~] = playSingleGame(QTable, agent_role);
                is_win = (sim_winner == agent_role);
                winHistory_vs_Random(end+1) = is_win;
                if is_win, rewardHistory_vs_Random(end+1) = 100;
                elseif sim_winner == 0, rewardHistory_vs_Random(end+1) = -10;
                else, rewardHistory_vs_Random(end+1) = -100; end
            end
            fprintf('--- Simulazione Completata in %.2f secondi ---\n', toc);
            break;
        else % "next"
            gameCount_vs_Random = gameCount_vs_Random + 1;
            [winner, finalBoard] = playSingleGame(QTable, agent_role);
            plotBoard(finalBoard);
            if winner == agent_role, resultMsg = 'Agente ha VINTO';
            elseif winner == 0, resultMsg = 'PAREGGIO';
            else, resultMsg = 'Agente ha PERSO'; end
            fprintf('Risultato Partita #%d vs Random: %s\n', gameCount_vs_Random, resultMsg);
            title(sprintf('Partita #%d vs Random: %s', gameCount_vs_Random, resultMsg));
        end
    end
    
    if ~isempty(winHistory_vs_Random)
        totalGamesPlayed = length(winHistory_vs_Random);
        winRate = (sum(winHistory_vs_Random) / totalGamesPlayed) * 100;
        fprintf('\n--- Statistiche Finali ---\n');
        fprintf('Agente testato: Agente %d\n', agent_role);
        fprintf('Partite totali giocate vs Random: %d\n', totalGamesPlayed);
        fprintf('>> PERCENTUALE DI VITTORIA COMPLESSIVA: %.2f%% <<\n', winRate);
        generatePlots(winHistory_vs_Random, rewardHistory_vs_Random, agent_role);
    end
end

function runComparison()
    fprintf('\n--- Avvio Confronto Agenti vs. Random (1000 partite per agente) ---\n');
    num_games_compare = 1000;

    % Test Agente 1
    fprintf('\nFase 1/2: Test di Agente 1 (primo a muovere)...\n');
    try, loaded_data = load('q_table_agent1_final.mat'); fn = fieldnames(loaded_data); QTable1 = loaded_data.(fn{1});
    catch, error('File per Agente 1 non trovato!'); end
    wins1 = 0;
    for i = 1:num_games_compare
        [winner, ~] = playSingleGame(QTable1, 1);
        if winner == 1, wins1 = wins1 + 1; end
    end
    win_rate1 = (wins1 / num_games_compare) * 100;

    % Test Agente 2
    fprintf('Fase 2/2: Test di Agente 2 (secondo a muovere)...\n');
    try, loaded_data = load('q_table_agent2_final.mat'); fn = fieldnames(loaded_data); QTable2 = loaded_data.(fn{1});
    catch, error('File per Agente 2 non trovato!'); end
    wins2 = 0;
    for i = 1:num_games_compare
        [winner, ~] = playSingleGame(QTable2, 2);
        if winner == 2, wins2 = wins2 + 1; end
    end
    win_rate2 = (wins2 / num_games_compare) * 100;

    fprintf('\n\n--- RISULTATI CONFRONTO FINALE ---\n');
    fprintf('Agente 1 (vs Random, come P1): %.2f%% di vittorie\n', win_rate1);
    fprintf('Agente 2 (vs Random, come P2): %.2f%% di vittorie\n', win_rate2);
    fprintf('--------------------------------------\n');
end

function [winner, board] = playSingleGame(QTable, agent_role)
    board = createBoard(); done = false; turn = 1;
    while ~done
        if mod(turn, 2) == 1, currentPlayer = 1; else, currentPlayer = 2; end
        validMoves = getValidMoves(board);
        if isempty(validMoves), winner = 0; done = true; continue; end
        
        if currentPlayer == agent_role % Turno dell'Agente
            state = boardToState(board);
            if isKey(QTable, state)
                q_values = QTable(state);
                valid_q = -inf(1,7); valid_q(validMoves) = q_values(validMoves);
                [~, action] = max(valid_q);
            else, action = validMoves(randi(length(validMoves))); end
        else % Turno del Giocatore Random
            action = validMoves(randi(length(validMoves)));
        end
        [board, winner, done] = makeMove(board, action, currentPlayer);
        turn = turn + 1;
    end
end

function playAgainstHuman(QTable, agent_role)
    board = createBoard(); done = false; turn = 1;
    if agent_role == 1, agentPlayer = 1; humanPlayer = 2;
        fprintf('L''agente è specializzato per la prima mossa, quindi inizierà lui.\n');
    else, agentPlayer = 2; humanPlayer = 1;
        fprintf('L''agente è specializzato per la seconda mossa, quindi inizierai tu.\n');
    end
    while ~done
        plotBoard(board);
        if mod(turn, 2) == 1, currentPlayer = 1; else, currentPlayer = 2; end
        if currentPlayer == humanPlayer
            title("Tocca a te!"); action = -1;
            while ~ismember(action, getValidMoves(board))
                prompt = sprintf('Scegli una colonna (Opzioni: %s): ', num2str(getValidMoves(board)));
                action = input(prompt);
            end
        else % Turno dell'agente
            title("L'agente sta pensando..."); pause(1);
            state = boardToState(board); validMoves = getValidMoves(board);
            if isKey(QTable, state)
                q_values = QTable(state); valid_q = -inf(1,7);
                valid_q(validMoves) = q_values(validMoves);
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