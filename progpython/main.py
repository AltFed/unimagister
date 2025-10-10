import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import random
from tqdm import tqdm

# =============================================================================
# 1. FUNZIONI PER LE FEATURES
# =============================================================================

def count_consecutive(array, player, length):
    """Conta il numero di sequenze consecutive di una data lunghezza in un array 1D."""
    count = 0
    # Utilizza una "finestra mobile" per controllare le sequenze
    for i in range(len(array) - length + 1):
        if np.all(array[i:i+length] == player):
            count += 1
    return count

def count_threes(board, player):
    """Conta il numero totale di "tris" per un giocatore sulla scacchiera."""
    threes = 0
    rows, cols = board.shape

    # Controllo orizzontale
    for r in range(rows):
        threes += count_consecutive(board[r, :], player, 3)
    
    # Controllo verticale
    for c in range(cols):
        threes += count_consecutive(board[:, c], player, 3)
        
    # Controllo diagonale (da sinistra-alto a destra-basso)
    for d in range(-rows + 1, cols):
        threes += count_consecutive(np.diagonal(board, offset=d), player, 3)
        
    # Controllo anti-diagonale (da destra-alto a sinistra-basso)
    flipped_board = np.fliplr(board)
    for d in range(-rows + 1, cols):
        threes += count_consecutive(np.diagonal(flipped_board, offset=d), player, 3)
        
    return threes

def extract_column_features(board):
    """Estrae il numero di dischi di ogni giocatore in ogni colonna."""
    num_columns = board.shape[1]
    features = np.zeros(num_columns * 2)
    for col in range(num_columns):
        features[col] = np.sum(board[:, col] == 1)
        features[col + num_columns] = np.sum(board[:, col] == 2)
    return features

def get_center_control(board, player):
    """Calcola una feature per il controllo della colonna centrale."""
    opponent = 3 - player
    center_column_idx = board.shape[1] // 2
    center_column = board[:, center_column_idx]
    return np.sum(center_column == player) - np.sum(center_column == opponent)

def extract_features(board, player):
    """Assembla il vettore finale di features per un dato giocatore."""
    opponent = 3 - player
    
    column_feats = extract_column_features(board)
    my_threes = count_threes(board, player)
    # Per ora non usiamo le minacce avversarie per mantenere le features semplici
    # opponent_threats = count_winning_threats(board, opponent) 
    center_control = get_center_control(board, player)
    
    # Ritorna un vettore colonna, come in MATLAB
    return np.array([*column_feats, my_threes, center_control]).reshape(-1, 1)


# =============================================================================
# 2. FUNZIONI PER LA LOGICA DI GIOCO
# =============================================================================

def create_board():
    """Crea una scacchiera di Forza 4 vuota (6 righe, 7 colonne)."""
    return np.zeros((6, 7), dtype=int)

def get_valid_actions(board):
    """Ritorna una lista di colonne in cui è possibile inserire un disco."""
    return [col for col in range(board.shape[1]) if board[0, col] == 0]

def execute_move(board, action, player):
    """Esegue una mossa per un giocatore e ritorna la nuova scacchiera e la posizione."""
    # Trova la prima riga libera dal basso
    for r in range(board.shape[0] - 1, -1, -1):
        if board[r, action] == 0:
            board[r, action] = player
            return board, (r, action)
    return None, None # Se la colonna è piena

def check_win(board, last_move):
    """Controlla se l'ultima mossa è stata vincente."""
    if last_move is None:
        return False
        
    player = board[last_move]
    row, col = last_move
    
    # Controlla 4 direzioni: orizzontale, verticale, 2 diagonali
    directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
    for dr, dc in directions:
        count = 1
        # Controlla in una direzione
        for i in range(1, 4):
            r, c = row + i * dr, col + i * dc
            if 0 <= r < 6 and 0 <= c < 7 and board[r, c] == player:
                count += 1
            else:
                break
        # Controlla nella direzione opposta
        for i in range(1, 4):
            r, c = row - i * dr, col - i * dc
            if 0 <= r < 6 and 0 <= c < 7 and board[r, c] == player:
                count += 1
            else:
                break
        if count >= 4:
            return True
            
    return False

# =============================================================================
# 3. FUNZIONI PER LA VISUALIZZAZIONE
# =============================================================================

def plot_win_rate(win_rates):
    """Genera un grafico del win rate durante l'addestramento."""
    plt.figure(figsize=(12, 6))
    plt.plot(win_rates)
    plt.title('Win Rate Agente in Self-Play (Media mobile)')
    plt.xlabel('Iterazioni (x500 episodi)')
    plt.ylabel('Win Rate')
    plt.grid(True)
    plt.show()

