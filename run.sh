#!/bin/bash
# First check that Leo is installed.
if ! command -v leo &> /dev/null
then
    echo "leo is not installed."
    exit
fi

echo "
We will have 3 parties playing this round of auction in this example.

The private key and address of the Bidder #1.
private_key: APrivateKey1zkpG9Af9z5Ha4ejVyMCqVFXRKknSm8L1ELEwcc4htk9YhVK
address: aleo1yzlta2q5h8t0fqe0v6dyh9mtv4aggd53fgzr068jvplqhvqsnvzq7pj2ke

The private key and address of the Bidder #2.
private_key: APrivateKey1zkpAFshdsj2EqQzXh5zHceDapFWVCwR6wMCJFfkLYRKupug
address: aleo1esqchvevwn7n5p84e735w4dtwt2hdtu4dpguwgwy94tsxm2p7qpqmlrta4

The private key and address of the Auctioneer.
private_key: APrivateKey1zkp5wvamYgK3WCAdpBQxZqQX8XnuN2u11Y6QprZTriVwZVc
address: aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh
"

echo "
Let's start an auction!

###############################################################################
########                                                               ########
########           Step 0: Initialize a new 2-party auction            ########
########                                                               ########
########                -------------------------------                ########
########                |  OPEN   |    A    |    B    |                ########
########                -------------------------------                ########
########                |   Bid   |         |         |                ########
########                -------------------------------                ########
########                                                               ########
###############################################################################
"

echo "
First we take the role of the runner/Auctioneer who initializes the auction.

We're going to run the transition function "init_auction" to start the auction.
"

# This statement swaps in the private key of the auctioneer to .env so that the auction is owned by that address.
echo "
NETWORK=testnet3
PRIVATE_KEY=APrivateKey1zkp5wvamYgK3WCAdpBQxZqQX8XnuN2u11Y6QprZTriVwZVc
" > .env

# Have the auctioneer initialize the auction.
auction_output=$(leo run init_auction 2077160157502449938194577302446444field)

# Extract the auction ID from the output.
auction_id=$(echo "$auction_output" | grep -o '• [0-9]\{1,\}field' | awk '{print $2}')

echo "$auction_id"

echo "
Now, let's take the role of the first bidder - we'll swap in the private key and address of the first bidder to .env.

We're going to run the transition function "place_bid", slotting in the first bidder's public address and the amount that is being bid. The inputs are the user's public address and the amount being bid.

echo '
NETWORK=testnet3
PRIVATE_KEY=APrivateKey1zkpG9Af9z5Ha4ejVyMCqVFXRKknSm8L1ELEwcc4htk9YhVK
' > .env

leo run place_bid aleo1yzlta2q5h8t0fqe0v6dyh9mtv4aggd53fgzr068jvplqhvqsnvzq7pj2ke 10u64 "$auction_id" aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh
"

# Swap in the private key of the first bidder to .env.
echo "
NETWORK=testnet3
PRIVATE_KEY=APrivateKey1zkpG9Af9z5Ha4ejVyMCqVFXRKknSm8L1ELEwcc4htk9YhVK
" > .env

# Have the first bidder place a bid of 10.
leo run place_bid aleo1yzlta2q5h8t0fqe0v6dyh9mtv4aggd53fgzr068jvplqhvqsnvzq7pj2ke 10u64 "$auction_id" aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh

echo "
###############################################################################
########                                                               ########
########         Step 1: The first bidder places a bid of 10           ########
########                                                               ########
########                -------------------------------                ########
########                |  OPEN   |    A    |    B    |                ########
########                -------------------------------                ########
########                |   Bid   |   10    |         |                ########
########                -------------------------------                ########
########                                                               ########
###############################################################################
"

echo "
Now we're going to place another bid as the second bidder, so let's switch our keys to the second bidder and run the same transition function, this time with the second bidder's keys, public address, and different amount.

echo '
NETWORK=testnet3
PRIVATE_KEY=APrivateKey1zkpAFshdsj2EqQzXh5zHceDapFWVCwR6wMCJFfkLYRKupug
' > .env

leo run place_bid aleo1esqchvevwn7n5p84e735w4dtwt2hdtu4dpguwgwy94tsxm2p7qpqmlrta4 90u64 "$auction_id" aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh
"

# Swap in the private key of the second bidder to .env.
echo "
NETWORK=testnet3
PRIVATE_KEY=APrivateKey1zkpAFshdsj2EqQzXh5zHceDapFWVCwR6wMCJFfkLYRKupug
" > .env

# Have the second bidder place a bid of 90.
leo run place_bid aleo1esqchvevwn7n5p84e735w4dtwt2hdtu4dpguwgwy94tsxm2p7qpqmlrta4 90u64 "$auction_id" aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh

echo "
###############################################################################
########                                                               ########
########          Step 2: The second bidder places a bid of 90         ########
########                                                               ########
########                -------------------------------                ########
########                |  OPEN   |    A    |    B    |                ########
########                -------------------------------                ########
########                |   Bid   |   10    |   90    |                ########
########                -------------------------------                ########
########                                                               ########
###############################################################################
"

echo "
Now, let's take the role of the auctioneer, so we can determine which bid wins. Let's swap our keys to the auctioneer and run the resolve command on the output of the two bids from before. The resolve command takes the two output records from the bids as inputs and compares them to determine which bid wins.

echo '
NETWORK=testnet3
PRIVATE_KEY=APrivateKey1zkp5wvamYgK3WCAdpBQxZqQX8XnuN2u11Y6QprZTriVwZVc
' > .env

