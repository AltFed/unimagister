clear all
close all
clc

rng(1) % set the random seed

A = 5; % dimension action space
alpha = 1e-2; % update step for preferences
beta = 1e-1; % update step for rewards
lengthEpisode = 20000; % number of actions to take

H = zeros(A, 1); % preferences of actions
avg_r = 0; % initialization of average reward

% save history of H
historyH = zeros(A, lengthEpisode);

for i = 1:lengthEpisode
    Proba = exp(H)/sum(exp(H));
    csProba = cumsum(Proba);
    a = find(rand < csProba, 1, "first");
    r =player(a); 
    H(a) = H(a) + alpha*(r - avg_r)*(1-Proba(a));
    nota = 1:A;
    nota(a) = [];
    H(nota) = H(nota) - alpha*(r - avg_r)*Proba(nota);
    avg_r = avg_r + beta*(r-avg_r); % constant step for averagin rewards

    % save the history
    historyH(:,i) = H;
end

%% plots

% plot the history of Q
figure()
plot(historyH','LineWidth',2)
title('preference updates')