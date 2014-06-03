
-- sqlite3

-- CREATE TABLE users (
--   id INTEGER PRIMARY KEY,
--   fname VARCHAR(255) NOT NULL,
--   lname VARCHAR(255) NOT NULL,
--   email VARCHAR(255) NOT NULL,
--   password_digest VARCHAR(255) NOT NULL,
--   session_token VARCHAR(255) NOT NULL
-- );
--
-- CREATE TABLE statuses (
--   id INTEGER PRIMARY KEY,
--   body VARCHAR(255) NOT NULL,
--   author_id INTEGER NOT NULL,
--
--   FOREIGN KEY(author_id) REFERENCES user(id)
-- );


-- postgresql

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  password_digest VARCHAR(255) NOT NULL,
  session_token VARCHAR(255) NOT NULL
);

CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL
);

ALTER TABLE users ADD COLUMN photo_url VARCHAR(255);





-- sqlite3 examples

-- CREATE TABLE cats (
--   id INTEGER PRIMARY KEY,
--   name VARCHAR(255) NOT NULL,
--   owner_id INTEGER NOT NULL,
--
--   FOREIGN KEY(owner_id) REFERENCES human(id)
-- );
--
-- CREATE TABLE humans (
--   id INTEGER PRIMARY KEY,
--   fname VARCHAR(255) NOT NULL,
--   lname VARCHAR(255) NOT NULL,
--   house_id INTEGER NOT NULL,
--
--   FOREIGN KEY(house_id) REFERENCES human(id)
-- );
--
-- CREATE TABLE houses (
--   id INTEGER PRIMARY KEY,
--   address VARCHAR(255) NOT NULL
-- );
--
-- INSERT INTO
--   houses (address)
-- VALUES
--   ("26th and Guerrero"), ("Dolores and Market");
--
-- INSERT INTO
--   humans (fname, lname, house_id)
-- VALUES
--   ("Devon", "Watts", 1), ("Matt", "Rubens", 1), ("Ned", "Ruggeri", 2);
--
-- INSERT INTO
--   cats (name, owner_id)
-- VALUES
--   ("Breakfast", 1), ("Earl", 2), ("Haskell", 3), ("Markov", 3);
