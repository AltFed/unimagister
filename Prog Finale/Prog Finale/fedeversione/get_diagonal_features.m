function diagonal_features_bin= get_diagonal_features(s)
% Inizializza il vettore delle caratteristiche diagonali
diagonal_features = zeros(1,4);
diagonal_features_bin=[];
% Diagonali principali
diag1 = diag(s);
diag2 = diag(flipud(s));

% Numero di pezzi nelle diagonali principali

diagonal_features(1,1)=sum(diag1 ~= 0); 
diagonal_features(1,2)=sum(diag2 ~= 0);

% Diagonali secondarie
for k = -size(s,1)+1:size(s,2)-1
    d1 = diag(s, k);
    d2 = diag(flipud(s), k);
    if sum(d1 ~= 0) ~= 0 && sum(d2 ~= 0) ~= 0
            diagonal_features(1,3)=sum(d1 ~= 0); 
            diagonal_features(1,4)=sum(d2 ~= 0);
    end
end
for i = 1:length(diagonal_features)
    % Converti ogni elemento in binario con una lunghezza fissa (es. 4 bit)
    bin_str = dec2bin(diagonal_features(i), 4);
    diagonal_features_bin = [diagonal_features_bin, bin_str - '0'];
end
diagonal_features_bin=diagonal_features_bin';
end