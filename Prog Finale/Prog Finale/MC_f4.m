clear all
close all
clc
% number of actions
A = 7;
% number of episodes
numEpisodes = 10000;
% exploration parameter
epsilon = 0.2;
% foresight parameter
gamma = 0.8;
% update parameter
% alpha = 1e-5; % implementato dinamicamente
% eligibility traces parameter
lambda = 0.95;
% dimension of the weight vector
d = 244;
% variabile per determinare il valore migliore
Arr_win_rate=[];
Var={};
k=0;
%% Cerco le variabili migliori
fprintf("Avvio la ricerca dei valori migliori:")
% for epsilon=0.2:0.1:0.6
%     for gamma=0.7:0.1:0.9
%         for lambda=0.5:0.1:0.8
            Var=[Var,{{epsilon,gamma,lambda}}];
            k=k+1;
            fprintf("Iter %d\n ",k);
            %% Player 1 policy
            % initialize the weigth vector
            w = zeros(d,A);
            Rate=[0 0 0];
            Win_Rate=[];
            % total return
            G = zeros(numEpisodes,1);
            Din_epis=[];
            t=0.01;
            for e = 1:numEpisodes
                if mod(e,1000) == 0
                    disp(e)
                end
                alpha=t*(1-(e/(numEpisodes+500))); % alpha dinamico
                % initialize the episode
                s = zeros(6,7);
                possib=ones(1,7);
                % initialize eligibility traces
                z = zeros(size(w));
                % get feature for initial state
                Fac = Features(s);
                % get quality function
                Q = w'*Fac;
                % take epsilon greedy actions
                if rand < epsilon
                    a = randi(A); % take random action
                else
                    a = find(Q == max(Q), 1, 'first'); % take greedy action wrt Q
                end
                % at the beginning is not terminal
                isTerminal = false;
                while ~isTerminal
                    % take action a and observe sp and r
                    [possib,sp, r, isTerminal] = grid1(possib,s,a);
                    % update total return
                    G(e) = G(e) + r;
                    if isTerminal
                        % % mi salvo quanto volte vinco/perdo/pari lo dovrei fare sulla
                        % policy finale che ottengo
                        if( r== 1)
                            Rate(1)=Rate(1)+1;
                        elseif(r == -1 )
                            Rate(2)=Rate(2)+1;
                        else
                            Rate(3)=Rate(3)+1;
                        end
                        % impose that next value is 0
                        delta = r - w(:,a)'*Fac;
                    else
                        % get active features at next state
                        Facp = Features(sp,1);
                        % compute next q function
                        Qp =  w'*Facp;
                        vec = possibleaction(possib); % take random action on the ones you can take
                        temp=size(vec);
                        % take epsilon greedy action
                        if rand < epsilon
                            ap=vec(randi(temp(2)));
                        else
                            ap = find(Qp == max(Qp(vec)), 1, 'first'); % take greedy action QP(vec) prendo il max  solo delle azioni possibili
                        end
                        % compute temporal difference error
                        delta = r + gamma*Qp(ap) -  w(:,a)'*Fac;
                    end
                    % update elegibility traces
                    z = gamma*lambda*z;
                    z(:,a) = z(:,a) + Fac;

                    % update weigth vector
                    w = w + alpha*delta*z;

                    if ~isTerminal
                        % update state, action and features
                        s = sp;
                        a = ap;
                        Fac = Facp;
                    end
                    % dopo tot episodi stampo un game
                    if mod(e,10000000) == 0
                        clf
                        sp=swapRows(sp);
                        in_board(s,7,6)
                        pause(1)
                        disp(r)
                    end
                end
                % mi salvo il win rate ogni 1000 episodi
                if mod(e, 10) == 0
                    Win_Rate=[Win_Rate Rate(1)/e];
                end
                if mod(e,100000000) == 0
                    clf
                    sp=swapRows(sp);
                    in_board(sp,7,6)
                    pause(1)
                    disp(r)
                end
            end
             %% Graphic 1
            % qui viene stampato il win rate generico durante l'evoluzione della policy
            fprintf('WinRate Medio %d ',mean(Win_Rate));
            l=size(Win_Rate);
            y=1:l(2);
            figure(1)
            plot(y,Win_Rate*100)
            title('Winrate Player 1 vs Random Player','Interpreter','latex');
            fprintf('Media ritorno %d',mean(G));
            %% Player 2 policy
            % initialize the weigth vector
            w3 = zeros(d,A);
            Rate=[0 0 0];
            Win_Rate2=[];
            Din_epis1=[];
            t=0.01;
            % epsilon = 0.2;
            % total return
            G2 = zeros(numEpisodes,1);
            for e = 1:numEpisodes
                alpha=t*(1-(e/(numEpisodes+500))); % alpha dinamico
                if mod(e,1000) == 0
                    disp(e)
                end
                % initialize the episode
                s = zeros(6,7);
                possib=ones(1,7);
                % initialize eligibility traces
                z = zeros(size(w3));
                % player 1 prende una azione random all inizio
                vec = possibleaction(possib); % take random action on the ones you can take
                temp=size(vec);
                a=vec(randi(temp(2)));% il gicatore 1 prende azioni random
                %
                for i=1:1:6
                    if(s(i,a)==0 && i==6) %verifica dell'ultima linea
                        s(i,a)=1;
                        ins=[i,a]; %salvo il punto in cui ho inserito per effettuare le verifiche dopo
                        break;
                    end
                    if(s(i,a)~=0) %verifica valida fino alla penultima riga
                        if(possib(a)==1)
                            s(i-1,a)=1;
                            ins=[i-1,a];
                            if(i-1==1)
                                possib(a)=0;
                            end
                            break;
                        end
                    end
                end
                %
                % get feature for initial state
                Fac = Features(s,2);
                % get quality function
                Q2 = w3'*Fac;
                % player 2 take epsilon greedy actions
                if rand < epsilon
                    a = randi(A); % take random action
                else
                    a = find(Q2 == max(Q2), 1, 'first'); % take greedy action wrt Q
                end
                % at the beginning is not terminal
                isTerminal = false;
                while ~isTerminal
                    % take action a and observe sp and r
                    [possib,sp, r, isTerminal] = grid2(possib,s,a);
                    % update total return
                    G2(e) = G2(e) + r;
                    if isTerminal
                        % % mi salvo quanto volte vinco/perdo/pari lo dovrei fare sulla
                        % policy finale che ottengo
                        if( r== 1)
                            Rate(1)=Rate(1)+1;
                        elseif(r == -1 )
                            Rate(2)=Rate(2)+1;
                        else
                            Rate(3)=Rate(3)+1;
                        end
                        % impose that next value is 0
                        delta = r - w3(:,a)'*Fac;
                    else
                        % get active features at next state
                        Facp = Features(sp,2);
                        % compute next q function
                        Qp2 =  w3'*Facp;
                        vec = possibleaction(possib); % take random action on the ones you can take
                        temp=size(vec);
                        % take epsilon greedy action
                        if rand < epsilon
                            ap=vec(randi(temp(2)));
                        else
                            ap = find(Qp2 == max(Qp2(vec)), 1, 'first'); % take greedy action QP(vec) prendo il max  solo delle azioni possibili
                        end
                        % compute temporal difference error
                        delta = r + gamma*Qp2(ap) -  w3(:,a)'*Fac;
                    end
                    % update elegibility traces
                    z = gamma*lambda*z;
                    z(:,a) = z(:,a) + Fac;

                    % update weigth vector
                    w3 = w3 + alpha*delta*z;

                    if ~isTerminal
                        % update state, action and features
                        s = sp;
                        a = ap;
                        Fac = Facp;
                    end
                    % dopo tot episodi stampo un game
                    if mod(e,15000000) == 0
                        clf
                        te=swapRows(s);
                        in_board(te,7,6)
                        pause(1)
                        disp(r)
                    end
                end
                % mi salvo il win rate ogni 1000 episodi
                if mod(e, 10) == 0
                    Win_Rate2=[Win_Rate2 Rate(1)/e];
                end
                if mod(e,1500000) == 0
                    clf
                    sp=swapRows(sp);
                    in_board(sp,7,6)
                    pause(1)
                    disp(r)
                end
            end
             %% Graphic 2
            % qui viene stampato il win rate generico durante l'evoluzione della policy
            fprintf('WinRate Medio %ld ',mean(Win_Rate2));
            l=size(Win_Rate2);
            y=1:l(2);
            figure(2)
            plot(y,Win_Rate2*100)
            title('Winrate Player 2 vs Random Player','Interpreter','latex');
            %% AUTOLEARNING
            alpha = 1e-2;
            w1=w;
            w2=w3;
            % epsilon=0.2;
            for i=1:10
                fprintf("player 2 start autolearn num: %d\n",i)
                [w,w3]=AutoLearn2(A,gamma,alpha,lambda,w,w3);%player 2 play against player 1 with non random policy
                fprintf("player 1 start autolearn  num : %d\n",i)
                [w,w3]=AutoLearn1(A,gamma,alpha,lambda,w,w3);%player 1 play against player 2 with non random policy
                fprintf("player 1 start autolearn vs random   num : %d\n",i)
                w=Learning_random(w,lambda,gamma,epsilon);
                fprintf("player 2 start autolearn vs random   num : %d\n",i)
                w3=Learning_random1(w3,lambda,gamma,epsilon);
            end
            %% Variance of w/w3
            ps = size(w);

            % Creazione della griglia di coordinate;
            [X, Y] = meshgrid(1:ps(1), 1:ps(2));
            X = X';
            Y = Y';

            % Visualizzazione della prima superficie
            figure(3);
            surf(X, Y, w);
            title('Surface Plot of w','Interpreter','latex');
            xlabel('X-axis','Interpreter','latex');
            ylabel('Y-axis','Interpreter','latex');
            zlabel('Weight Values','Interpreter','latex');
            colorbar; % Aggiunge una barra di colore
            shading interp; % Migliora l'interpolazione del colore sulla superficie

            figure(4);
            surf(X, Y, w1);
            title('Surface Plot of w pre AutoLearning','Interpreter','latex');
            xlabel('X-axis','Interpreter','latex');
            ylabel('Y-axis','Interpreter','latex');
            zlabel('Weight Values','Interpreter','latex');
            colorbar; % Aggiunge una barra di colore
            shading interp; % Migliora l'interpolazione del colore sulla superficie
            % Visualizzazione della seconda superficie
            figure(5);
            surf(X, Y, w2);
            title('Surface Plot of w3 pre AutoLearning','Interpreter','latex');
            xlabel('X-axis','Interpreter','latex');
            ylabel('Y-axis','Interpreter','latex');
            zlabel('Weight Values','Interpreter','latex');
            colorbar; % Aggiunge una barra di colore
            shading interp; % Migliora l'interpolazione del colore sulla superficie
            figure(6);
            surf(X, Y, w3);
            title('Surface Plot of w3','Interpreter','latex');
            xlabel('X-axis','Interpreter','latex');
            ylabel('Y-axis','Interpreter','latex');
            zlabel('Weight Values','Interpreter','latex');
            colorbar; % Aggiunge una barra di colore
            shading interp; % Migliora l'interpolazione del colore sulla superficie
            %% Game
            epsilon=0;
            % analizzo il win rate della policy finale
            Win_Rate3=[];
            numEpisodes=15000; % numero di partite su cui testo la policy finale
            for i= 1:5
                disp(i)
                Rate=[0 0 0];
                for e = 1:numEpisodes
                    s = zeros(6,7);
                    possib=ones(1,7);
                    Fac = Features(s,1);
                    % get quality function
                    Q = w'*Fac;
                    if rand < epsilon
                        a = randi(A); % take random action
                    else
                        a = find(Q == max(Q), 1, 'first'); % take greedy action wrt Q
                    end
                    isTerminal = false;
                    while ~isTerminal
                        [possib,sp,r,isTerminal]=grid1(possib,s,a);
                        if isTerminal
                            if( r== 1)
                                Rate(1)=Rate(1)+1;
                            elseif(r == -1 )
                                Rate(2)=Rate(2)+1;
                            else
                                Rate(3)=Rate(3)+1;
                            end
                        else
                            Facp = Features(sp,1);
                            Qp = w'*Facp;
                            vec = possibleaction(possib); % take random action on the ones you can take
                            a = find(Qp == max(Qp(vec)), 1, 'first'); % take greedy action QP(vec) prendo il max  solo delle azioni possibili
                            s = sp;
                        end
                        if mod(e,50050) == 0 && i == 10
                            clf
                            te=swapRows(sp);
                            in_board(te,7,6)
                            pause(1)
                        end
                    end
                end
                Win_Rate3=[Win_Rate3 Rate(1)/numEpisodes];
            end
            Arr_win_rate=[Arr_win_rate max(Win_Rate3)*100];
