import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Float "mo:base/Float";
import User "canister:user";
import User1 "canister:user1";
import Text "mo:base/Text";
import Database "./Database";
import Types "./Types";
import Utils "./Utils";
import Reserve "canister:reserves" ;
import Result "mo:base/Result";

actor product{

    type Account = Types.Account;
    type UserId = Types.UserId;
//only keeps track of aCycle and aICP... token_outstanding put in reserves canister
    var aCycle_outstanding : Float = 0.0; //product balance of acycles created
    var aICP_outstanding : Float = 0.0;

    var icp_to_dollar : Float = 1.0; //this will change for now 1.0 for simplicity
    var cycle_to_dollar : Float = 1.0; //this will change for now 1.0 for simplicity
    var minRatio : Float = 2.0; //200%
    var interest: Float = 1.2; //20%

    var db: Database.Database = Database.Database();

    //must first open up an account with the protocol
    public shared(msg) func openAccount() : async (Text, Bool) {
        db.updateAccount(msg.caller, Utils.newAccount(0));  
        return("Succes", true); 
    };


    //getter functions for product canister
    public func icp_tokenbalance(): async Float {
        let icp_token_outstanding = await Reserve.icp_balance();
        return icp_token_outstanding;
    };

    public func cycle_tokenbalance(): async Float {
        let cycle_token_outstanding = await Reserve.cycles_balance();
        return cycle_token_outstanding;
    };

    public func aICP_balance(): async Float {
        return aICP_outstanding;
    };

    public func aCycle_balance(): async Float {
        return aCycle_outstanding;
    };

    //getter functions for user
    public shared(msg) func getBalances(token: Text) : async Float {
        let check = db.findAccount(msg.caller);

        switch check {
        case (?account) {
            if(Text.equal(token, "cycles")){
                return account.cycles;
            };
            if(Text.equal(token, "icp")){
                return account.icp;
            };
            if(Text.equal(token, "aCycles")){
                return account.aCycles;
            };
            if(Text.equal(token, "aICP")){
                return account.aICP;
            };
            return -10.0;
        };
        case (null) {
            return -10.0;
        };
        }
    };


    //adds funds to account of user to have ability to lend and borrow
    //can only deposit ICP and cycles to account as of now
    //for now works with user canisters to test functionality of reducing their personal funds
    //eventually get rid of checking userId 
    public shared(msg) func addFunds(userId: Text, token_name : Text, amount : Float) : async (Text, Bool) {

        let check = db.findAccount(msg.caller);
        switch check {
        case (?account) {
            //for user canister...to decrease users balance in their personal account for now
            if(Text.equal(userId, "User")){
                if(Text.equal(token_name, "cycles")){
                    let cycle_user = await User.cycle_tokenbalance();
                    if(amount <= cycle_user){
                        let temp = await User.decreaseCycles(amount); 
                        account.cycles += amount;
                        db.updateAccount(msg.caller, account);
                        return ("Success", true);
                    };
                    return ("Failure: amount is more than your balance of cycles", false);
                };
                if(Text.equal(token_name, "ICP")){
                    let icp_user = await User.icp_tokenbalance();
                    if(amount <= icp_user){
                        let temp = await User.decreaseICP(amount);
                        account.icp += amount;
                        db.updateAccount(msg.caller, account);
                        return ("Success", true);
                    };
                    return ("Failure: amount is more than your balance of ICP", false);
                };
            };
            
            ///////
            //for user1 canister...

            if(Text.equal(userId, "User1")){
                if(Text.equal(token_name, "cycles")){
                    let cycle_user = await User1.cycle_tokenbalance();
                    if(amount <= cycle_user){
                        let temp = await User1.decreaseCycles(amount); 
                        account.cycles += amount;
                        db.updateAccount(msg.caller, account);
                        return ("Success", true);
                    };
                    return ("Failure: amount is more than your balance of cycles", false);
                };
                if(Text.equal(token_name, "ICP")){
                    let icp_user = await User1.icp_tokenbalance();
                    if(amount <= icp_user){
                        let temp = await User1.decreaseICP(amount);
                        account.icp += amount;
                        db.updateAccount(msg.caller, account);
                        return ("Success", true);
                    };
                    return ("Failure: amount is more than your balance of ICP", false);
                };
                return("Not correct token name", false);
            };
            return("Not correct User name", false);
        };
        case (null) {
            return ("Error: Account not found!", false);
        };
    }
    };

//utilizing reserve canister!!

//now making functions called from product canister... users interact with the product canister
// to deposit, redeem, borrow, repay. Acts as lending pool smart contract like in AAVE

    //has functionality associated with depositng their funds to lending pool to earn interest!
    /// Increments caller's balance by |amount|.
    ///deposit only not redeem
    /// Args:
    ///   |amount|   The amount to increment the caller's balance by.
    public shared(msg) func deposit(token_name : Text, amount : Float) : async (Text, Bool) {
        let check = db.findAccount(msg.caller);
        switch check {
        case (?account) {           
            if(Text.equal(token_name, "cycles")){
                //must check if user has enough in their account
                let funds = account.cycles;
                if(funds >= amount){
                    aCycle_outstanding += amount; //minting
                    let temp1 = await Reserve.increaseAvailCycles(amount);
                    account.cycles -= amount;
                    account.aCycles += amount;
                    db.updateAccount(msg.caller, account);
                    return ("Success", true);
                };
            return ("Failure: not enough cycles in account", false);
            };
            if(Text.equal(token_name, "ICP")){
                let funds = account.icp;
                if(funds >= amount){
                    aICP_outstanding += amount; //minting
                    let temp1 = await Reserve.increaseAvailICP(amount);
                    account.icp -= amount;
                    account.aICP += amount;
                    db.updateAccount(msg.caller, account);
                    return ("Success", true);
                };
            return ("Failure: not enough ICP in account", false);
            };
            return("Not correct token name", false);
        };
        case (null) {
            return ("Error: Account not found!", false);
        };
        }
    };


    //functionality for redeeming tokens
    ///////

    public shared(msg) func redeem(token_name : Text, amount : Float) : async (Text, Bool) {
        let check = db.findAccount(msg.caller);
        switch check {
        case (?account) {           
            if(Text.equal(token_name, "aCycles")){
                //must check if user has enough in their account
                let funds = account.aCycles;
                if(funds >= amount){
                    aCycle_outstanding -= amount; //burning
                    let temp1 = await Reserve.decreaseAvailCycles(amount);
                    account.cycles += amount; //eventually include interest rate earned as well...
                    account.aCycles -= amount;
                    db.updateAccount(msg.caller, account);
                    return ("Success", true);
                };
            return ("Failure: not enough aCycles in account", false);
            };
            if(Text.equal(token_name, "aICP")){
                let funds = account.aICP;
                if(funds >= amount){
                    aICP_outstanding -= amount; //burning
                    let temp1 = await Reserve.increaseAvailICP(amount);
                    account.icp += amount;
                    account.aICP -= amount;
                    db.updateAccount(msg.caller, account);
                    return ("Success", true);
                };
            return ("Failure: not enough aICP in account", false);
            };
            return("Not correct token name", false);
        };
        case (null) {
            return ("Error: Account not found!", false);
        };
        }
    };

    ////
    //functionality for borrowing
    public shared(msg) func borrow(token_name : Text, amount : Float) : async (Text, Bool){
        let check = db.findAccount(msg.caller);
        switch check {
        case (?account) {           
            if(Text.equal(token_name, "cycles")){
                //must check if user has enough aICP in their account to borrow
                let aicp_user = account.aICP;
                if(((aicp_user * icp_to_dollar) / (amount * cycle_to_dollar)) >= minRatio){ 
                    account.cycles += amount;
                    let temp = await Reserve.lockICP(minRatio * amount * cycle_to_dollar);
                    account.aICP -= (amount*minRatio); //user sends aICP to product
                    aICP_outstanding += (amount * minRatio); 
                    //for now just lock minRatio * amount so just lock up bare minimum to borrow (eventually it will be based off how much you want to borrow and health factor)
                    let temp1 = await Reserve.decreaseAvailCycles(amount);
                    db.updateAccount(msg.caller, account);
                    return ("Success", true);
                };
            return ("Failure: not enough aCycles in account", false);
            };
            if(Text.equal(token_name, "ICP")){
                let acycle_user = account.aCycles;
                if(((acycle_user * icp_to_dollar) / (amount * cycle_to_dollar)) >= minRatio){ 
                    account.icp += amount;
                    let temp = await Reserve.lockCycles(minRatio * amount * cycle_to_dollar);
                    account.aCycles -= (amount*minRatio); //user sends aICP to product
                    aCycle_outstanding += (amount * minRatio); 
                    //for now just lock minRatio * amount so just lock up bare minimum to borrow (eventually it will be based off how much you want to borrow and health factor)
                    let temp1 = await Reserve.decreaseAvailICP(amount);
                    db.updateAccount(msg.caller, account);
                    return ("Success", true);
                };
            return ("Failure: not enough aICP in account", false);
            };
            return("Not correct token name", false);
        };
        case (null) {
            return ("Error: Account not found!", false);
        };
        }
    };


    /////
    //functionality for repaying loan
    public shared(msg) func repay(token_name : Text, amount : Float) : async (Text, Bool){
        let check = db.findAccount(msg.caller);
        switch check {
        case (?account) {           
            if(Text.equal(token_name, "cycles")){
                //must check if user has enough in their account
                let funds = account.cycles;
                if(funds >= amount){
                    let temp1 = await Reserve.increaseAvailCycles(amount); //cycles given back
                    let unlock = await Reserve.unlockICP(amount);    //unlock reserve ICP not used for collateral anymore and can be borroed by others
                    account.cycles -= amount;
                    aICP_outstanding -= ((amount/interest)*minRatio); //product gives back to user less than 1:1 bc of interest
                    account.aICP += ((amount/interest)*minRatio); //user balance only increases by amount repaid/interest times the minratio to get locked up back
                    db.updateAccount(msg.caller, account);
                    return ("Success", true);
                };
            return ("Failure: not enough cycles in account", false);
            };
            if(Text.equal(token_name, "ICP")){
                let funds = account.icp;
                if(funds >= amount){
                    let temp1 = await Reserve.increaseAvailICP(amount); //cycles given back
                    let unlock = await Reserve.unlockCycles(amount);    //unlock reserve ICP not used for collateral anymore and can be borroed by others
                    account.icp -= amount;
                    aCycle_outstanding -= ((amount/interest)*minRatio); //product gives back to user less than 1:1 bc of interest
                    account.aCycles += ((amount/interest)*minRatio); //user balance only increases by amount repaid/interest times the minratio to get locked up back
                    db.updateAccount(msg.caller, account);
                    return ("Success", true);
                };
            return ("Failure: not enough ICP in account", false);
            };
            return("Not correct token name", false);
        };
        case (null) {
            return ("Error: Account not found!", false);
        };
        }
    };





    //Withdraw to get funds back into individual user Canister!
    // Decrements caller's balance by |amount|. Note that balances cannot go below zero.
    /// Args:
    ///   |amount|   The amount to decrement the caller's balance by.
    /// Returns:
    ///   Nothing if successful and an Error if the caller's account doesn't exist.
    ///   Possible errors: #accountNotFound
    public shared(msg) func withdrawFunds(userId: Text, token_name : Text, amount : Float) : async (Text, Bool){

        let check = db.findAccount(msg.caller);
        switch check {
        case (?account) {
            //for user canister...to decrease users balance in their personal account for now
            if(Text.equal(userId, "User")){
                if(Text.equal(token_name, "cycles")){
                    let funds = account.cycles;
                    if(funds >= amount){
                        let temp = await User.increaseCycles(amount); 
                        account.cycles -= amount;
                        db.updateAccount(msg.caller, account);
                        return ("Success", true);
                    };
                    return ("Failure: amount is more than your balance of cycles", false);
                };
                if(Text.equal(token_name, "ICP")){
                    let funds = account.icp;
                    if(funds >= amount){
                        let temp = await User.increaseICP(amount);
                        account.icp -= amount;
                        db.updateAccount(msg.caller, account);
                        return ("Success", true);
                    };
                    return ("Failure: amount is more than your balance of ICP", false);
                };
                return("Not correct token name", false);
            };
            
            ///////
            //for user1 canister...

            if(Text.equal(userId, "User1")){
                if(Text.equal(token_name, "cycles")){
                    let funds = account.cycles;
                    if(funds >= amount){
                        let temp = await User1.increaseCycles(amount); 
                        account.cycles -= amount;
                        db.updateAccount(msg.caller, account);
                        return ("Success", true);
                    };
                    return ("Failure: amount is more than your balance of cycles", false);
                };
                if(Text.equal(token_name, "ICP")){
                    let funds = account.icp;
                    if(funds >= amount){
                        let temp = await User1.increaseICP(amount);
                        account.icp -= amount;
                        db.updateAccount(msg.caller, account);
                        return ("Success", true);
                    };
                    return ("Failure: amount is more than your balance of ICP", false);
                };
                return("Not correct token name", false);
            };
            return("Not correct User name", false);
        };
        case (null) {
            return ("Error: Account not found!", false);
        };
        }
    };



};
