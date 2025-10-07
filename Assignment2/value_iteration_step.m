function [vpin, policy] = value_iteration_step(S,A,P,R,gamma,vpi)

% initialize matrices
q = zeros(S,A);
vpin = zeros(S,1);
policy = zeros(S,1);

% we loop for all the state
for s = 2:S-1 
    for a = 1:s-1
        q(s,a) = R(s,a) + gamma*P(s,:,a)*vpi;
    end
    % synchronous substitution
    vpin(s) = max(q(s,1:s-1));
    policy(s) = find(q(s,1:s-1) == max(q(s,1:s-1)),1,"first");
end
