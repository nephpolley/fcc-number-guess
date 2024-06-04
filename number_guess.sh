#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=users -t --no-align -c"

echo -e "\nEnter your username:"
read USERNAME

#get username from database
USERNAME_RESULT=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")
#if doesn't exist
if [[ -z $USERNAME_RESULT ]]
then
  #continue with game
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  #add user
  ADD_USER=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 0)")
else
  echo $USERNAME_RESULT | while IFS="|"; read GAMES_PLAYED BEST_GAME
  do
    #show game stats
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

#generate correct answer
CORRECT_ANSWER=$((1 + $RANDOM % 1000))
NUMBER_OF_GUESSES=1
echo "Guess the secret number between 1 and 1000:"

#begin game loop
while read GUESS
do
  #if guess is not a number
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    #try again
    echo "That is not an integer, guess again:"
  #if guess is correct
  elif [[ $GUESS == $CORRECT_ANSWER ]]
    then
      #break game
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $CORRECT_ANSWER. Nice job!"
      break
  #if guess is too low
  elif [[ $GUESS -lt $CORRECT_ANSWER ]]
    then
      echo "It's higher than that, guess again:"
  #if guess is too high
  elif [[ $GUESS -gt $CORRECT_ANSWER ]]
    then
      echo "It's lower than that, guess again:"
  fi
  #increment number of guesses
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
done

#get the previous high score
LAST_BEST_GUESS=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

#if doesn't exist or current game is better
if [[ -z $LAST_BEST_GUESS ]] || [[ $NUMBER_OF_GUESSES -lt $LAST_BEST_GUESS ]]
then
  #update the high score
  ADD_BEST_GUESS=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username='$USERNAME'")
fi

#increment games played for user
ADD_TO_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played+1 WHERE username='$USERNAME'")
