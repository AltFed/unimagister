%% Player 1 Autolearning 
function [w,w3]=AutoLearn1(A,gamma,~,lambda,w,w3)
epsilon=0.2;
t=0.01;
for i=1:5
    Rate=[0 0 0];
    numEpisodes=500*i;
    for e = 1:numEpisodes
        alpha=t*(1-(e/(numEpisodes+500))); % alpha dinamico
        % initialize the episode
        s = zeros(6,7);
        possib=ones(1,7);
        % initialize eligibility traces
        z = zeros(size(w));
        % get feature for initial state
        Fac = Features(s,1);
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
            [possib,sp,r,isTerminal]=gridAuto(possib,s,a,w3);
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
            if (mod(e,1000000) == 0)
                clf
                te=swapRows(s);
                in_board(te,7,6)
                pause(1)
                disp(r)
            end
        end
        if mod(e,100000) == 0
            clf
            te=swapRows(sp);
            in_board(te,7,6)
            pause(1)
            disp(r)
        end
    end
    % disp(Rate(1)/e)
end