function count = countInDirection(board, startPos, player, direction)
% Funzione ausiliaria che conta i dischi consecutivi in una data direzione.
    count = 0;
    nextPos = startPos + direction;
    while all(nextPos >= [1,1]) && all(nextPos <= [6,7]) && board(nextPos(1), nextPos(2)) == player
        count = count + 1;
        nextPos = nextPos + direction;
    end
end
