# Text-to-SQL examples

These examples use the chess tournament schema in `setup.sql` and sample records in `setupData.sql`. The questions and responses below are drawn from the response logs in this repository.

## Tournament participation

**Question:** Which players participated in a given tournament, and what were their seeds and final ranks?

**SQLite query:**

```sql
SELECT
  T1.name AS player_name,
  T2.seed,
  T2.rank,
  T3.name AS tournament_name
FROM player AS T1
JOIN tournament_player AS T2
  ON T1.player_id = T2.player_id
JOIN tournament AS T3
  ON T2.tournament_id = T3.tournament_id;
```

**Response:**

```text
Here are the players, their seeds, and their final ranks grouped by tournament:

**Wasatch Open**
* **Priya Patel:** Seed 3, Rank 1
* **Alice Morgan:** Seed 1, Rank 2
* **David Chen:** Seed 2, Rank 3
* **Mateo Ruiz:** Seed 4, Rank 4
* **Sofia Kim:** Seed 5, Rank 5

**Provo Summer Classic**
* **Priya Patel:** Seed 1, Rank 1
* **Nora Williams:** Seed 2, Rank 2
* **Owen Davis:** Seed 4, Rank 3
* **Ethan Brooks:** Seed 3, Rank 4

**Front Range Rapid**
* **Nora Williams:** Seed 2, Rank 1
* **Alice Morgan:** Seed 1, Rank 2
* **David Chen:** Seed 3, Rank 3
* **Sofia Kim:** Seed 4, Rank 4
```

## Most common opening move

**Question:** What is the most common opening move?

**SQLite query:**

```sql
SELECT start_position || '-' || end_position AS opening_move
FROM move
WHERE move_number = 1
GROUP BY start_position, end_position
ORDER BY COUNT(*) DESC
LIMIT 1;
```

**Result:** `e2-e4`

**Response:** The most common opening move is e2-e4!

## Tournaments by city

**Question:** What tournaments have been held in each city?

**SQLite query:**

```sql
SELECT
  t.name AS tournament_name,
  a.city
FROM tournament AS t
JOIN location AS l ON t.location_id = l.location_id
JOIN address AS a ON l.address_id = a.address_id;
```

**Response:**

```text
Here are the tournaments that have been held in each city:

* **Salt Lake City:** Wasatch Open
* **Provo:** Provo Summer Classic
* **Denver:** Front Range Rapid
```

## Player with the most wins

**Question:** Which player has won the most games?

**SQLite query:**

```sql
SELECT p.name
FROM player AS p
JOIN game AS g ON (
  (g.winner_id = 'white' AND g.white_id = p.player_id) OR
  (g.winner_id = 'black' AND g.black_id = p.player_id)
)
GROUP BY p.player_id, p.name
ORDER BY COUNT(*) DESC
LIMIT 1;
```

**Result:** Alice Morgan.

**Response:** The player who has won the most games is Alice Morgan!

## Most frequently moved piece type

**Question:** What pieces were most frequently moved across all games?

**SQLite query:**

```sql
SELECT piece_type
FROM move
GROUP BY piece_type
ORDER BY COUNT(*) DESC
LIMIT 1;
```

**Result:** `pawn`

**Response:** The pawn was the piece most frequently moved across all games!

## Games per tournament

**Question:** How many games did each tournament contain?

**SQLite query:**

```sql
SELECT
  t.name AS tournament_name,
  COUNT(g.game_id) AS game_count
FROM tournament AS t
LEFT JOIN game AS g ON t.tournament_id = g.tournament_id
GROUP BY t.tournament_id, t.name;
```

**Response:**

```text
Here is how many games each tournament contained:

* **Wasatch Open:** 3 games
* **Provo Summer Classic:** 2 games
* **Front Range Rapid:** 1 game
```

## Longest game

**Question:** What was the longest game in terms of moves?

One logged response returned the game ID:

```sql
SELECT g.game_id
FROM game AS g
JOIN move AS m ON g.game_id = m.game_id
GROUP BY g.game_id
ORDER BY MAX(m.move_number) DESC
LIMIT 1;
```

**Result:** Game 1.

**Response:** The longest game in terms of moves is game number 1!

Another logged response included the tournament and move count:

```sql
SELECT
  g.game_id,
  t.name AS tournament_name,
  COUNT(m.move_id) AS move_count
FROM game AS g
JOIN tournament AS t ON g.tournament_id = t.tournament_id
JOIN move AS m ON g.game_id = m.game_id
GROUP BY g.game_id, t.name
ORDER BY move_count DESC
LIMIT 1;
```

**Result:** Game 1, Wasatch Open, 7 recorded moves.

**Response:** The longest game was game ID 1 from the Wasatch Open tournament, which lasted for 7 moves!

## Question outside the database

**Question:** Which player has the cutest dog?

The database has no pet or dog information. The logged response returned a literal answer instead of querying unrelated tables:

```sql
SELECT 'I am sorry, but the database does not contain information about pets or dogs.' AS answer;
```

**Response:** I am sorry, but the database does not contain information about pets or dogs!
