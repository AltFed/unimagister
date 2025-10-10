function X = Features(s, player)
    column_features_bin = extract_column_features(s);
    my_threes = count_threes(s, player); % Feature per l'attacco

    if player == 1
        opponent = 2;
    else
        opponent = 1;
    end

    % --- NUOVA FEATURE PER LA DIFESA ---
    % Sostituiamo il conteggio dei tris con il conteggio delle minacce di vittoria
    opponent_threats = count_winning_threats(s, opponent);
    % --- FINE MODIFICA ---

    % Il vettore finale ora contiene un segnale di attacco e uno di difesa
    t = [column_features_bin; my_threes; opponent_threats];

    X = t;
end