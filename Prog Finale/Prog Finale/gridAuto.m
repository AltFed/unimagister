function [possib,sp,r,Terminal]=gridAuto(possib,s,a,w2)
    colore_agente = 1;
    colore_avversario = 2;

    % =================== MULTA PER STUPIDITÀ ===================
    threat_move = find_critical_move(s, colore_avversario);
    if ~isempty(threat_move) && a ~= threat_move
        sp = s; 
        Terminal = true;
        r = -10; % Punizione immediata e pesante!
        for i=6:-1:1, if sp(i,a)==0, sp(i,a)=colore_agente; break; end, end
        return; 
    end
    % =============================================================
    
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
    
    if rand() < 0.2
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
    if (won == 2), Terminal=true; r=-1;
    elseif (~nz), Terminal=true; r=0;
    else, Terminal=false; r=0;
    end
end