function [possib,sp,r,Terminal]=gridAuto(possib,s,a,w2)
    colore_agente = 1;
    colore_avversario = 2;
    
    % =================================================================
    % --- LOGICA DI REWARD SHAPING (IL CUORE DELLA SOLUZIONE) ---
    % =================================================================
    % Prima di eseguire la mossa dell'agente, controlliamo lo stato precedente 's'.
    % C'era una mossa vincente per l'avversario?
    
    vec_possibili = possibleaction(possib);
    mossa_vincente_avversario = [];
    
    % Simulo ogni possibile mossa dell'avversario per vedere se avrebbe vinto
    for i = 1:length(vec_possibili)
        col = vec_possibili(i);
        temp_s = s;
        ins_temp = [];
        for row = 6:-1:1
            if temp_s(row, col) == 0
                temp_s(row, col) = colore_avversario;
                ins_temp = [row, col];
                break;
            end
        end
        if ~isempty(ins_temp) && checker(possib, temp_s, colore_avversario, ins_temp) > 0
            mossa_vincente_avversario = col; % Ho trovato la colonna dove l'avversario vince
            break;
        end
    end
    
    % ORA CONTROLLO LA MOSSA 'a' SCELTA DALL'AGENTE
    % Se l'avversario poteva vincere e l'agente NON ha bloccato quella mossa...
    if ~isempty(mossa_vincente_avversario) && a ~= mossa_vincente_avversario
        % ...allora è un errore gravissimo!
        sp = s; % Lo stato successivo non cambia molto, ma la partita finisce
        for i=6:-1:1, if sp(i,a)==0, sp(i,a)=colore_agente; break; end, end % Eseguo comunque la sua mossa stupida
        
        Terminal = true;  % La partita finisce qui per punizione
        r = -10;          % PUNIZIONE ENORME E IMMEDIATA!
        return;           % Usciamo subito dalla funzione
    end
    % =================================================================
    % --- FINE DELLA NUOVA LOGICA ---
    % =================================================================
    
    % Se siamo qui, o non c'erano minacce o l'agente ha bloccato correttamente.
    % Il resto del codice rimane quasi invariato.
    
    h=s;
    Terminal=false;
    ins=[];
    
    % Mossa dell'Agente (P1)
    for i=6:-1:1
        if(h(i,a)==0)
            h(i,a)=colore_agente;
            ins=[i,a];
            if i == 1, possib(a) = 0; end
            break;
        end
    end
    sp=h;

    won=checker(possib,h,colore_agente,ins);
    nz = any(possib(:));
    if(won == 1 ), Terminal = true; r=1; return; end
    if(~nz), Terminal=true; r=0; return; end
    
    % Mossa dell'Avversario (P2)
    Fac=Features(sp,colore_avversario);
    Qp=w2'*Fac;
    vec = possibleaction(possib);
    if isempty(vec), Terminal=true; r=0; return; end
    
    if rand() < 0.2 % Manteniamo un po' di casualità nell'avversario
        ap=vec(randi(length(vec)));
    else
        [~, ap_idx] = max(Qp(vec));
        ap = vec(ap_idx);
    end
    
    ins_opp=[];
    for i=6:-1:1
        if(sp(i,ap)==0)
            sp(i,ap)=colore_avversario;
            ins_opp=[i,ap];
            if i == 1, possib(ap) = 0; end
            break;
        end
    end

    won=checker(possib,sp,colore_avversario,ins_opp);
    nz = any(possib(:));
    if (won == 2), Terminal=true; r=-1; % La punizione standard per la sconfitta
    elseif (~nz), Terminal=true; r=0;
    else, Terminal=false; r=0;
    end
end