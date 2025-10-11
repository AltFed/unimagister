% test_agent.m
% Script unico per testare l'agente addestrato.
clear; clc; close all;

%% Caricamento Agente
try
    loaded_data = load('q_table.mat');
    QTable = loaded_data.QTable;
    fprintf('Q-Table "q_table.mat" (struct) caricata con successo!\n');
catch ME
    error('File "q_table.mat" non trovato. Esegui prima lo script train_agent.m. Errore: %s', ME.message);
end

%% Loop Interattivo
winHistory = []; rewardHistory = [];
while true
    prompt = '\nScrivi "me" per giocare, un numero (es. 1000) per una simulazione, o "stop": ';
    userInput = input(prompt, 's');
    numGames_sim = str2double(userInput);
    if strcmpi(userInput, 'stop'), break; end

    if strcmpi(userInput, 'me')
        playAgainstHuman(QTable);
    elseif ~isnan(numGames_sim) && numGames_sim > 0
        fprintf('\nAvvio simulazione per %d partite...\n', numGames_sim); tic;
        for i = 1:numGames_sim
            [winner, ~] = playSingleGame(QTable);
            is_win = (winner == 1);
            winHistory(end+1) = is_win;
            if is_win, rewardHistory(end+1) = 100;
            elseif winner == 0, rewardHistory(end+1) = -10;
            else, rewardHistory(end+1) = -100; end
        end
        fprintf('--- Simulazione Completata in %.2f secondi ---\n', toc); break;
    else, fprintf('Input non valido.\n'); end
end

%% Grafici
if ~isempty(winHistory)
    winRate = (sum(winHistory) / length(winHistory)) * 100;
    fprintf('\n--- Statistiche Finali ---\n');
    fprintf('Partite giocate vs Random: %d\n', length(winHistory));
    fprintf('>> PERCENTUALE DI VITTORIA: %.2f%% <<\n', winRate);
    generatePlots(winHistory, rewardHistory);
end
fprintf('\nScript terminato.\n');


%% --- FUNZIONI LOCALI (SCRIPT AUTONOMO) ---

function [winner, board] = playSingleGame(QTable)
    board = createBoard(); done = false; turn = 1;
    while ~done
        if mod(turn, 2) == 1, currentPlayer = 1; else, currentPlayer = 2; end
        validMoves = getValidMoves(board);
        if isempty(validMoves), winner = 0; done = true; continue; end
        if currentPlayer == 1 % Agente
            state_key = boardToState_struct(board);
            if isfield(QTable, state_key)
                q_values = QTable.(state_key); valid_q = -inf(1,7,'single');
                valid_q(validMoves) = q_values(validMoves);
                [~, action] = max(valid_q);
            else, action = validMoves(randi(length(validMoves))); end
        else % Random
            action = validMoves(randi(length(validMoves)));
        end
        [board, winner, done] = makeMove(board, action, currentPlayer);
        turn = turn + 1;
    end
end

function playAgainstHuman(QTable)
    board = createBoard(); done = false; turn = 1;
    choice = input('Vuoi iniziare tu (1) o l''agente (2)? [2]: ');
    if choice == 1, humanPlayer = 1; agentPlayer = 2; else, humanPlayer = 2; agentPlayer = 1; end
    
    while ~done
        plotBoard(board);
        if mod(turn, 2) == 1, currentPlayer = 1; else, currentPlayer = 2; end
        if currentPlayer == humanPlayer
            title("Tocca a te!"); action = -1;
            validMoves = getValidMoves(board);
            while ~ismember(action, validMoves), action = input(sprintf('Scegli colonna (%s): ', num2str(validMoves))); end
        else % Agente
            title("L'agente sta pensando..."); pause(1);
            state_key = boardToState_struct(board);
            validMoves = getValidMoves(board);
            if isfield(QTable, state_key)
                q_values = QTable.(state_key); valid_q = -inf(1,7,'single');
                valid_q(validMoves) = q_values(validMoves);
                [~, action] = max(valid_q);
            else, action = validMoves(randi(length(validMoves))); end
        end
        [board, winner, done] = makeMove(board, action, currentPlayer);
        turn = turn + 1;
    end
    plotBoard(board);
    if winner == humanPlayer, msgbox('Hai vinto!');
    elseif winner == agentPlayer, msgbox('Hai perso.'); else, msgbox('Pareggio!'); end
end

function generatePlots(winHistory, rewardHistory)
    figure('Name', 'Ricompensa per Partita');
    plot(rewardHistory, 'b.-'); title('Andamento Ricompensa vs. Random');
    xlabel('Partita'); ylabel('Ricompensa'); grid on;
    windowSize = min(50, length(winHistory));
    movingAvgWinRate = movmean(winHistory, windowSize) * 100;
    figure('Name', 'Percentuale di Vittoria');
    plot(movingAvgWinRate, 'r-', 'LineWidth', 2);
    title(sprintf('Percentuale Vittoria vs. Random (Media Mobile su %d partite)', windowSize));
    xlabel('Partita'); ylabel('Vittoria (%)'); grid on; ylim([0 105]);
end

function state_key = boardToState_struct(board)
    state_key = ['s' sprintf('%d', board(:))];
end

function board = createBoard()
    board = zeros(6, 7);
end

function validMoves = getValidMoves(board)
    validMoves = find(board(1, :) == 0);
end

function [newBoard, winner, isDone] = makeMove(board, column, player)
    newBoard = board; winner = 0; isDone = false;
    if column < 1 || column > 7 || board(1, column) ~= 0, return; end
    row = find(newBoard(:, column) == 0, 1, 'last');
    newBoard(row, column) = player;
    if checkWin(newBoard, row, column, player), winner = player; isDone = true;
    elseif isempty(getValidMoves(newBoard)), isDone = true; end
end

function isWin = checkWin(board, r, c, player)
    isWin = false;
    p_str = repmat(char(player+'0'), 1, 4);
    % Orizzontale
    if ~isempty(strfind(char(board(r,:)+'0'), p_str)), isWin = true; return; end
    % Verticale
    if ~isempty(strfind(char(board(:,c)+'0')', p_str)), isWin = true; return; end
    % Diagonale \
    diag1 = diag(board, c-r);
    if ~isempty(strfind(char(diag1+'0')', p_str)), isWin = true; return; end
    % Diagonale /
    diag2 = diag(fliplr(board), (size(board,2)-c+1)-r);
    if ~isempty(strfind(char(diag2+'0')', p_str)), isWin = true; return; end
end

function plotBoard(board)
    fig = findobj('Tag', 'Connect4GUI');
    if isempty(fig), fig = figure('Name', 'Forza 4', 'NumberTitle', 'off', 'Tag', 'Connect4GUI'); end
    clf(fig); rows = 6; cols = 7;
    rectangle('Position', [0, 0, cols, rows], 'FaceColor', [0.1 0.4 0.8]);
    axis equal; axis([0 cols 0 rows]); set(gca, 'XTick', [], 'YTick', []); hold on;
    for r_idx = 1:rows
        for c_idx = 1:cols
            player = board(r_idx, c_idx); centerX = c_idx - 0.5; centerY = (rows - r_idx) + 0.5;
            if player == 0, color = [1 1 1];
            elseif player == 1, color = [1 0.2 0.2];
            else, color = [1 1 0.2]; end
            rectangle('Position', [centerX-0.4, centerY-0.4, 0.8, 0.8], ...
                      'Curvature', [1, 1], 'FaceColor', color);
        end
    end
    hold off; drawnow;
end