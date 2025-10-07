function  X = Features(s)
hashed_value = DataHash(s(:),struct('Method','SHA-256'));
% Converte l'hash SHA-256 in un array di byte
Fac = (reshape(dec2bin(hex2dec(reshape(hashed_value, 1, [])'),4),1,[]) - '0')'; % array delle features
% active components of the feature vector
column_features_bin = extract_column_features(s);
threes = count_threes(s);
diagonal_features= get_diagonal_features(s);
X=[Fac;column_features_bin;threes;diagonal_features];
end
