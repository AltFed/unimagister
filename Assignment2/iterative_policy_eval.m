function vpi = iterative_policy_eval(S,P,R,policy,gamma,vpi0)
% computes the value function of policy pi by iterative policy evaluation

% set tolerance
toll = 0.001;

% transition probability matrix
Ppi = zeros(S,S);
% reward vector
Rpi = zeros(S,1);
for s = 2:S-1
    % matrices can be constructed row by row
    
    Ppi(s,:) = P(s,:,policy(s));
    Rpi(s) = R(s,policy(s)); 
end

% initialize the value of the policy
vpi = vpi0;
while true
    % synchronous value update
    vpinew = Rpi + gamma*Ppi*vpi;
    if norm(vpi - vpinew, inf) < toll
        vpi = vpinew;
        break;
    else
        vpi = vpinew;
    end
end