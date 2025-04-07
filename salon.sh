#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ MY SALON ~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?"

LIST_SERVICES()
{
	if [[ $1 ]]
	then
		echo -e "\n$1"
	fi

	SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
	echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
	do
		echo "$SERVICE_ID) $SERVICE_NAME"
	done

  read SERVICE_ID_SELECTED
	if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
	then 
		LIST_SERVICES "\nI could not find that service. What would you like today?"
	else
		SERVICE_ID_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
		if [[ -z $SERVICE_ID_RESULT ]]
		then
			LIST_SERVICES "I could not find that service. What would you like today?"
    else
      CREATE_APPOINTMENT
		fi
	fi
}

CREATE_APPOINTMENT()
{
	echo -e "\nWhat's your phone number?"
	read CUSTOMER_PHONE
	CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
	if [[ -z $CUSTOMER_ID ]]
	then
    echo -e "\nI don't have a record for that phone number, what's your name?"
		read CUSTOMER_NAME
		SAVED_TO_TABLE_CUSTOMERS=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
	fi

  # create appointment
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
	SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -E 's/^ *| *$//g')
	echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
	read SERVICE_TIME
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
	echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
}

LIST_SERVICES


