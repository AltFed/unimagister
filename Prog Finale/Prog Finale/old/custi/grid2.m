function [possib,sp,r,Terminal]=grid2(possib,s,a)
ins=[];
won=0;
w=s;%cambierò un solo elemento alla matrice
Terminal=false;
% in base al giocatore che ha chiamato l'ambiente decido di che colore è la
% pedina da inserire.
colore=2; %sto giocando la prima mossa con il giocatore dell'algoritmo

% scorro tutte le righe fino a trovare un elemento inserito, allora
% inserisco la pedina di nome colore nella riga precedente

for i=1:1:6
    if(s(i,a)==0 && i==6) %verifica dell'ultima linea
        w(i,a)=colore;
        ins=[i,a]; %salvo il punto in cui ho inserito per effettuare le verifiche dopo
        break;
    end
    if(s(i,a)~=0) %verifica valida fino alla penultima riga
        if(possib(a)==1)
            w(i-1,a)=colore;
            ins=[i-1,a];
            if(i-1==1)
                possib(a)=0;
            end
            break;
        end
    end
end
if ~isempty(ins)
    won=checker(possib,w,colore,ins);
end
nz = any(possib(:) ~= 0); % check se possib ha almeno un elemento != da 0 -> nz= true
if(won == 2 )
    Terminal = true;
    r=1;
    sp=w;
    return;
end
if( won == 0 && ~nz) % stato terminale tie game
    r=-0.5;
    Terminal=true;
    sp=w;
    return;
end

sp=w;
vec = possibleaction(possib); % take random action on the ones you can take
temp=size(vec);
a=vec(randi(temp(2)));% il gicatore 2 prende azioni random
% da qua implemento il codice per far giocare in modo randomico il nuovo
% giocatore.

if( won ~= 2 && nz) % se il giocatore 2 vince non posso giocare
    colore=1;
    for i=1:1:6
        if(w(i,a)==0 && i==6) %verifica dell'ultima linea
            sp(i,a)=colore;
            ins=[i,a]; %salvo il punto in cui ho inserito per effettuare le verifiche dopo
            break;
        end

        if(w(i,a)~=0) %verifica valida fino alla penultima riga
            if(possib(a)==1)
                sp(i-1,a)=colore;
                ins=[i-1,a];
                if(i-1==1)
                    possib(a)=0;
                end
                break;
            end
        end
    end
end
won=checker(possib,sp,colore,ins);  % check se il secondo player vince
nz = any(possib(:) ~= 0); % check se possib ha almeno un elemento != da 0 -> nz= true
if (won == 1) % player 2 win
    Terminal=true;
    r=-1;
end

if (won == 0 && ~nz)    % tie game
    Terminal=true;
    r=-0.5;
end
if(won == 0 && nz) % nessuno ha ancora vinto e posso mettere altre pedine
    Terminal=false;
    r=0;
end
end
