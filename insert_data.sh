#! /bin/bash
# script to insert data from games.csv into games and teams table

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")
# In each loop == row in .csv file do next:
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do 
  #escape first row of csv.
  if [[ $YEAR != "year" ]]
  then 
    #get team_id
    TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    #if not found insert team
    if [[ -z $TEAM_ID_WINNER ]]
    then 
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then 
        echo Inserted in teams $WINNER
      fi
      #get new major id
      TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi
    TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    #if not found insert team
    if [[ -z $TEAM_ID_OPPONENT ]]
    then 
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then 
        echo Inserted in teams $OPPONENT
      fi
      #get new major id
      TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi 
    INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
                                 VALUES($YEAR, '$ROUND', $TEAM_ID_WINNER, $TEAM_ID_OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
      then 
        echo Inserted in games $YEAR, $ROUND, $TEAM_ID_WINNER, $TEAM_ID_OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS
      fi
  fi   
done
