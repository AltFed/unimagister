%ambiente che regola l'inserimento delle pedine all'interno della griglia
%del forza quattro.

%questa funzione riceve in ingresso :
%le mosse ancora disponibili (da aggiornare se necessario)
%la disposizione attuale della tabella (0 vuoto, 1 giocatore, 2 avversario)
% il valore Tra 1 e 7 per definire la riga in cui si vuole inserire il coin
%il giocatore che fa la mossa

%in uscita: stato successivo, reward e possibilità
function [possib,sp,r,Terminal]=grid1(possib,s,a)

 w=s;%cambierò un solo elemento alla matrice
Terminal=false;
% in base al giocatore che ha chiamato l'ambiente decido di che colore è la
% pedina da inserire.

colore=1; %sto giocando la prima mossa con il giocatore dell'algoritmo

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
won=checker(possib,w,colore,ins);
  nz = any(possib(:) ~= 0); % check se possib ha almeno un elemento != da 0 -> nz= true
if(won == 1 )
    Terminal = true;
    r=1;
end
if( won == 0 && ~nz) % stato terminale tie game
    r=0;
    Terminal=true;
end

  sp=w;
vec = possibleaction(possib); % take random action on the ones you can take
temp=size(vec);
a=vec(randi(temp(2)));% il gicatore 2 prende azioni random
% da qua implemento il codice per far giocare in modo randomico il nuovo
% giocatore.

if( won ~= 1 && nz) % se il giocatore 1 vince non posso giocare
    colore=2;
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
if (won == 2) % player 2 win
    Terminal=true;
    r=-1;
end

if (won == 0 && ~nz)    % tie game
    Terminal=true;
    r=0;
end
if(won == 0 && nz) % nessuno ha ancora vinto e posso mettere altre pedine
    Terminal=false;
    r=0;
end
end
