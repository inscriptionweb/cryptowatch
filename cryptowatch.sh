#!/usr/bin/env bash

### cryptowatch.sh
### 20170915
### v0.3.1

### Known issues:
### API interval and original value are used via two variables messily.

### Configurables

# Set the API polling interval in seconds - be nice or the API might block you
__API_INTERVAL=30

# Set the dollar amount threshold above which we will start beeping
__WATCH_PRICE=350

# How much you've put into ETH (not required)
__INVESTED=260.28

# Set the API scraping URL
__API_URL="https://api.cryptowat.ch/markets/gdax/ethusd/price"

### Start script

echo "API scrape URL: ${__API_URL}"
__API_ORIG=${__API_INTERVAL}

### Loop through price

while :
do

    # Scrape the API for the price in USD of 1 ETH
    ETHAPIPRICE=$(curl -sq ${__API_URL} | awk -F: '/price/ {print $2}' | tr -d '\ ')
    
    # Ensure 2 decimal places for printing the real price since bash doesn't handle float well
    ETHPRICE=$(echo "scale=2;${ETHAPIPRICE} / 1" | bc)
    
    # And grab the dollar amount for conditional comparison
    ETHDOLLAR=$(echo ${ETHPRICE} | cut -d\. -f1)

    if [[ "${ETHDOLLAR}" -gt ${__WATCH_PRICE} ]]

    then
        __API_INTERVAL=$(( ${__API_INTERVAL} * 0.1 ))
        beep; beep; beep
        echo "$(date): ETH price has exceeded the watch price - current price is \$${ETHPRICE}"
        __API_INTERVAL=${__API_ORIG}

    elif [[ "${ETHDOLLAR}" -lt $(printf %.0f $(echo "scale=0;${ETHAPIPRICE} * 0.50" | bc)) && "${ETHDOLLAR}" -gt $(printf %.0f $(echo "scale=0;${ETHAPIPRICE} * 0.05" | bc)) ]]

    then
        __API_INTERVAL=$(( ${__API_INTERVAL} * 0.1 ))
        beep; beep; beep
        echo "$(date): ETH price has dropped significantly - current price is \$${ETHPRICE}"
        __API_INTERVAL=${__API_ORIG}

    elif [[ "${ETHDOLLAR}" -lt $(printf %.0f $(echo "scale=0;${ETHAPIPRICE} * 0.75" | bc)) && "${ETHDOLLAR}" -gt $(printf %.0f $(echo "scale=0;${ETHAPIPRICE} * 0.50" | bc)) ]]

    then
        __API_INTERVAL=$(( ${__API_INTERVAL} * 0.1 ))
        beep; beep; beep
        echo "$(date): ETH price is \$${ETHPRICE} - crashed?"
        __API_INTERVAL=${__API_ORIG}

    else
        if [[ "${__API_INTERVAL}" -eq "${__API_ORIG}" ]]
        then
            echo "$(date): ETH \$${ETHPRICE} - Alarm when ETH > \$${__WATCH_PRICE}; in for \$${__INVESTED}"
        else
            __API_INTERVAL=${__API_ORIG}
            echo "$(date): ETH \$${ETHPRICE} - Alarm when ETH > \$${__WATCH_PRICE}; in for \$${__INVESTED}"
       fi
    fi

    sleep ${__API_INTERVAL}

done
