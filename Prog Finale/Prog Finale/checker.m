function [won]=checker(possib,sp,colore,ins)

counter=1;

j=1;
i=1;
stop=[0,0];

won=0;
%effettuo il controllo sui valori verticali della matrice per verificare se
%qualcuno ha vinto, ho un sacco di verifiche per evitare di uscire dai
%limiti

while (counter<4 && (stop(1)~=1 || stop(2)~=1))
    if(ins(1)-i~=0)
        if(sp(ins(1)-i,ins(2))==colore)
            counter=counter+1;
            i=i+1;
        else
            stop(1)=1;
        end
    else
        stop(1)=1;
    end
    if(ins(1)+j~=7)
        if(sp(ins(1)+j,ins(2))==colore)
            counter=counter+1;
            j=j+1;
        else
            stop(2)=1;
        end
    else
        stop(2)=1;
    end
end

if(counter>=4)
    if colore == 1
       won=1;
        return;
    else
        won=2;
        return;
    end
end

counter=1;

j=1;
i=1;
stop=[0,0];

%effettuo il controllo sui valori orizzontali della matrice per verificare se
%qualcuno ha vinto, ho un sacco di verifiche per evitare di uscire dai
%limiti

while (counter<4 && (stop(1)~=1 || stop(2)~=1))
    if(ins(2)-i~=0)
        if(sp(ins(1),ins(2)-i)==colore)
            counter=counter+1;
            i=i+1;
        else
            stop(1)=1;
        end
    else
        stop(1)=1;
    end
    if(ins(2)+j~=8)
        if(sp(ins(1),ins(2)+j)==colore)
            counter=counter+1;
            j=j+1;
        else
            stop(2)=1;
        end
    else
        stop(2)=1;
    end
end

if(counter>=4)
    if colore == 1
        won=1;
        return;
    else
        won=2;
        return;
    end
end

counter=1;

j=1;
i=1;
stop=[0,0];


%effettuo il controllo sui valori diagonali della matrice per verificare se
%qualcuno ha vinto, ho un sacco di verifiche per evitare di uscire dai
%limiti

while (counter<4 && (stop(1)~=1 || stop(2)~=1))
    if(ins(2)-i~=0 && ins(1)-i~=0)
        if(sp(ins(1)-i,ins(2)-i)==colore)
            counter=counter+1;
            i=i+1;
        else
            stop(1)=1;
        end
    else
        stop(1)=1;
    end
    if(ins(2)+j~=8 && ins(1)+j~=7)
        if(sp(ins(1)+j,ins(2)+j)==colore)
            counter=counter+1;
            j=j+1;
        else
            stop(2)=1;
        end
    else
        stop(2)=1;
    end
end

if(counter>=4)
    if colore == 1
        won=1;
        return;
    else
        won=2;
        return;
    end
end

counter=1;

j=1;
i=1;
stop=[0,0];
%effettuo il controllo sui valori diagonali della matrice per verificare se
%qualcuno ha vinto, ho un sacco di verifiche per evitare di uscire dai
%limiti

while (counter<4 && (stop(1)~=1 || stop(2)~=1))
    if(ins(2)-i~=0 && ins(1)+i~=7)
        if(sp(ins(1)+i,ins(2)-i)==colore)
            counter=counter+1;
            i=i+1;
        else
            stop(1)=1;
        end
    else
        stop(1)=1;
    end
    if(ins(2)+j~=8 && ins(1)-j~=0)
        if(sp(ins(1)-j,ins(2)+j)==colore)
            counter=counter+1;
            j=j+1;
        else
            stop(2)=1;
        end
    else
        stop(2)=1;
    end
end

if(counter>=4)
    if colore == 1
        won=1;
        return;
    else
        won=2;
        return;
    end
end

if possib == zeros(1,7)
    if(won ~= 1 && won ~= 2 )
        won=0;  % tie game
    end
end
%else won = 0 sempre



