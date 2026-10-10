-- SQLite needs foreign-key enforcement enabled per connection.
PRAGMA foreign_keys = ON;

-- Addresses shared by chess players and playing locations.
CREATE TABLE address (
    address_id INTEGER PRIMARY KEY,
    country TEXT NOT NULL,
    state TEXT,
    city TEXT NOT NULL,
    street TEXT NOT NULL,
    zip INTEGER NOT NULL
);

CREATE TABLE player (
    player_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    birth_date DATE NOT NULL,
    elo INTEGER NOT NULL CHECK (elo >= 0),
    address_id INTEGER NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    FOREIGN KEY (address_id) REFERENCES address(address_id)
);

CREATE TABLE location (
    location_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    address_id INTEGER NOT NULL,
    FOREIGN KEY (address_id) REFERENCES address(address_id)
);

CREATE TABLE tournament (
    tournament_id INTEGER PRIMARY KEY,
    location_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    prize_USD INTEGER NOT NULL CHECK (prize_USD >= 0),
    start_date DATE NOT NULL,
    end_date DATETIME NOT NULL,
    CHECK (datetime(end_date) >= datetime(start_date)),
    FOREIGN KEY (location_id) REFERENCES location(location_id)
);

CREATE TABLE tournament_player (
    tournament_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    seed INTEGER NOT NULL CHECK (seed > 0),
    rank INTEGER CHECK (rank IS NULL OR rank > 0),
    PRIMARY KEY (tournament_id, player_id),
    UNIQUE (tournament_id, seed),
    FOREIGN KEY (tournament_id) REFERENCES tournament(tournament_id),
    FOREIGN KEY (player_id) REFERENCES player(player_id)
);

CREATE TABLE game (
    game_id INTEGER PRIMARY KEY,
    table_id INTEGER NOT NULL,
    white_id INTEGER NOT NULL,
    black_id INTEGER NOT NULL,
    winner_id TEXT NOT NULL CHECK (winner_id IN ('white', 'black', 'draw')),
    date_time DATETIME NOT NULL,
    tournament_id INTEGER NOT NULL,
    CHECK (white_id <> black_id),
    UNIQUE (tournament_id, table_id, date_time),
    FOREIGN KEY (table_id) REFERENCES location(location_id),
    FOREIGN KEY (white_id) REFERENCES player(player_id),
    FOREIGN KEY (black_id) REFERENCES player(player_id),
    FOREIGN KEY (tournament_id) REFERENCES tournament(tournament_id)
);

CREATE TABLE move (
    move_id INTEGER PRIMARY KEY,
    game_id INTEGER NOT NULL,
    move_number INTEGER NOT NULL CHECK (move_number > 0),
    player_id INTEGER NOT NULL,
    start_position CHAR(2) NOT NULL CHECK (
        length(start_position) = 2 AND
        lower(substr(start_position, 1, 1)) BETWEEN 'a' AND 'h' AND
        substr(start_position, 2, 1) BETWEEN '1' AND '8'
    ),
    end_position CHAR(2) NOT NULL CHECK (
        length(end_position) = 2 AND
        lower(substr(end_position, 1, 1)) BETWEEN 'a' AND 'h' AND
        substr(end_position, 2, 1) BETWEEN '1' AND '8'
    ),
    promotion_piece TEXT CHECK (
        promotion_piece IS NULL OR
        promotion_piece IN ('queen', 'rook', 'bishop', 'knight')
    ),
    piece_type TEXT NOT NULL CHECK (
        piece_type IN ('king', 'queen', 'rook', 'bishop', 'knight', 'pawn')
    ),
    captured_piece TEXT CHECK (
        piece_type IN ('king', 'queen', 'rook', 'bishop', 'knight', 'pawn')
    ),
    UNIQUE (game_id, move_number),
    FOREIGN KEY (game_id) REFERENCES game(game_id),
    FOREIGN KEY (player_id) REFERENCES player(player_id)
);
