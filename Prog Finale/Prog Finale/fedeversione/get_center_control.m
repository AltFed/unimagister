function center_feature = get_center_control(s, player)
% Calcola una feature che rappresenta il controllo della colonna centrale (la 4a).
    opponent = 3 - player;
    center_column = s(:, 4);
    player_pieces = sum(center_column == player);
    opponent_pieces = sum(center_column == opponent);
    center_feature = player_pieces - opponent_pieces;
end
