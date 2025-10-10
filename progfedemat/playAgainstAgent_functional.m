% playAgainstAgent_functional.m
clear; clc; close all;

% Carica la Q-Table addestrata
try
    load('q_table_connect4.mat', 'QTable');
    fprintf('Q-Table caricata con successo!\n');
catch
    error('File q_table_connect4.mat non trovato. Esegui prima `trainAgent_functional`.');
end

% Inizializza il gioco
board = createBoard();
humanPlayer = 1;
agentPlayer = 2;
currentPlayer = humanPlayer;
done = false;

fprintf('Inizia la partita! Tu sei il giocatore Rosso.\n');

while ~done
    plotBoard(board); % Mostra la scacchiera

    if currentPlayer == humanPlayer
        % Turno dell'umano
        validMoves = getValidMoves(board);
        action = 0;
        while ~ismember(action, validMoves)
            prompt = sprintf('Tocca a te. Scegli una colonna (Opzioni: %s): ', num2str(validMoves));
            action = input(prompt);
        end
        [board, winner, done] = makeMove(board, action, currentPlayer);
        if ~done, currentPlayer = agentPlayer; end
    else
        % Turno dell'agente
        fprintf('L''agente sta pensando...\n');
        pause(1);
        
        state = boardToState(board);
        validMoves = getValidMoves(board);
        
        if isKey(QTable, state) && ~isempty(validMoves)
            q_values = QTable(state);
            [~, sorted_indices] = sort(q_values(validMoves), 'descend');
            action = validMoves(sorted_indices(1));
        else
            fprintf('Stato non conosciuto, l''agente esegue una mossa casuale.\n');
            action = validMoves(randi(length(validMoves)));
        end
        [board, winner, done] = makeMove(board, action, currentPlayer);
        if ~done, currentPlayer = humanPlayer; end
    end

    % Controlla lo stato della partita
    if done
        plotBoard(board);
        if winner == humanPlayer
            msgbox('Hai vinto!', 'Congratulazioni');
        elseif winner == agentPlayer
            msgbox('Hai perso. L''agente ha vinto.', 'Peccato');
        else
            msgbox('Pareggio!', 'Partita finita');
        end
    end
end
