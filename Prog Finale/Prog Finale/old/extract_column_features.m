function column_features_bin = extract_column_features(s)
    % Estrae features basate sulle informazioni delle colonne
    num_columns = size(s, 2);
    column_features = zeros(num_columns * 2, 1);
    
    for col = 1:num_columns
        column_features(col) = sum(s(:, col) == 1);  % Numero di dischi del giocatore nella colonna
        column_features(col + num_columns) = sum(s(:, col) == 2);  % Numero di dischi dell'avversario nella colonna
    end
    
    % Converti il vettore delle features in una rappresentazione binaria
    column_features_bin = [];
    for i = 1:length(column_features)
        % Converti ogni elemento in binario con una lunghezza fissa (es. 4 bit)
        bin_str = dec2bin(column_features(i), 4);
        column_features_bin = [column_features_bin, bin_str - '0'];
    end
    column_features_bin=column_features_bin';
end