def plot_weights_surf(weights):
    """Genera un grafico 3D di superficie per la matrice dei pesi."""
    fig = plt.figure(figsize=(12, 8))
    ax = fig.add_subplot(111, projection='3d')
    
    d, A = weights.shape
    x = np.arange(A)      # Azioni (colonne 0-6)
    y = np.arange(d)      # Features
    X, Y = np.meshgrid(x, y)
    
    # Usiamo i pesi trasposti per far coincidere le dimensioni
    Z = weights.T
    
    ax.plot_surface(X, Y, Z, cmap='viridis')
    
    ax.set_xlabel('Azioni (Colonne)')
    ax.set_ylabel('Indice della Feature')
    ax.set_zlabel('Valore del Peso')
    ax.set_title('Visualizzazione 3D dei Pesi Appresi (w)')
    plt.show()


# =============================================================================
# 4. CICLO DI ADDESTRAMENTO PRINCIPALE
# =============================================================================

def train_agent():
    """Funzione principale che esegue l'intero ciclo di addestramento."""
    
    # --- Parametri di Inizializzazione ---
    A = 7                          # Numero di azioni
    d = 14 + 1 + 1                 # 14 colonne + 1 tris + 1 centro = 16 features
    num_episodes = 200000          # Numero di partite da giocare
    
    epsilon = 0.9                  # Epsilon iniziale
    gamma = 0.9                    # Fattore di sconto
    lambda_ = 0.8                  # Parametro tracce di eligibilità (lambda è una keyword in Python)
    learning_rate = 0.01           # Tasso di apprendimento
    
    w = np.zeros((d, A))
    w_opponent = np.zeros((d, A))
    
    win_history = []
    wins_in_last_500 = 0

    # --- Inizio Ciclo di Addestramento ---
    for e in tqdm(range(num_episodes), desc="Addestramento Agente"):
        
        current_epsilon = epsilon * (0.99995**e)
        if current_epsilon < 0.01: current_epsilon = 0.01
        
        alpha = learning_rate * (1 - (e / (num_episodes + 1)))

        if e % 100 == 0:
            w_opponent = w.copy()

        board = create_board()
        z = np.zeros_like(w) # Tracce di eligibilità
        
        # --- Ciclo di una singola partita ---
        done = False
        last_move_info = {'player': 2} # Inizia il giocatore 1
        
        while not done:
            # Turno del giocatore che deve muovere
            current_player = 3 - last_move_info['player']
            
            # Se è il turno del nostro agente
            if current_player == 1:
                features = extract_features(board, player=1)
                q_values = w.T @ features
                valid_actions = get_valid_actions(board)
                
                # Epsilon-Greedy
                if random.random() < current_epsilon:
                    action = random.choice(valid_actions)
                else:
                    valid_q_values = {a: q_values[a] for a in valid_actions}
                    action = max(valid_q_values, key=valid_q_values.get)

                # Esegui la mossa e osserva
                new_board, last_move = execute_move(board.copy(), action, player=1)
                
                # Controlla l'esito
                if check_win(new_board, last_move):
                    reward = 1.0
                    done = True
                elif not get_valid_actions(new_board):
                    reward = 0.5
                    done = True
                else:
                    reward = 0.0
                
                # --- APPRENDIMENTO Q-LEARNING ---
                if done:
                    delta = reward - (w[:, action].T @ features)
                else:
                    next_features = extract_features(new_board, player=1)
                    next_q_values = w.T @ next_features
                    valid_next_actions = get_valid_actions(new_board)
                    max_q_next = max([next_q_values[a] for a in valid_next_actions])
                    delta = reward + gamma * max_q_next - (w[:, action].T @ features)

                z = gamma * lambda_ * z
                z[:, action] += features.flatten()
                w += alpha * delta * z
                
                board = new_board
                last_move_info = {'player': 1, 'move': last_move}
            
            # Se è il turno dell'avversario
            else:
                features_opp = extract_features(board, player=2)
                q_values_opp = w_opponent.T @ features_opp
                valid_actions_opp = get_valid_actions(board)
                
                # L'avversario gioca sempre greedy
                valid_q_values_opp = {a: q_values_opp[a] for a in valid_actions_opp}
                action_opp = max(valid_q_values_opp, key=valid_q_values_opp.get)
                
                board, last_move_opp = execute_move(board.copy(), action_opp, player=2)

                # Controlla se l'avversario ha vinto (agente perde)
                if check_win(board, last_move_opp):
                    # Questa sconfitta viene appresa nel turno precedente dell'agente,
                    # che ha portato a questa situazione
                    done = True 
                elif not get_valid_actions(board):
                    done = True # Pareggio
                
                last_move_info = {'player': 2, 'move': last_move_opp}

        # Registra la vittoria per il grafico
        if reward == 1.0:
            wins_in_last_500 += 1
        if (e + 1) % 500 == 0:
            win_history.append(wins_in_last_500 / 500)
            wins_in_last_500 = 0
            
    return w, win_history


# =============================================================================
# 5. ESECUZIONE DEL PROGRAMMA
# =============================================================================
if __name__ == "__main__":
    trained_weights, win_rate_history = train_agent()
    
    print("\nAddestramento completato!")
    np.save("agente_forza4_pesi.npy", trained_weights)
    print("Pesi salvati in 'agente_forza4_pesi.npy'")
    
    # Genera i grafici
    plot_win_rate(win_rate_history)
    plot_weights_surf(trained_weights)
