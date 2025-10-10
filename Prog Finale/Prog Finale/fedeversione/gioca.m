% ============== SCRIPT PER GIOCARE CONTRO L'IA ALLENATA ==============
clear all;
close all;
clc;

%% 1. Carica i Pesi dell'Agente Allenato
% Questo comando cerca il file 'agente_singolo.mat' nella stessa cartella
% e carica la variabile 'w' (la matrice dei pesi) nel workspace.
try
    load('agente_singolo.mat');
    fprintf('Pesi dell''agente caricati con successo!\n');
catch
    error('File "agente_singolo.mat" non trovato. Assicurati di aver completato l''addestramento o che il file sia nella stessa cartella.');
end


%% 2. Inizializzazione della Partita
A = 7; % Numero di azioni

fprintf('\n--- Inizia la partita contro l''AI ---\n');
fprintf('Tu sei il giocatore O (rosso), l''AI è il giocatore X (nero).\n');
fprintf('L''AI farà la prima mossa.\n');
pause(2); % Pausa per leggere le istruzioni

s = zeros(6,7);
possib = ones(1,7);
isTerminal = false;

%% 3. Ciclo di Gioco (Tu vs. AI)
while ~isTerminal
    % ---------------------------------
    % TURNO DELL'AGENTE AI (Giocatore 1)
    % ---------------------------------
    
    % Calcola le features per lo stato attuale
    Fac = Features(s, 1);
    
    % Calcola i valori Q per tutte le azioni
    Q = w' * Fac;
    
    % Scegli l'azione migliore (greedy, senza esplorazione)
    vec = possibleaction(possib);
    [~, best_action_index] = max(Q(vec));
    a = vec(best_action_index);
    
    fprintf('L''AI sceglie la colonna %d...\n', a);

    % ----------------------------------------------------------------
    % ESECUZIONE DEL TURNO (AI + UMANO) TRAMITE grid3.m
    % ----------------------------------------------------------------
    [possib, s, r, isTerminal] = grid3(possib, s, a);
    
    % Mostra la scacchiera aggiornata dopo la tua mossa
    clf;
    temp_board = swapRows(s);
    in_board(temp_board, 7, 6);
    
    % Controlla l'esito della partita
    if isTerminal
        if r == 1
            disp('L''AI ha vinto!');
        elseif r == -1
            disp('Hai vinto! Complimenti!');
        else
            disp('Pareggio!');
        end
    end
end