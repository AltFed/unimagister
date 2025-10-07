%% Player 2 random learning
function w3=Learning_random1(w3,lambda,gamma,epsilon)
t=0.01;
numEpisodes=3000;
for j=1:5
    Rate=[0 0 0];
    for e = 1:numEpisodes
        alpha=t*(1-(e/(numEpisodes+500))); % alpha dinamico
        % initialize the episode
        s = zeros(6,7);
        possib=ones(1,7);
        % initialize eligibility traces
        z = zeros(size(w3));
        vec = possibleaction(possib); % take random action on the ones you can take
        temp=size(vec);
        a=vec(randi(temp(2))); % player 1 take random action
        %
        for i=1:1:6
            if(s(i,a)==0 && i==6) %verifica dell'ultima linea
                s(i,a)=1;
                break;
            end
            if(s(i,a)~=0) %verifica valida fino alla penultima riga
                if(possib(a)==1)
                    s(i-1,a)=1;
                    if(i-1==1)
                        possib(a)=0;
                    end
                    break;
                end
            end
        end
        %
        % get feature for initial state
        Fac = Features(s);
        % get quality function
        Q = w3'*Fac;
        vec = possibleaction(possib); % take random action on the ones you can take
        temp=size(vec);
        % take epsilon greedy actions
        if rand < epsilon
            a=vec(randi(temp(2))); % take random action
        else
            a = find(Q == max(Q(vec)), 1, 'first'); % take greedy action wrt Q
        end
        % at the beginning is not terminal
        isTerminal = false;
        while ~isTerminal
            % take action a and observe sp and r
            [possib,sp,r,isTerminal]=grid2(possib,s,a);
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
                Facp = Features(sp);
                % compute next q function
                Qp =  w3'*Facp;
                vec = possibleaction(possib); % take random action on the ones you can take
                temp=size(vec);
                % take epsilon greedy action
                if rand < epsilon
                    ap=vec(randi(temp(2)));
                else
                    ap = find(Qp == max(Qp(vec)), 1, 'first'); % take greedy action QP(vec) prendo il max  solo delle azioni possibili
                end
                % compute temporal difference error
                delta = r + gamma*Qp(ap) -  w3(:,a)'*Fac;
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
        end
    end
    % disp(Rate(1)/e)
end