leo run resolve '{
        owner: aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh.private,
        bidder: aleo1yzlta2q5h8t0fqe0v6dyh9mtv4aggd53fgzr068jvplqhvqsnvzq7pj2ke.private,
        amount: 10u64.private,
        is_winner: false.private,
        auction_id: $auction_id.private,
        _nonce: 4668394794828730542675887906815309351994017139223602571716627453741502624516group.public
    }' '{
        owner: aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh.private,
        bidder: aleo1esqchvevwn7n5p84e735w4dtwt2hdtu4dpguwgwy94tsxm2p7qpqmlrta4.private,
        amount: 90u64.private,
        is_winner: false.private,
        auction_id: $auction_id.private,
        _nonce: 5952811863753971450641238938606857357746712138665944763541786901326522216736group.public
    }'
"

# Swaps in the private key of the auctioneer to .env.
echo "
NETWORK=testnet3
PRIVATE_KEY=APrivateKey1zkp5wvamYgK3WCAdpBQxZqQX8XnuN2u11Y6QprZTriVwZVc
" > .env

# Have the auctioneer select the winning bid.
leo run resolve "{
        owner: aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh.private,
        bidder: aleo1yzlta2q5h8t0fqe0v6dyh9mtv4aggd53fgzr068jvplqhvqsnvzq7pj2ke.private,
        amount: 10u64.private,
        is_winner: false.private,
        auction_id: $auction_id.private,
        _nonce: 4668394794828730542675887906815309351994017139223602571716627453741502624516group.public
    }" "{
        owner: aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh.private,
        bidder: aleo1esqchvevwn7n5p84e735w4dtwt2hdtu4dpguwgwy94tsxm2p7qpqmlrta4.private,
        amount: 90u64.private,
        is_winner: false.private,
        auction_id: $auction_id.private,
        _nonce: 5952811863753971450641238938606857357746712138665944763541786901326522216736group.public
    }"

echo "
###############################################################################
########                                                               ########
########     Step 3: The auctioneer determines the winning bidder      ########
########                                                               ########
########                -------------------------------                ########
########                |  OPEN   |    A    |  → B ←  |                ########
########                -------------------------------                ########
########                |   Bid   |   10    |  → 90 ← |                ########
########                -------------------------------                ########
########                                                               ########
###############################################################################
"

echo "
Keeping the key environment the same since we're still the auctioneer, let's finalize the auction and label the winning output as the winner. The finish transition takes the winning output bid as the input and marks it as such.

leo run finish '{
        owner: aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh.private,
        bidder: aleo1esqchvevwn7n5p84e735w4dtwt2hdtu4dpguwgwy94tsxm2p7qpqmlrta4.private,
        amount: 90u64.private,
        is_winner: false.private,
        auction_id: $auction_id.private,
        _nonce: 5952811863753971450641238938606857357746712138665944763541786901326522216736group.public
    }' $auction_id aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh
"

# Have the auctioneer finish the auction.
leo run finish "{
        owner: aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh.private,
        bidder: aleo1esqchvevwn7n5p84e735w4dtwt2hdtu4dpguwgwy94tsxm2p7qpqmlrta4.private,
        amount: 90u64.private,
        is_winner: false.private,
        auction_id: $auction_id.private,
        _nonce: 5952811863753971450641238938606857357746712138665944763541786901326522216736group.public
    }" $auction_id aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh

echo "
###############################################################################
########                                                               ########
########              The auctioneer completes the auction.            ########
########                                                               ########
########                -------------------------------                ########
########                |  CLOSE  |    A    |  → B ←  |                ########
########                -------------------------------                ########
########                |   Bid   |   10    |  → 90 ← |                ########
########                -------------------------------                ########
########                                                               ########
###############################################################################
"

# Swaps in the private key of the auctioneer to .env.
echo "
NETWORK=testnet3
PRIVATE_KEY=APrivateKey1zkpAFshdsj2EqQzXh5zHceDapFWVCwR6wMCJFfkLYRKupug
" > .env


echo "It's finally time for the winner to claim the prize. We start with updating the private key to the winner address in the .env file. The claim transition takes the winning record, owned by the winner and gets the prize record in return

leo run claim '{
  owner: aleo1esqchvevwn7n5p84e735w4dtwt2hdtu4dpguwgwy94tsxm2p7qpqmlrta4.private,
  bidder: aleo1esqchvevwn7n5p84e735w4dtwt2hdtu4dpguwgwy94tsxm2p7qpqmlrta4.private,
  amount: 90u64.private,
  is_winner: true.private,
  auction_id: 2805252584833208809872967597325381727971256629741137995614832105537063464740field.private,
  _nonce: 126339656685531136439127090372814066083378317113604862826439818916710711975group.public
}'
"

leo run claim "{
  owner: aleo1esqchvevwn7n5p84e735w4dtwt2hdtu4dpguwgwy94tsxm2p7qpqmlrta4.private,
  bidder: aleo1esqchvevwn7n5p84e735w4dtwt2hdtu4dpguwgwy94tsxm2p7qpqmlrta4.private,
  amount: 90u64.private,
  is_winner: true.private,
  auction_id: 2805252584833208809872967597325381727971256629741137995614832105537063464740field.private,
  _nonce: 126339656685531136439127090372814066083378317113604862826439818916710711975group.public
}" $auction_id

echo "
###############################################################################
########                                                               ########
########              Bidder B wins and claims the prize              ########
########                                                               ########
########                -------------------------------                ########
########                           |  → B ←  |                         ########
########                -------------------------------                ########
########                             10000                             ########
########                -------------------------------                ########
########                                                               ########
###############################################################################
"
