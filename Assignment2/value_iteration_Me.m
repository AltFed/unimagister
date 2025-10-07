load Better.mat

vpi = zeros(S,1);
 tic
while true
    % perform a value iteration step
    [vpin, policy] = value_iteration_step(S,A,P,R,gamma,vpi);

    % condition to interrupt the iteration - value function converged
    if norm(vpin - vpi,inf) <toll
        break;
    else
        vpi = vpin;
    end
end
 toc

states=[1:S];

figure(1)
plot(states,transpose(policy))

figure(2);
plot(states,vpi)
