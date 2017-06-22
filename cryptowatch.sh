### ethwatch.sh
### v0.2
### changelog: decided to use github

### Configurables

# Set the API polling interval - WARNING: Do 
__API_INTERVAL=30
# Set the dollar amount threshold above which we will start beeping
WATCHPRICE=349


while :
do
    # Scrape the API for the price in USD of 1 ETH
    ETHAPIPRICE=$(curl -sqk 'https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD' | jq -M '.' | awk '/USD/ {print $2}')
    # Ensure 2 decimal places for printing the real price since bash doesn't handle float well
    ETHPRICE=$(echo "scale=2;${ETHAPIPRICE} / 1" | bc)
    # And grab the dollar amount for conditional comparison

    ETHDOLLAR=$(echo ${ETHPRICE} | cut -d\. -f1)

    if [[ "${ETHDOLLAR}" -gt ${WATCHPRICE} ]]
    then
        beep; beep; beep; beep; beep; beep; beep; beep; beep; beep; beep; beep; beep; beep; beep; beep; beep; beep;
        echo "ETH is currently \$${ETHPRICE} at $(date) - SELL!"
    elif [[ "${ETHDOLLAR}" -lt 100 ]]
    then
        beep; beep; beep
        echo "ETH JUST DROPPED HARD - Current price is \$${ETHPRICE} - might want to buy a lot!"
    elif [[ "${ETHDOLLAR}" -lt 10 ]]
    then
        beep; beep; beep; beep; beep; beep;
        echo "ETH HAS CRASHED - BUY BUY BUY - Current price is \$${ETHPRICE}"
    else
        echo "ETH is \$${ETHPRICE} at $(date). Alarm set to ring after ETH is over \$${WATCHPRICE}."
    fi
    sleep 30
done
