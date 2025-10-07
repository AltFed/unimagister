clear all
close all
clc
% creo la mappa (indipendente)
Map=Create_Racing_Circuit();
temp=size(Map);
% inizializzo
Sx=temp(1);
Sy=temp(2);
StartState=0;
% Map == 3 start state
% Map == 2 terminal state
% Map == 1 Race
% Map == 0 out of limit
% ricavo gli stati di partenza
for i =1:Sx
    for j=1:Sy
        if Map(i,j) == 3
            s=sub2ind([Sx,Sy],i,j);
            StartState=[StartState,s];
        end
    end
end
A=9;
S=Sx*Sy; % total number of states
gamma = 1; % discount factor;
numEpisodes = 3e4; % number of episodes to mean
epsilon = 0.3;
alpha = 1e-2;
%se vogliamo diminuire gli stati di partenza e arrivo dobbiamo aumentare
%epsilon
%% DEFINISCO EPISODI E-POLICY
% usare e-policy greedy perchè ho uno stato iniziale che è comunque fissato !!!
policy = randi(A,[S,1]); % policy   ( prendo una policy che mi da un azione random specifica per ogni stato per ogni elemento del tensore ))
while true
    % e greedy policy
    Q = zeros(S, A); % quality function -> stima della q
    QQ = zeros(S, A); % quality function -> stima della q
    N = zeros(S, A); % counter of visits
    for j = 1:numEpisodes
        % beginning of episode
        s0 = randi([1,max(1,StartState(randi(numel(StartState))))]);  % random start state da 1 a 20 perchè sub2ind avanza per colonne quindi prendi i primi 20 elementi ovvero 1,1 2,1 3,1 ecc -> 20,1
        a0 = randi(A);  % random action posso sfruttare ind2sub per mappare l'azione rispetto ad una matrice i cui indici mi specificano Ax e Ay
        Ax=1; % reset velocità asse x
        Ay=2; % reset velocità asse y
        states = s0;
        actions = a0;
        rewards = [];
        s = s0;
        a = a0;
        sp = s0;
        while sp ~= -1 %(-1 != stato terminale))
            %  MI STO SALVANDO L 'EPISODIO CREO ARRAY DEI REWARD/STATI/AZIONI
            [sp,r,Ax,Ay] = car_race_v1(Map,s,a,Ax,Ay,StartState);    %(sto generando l'episodio in maniera random)
            rewards = [rewards, r];  % mi salvo il reward ottenuto in un array di reward
            if sp ~= -1
                states = [states, sp]; %(array degli stati)
                % e greedy policy
                a = policy(sp);
                if rand < epsilon
                    a = randi(A);
                end
                actions = [actions, a]; %(array delle azioni)
                s = sp;
            end
        end
        G=0;
        % Every visit prediction
        for i = length(actions):-1:1 % explore the episode backwards UNA VOLTA GENERATO L'EPISODIO L ESPLORO ALL'INDIETRO
            G = gamma*G + rewards(i);
            St = states(i);
            At = actions(i);
            N(St, At) = N(St, At) + 1;
            Q(St, At) = Q(St, At) + 1/N(St, At)*(G - Q(St, At));
            QQ(St,At) = QQ(St, At) + alpha*(G-QQ(St, At));   % alpha
        end
    end
    newpolicy = zeros(S,1);
    nnewpolicy = zeros(S,1);
    % update the policy as greedy w.r.t. Q
    for s = 1:S
        newpolicy(s) = find(Q(s,:) == max(Q(s, :)), 1, 'first');    % come per DP policy greedy rispetto alla stima della q(s,a)
        nnewpolicy(s) = find(QQ(s,:) == max(QQ(s, :)), 1, 'first');    % come per DP policy greedy rispetto alla stima della q(s,a)
    end
    % if policy doesn't change stop
    if norm(newpolicy-policy,inf) <= 7 % corrisponde al numero di elementi -> azioni che cambiamo alla policy nella singola iterazione rispetto alla policy prima
        policy= newpolicy;
        policy2=nnewpolicy;
        break;
    else
        disp(norm(newpolicy-policy,inf))
        policy = newpolicy;
        policy2=nnewpolicy;
    end
end
%% Graph
% Define the grid
clf
[x, y] = meshgrid(1:Sx, 1:Sy);
Ax = zeros(Sx,Sy);
Ay= zeros(Sx,Sy);
Vx = zeros(Sx,Sy);
Vy= zeros(Sx,Sy);
AAx= zeros(Sx,Sy);
AAy= zeros(Sx,Sy);
axp=0;
ayp=0;
for i = 1:Sx
    for j = 1:Sy
        % mi salvo Acc e Velocità di tutti gli stati
        ss=sub2ind([Sx,Sy],i,j);
        AA=policy(ss);
        AN=policy2(ss);
        [ax,ay]=ind2sub([3,3],AA);
        [ax1,ay1]=ind2sub([3,3],AN);
        AAx(i,j)=max((ax1-2),0);
        AAy(i,j)=max((ay1-2),0);
        Ax(i,j)=max((ax-2),0);
        Ay(i,j)=max((ay-2),0);
        % velocità
        Vx(i,j)=max(axp+(ax-2),0);
        Vy(i,j)=max(ayp+(ay-2),0);
        Vx(i,j)=min(Vx(i,j),5);
        Vy(i,j)=min(Vy(i,j),5);
        axp=ax;
        ayp=ay;
    end
end
% creo un episodio da graficare poi mi salvo la storia una volta applicando
% la policy ottima e un altra applicando la policy random cosi vedo la diff
s=randi([1,max(1,StartState(randi(numel(StartState))))]);   % random start
[Hx,Hy]=ind2sub([Sx,Sy],s);
HH=s;
Bx=2;
By=1;
Velx=0;
Vely=0;
% episodio generato dalla policy ottima
while sp ~= -1
    [sp ,r,Bx,By] = car_race_v1(Map,s,policy(s),Bx,By,StartState);    % se sostituisco la policy con policy2 ottengo un generico episodio per la e-greedy con alpha
    s = sp;
    if(sp==-1)
        Velx=[Velx,Bx];
        Vely=[Vely,By];
        break;
    end
    [hx,hy]=ind2sub([Sx,Sy],s);
    % mi ricavo lo stato finale
    Hx=[Hx,hx];
    Hy=[Hy,hy];
    Velx=[Velx,Bx]; % il primo indice è inutile dato che la velocità del punto in cui mi trovo la definisce la Car_race func
    Vely=[Vely,By];
end
sz=1; % dim [w,l] rect
% Plot the rectangles (qui per definire il percorso devo conoscere la
% mappa)
figure(1);
hold on;
for i = 1:Sx
    for j =1:Sy
        if(Map(i,j) == 1 )
            rectangle('Position',[i,j,sz,sz], 'FaceColor', [1, 1, 1], 'LineWidth', 0.1);
        elseif(Map(i,j) == 0)
            rectangle('Position',[i,j,sz,sz], 'FaceColor', [0, 0, 0], 'LineWidth', 0.1);
        elseif(Map(i,j) == 2 )
            rectangle('Position', [i,j,sz,sz], 'FaceColor', [1, 0, 0], 'LineWidth', 0.1);
        elseif(Map(i,j) == 3)
            rectangle('Position', [i,j,sz,sz], 'FaceColor', [0, 1, 0], 'LineWidth', 0.1);
        end
    end
end
axis equal
a=size(Hx);
% random color ogni volta che ritorno nello stato iniziale tiene traccia di
% quante volte torno indietro
C=[1,1,0];
for i = 1:a(2)
    if(Hy(i) == 1 && Velx(i+1) ~= 0)
        C=rand(1,3);
    end
    rectangle('Position', [Hx(i),Hy(i),sz,sz], 'FaceColor', C, 'LineWidth', 0.5);
    quiver(Hx(i)+0.5,Hy(i)+0.5,Velx(i+1),Vely(i+1),'LineWidth',0.7) % mi disegno le acc per ogni rect in cui passo
    title('Eval policy * ','Interpreter','latex');
end
axis equal;
figure(2)
quiver(x,y,Ax,Ay)
title('Acc e greedy policy ','Interpreter','latex')
axis equal
figure(3)
quiver(x,y,AAx,AAy)
title('Acc e greedy policy con alpha','Interpreter','latex')
axis equal
figure(4)
quiver(x,y,Vx,Vy)
title('Velocita e greedy policy','Interpreter','latex')
axis equal
