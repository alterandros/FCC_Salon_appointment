#!/bin/bash

PSQL='psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c'

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to my salon, how may I help you?"

#Enter or check Customer in database
GET_SERVICE() {
  #get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $1")
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  #get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    #add name and phone to database
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_C_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    if [[ $INSERT_C_RESULT == "INSERT 0 1" ]]
    then
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
  fi
  #Add appointment
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  INSERT_A_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $1, '$SERVICE_TIME')")
  if [[ $INSERT_A_RESULT == "INSERT 0 1" ]]
    then
      #Print appointment
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

#Menu prompt
MAIN_MENU() {

  if [[ $1 ]]
  then
    echo $1
  fi

  # Get all services
  SERVICES=$($PSQL "SELECT name, service_id FROM services")
  # Print services
  echo "$SERVICES" | while IFS="|" read SERVICE_NAME SERVICE_ID
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  #Read input for service
  read SERVICE_ID_SELECTED
  #If not a number
  if [[ ! $SERVICE_ID_SELECTED =~ [1-5] ]]
  then
    #return to Main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    #ask for phone number
    GET_SERVICE $SERVICE_ID_SELECTED
  fi
}

MAIN_MENU
