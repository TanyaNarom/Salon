#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ My salon ~~~~\n"
echo -e "Welcome to my salon, how can I help you?\n"

CUSTOMER_NAME=""
CUSTOMER_PHONE=""

CREATE_APPOINTMENT(){
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/^ *//;s/ *$//'), $(echo $CUSTOMER_NAME | sed 's/^ *//;s/ *$//')?"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
#!/bin/bash

echo -e "\n~~~~ MY SALON ~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

PSQL="psql --username=postgres --dbname=salon -t --no-align -c"

SERVICES=$($PSQL "SELECT service_id, name FROM services;")

echo "$SERVICES" | while IFS="|" read -r ID NAME; do
  echo -e "$ID) $NAME"
done

while true; do
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")

  if [[ -z $SERVICE_NAME ]]
    then
      echo -e "\nI could not find that service. What would you like today?"
      echo "$SERVICES" | while IFS="|" read -r ID NAME; do
        echo -e "$ID) $NAME"
      done

      SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  else
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    break
  fi
done

echo -e "What's your phone number?"

read CUSTOMER_PHONE

PHONE_CUSTOMER=$($PSQL "SELECT phone, name FROM customers WHERE phone='$CUSTOMER_PHONE';")

if [[ -z $PHONE_CUSTOMER ]]
  then
    echo -e "I don't have a record for that phone number, what's your name?"

    read CUSTOMER_NAME

    NEW_CUSTOMER_NAME=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")

    NEW_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME';")

    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"

    read SERVICE_TIME

    NEW_CUSTOMER_TIME=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($NEW_CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME');")

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

else
  OLD_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

  OLD_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

  echo -e "\nWhat time would you like your $SERVICE_NAME, $OLD_CUSTOMER_NAME?"
  read SERVICE_TIME

  OLD_CUSTOMER_TIME=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($OLD_CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME');")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $OLD_CUSTOMER_NAME."
fi
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/^ *//;s/ *$//') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ *//;s/ *$//')."

  $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"
}

LIST_SERVICES(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    LIST_SERVICES "I could not find that service. What would you like today?"
    return
  fi

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

  if [[ -z $SERVICE_NAME ]]
  then
    LIST_SERVICES "I could not find that service. What would you like today?"
    return
  fi

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
  fi

  CREATE_APPOINTMENT
}

LIST_SERVICES
