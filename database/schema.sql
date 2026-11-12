CREATE DATABASE IF NOT EXISTS gamestats_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE gamestats_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE games (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE game_modes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,

    UNIQUE (game_id, id),
    UNIQUE (game_id, name),

    FOREIGN KEY (game_id)
        REFERENCES games(id)
        ON DELETE CASCADE
);

CREATE TABLE matches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    game_id INT NOT NULL,
    game_mode_id INT NOT NULL,
    played_at DATETIME NOT NULL,
    duration_seconds INT,
    result VARCHAR(20) NOT NULL,
    map_name VARCHAR(100),
    source VARCHAR(20) DEFAULT 'manual',

    FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    FOREIGN KEY (game_id)
        REFERENCES games(id),

    FOREIGN KEY (game_id, game_mode_id)
        REFERENCES game_modes(game_id, id),

    CHECK (duration_seconds IS NULL OR duration_seconds >= 0),
    CHECK (result IN ('win', 'loss', 'draw', 'abandoned')),
    CHECK (source IN ('manual', 'api', 'import'))
);

CREATE TABLE stat_definitions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT NOT NULL,
    code VARCHAR(50) NOT NULL,
    label VARCHAR(100) NOT NULL,
    unit VARCHAR(30),
    aggregation_type VARCHAR(30) DEFAULT 'sum',

    UNIQUE (game_id, code),

    FOREIGN KEY (game_id)
        REFERENCES games(id)
        ON DELETE CASCADE
);

CREATE TABLE match_stat_values (
    id INT AUTO_INCREMENT PRIMARY KEY,
    match_id INT NOT NULL,
    stat_definition_id INT NOT NULL,
    value DECIMAL(12,2) NOT NULL,

    UNIQUE (match_id, stat_definition_id),

    FOREIGN KEY (match_id)
        REFERENCES matches(id)
        ON DELETE CASCADE,

    FOREIGN KEY (stat_definition_id)
        REFERENCES stat_definitions(id)
);

CREATE INDEX idx_matches_user_date
ON matches(user_id, played_at);

CREATE INDEX idx_matches_game
ON matches(game_id);
