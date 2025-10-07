%we call: 1=rock, 2=paper, 3=scissors, 4=spock, 5=lizard
function [r] = player(a)
% non stationary case
%we take a random action: than we check who wins between the player and the
%machine, so we return the gain.

A=randi(5);

if(rand()<=0.6)
    A=5;
else
    A=randi([1,4]);
end


if ((mod(A,5)==mod(a-1,5))||(mod(A,5)==mod(a+2,5)))
    r=1;
elseif((mod(A,5)==mod(a+1,5))||(mod(A,5)==mod(a-2,5)))
    r=-1;
else
    r=0;

end

% the reward is the correspondig value + a random Gaussian number
