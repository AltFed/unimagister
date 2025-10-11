% runTestSession.m
% Versione 4: Aggiunta la modalità di gioco Utente vs. Agente ("me")
clear; clc; close all;

% Carica la Q-Table addestrata
try
    load('master_q_table.mat', 'QTable');
    fprintf('Q-Table caricata con successo!\n');
catch
    error('File q_table_connect4.mat non trovato. Esegui prima lo script di addestramento.');
end

% Inizializzazione delle statistiche per le partite Agente vs. Random
winHistory_vs_Random = [];
rewardHistory_vs_Random = [];
gameCount_vs_Random = 0;

% Loop principale della sessione
while true
    
    % --- Chiedi all'utente la prossima mossa ---
    prompt = '\nScrivi "me" per giocare, un numero (es. 1000) per simulare, "next" per una partita vs Random, o "stop" per terminare: ';
    userInput = input(prompt, 's');
    numGames_sim = str2double(userInput);
    
    % --- Interpreta il comando dell'utente ---
    if strcmpi(userInput, 'stop')
        % Esce dal loop per andare alla sezione grafici
        break;
        
    elseif strcmpi(userInput, 'me')
        % --- Modalità Utente vs. Agente ---
        fprintf('\n--- Inizia la partita contro l''agente! ---\n');
        playAgainstHuman(QTable); % Chiama la funzione locale per la partita
        fprintf('\n--- Partita terminata. Torno al menu principale. ---\n');
        
    elseif ~isnan(numGames_sim) && numGames_sim > 0
        % --- Modalità Simulazione Automatica (Agente vs. Random) ---
        fprintf('\nAvvio simulazione automatica per %d partite. Attendere...\n', numGames_sim);
        tic;
        for i = 1:numGames_sim
            [sim_winner, ~] = playSingleGame(QTable);
            if sim_winner == 1 % Agente
                winHistory_vs_Random(end+1) = 1;
                rewardHistory_vs_Random(end+1) = 100;
            else % Sconfitta o Pareggio
                winHistory_vs_Random(end+1) = 0;
                rewardHistory_vs_Random(end+1) = (sim_winner == 0) * -10 + (sim_winner == 2) * -100;
            end
        end
        elapsedTime = toc;
        fprintf('--- Simulazione Completata in %.2f secondi ---\n', elapsedTime);
        break; % Esce dal loop e va ai grafici
        
    else % Se l'utente scrive "next" o qualsiasi altra cosa
        % --- Modalità Interattiva (Agente vs. Random) ---
        gameCount_vs_Random = gameCount_vs_Random + 1;
        [winner, finalBoard] = playSingleGame(QTable);
        
        plotBoard(finalBoard);
        if winner == 1
            resultMsg = 'Agente ha VINTO';
            winHistory_vs_Random(end+1) = 1;
            rewardHistory_vs_Random(end+1) = 100;
        elseif winner == 2
            resultMsg = 'Agente ha PERSO';
            winHistory_vs_Random(end+1) = 0;
            rewardHistory_vs_Random(end+1) = -100;
        else
            resultMsg = 'PAREGGIO';
            winHistory_vs_Random(end+1) = 0;
            rewardHistory_vs_Random(end+1) = -10;
        end
        fprintf('Risultato Partita #%d vs Random: %s\n', gameCount_vs_Random, resultMsg);
        title(sprintf('Partita #%d vs Random: %s', gameCount_vs_Random, resultMsg));
    end
end

%% Sezione Grafici e Statistiche Finali (Solo per Agente vs. Random)
fprintf('\n--- Sessione Terminata ---\n');
if ~isempty(winHistory_vs_Random)
    totalGamesPlayed = length(winHistory_vs_Random);
    totalWins = sum(winHistory_vs_Random);
    winRate = (totalWins / totalGamesPlayed) * 100;
    
    fprintf('Statistiche finali delle partite Agente vs. Random:\n');
    fprintf('Partite totali giocate: %d\n', totalGamesPlayed);
    fprintf('Vittorie totali dell''agente: %d\n', totalWins);
    fprintf('>> PERCENTUALE DI VITTORIA COMPLESSIVA: %.2f%% <<\n', winRate);
    
    generatePlots(winHistory_vs_Random, rewardHistory_vs_Random);
else
    fprintf('Nessuna partita Agente vs. Random è stata giocata.\n');
end

fprintf('\nScript terminato.\n');


%% --- Funzioni Locali ---

function [winner, board] = playSingleGame(QTable)
    % Gioca una partita Agente (1) vs. Random (2)
    board = createBoard();
    currentPlayer = 1;
    done = false;
    while ~done
        if currentPlayer == 1 % Agente
            state = boardToState(board);
            validMoves = getValidMoves(board);
            if isKey(QTable, state) && ~isempty(validMoves)
                q_values = QTable(state);
                [~, idx] = max(q_values(validMoves));
                action = validMoves(idx);
            else, action = validMoves(randi(length(validMoves))); end
        else % Random
            validMoves = getValidMoves(board);
            action = validMoves(randi(length(validMoves)));
        end
        [board, winner, done] = makeMove(board, action, currentPlayer);
        if ~done, currentPlayer = 3 - currentPlayer; end
    end
end

function playAgainstHuman(QTable)
    % Gestisce una partita Utente vs. Agente
    board = createBoard();
    done = false;
    
    choice = input('Vuoi iniziare tu (1) o l''agente (2)? [1]: ');
    if isempty(choice) || choice ~= 2, humanPlayer = 1; agentPlayer = 2;
    else, humanPlayer = 2; agentPlayer = 1; end
    
    currentPlayer = 1;
    while ~done
        plotBoard(board);
        if currentPlayer == humanPlayer
            title("Tocca a te!");
            validMoves = getValidMoves(board);
            action = -1;
            while ~ismember(action, validMoves)
                prompt = sprintf('Scegli una colonna (Opzioni: %s): ', num2str(validMoves));
                action = input(prompt);
            end
        else % Turno dell'agente
            title("L'agente sta pensando...");
            pause(1);
            state = boardToState(board);
            validMoves = getValidMoves(board);
            if isKey(QTable, state) && ~isempty(validMoves)
                q_values = QTable(state);
                [~, idx] = max(q_values(validMoves));
                action = validMoves(idx);
            else, action = validMoves(randi(length(validMoves))); end
        end
        
        [board, winner, done] = makeMove(board, action, currentPlayer);
        if ~done, currentPlayer = 3 - currentPlayer; end
    end
    
    plotBoard(board);
    if winner == humanPlayer, msgbox('Hai vinto!', 'Congratulazioni');
    elseif winner == agentPlayer, msgbox('Hai perso. L''agente ha vinto.', 'Peccato');
    else, msgbox('Pareggio!', 'Partita Finita'); end
end

function generatePlots(winHistory, rewardHistory)
    % Crea i grafici finali
    gameCount = length(winHistory);
    figure('Name', 'Ricompensa per Partita', 'NumberTitle', 'off');
    plot(rewardHistory, 'b.-');
    title('Andamento Ricompensa (Agente vs. Random)');
    xlabel('Partita'); ylabel('Ricompensa'); grid on;
    
    windowSize = min(50, gameCount);
    movingAvgWinRate = movmean(winHistory, windowSize) * 100;
    
    figure('Name', 'Percentuale di Vittoria', 'NumberTitle', 'off');
    plot(movingAvgWinRate, 'r-', 'LineWidth', 2);
    title(sprintf('Percentuale Vittoria vs. Random (Media Mobile su %d partite)', windowSize));
    xlabel('Partita'); ylabel('Vittoria (%)'); grid on; ylim([0 105]);
end