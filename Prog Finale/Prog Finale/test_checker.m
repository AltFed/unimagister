% Esegui questo nella Command Window o in un nuovo script
clear; clc;

% Stato ESATTO prima della mossa sbagliata dell'AI
s_debug = zeros(6,7);
s_debug(6,1) = 1; % AI
s_debug(6,3) = 1; % AI
s_debug(6,4) = 1; % AI
s_debug(5,2) = 2; % Human
s_debug(4,2) = 2; % Human
s_debug(3,2) = 2; % Human

disp('Scacchiera iniziale del test:');
disp(s_debug);

% Stiamo cercando minacce create dal Giocatore 2 (Human)
colore_minaccia = 2; 

critical_col = find_critical_move(s_debug, colore_minaccia);

fprintf('\nRISULTATO FINALE -> La colonna critica rilevata è: %s\n', mat2str(critical_col));