#!/bin/bash

#the following script makes sstudents database dump
#pg_dump --clean --create --inserts --username=freecodecamp salon > salon.sql
#the following script uploads the dump file to the database
#psql -U postgres < salon.sql

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

SERVICES_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?"
  fi

  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  
  # render service menu
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # read service id
  read SERVICE_ID_SELECTED

  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to services menu
    SERVICES_MENU "That is not a valid service number. What would you like today?"
  else
    # check if giver service id exists
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      
    # if does not exist
    if [[ -z $SERVICE_NAME ]]
    then
      # send to services menu
      SERVICES_MENU "I could not find that service. What would you like today?"
    else
      # read customer phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      # check if customer phone number exists in the database 
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # if customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get new customer name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi

      # get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")          

      # read appointment time
      echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
      read SERVICE_TIME

      # insert new appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      # print confirmation
      if [[ $INSERT_APPOINTMENT_RESULT == 'INSERT 0 1' ]]
      then
        echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      else
        echo Something went wrong, please try again later
      fi
    fi
  fi
}

SERVICES_MENU
