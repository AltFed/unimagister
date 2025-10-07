function B = swapRows(A)
    % This function takes a 6x7 matrix A and swaps its rows as described
    % Input:
    %   A - a 6x7 matrix
    % Output:
    %   B - the matrix A with rows swapped

    % Check if the input is a 6x7 matrix
    [rows, cols] = size(A);
    if rows ~= 6 || cols ~= 7
        error('Input must be a 6x7 matrix');
    end

    % Create an empty matrix of the same size as A
    B = zeros(size(A));

    % Swap the rows
    B(1,:) = A(6,:);
    B(2,:) = A(5,:);
    B(3,:) = A(4,:);
    B(4,:) = A(3,:);
    B(5,:) = A(2,:);
    B(6,:) = A(1,:);

end
