import numpy as np
import os

# =============================================================================
# 1. FUNZIONI DI FEATURE E LOGICA (Copiate dallo script di addestramento)
# =============================================================================

def count_consecutive(array, player, length):
    count = 0
    for i in range(len(array) - length + 1):
        if np.all(array[i:i+length] == player):
            count += 1
    return count

def count_threes(board, player):
    threes = 0
    rows, cols = board.shape
    for r in range(rows):
        threes += count_consecutive(board[r, :], player, 3)
    for c in range(cols):
        threes += count_consecutive(board[:, c], player, 3)
    for d in range(-rows + 1, cols):
        threes += count_consecutive(np.diagonal(board, offset=d), player, 3)
    flipped_board = np.fliplr(board)
    for d in range(-rows + 1, cols):
        threes += count_consecutive(np.diagonal(flipped_board, offset=d), player, 3)
    return threes

def extract_column_features(board):
    num_columns = board.shape[1]
    features = np.zeros(num_columns * 2)
    for col in range(num_columns):
        features[col] = np.sum(board[:, col] == 1)
        features[col + num_columns] = np.sum(board[:, col] == 2)
    return features

def get_center_control(board, player):
    opponent = 3 - player
    center_column_idx = board.shape[1] // 2
    center_column = board[:, center_column_idx]
    return np.sum(center_column == player) - np.sum(center_column == opponent)

def extract_features(board, player):
    column_feats = extract_column_features(board)
    my_threes = count_threes(board, player)
    center_control = get_center_control(board, player)
    return np.array([*column_feats, my_threes, center_control]).reshape(-1, 1)

def get_valid_actions(board):
    return [col for col in range(board.shape[1]) if board[0, col] == 0]

def execute_move(board, action, player):
    for r in range(board.shape[0] - 1, -1, -1):
        if board[r, action] == 0:
            board[r, action] = player
            return board, (r, action)
    return None, None

def check_win(board, last_move):
    if last_move is None: return False
    player = board[last_move]
    row, col = last_move
    directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
    for dr, dc in directions:
        count = 1
        for i in range(1, 4):
            r, c = row + i * dr, col + i * dc
            if 0 <= r < 6 and 0 <= c < 7 and board[r, c] == player: count += 1
            else: break
        for i in range(1, 4):
            r, c = row - i * dr, col - i * dc
            if 0 <= r < 6 and 0 <= c < 7 and board[r, c] == player: count += 1
            else: break
        if count >= 4: return True
    return False

# =============================================================================
# 2. FUNZIONI PER L'INTERFACCIA DI GIOCO
# =============================================================================

def print_board(board):
    """Stampa la scacchiera sul terminale in modo leggibile."""
    # Mappa i numeri ai simboli
    symbols = {0: '.', 1: 'X', 2: 'O'}
    print("\n  0 1 2 3 4 5 6")
    print("-----------------")
    # Stampa la scacchiera flippata per una visualizzazione corretta
    for r in range(board.shape[0]):
        row_str = " ".join([symbols[p] for p in board[r, :]])
        print(f"| {row_str} |")
    print("-----------------")

def get_human_move(board):
    """Chiede all'utente una mossa e la valida."""
    while True:
        try:
            col_str = input("Scegli una colonna (0-6): ")
            col = int(col_str)
            if col in get_valid_actions(board):
                return col
            else:
                print("ERRORE: Colonna non valida o piena. Riprova.")
        except ValueError:
            print("ERRORE: Inserisci un numero intero.")

# =============================================================================
# 3. CICLO DI GIOCO PRINCIPALE
# =============================================================================

def play_game():
    """Funzione principale che gestisce la partita tra umano e IA."""
    
    # --- Caricamento Pesi ---
    weights_file = "agente_forza4_pesi.npy"
    if not os.path.exists(weights_file):
        print(f"ERRORE: File dei pesi '{weights_file}' non trovato.")
        print("Assicurati di aver prima eseguito lo script di addestramento.")
        return
        
    w = np.load(weights_file)
    print("Pesi dell'agente caricati con successo!")

    # --- Inizializzazione Partita ---
    board = np.zeros((6, 7), dtype=int)
    turn = 0 # 0 per l'AI, 1 per l'umano

    print("\n--- INIZIA LA PARTITA ---")
    print("Tu sei 'O', l'intelligenza artificiale è 'X'.")
    print("L'IA fa la prima mossa.")
    print_board(board)

    while True:
        # --- Turno dell'IA (Giocatore 1) ---
        if turn == 0:
            features = extract_features(board, player=1)
            q_values = w.T @ features
            valid_actions = get_valid_actions(board)
            
            # L'IA sceglie la mossa migliore (greedy)
            valid_q_values = {a: q_values[a] for a in valid_actions}
            action = max(valid_q_values, key=valid_q_values.get)
            
            board, last_move = execute_move(board, action, player=1)
            print(f"\nL'IA ha scelto la colonna: {action}")
            print_board(board)

            if check_win(board, last_move):
                print("L'IA HA VINTO!")
                break
        
        # --- Turno dell'Umano (Giocatore 2) ---
        else:
            action = get_human_move(board)
            board, last_move = execute_move(board, action, player=2)
            print_board(board)

            if check_win(board, last_move):
                print("COMPLIMENTI, HAI VINTO!")
                break
        
        # Controlla il pareggio
        if not get_valid_actions(board):
            print("PAREGGIO!")
            break
            
        # Passa il turno
        turn = 1 - turn

# Esecuzione del gioco
if __name__ == "__main__":
    play_game()
