// The `program` scope defines the data types, functions, and state associated with the `auction` program.
program auction.aleo {

    // A bid in an auction.
    // - `owner`     : The address of the account that owns the record associated with this bid.
    //                 This is separate from the address of the account that placed the bid.
    // - `bidder`    : The address of the account that placed the bid.
    // - `amount`    : The amount of the bid.
    // - `is_winner` : Whether the bid is the winning bid.
    record Bid {
        owner: address,
        bidder: address,
        amount: u64,
        is_winner: bool,
        auction_id: field
    }

    struct Auction {
        runner: address,
        title: field,
        complete: bool,
        prize_claimed: bool
    }

    record Prize {
        owner: address,
        amount: u64
    }

    mapping auctions: field => Auction;

    async transition init_auction(title: field) -> (field, Future) {
       let auction_id: field = BHP256::hash_to_field(title);

       return (auction_id, init_auction_finalize(self.caller, title, auction_id));
    }

    async function init_auction_finalize(caller: address, title: field, id: field) {
        let auction: Auction = Auction {
            runner: caller,
            title: title,
            complete: false,
            prize_claimed: false
        };

        let existing: Auction = Mapping::get_or_use(auctions, id, auction);

        if (existing == auction){
            Mapping::set(auctions, id, auction);
        }
    }

    // Returns a new bid.
    // - `bidder` : The address of the account that placed the bid.
    // - `amount` : The amount of the bid.
    // - `auction_id` : The id of the auction.
    // - `runner` : The address of the account that is running the auction.
    // Requires that `bidder` matches the function caller.
    // The owner of the record is set to the entity responsible for running the auction (auction runner).
    // The address of the auction runner is aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh.
    transition place_bid(bidder: address, amount: u64, auction_id: field, runner: address) -> Bid {
        // Ensure the caller is the auction bidder.
        assert_eq(self.caller, bidder);
        // Return a new 'Bid' record for the auction bidder.
        return Bid {
            owner: runner,
            bidder: bidder,
            amount: amount,
            is_winner: false,
            auction_id: auction_id
        };
    }

    // Returns the winning bid.
    // - `first`  : The first bid.
    // - `second` : The second bid.
    // Requires that the function caller is the auction runner.
    // Assumes that the function is invoked only after the bidding period has ended.
    // In the event of a tie, the first bid is selected.
    transition resolve(first: Bid, second: Bid) -> Bid {
        // Ensure the caller is the auctioneer.
        assert_eq(self.caller, aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh);
        // Resolve the winner of the auction and check that the auction_id is the same.
        if (first.amount >= second.amount && first.auction_id == second.auction_id) {
            return first;
        } else {
            return second;
        }
    }

    // Returns ownership of the bid to bidder.
    // - `bid` : The winning bid.
    // Requires that the function caller is the auction runner.
    // Assumes that the function is invoked only after all bids have been resolved.
    async transition finish(bid: Bid, auction_id: field, runner: address) -> (Bid, Future) {
        // Ensure the caller is the auctioneer.
        assert_eq(self.caller, runner);

        // Return 'is_winner' as 'true' in the winning 'Bid'.
        return (Bid {
            owner: bid.bidder,
            bidder: bid.bidder,
            amount: bid.amount,
            is_winner: true,
            auction_id: auction_id
        }, finish_finalize(auction_id));
    }

    async function finish_finalize(auction_id: field) {
        let auction: Auction = Mapping::get(auctions, auction_id);

        let updated_auction: Auction = Auction {
            runner: auction.runner,
            title: auction.title,
            complete: true,
            prize_claimed: false
        };

        Mapping::set(auctions, auction_id, updated_auction);
    }

    // Returns the Prize record corresponding to the winning bid who called the claim function to claim the prize
    // - `bid` : The winning bid
    // Requires that the function caller is the auction winner. The amount for now is hardcoded, can be added as an argument in the auction to fetch the prize.
    async transition claim(bid: Bid, auction_id: field) -> (Prize, Future) {
        assert_eq(bid.is_winner, true);

           return (Prize {
            owner: bid.bidder,
            amount: 10000u64
        }, claim_finalize(auction_id));
    }


     async function claim_finalize(auction_id: field) {
        let auction: Auction = Mapping::get(auctions, auction_id);

        let updated_auction: Auction = Auction {
            runner: auction.runner,
            title: auction.title,
            complete: true,
            prize_claimed: true
        };

        Mapping::set(auctions, auction_id, updated_auction);
    }
}