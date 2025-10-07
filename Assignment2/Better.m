clear al
close all
clc

S=101; %numero di stati possibili relativi ai soldi del giocatore
A=S; %numero di azioni disponibili, corrispondenti all'importo scommesso

Ptesta=0.5;
Pcroce=0.50;
%probabilità risultati lancio della moneta

P=zeros(S,S,A);

toll=0.00001;

for i=1:S-1
    for j=1:S
        for k=1:S-1
            if(j==min(i+k,S) && k<i)
                P(i,min(i+k,S),k)=Ptesta;
            end
            if(j==max(i-k,1) && k<i)
                P(i,max(i-k,1),k)=Pcroce;
            end
        end
    end
end

R=zeros(S,A);
earn=zeros(S,1);
for i=1:S
       if(i==S)
          earn(i)=1;
       end
       if(i==1)
           earn(i)=-1;
       end
end


for a=1:A
    R(:,a)=P(:,:,a)*earn;
end

gamma=0.9;

policy=zeros(A,1);

for i=2:(A-1)
   policy(i,1)=randi([1,i-1]);
end


%effettuo policy evaluation di una policy casuale

vpi1 = policy_eval(S,P,R,policy,gamma);

vpi0 = zeros(S,1);

vpi2 = iterative_policy_eval(S,P,R,policy,gamma,vpi0);

%codice per il policy iteration

vpi = zeros(S,1);
% tic
while true
    % policy evaluation step
    % vpi = policy_eval(S,P,R,policy,gamma);
    vpi = iterative_policy_eval(S,P,R,policy,gamma,vpi);
    % quality function
    qpi = zeros(S,A);
    % new policy
    policyp = zeros(S,1);
    for s = 2:S-1
        for a = 1:s-1
            % definition
            qpi(s,a) = R(s,a) + gamma*P(s,:,a)*vpi;
        end 
        % policy improvement
        policyp(s) = find(qpi(s,1:s-1) == max(qpi(s,1:s-1)),1,"first");
    end

    % condition to interrupt the while - policy stable
    if norm(policy-policyp,inf) == 0
        break;
    else
        policy = policyp;
    end
end
tic
vpi2 = iterative_policy_eval(S,P,R,policy,gamma,vpi0);

%provo a vedere se il valore degli statio utilizzando un'altra policy varia
%di molto
vpilast = zeros(S,1);
 toc
while true
    % policy evaluation step
    % vpi = policy_eval(S,P,R,policy,gamma);
    vpilast = iterative_policy_eval(S,P,R,policy,gamma,vpilast);
    % quality function
    qpi = zeros(S,A);
    % new policy
    policyp = zeros(S,1);
    for s = 2:S-1
        for a = 1:s-1
            % definition
            qpi(s,a) = R(s,a) + gamma*P(s,:,a)*vpilast;
        end 
        % policy improvement
        policyp(s) = find(qpi(s,1:s-1) == max(qpi(s,1:s-1)),1,"first");
    end

    % condition to interrupt the while - policy stable
    if norm(policy-policyp,inf) == 0
        break;
    else
        policy = policyp;
    end
end

%ciclo while per l'implementazione del value iteration

states=[1:S];

figure(1)
plot(states,transpose(policy))
title('optimal action to take after policy iteration')

figure(2);
plot(states,vpi)
title('value after policy evaluation')

figure(3);
plot(states,vpi2)
title('value after iterative policy evaluation')

save Better.mat S A P R