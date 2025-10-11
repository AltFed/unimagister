% run_advanced_training.m
clear; clc; close all;

%% Definizione dei Parametri di Addestramento

% Strategia 1: "Esplorazione Aggressiva" - Per addestramento contro un avversario debole/casuale
params_vs_random = struct(...
    'learningRate', 0.1, ...
    'discountFactor', 0.9, ...
    'epsilon', 0.8, ...         % Epsilon INIZIALE ALTA per massima esplorazione
    'epsilonDecay', 0.99999, ...  % Decay standard
    'minEpsilon', 0.01);

% Strategia 2: "Raffinamento" - Per addestramento contro un avversario forte
params_vs_agent = struct(...
    'learningRate', 0.05, ...       % Tasso di apprendimento più basso per "aggiustamenti" fini
    'discountFactor', 0.95, ...     % Maggiore importanza alle ricompense future
    'epsilon', 0.4, ...             % Epsilon INIZIALE PIÙ BASSA per sfruttare la conoscenza acquisita
    'epsilonDecay', 0.999995, ...   % Decay PIÙ LENTO per un'esplorazione più lunga e mirata
    'minEpsilon', 0.01);


%% FASE 0: Creazione dell'Agente di Base
fprintf('--- FASE 0: Inizio addestramento agente di base vs. Random ---\n');
base_episodes = 1000000;
QTable_base = train_agent_core(base_episodes, containers.Map, 'random', 1, params_vs_random,0);
save('q_table_base.mat', 'QTable_base');
fprintf('--- FASE 0: Agente di base creato e salvato in q_table_base.mat ---\n\n');


%% FASE 1: Specializzazione degli Agenti vs. Random
agent_vs_random_episodes = 5000000;
fprintf('--- FASE 1: Inizio specializzazione Agente 1 (primo a muovere) ---\n');
QTable_agent1 = train_agent_core(agent_vs_random_episodes, QTable_base, 'random', 1, params_vs_random,12);
save('q_table_agent1_specialized.mat', 'QTable_agent1');
fprintf('--- FASE 1: Agente 1 specializzato e salvato. ---\n\n');

fprintf('--- FASE 1: Inizio specializzazione Agente 2 (secondo a muovere) ---\n');
QTable_agent2 = train_agent_core(agent_vs_random_episodes, QTable_base, 'random', 2, params_vs_random,21);
save('q_table_agent2_specialized.mat', 'QTable_agent2');
fprintf('--- FASE 1: Agente 2 specializzato e salvato. ---\n\n');


%% FASE 2: Addestramento Incrociato (Agenti vs. Agenti)
cross_train_episodes = 1000000;
fprintf('--- FASE 2: Inizio addestramento Agente 1 vs. Agente 2 ---\n');
QTable_agent1_specialized = train_agent_core(cross_train_episodes, QTable_agent1, QTable_agent2, 1, params_vs_agent),212;
save('q_table_agent1_specialized.mat', 'QTable_agent1_specialized');
fprintf('--- FASE 2: Addestramento di Agente 1 completato. ---\n\n');

fprintf('--- FASE 2: Inizio addestramento Agente 2 vs. Agente 1 ---\n');
QTable_agent2_specialized = train_agent_core(cross_train_episodes2, QTable_agent2, QTable_agent1_specialized, 2, params_vs_agent,221);
save('q_table_agent2_specialized.mat', 'QTable_agent2_specialized');
fprintf('--- FASE 2: Addestramento di Agente 2 completato. ---\n\n');

fprintf('TUTTE LE FASI DI ADDESTRAMENTO SONO COMPLETATE!\n');