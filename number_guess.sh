#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Check for username
echo -e "\nEnter your username:"
read USERNAME

# Search if user already exists or not
USER_DATA=$($PSQL "SELECT games_played, best_games FROM users WHERE username='$USERNAME'")

# If new user
if [[ -z $USER_DATA ]]; then 
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert new user into the database
  $PSQL "INSERT INTO users(username, games_played, best_games) VALUES('$USERNAME', 0, 0)"  > /dev/null
else 
  # If existing user
  echo "$USER_DATA" | while IFS='|' read -r GAMES_PLAYED BEST_GAME; do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# Start to play
# Define a random number
RANDOM_NUMBER=$((1 + RANDOM % 1000))
NB_OF_INPUT=0
echo -e "\nGuess the secret number between 1 and 1000:"

# Game loop
while true; do
  read USER_INPUT

  # Check if input is a number
  if [[ ! $USER_INPUT =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  else
    ((NB_OF_INPUT++))
    # Check if the guess is correct
    if (( USER_INPUT == RANDOM_NUMBER )); then
      echo "You guessed it in $NB_OF_INPUT tries. The secret number was $RANDOM_NUMBER. Nice job!"
      
      # Update user's best game if it's a new record
      FETCH_BEST_GAME=$($PSQL "SELECT best_games FROM users WHERE username='$USERNAME'")
      if (( $NB_OF_INPUT < FETCH_BEST_GAME || FETCH_BEST_GAME == 0 )); then
        $PSQL "UPDATE users SET best_games=$NB_OF_INPUT WHERE username='$USERNAME'"  > /dev/null
      fi

      # Increment the number of games played
      $PSQL "UPDATE users SET games_played=games_played + 1 WHERE username='$USERNAME'"  > /dev/null
      break
    elif (( USER_INPUT > RANDOM_NUMBER )); then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi
done

