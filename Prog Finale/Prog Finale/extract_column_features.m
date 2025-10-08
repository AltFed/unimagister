function column_features = extract_column_features(s)
% Estrae il numero di dischi di ogni giocatore in ogni colonna.
    num_columns = size(s, 2);
    column_features = zeros(num_columns * 2, 1);
    for col = 1:num_columns
        column_features(col) = sum(s(:, col) == 1);
        column_features(col + num_columns) = sum(s(:, col) == 2);
    end
end
