#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"

#Ask and then read a username
echo -e "\nEnter your username:"
read USERNAME
#Check if username exists in db
USERNAME_ID=$($PSQL "SELECT username_id FROM records WHERE username = '$USERNAME';")
if [[ -z $USERNAME_ID ]]
then
  #Create user
  INSERT_USERNAME=$($PSQL "INSERT INTO records(username) VALUES('$USERNAME');")
  USERNAME_ID=$($PSQL "SELECT username_id FROM records WHERE username = '$USERNAME';")
  # New player welcome message 
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  # Get history 
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM records WHERE username_id = $USERNAME_ID;")
  BEST_GAME=$($PSQL "SELECT best_game FROM records WHERE username_id = $USERNAME_ID;")
  # Pop welcome message and game history of player 
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#Select a random secret number
SECRET_NUMBER=$((1+$RANDOM % 1000))
# Print message to start the game 
echo -e "\nLet's play the game!"
echo -e "\nGuess the secret number between 1 and 1000:"
i=1
NUMBER_GUESSED=0

while [ $SECRET_NUMBER != $NUMBER_GUESSED ]
do 
  read NUMBER_GUESSED
  if ! [[  $NUMBER_GUESSED =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  elif [[ $NUMBER_GUESSED -lt $SECRET_NUMBER ]]
  then
    echo -e "\nIt's higher than that, guess again:"
    ((i++))
  elif [[ $NUMBER_GUESSED -gt $SECRET_NUMBER ]]
  then
    echo -e "\nIt's lower than that, guess again:"
    ((i++))
  elif [[ $NUMBER_GUESSED == $SECRET_NUMBER ]]
  then
    #insert data into sql
    BEST_GAME=$($PSQL "SELECT best_game FROM records WHERE username_id = $USERNAME_ID;")
    if [[ $i -lt $BEST_GAME ]]
    then
      UPDATE_RESULTS=$($PSQL "UPDATE records SET games_played=$GAMES_PLAYED+1, best_game=$i WHERE username_id=$USERNAME_ID;")
    else
      UPDATE_RESULTS=$($PSQL "UPDATE records SET games_played=$GAMES_PLAYED+1 WHERE username_id=$USERNAME_ID;")
    fi
    echo -e "\nYou guessed it in $i tries. The secret number was $SECRET_NUMBER. Nice job!"
    
  fi
done
