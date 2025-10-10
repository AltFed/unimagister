function X = Features(s, player)
% Assembla il vettore finale delle features numeriche.
    opponent = 3 - player;

    % 1. Conteggio pezzi in ogni colonna (14 features)
    column_features = extract_column_features(s);
    % 2. Conteggio dei "tris" per l'attacco (1 feature)
    my_threes = count_threes(s, player);
    % 3. Conteggio delle minacce avversarie per la difesa (1 feature)
    opponent_threats = count_winning_threats(s, opponent);
    % 4. Controllo della colonna centrale (1 feature)
    center_control = get_center_control(s, player);

    X = [column_features; my_threes; opponent_threats; center_control];
end
