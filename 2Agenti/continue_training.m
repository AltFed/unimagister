% continue_cross_training.m
% Carica gli agenti 1 e 2 e continua il loro addestramento reciproco.
clear; clc; close all;
%% Definizioni parametri
params_vs_agent = struct(...
    'learningRate', 0.05, ...       % Tasso di apprendimento più basso per "aggiustamenti" fini
    'discountFactor', 0.95, ...     % Maggiore importanza alle ricompense future
    'epsilon', 0.4, ...             % Epsilon INIZIALE PIÙ BASSA per sfruttare la conoscenza acquisita
    'epsilonDecay', 0.999995, ...   % Decay PIÙ LENTO per un'esplorazione più lunga e mirata
    'minEpsilon', 0.01);
%% Carica gli Agenti Esistenti
fprintf('--- Caricamento degli agenti esistenti ---\n');

try
    load('q_table_agent1_final.mat', 'QTable_agent1');
    fprintf('Caricato Agente 1 (primo a muovere).\n');
catch
    error('File "q_table_agent1_final.mat" non trovato. Esegui prima lo script di addestramento completo.');
end

try
    load('q_table_agent2_final.mat', 'QTable_agent2');
    fprintf('Caricato Agente 2 (secondo a muovere).\n');
catch
    error('File "q_table_agent2_final.mat" non trovato. Esegui prima lo script di addestramento completo.');
end

%% Chiedi all'Utente il Numero di Episodi
fprintf('\n');
prompt = 'Inserisci per quanti episodi aggiuntivi vuoi continuare l''addestramento incrociato (es. 500000): ';
cross_train_episodes= input(prompt);

%% Esegui Ciclo di Addestramento Aggiuntivo
fprintf('\n--- Inizio ciclo di addestramento aggiuntivo per %d episodi totali ---\n', cross_train_episodes);
tic;

% 1. L'agente 1 (P1) si allena contro l'agente 2 (P2)
fprintf('Addestramento Agente 1 vs. Agente 2...\n');
QTable_agent1_updated = train_agent_core(cross_train_episodes, QTable_agent1, QTable_agent2, 1, params_vs_agent);

% 2. L'agente 2 (P2) si allena contro la versione aggiornata dell'agente 1 (P1)
fprintf('Addestramento Agente 2 vs. Agente 1 (aggiornato)...\n');
QTable_agent2_updated = train_agent_core(cross_train_episodes, QTable_agent2, QTable_agent1_updated, 2, params_vs_agent);

fprintf('Ciclo di addestramento completato in %.2f minuti.\n', toc/60);

%% Salvataggio dei Progressi
fprintf('Salvataggio dei nuovi pesi...\n');

QTable_agent1 = QTable_agent1_updated;
save('q_table_agent1_final.mat', 'QTable_agent1');

QTable_agent2 = QTable_agent2_updated;
save('q_table_agent2_final.mat', 'QTable_agent2');

fprintf('\nfile aggiornati con successo\n');
