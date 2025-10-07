clear all
close all
clc

rng(2) % set the random seed

A = 5; % dimension action space
epsilon = 0.2; % probability we take a random action
lengthEpisode = 1000; % number of actions to take
alpha = 0.01; % step size

q = zeros(A, 1); % initial value of the bandit
Q = ones(A, 1); % estimate of the value of actions
N = zeros(A, 1); % number of times we take each action

% save history of Q and N
historyq = zeros(A, lengthEpisode);
historyQ = zeros(A, lengthEpisode);
historyN = zeros(A, lengthEpisode);

for i = 1:lengthEpisode
    if rand < epsilon
        a = randi(A); % we take a random action
    else
        % to break parity
        a = find(Q == max(Q), 1, 'first');  % either we take the one with lower index
        % a = find(Q == max(Q)); % list all optimal actions;
        % a = a(randi(length(a))); % take a random action among the optimal ones
    end
    [r] = player(a); 
    N(a) = N(a) + 1; % increment the counter for the actions taken
    q(a) = q(a) + 1/N(a)*(r - q(a)); % average updates
    Q(a) = Q(a) + alpha*(r - Q(a)); % constant updates

    % save the history
    historyq(:,i) = q;
    historyQ(:,i) = Q;
    historyN(:, i) = N;
end

%% plots
% plot the history of q
figure()
plot(historyq','LineWidth',2)
legend('1','2','3','4','5','fontsize',24)
% title('azioni prese con constant updates')
% plot the history of Q
figure()
plot(historyQ','LineWidth',2)
legend('1','2','3','4','5','fontsize',24)
title('valore associato al giocatore 1')
% plot the history of N
figure()
plot(historyN','LineWidth',2)
legend('1','2','3','4','5','fontsize',24)

% convergence of Q for number of episodes tending to infinity