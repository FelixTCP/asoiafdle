CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  nickname TEXT NOT NULL,
  friend_code TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Performance indexes for users table
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_friend_code ON users(friend_code);

CREATE TABLE IF NOT EXISTS characters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  allegience TEXT NOT NULL,
  region TEXT NOT NULL,
  gender TEXT NOT NULL,
  status TEXT NOT NULL,
  first_appearance TEXT NOT NULL,
  title TEXT NOT NULL,
  age_bracket TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS games (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  character_name TEXT NOT NULL,
  guesses INTEGER NOT NULL,
  guess_names TEXT,
  date TEXT NOT NULL,
  won BOOLEAN NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id),
  UNIQUE(user_id, date)
);

-- Performance indexes for games table
CREATE INDEX IF NOT EXISTS idx_games_user_date ON games(user_id, date);
CREATE INDEX IF NOT EXISTS idx_games_date ON games(date);

CREATE TABLE IF NOT EXISTS friends (
  user_id INTEGER NOT NULL,
  friend_id INTEGER NOT NULL,
  PRIMARY KEY (user_id, friend_id),
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (friend_id) REFERENCES users (id)
);

-- Performance index for friends table
CREATE INDEX IF NOT EXISTS idx_friends_user_id ON friends(user_id);

-- Application metadata table for tracking metrics
CREATE TABLE IF NOT EXISTS app_metadata (
  key TEXT PRIMARY KEY,
  value INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Initialize deletion counter
INSERT OR IGNORE INTO app_metadata (key, value) VALUES ('total_deletions', 0);
INSERT OR IGNORE INTO app_metadata (key, value) VALUES ('total_registrations', 0);
INSERT OR IGNORE INTO app_metadata (key, value) VALUES ('total_games_won', 0);


