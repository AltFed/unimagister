% createWeightsSurfPlot.m
clear; clc; close all;

% Carica la Q-Table addestrata
try
    load('master_q_table.mat', 'QTable');
    fprintf('Q-Table caricata con successo!\n');
catch
    error('File q_table_connect4.mat non trovato. Esegui prima lo script di addestramento.');
end

% Estrai tutti gli stati e i Q-valori dalla mappa
states = keys(QTable);
all_q_values = values(QTable);

fprintf('Raggruppando %d pesi in base al progresso della partita...\n', length(states));

% Inizializza una cella per raggruppare i Q-valori.
% L'indice della cella corrisponde al numero di pedine sulla scacchiera (da 1 a 42).
q_groups = cell(1, 42);

% Itinera attraverso ogni stato salvato
for i = 1:length(states)
    % Ricostruisci la scacchiera e calcola il numero di pedine
    board = reshape(str2num(states{i}), [6, 7]);
    num_pieces = sum(board(:) ~= 0);
    
    if num_pieces > 0
        % Aggiungi il vettore dei Q-valori (1x7) al gruppo corrispondente
        q_groups{num_pieces} = [q_groups{num_pieces}; all_q_values{i}];
    end
end

% Calcola la media dei Q-valori per ogni fase della partita e per ogni azione
Z_data = zeros(42, 7); % Matrice per i dati del grafico Z
for i = 1:42
    if ~isempty(q_groups{i})
        % Calcola la media per ogni colonna (azione)
        Z_data(i, :) = mean(q_groups{i}, 1);
    end
end

% Sostituiamo gli zeri con NaN per non plottarli e rendere il grafico più pulito.
Z_data(Z_data == 0) = NaN;

% Crea gli assi X e Y per il grafico
[X, Y] = meshgrid(1:7, 1:42); % X: Azioni (colonne), Y: Progresso (n. pedine)

% Crea il grafico surf
figure('Name', 'Valori dei Pesi (Q-Values) per Azione e Fase di Gioco', 'NumberTitle', 'off');

% === RIGA CORRETTA ===
% Ho rimosso la trasposizione (') da Z_data
surf(X, Y, Z_data);
% =====================

% Migliora l'aspetto del grafico
shading interp; % Rende la superficie più liscia
colorbar;
xlabel("Azione (Colonna)");
ylabel("Progresso della Partita (Numero di Pedine)");
zlabel("Peso Medio (Q-Value)");
title("Evoluzione della Strategia dell'Agente");
view(30, 45); % Imposta un angolo di visuale gradevole
grid on;

fprintf('Grafico dei pesi generato.\n');