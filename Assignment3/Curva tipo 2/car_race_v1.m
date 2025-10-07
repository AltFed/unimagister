function [sp,r,Ax,Ay] = car_race_v1(Map,s,a,Ax,Ay,S)
% dobbiamo definire un singolo step
% dinamico
temp=size(Map);
Sx=temp(1);% numero di stati asse x
Sy=temp(2);% numero di stati asse y

[ax,ay]=ind2sub([3,3],a);   % -> sfrutto gli indici di una matrice 3x3  ( l'indice 2,1 -> ax=0 ay=-1 , ecc )
% definisco l'azioni prese
Ax=max(Ax+(ax-2),0); % mantengo il valore delle velocità che ho precedentemente ottenuto
Ax=min(Ax,5);
Ay=max(Ay+(ay-2),0); % mantengo il valore delle velocità che ho precedentemente ottenuto
Ay=min(Ay,5);
if( Ax == 0 && Ay == 0) % le velocità non possono essere entrambi zero
    if rand() < 0.5
        Ax=1;
    else
        Ay=1;
    end
end
[x,y]=ind2sub([Sx,Sy],s); % definisco la posizione iniziale in cui mi trovo
while true
    x=max(x,1);
    y=max(y,1);
    % def nuove posizioni
    xn=x+Ax;
    yn=y+Ay;
    % sono uscito dal percorso
    if( Ax ~= 0 && Ay ~= 0)
        for i=1:Ax
            for j=1:Ay
                if(Map(min(x+i,Sx),min(y+j,Sy)) == 2)
                    %terminal state
                    sp=-1; %#ok<*NASGU>
                    r=-1;
                    break;
                elseif(Map(min(x+i,Sx),min(y+j,Sy)) == 0 )
                    sp= randi([1,max(1,S(randi(numel(S))))]); % ritorno random in uno stato iniziale del percorso
                    r=-1;
                    break;
                end
            end
        end
    elseif( Ax == 0 && Ay ~= 0)
        for i=1:Ay
            if(Map(x,min(y+i,Sy)) == 2)
                %terminal state
                sp=-1;
                r=-1;
                break;
            elseif(Map(x,min(y+i,Sy)) == 0 )
                sp= randi([1,max(1,S(randi(numel(S))))]); % ritorno random in uno stato iniziale del percorso
                r=-1;
                break;
            end
        end
    elseif(Ax ~= 0 && Ay == 0)
        for i=1:Ax
            if(Map(min(x+i,Sx),y) == 2)
                %terminal state
                sp=-1;
                r=-1;
                break;
            elseif(Map(min(x+i,Sx),y) == 0 )
                sp= randi([1,max(1,S(randi(numel(S))))]); % ritorno random in uno stato iniziale del percorso
                r=-1;
                break;
            end
        end
    end
    if(Map(min(xn,Sx),min(Sy,yn)) == 1 || Map(min(xn,Sx),min(Sy,yn)) == 3)
        sp=sub2ind([Sx,Sy],min(xn,Sx),min(yn,Sy));
        r=-1;
        break;
    elseif(Map(min(xn,Sx),min(Sy,yn))  == 0)
        sp= randi([1,max(1,S(randi(numel(S))))]); % ritorno random in uno stato iniziale del percorso
        r=-1;
        break;
    elseif(Map(min(xn,Sx),min(Sy,yn))  == 2)
        sp=-1;
        r=-1;
        break;
    end

end
end