%         end
%     end
% end
%% Graphic
disp(Rate)
l=size(Win_Rate3);
% l=size(Arr_win_rate);
y=1:l(2);
figure(8)
plot(y,Win_Rate3*100)
% plot(y,Arr_win_rate)
% [m,inx]=max(Arr_win_rate);
% fprintf("Index of Max element %d\n",inx);
title('WinRate legato alla scelta dei parametri','Interpreter','latex');
% title('WinRate vs Random Player','Interpreter','latex');
xlabel('x','Interpreter','latex');
ylabel('WinRate%','Interpreter','latex');
%% GAME VS ME
epsilon1=0;
s = zeros(6,7);
possib=ones(1,7);
Fac = Features(s,1);
% get quality function
Q = w'*Fac;
if rand < epsilon1
    a = randi(A); % take random action
else
    a = find(Q == max(Q), 1, 'first'); % take greedy action wrt Q
end
isTerminal = false;
while ~isTerminal
    [possib,sp,r,isTerminal]=grid3(possib,s,a);
    Facp = Features(sp,1);
    Qp = w'*Facp;
    vec = possibleaction(possib); % take random action on the ones you can take
    ap = find(Qp == max(Qp(vec)), 1, 'first'); % take greedy action QP(vec) prendo il max  solo delle azioni possibili
    if ~isTerminal
        % update state, action a2nd features
        s = sp;
        a = ap;
    end
    if mod(e,1) == 0
        clf
        sp=swapRows(sp);
        in_board(sp,7,6)
    end
end
%%
 %save MC_f4.mat

%% loader

  % load MC_f4.mat
