-- Mailing addresses for players and chess venues.
INSERT INTO address (address_id, country, state, city, street, zip) VALUES
(1, 'United States', 'UT', 'Salt Lake City', '125 South Temple', 84101),
(2, 'United States', 'CO', 'Denver', '1700 Lincoln Street', 80203),
(3, 'United States', 'UT', 'Provo', '100 North University Avenue', 84601),
(4, 'United States', 'UT', 'Sandy', '9300 South State Street', 84070),
(5, 'United States', 'CO', 'Boulder', '1500 Pearl Street', 80302),
(6, 'United States', 'UT', 'Ogden', '2450 Washington Boulevard', 84401);

INSERT INTO player
    (player_id, name, birth_date, elo, address_id, phone_number)
VALUES
(1, 'Alice Morgan', '1990-04-12', 1820, 1, '801-555-0101'),
(2, 'David Chen', '1985-09-22', 1765, 2, '303-555-0102'),
(3, 'Priya Patel', '1994-11-03', 2010, 3, '801-555-0103'),
(4, 'Mateo Ruiz', '1998-02-18', 1640, 4, '801-555-0104'),
(5, 'Nora Williams', '1979-07-30', 1935, 5, '303-555-0105'),
(6, 'Ethan Brooks', '2001-01-15', 1585, 6, '801-555-0106'),
(7, 'Sofia Kim', '1992-06-08', 1870, 1, '801-555-0107'),
(8, 'Owen Davis', '1988-12-01', 1710, 2, '303-555-0108');

INSERT INTO location (location_id, name, address_id) VALUES
(1, 'Wasatch Chess Club', 1),
(2, 'Provo City Library', 3),
(3, 'Rocky Mountain Chess Center', 2);

INSERT INTO tournament
    (tournament_id, location_id, name, prize_USD, start_date, end_date)
VALUES
(1, 1, 'Wasatch Open', 5000, '2025-05-10', '2025-05-12 18:00:00'),
(2, 2, 'Provo Summer Classic', 2500, '2025-06-20', '2025-06-21 17:00:00'),
(3, 3, 'Front Range Rapid', 1000, '2025-08-16', '2025-08-16 19:00:00');

INSERT INTO tournament_player (tournament_id, player_id, seed, rank) VALUES
(1, 1, 1, 2),
(1, 2, 2, 3),
(1, 3, 3, 1),
(1, 4, 4, 4),
(1, 7, 5, 5),
(2, 3, 1, 1),
(2, 5, 2, 2),
(2, 6, 3, 4),
(2, 8, 4, 3),
(3, 1, 1, 2),
(3, 5, 2, 1),
(3, 2, 3, 3),
(3, 7, 4, 4);

-- table_id is the board number at the venue. winner_id stores the winning color
-- or draw because the diagram marks it as an enum.
INSERT INTO game
    (game_id, table_id, white_id, black_id, winner_id, date_time, tournament_id)
VALUES
(1, 1, 1, 2, 'white', '2025-05-10 09:00:00', 1),
(2, 2, 3, 4, 'draw', '2025-05-10 09:00:00', 1),
(3, 1, 2, 3, 'black', '2025-05-11 09:00:00', 1),
(4, 1, 5, 6, 'black', '2025-06-20 10:00:00', 2),
(5, 2, 7, 8, 'white', '2025-06-20 10:00:00', 2),
(6, 3, 1, 5, 'draw', '2025-08-16 10:00:00', 3);

-- captured_piece stores the lowercase piece type when a move captures; otherwise
-- it is NULL. The schema does not include a separate chess-piece table.
INSERT INTO move
    (move_id, game_id, move_number, player_id, start_position, end_position,
     promotion_piece, piece_type, captured_piece)
VALUES
(1, 1, 1, 1, 'e2', 'e4', NULL, 'pawn', NULL),
(2, 1, 2, 2, 'e7', 'e5', NULL, 'pawn', NULL),
(3, 1, 3, 1, 'g1', 'f3', NULL, 'knight', NULL),
(4, 1, 4, 2, 'b8', 'c6', NULL, 'knight', NULL),
(5, 1, 5, 1, 'f1', 'b5', NULL, 'bishop', NULL),
(6, 1, 6, 2, 'a7', 'a6', NULL, 'pawn', NULL),
(7, 2, 1, 3, 'd2', 'd4', NULL, 'pawn', NULL),
(8, 2, 2, 4, 'd7', 'd5', NULL, 'pawn', NULL),
(9, 2, 3, 3, 'c2', 'c4', NULL, 'pawn', NULL),
(10, 2, 4, 4, 'e7', 'e6', NULL, 'pawn', NULL),
(11, 2, 5, 3, 'b1', 'c3', NULL, 'knight', NULL),
(12, 2, 6, 4, 'g8', 'f6', NULL, 'knight', NULL),
(13, 3, 1, 2, 'c2', 'c4', NULL, 'pawn', NULL),
(14, 3, 2, 3, 'e7', 'e5', NULL, 'pawn', NULL),
(15, 3, 3, 2, 'g1', 'f3', NULL, 'knight', NULL),
(16, 3, 4, 3, 'b8', 'c6', NULL, 'knight', NULL),
(17, 4, 1, 5, 'e2', 'e4', NULL, 'pawn', NULL),
(18, 4, 2, 6, 'c7', 'c5', NULL, 'pawn', NULL),
(19, 4, 3, 5, 'g1', 'f3', NULL, 'knight', NULL),
(20, 4, 4, 6, 'd7', 'd6', NULL, 'pawn', NULL),
(21, 5, 1, 7, 'd2', 'd4', NULL, 'pawn', NULL),
(22, 5, 2, 8, 'g8', 'f6', NULL, 'knight', NULL),
(23, 5, 3, 7, 'c2', 'c4', NULL, 'pawn', NULL),
(24, 5, 4, 8, 'e7', 'e6', NULL, 'pawn', NULL),
(25, 6, 1, 1, 'e2', 'e4', NULL, 'pawn', NULL),
(26, 6, 2, 5, 'e7', 'e5', NULL, 'pawn', NULL),
(27, 6, 3, 1, 'g1', 'f3', NULL, 'knight', NULL),
(28, 6, 4, 5, 'b8', 'c6', NULL, 'knight', NULL),
(29, 1, 7, 1, 'b5', 'c6', NULL, 'bishop', 'knight'),
(30, 2, 7, 3, 'c4', 'd5', NULL, 'pawn', 'pawn'),
(31, 3, 5, 2, 'd2', 'd4', NULL, 'pawn', NULL),
(32, 3, 6, 3, 'e5', 'd4', NULL, 'pawn', 'pawn'),
(33, 4, 5, 5, 'd2', 'd4', NULL, 'pawn', NULL),
(34, 4, 6, 6, 'c5', 'd4', NULL, 'pawn', 'pawn');
