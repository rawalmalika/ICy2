import Array "mo:base/Array";
import Map "mo:base/HashMap";
import Principal "mo:base/Principal";
import Float "mo:base/Float";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

actor reserves {

//purpose to act as reserves in lending pool for both ICP and cycles
//roles organize deposits and collateral to know what is available to borrow (organizes outstanding tokens into avail or locked)
    
//initiliazing icp tokens and cycle tokens to always have liquidity for now
    var icp_available : Float = 10000000.0;
    var cycles_available : Float = 10000000.0;
    var icp_locked : Float = 0.0;
    var cycles_locked : Float = 0.0;

    //Functionality needed to determine a number of users holdings as available or collateral
    //type user = Text;
    //let available_map = Map.HashMap<user, Nat>(0,Text.equal, Text.hash);
    //let collateral_map = Map.HashMap<user, Nat>(0,Text.equal, Text.hash);

    //getter function for total amount in icp reserve and cycle reserve (used by product canister)
    public func icp_balance(): async Float {
        return icp_available + icp_locked;
    };

    public func cycles_balance(): async Float {
        return cycles_available + cycles_locked;
    };

//for user to see how much they have locked up as collateral
    public func icp_collateral(): async Float {
        return icp_locked;
    };

    public func cycles_collateral(): async Float {
        return cycles_locked;
    };



//alters available cycles and icp bsed on user deposits to product
    //eventually able to take user id as argument
    public func increaseAvailCycles(amount : Float) : async (Text, Bool){
        cycles_available += amount;
        return ("Success", true);
        //if user not in available_map.keys...map.put
    };
 
    public func increaseAvailICP(amount : Float) : async (Text, Bool){
        icp_available += amount;
        return ("Success", true);
    };

    public func decreaseAvailCycles(amount : Float) : async (Text, Bool){
        cycles_available -= amount;
        return ("Success", true);
    };

    public func decreaseAvailICP(amount : Float) : async (Text, Bool){
        icp_available -= amount;
        return ("Success", true);
    };

//called from user when borrowing
    //lock up ICP when user borrows cycles
    public func lockICP(amount: Float) : async (Text, Bool){
        icp_available -= amount;
        icp_locked += amount;
        return ("Success", true);
    };

    //lock up cyles when user borrows icp to prevent other users from borrowing the collateral
    public func lockCycles(amount: Float) : async (Text, Bool){
        cycles_available -= amount;
        cycles_locked += amount;
        return ("Success", true);
    };

//called from user when repayment

    //unlock ICP when user repays cycles
    public func unlockICP(amount: Float) : async (Text, Bool){
        icp_available += amount;
        icp_locked -= amount;
        return ("Success", true);
    };

    //unlock cyles when user pays back cycles 
    public func unlockCycles(amount: Float) : async (Text, Bool){
        cycles_available += amount;
        cycles_locked -= amount;
        return ("Success", true);
    };


};




