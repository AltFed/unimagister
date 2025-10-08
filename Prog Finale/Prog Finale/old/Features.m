function  X = Features(s,player)
column_features_bin = extract_column_features(s);
threes = count_threes(s,player);
diagonal_features= get_diagonal_features(s);
d=(reshape(dec2bin(s(:),4),1,[])-'0')';
t=[d;column_features_bin;threes;diagonal_features];
% hashed_value = DataHash(t(:),struct('Method','SHA-256'));
% Converte l'hash SHA-256 in un array di byte
% Fac = (reshape(dec2bin(hex2dec(reshape(hashed_value, 1, [])'),4),1,[]) - '0')'; % array delle features
% active components of the feature vector
X=t;
end
