# ASOIAFDLE

A Wordle-style guessing game featuring characters from A Song of Ice and Fire (Game of Thrones).

## Features

- 🎮 **Daily Character Challenge**: Guess the character of the day based on their attributes
- 👥 **User Accounts**: Register and login to track your progress
- 🏆 **Leaderboards**: Compete globally or with friends
- 👫 **Friend System**: Add friends using unique friend codes
- 📊 **Guess Feedback**: Visual feedback showing which attributes match
- 🎨 **Responsive Design**: Beautiful UI with Tailwind CSS and HTMX
- 🔒 **Secure Authentication**: Password hashing with Safepass
- ⏱️ **Session Management**: 30-minute session timeout

## Tech Stack

- **Backend**: OCaml 5.3 with Dream web framework
- **Frontend**: HTMX for dynamic interactions, Tailwind CSS for styling
- **Database**: SQLite3 with Caqti for type-safe queries
- **Authentication**: Safepass for password hashing

## Prerequisites

- OCaml 5.3
- opam (OCaml package manager)
- SQLite3

## Installation

1. **Clone the repository**:

   ```bash
   cd asoiafdle
   ```

2. **Install dependencies**:

   ```bash
   opam install . --deps-only
   ```

3. **Build Tailwind CSS** (one-time setup):

   ```bash
   curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/download/v3.4.1/tailwindcss-linux-x64
   chmod +x tailwindcss-linux-x64
   ./tailwindcss-linux-x64 -i ./static/app.css -o ./static/output.css --minify
   ```

4. **Build the project**:

   ```bash
   dune build
   ```

## Running the Application

Start the server:

```bash
dune exec asoiafdle
```

The application will be available at `http://localhost:8080`

## How to Play

1. **Register** an account or play as a guest
2. **Guess** a character name from the ASOIAF universe
3. **Review** the feedback:
   - 🟢 **Green**: Attribute matches exactly
   - 🔴 **Red**: Attribute doesn't match
4. **Keep guessing** until you find the correct character!

## Game Attributes

Characters are compared based on:

- **Name**: Character's full name
- **House**: Their house allegiance
- **Region**: Geographic region
- **Gender**: Male/Female
- **Status**: Alive/Dead
- **First Appearance**: Book of first appearance
- **Title**: Noble title or role
- **Age Bracket**: Age range

## Social Features

### Friend System

- Each user gets a unique **friend code** (e.g., `FC-12345`)
- Share your code with friends to connect
- View your friends' scores on the leaderboard

### Leaderboards

- **Global Leaderboard**: See top players worldwide
- **Friends Leaderboard**: Compete with your friends
- Track games played and wins

## Project Structure

```
asoiafdle/
├── bin/
│   └── main.ml              # Application entry point
├── lib/
│   ├── models.ml            # Data type definitions
│   ├── db.ml                # Database setup and migrations
│   ├── auth.ml              # Authentication logic
│   ├── game.ml              # Game logic and character comparison
│   ├── handlers.ml          # HTTP request handlers
│   ├── views.ml             # HTML view generation
│   └── seed.ml              # Character seed data
├── static/
│   ├── app.css              # Tailwind input file
│   └── output.css           # Compiled Tailwind CSS
├── schema.sql               # Database schema
├── tailwind.config.js       # Tailwind configuration
└── dune-project             # Dune build configuration
```

## Development

### Database Schema

The application uses SQLite with the following tables:

- `users`: User accounts and authentication
- `characters`: ASOIAF character data
- `games`: Game history and results
- `friends`: Friend relationships

### Adding Characters

Edit `lib/seed.ml` to add more characters to the game. Each character needs:

```ocaml
{
  name = "Character Name";
  house = "House Name";
  region = "Region";
  gender = "Male/Female";
  status = "Alive/Dead";
  first_appearance = "Book Name";
  title = "Title/Role";
  age_bracket = "Age Range";
}
```

### Rebuilding CSS

After modifying `static/app.css`:

```bash
./tailwindcss-linux-x64 -i ./static/app.css -o ./static/output.css --minify
```

## Testing

Run unit tests:

```bash
dune runtest
```

## Security Notes

⚠️ **For Production Use**:

- Change the session secret in `bin/main.ml`
- Use environment variables for sensitive configuration
- Enable HTTPS
- Use a production-grade database
- Implement rate limiting
- Add CSRF protection to all forms (already implemented)

## License

This project is for educational purposes.

## Acknowledgments

- Inspired by Wordle by Josh Wardle
- Character data from A Song of Ice and Fire by George R.R. Martin
- Built with OCaml Dream framework
