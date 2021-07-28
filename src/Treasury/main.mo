import Nat "mo:base/Nat";
import User "canister:user";
import User1 "canister:user1";
import Text "mo:base/Text";
import Float "mo:base/Float";
import Principal "mo:base/Principal";

actor treasury {

    //initiliazing icp tokens and cycle tokens to then send to user canister
    var icp : Float = 0.0;
    var cycles : Float = 0.0;


    public func icp_balance(): async Float {
        return icp;
    };

    public func cycles_balance(): async Float {
        return cycles;
    };

    public func mintICP (amount : Float) : async (Text, Bool){
        icp += amount;
        return ("Success", true);
    };

    public func mintCycles (amount : Float) : async (Text, Bool){
        cycles += amount;
        return ("Success", true);
    };


//To User canister
    public func transferICP (amount : Float) : async (Text, Bool){
        if (icp >= amount){
            icp -= amount;
            let temp = await User.increaseICP(amount);
            return ("Success", true);
        };
        return ("Failure - Transfer Amount Exceeds Supply", false); 
    };


    public func transferCycles (amount : Float) : async (Text, Bool){
        if (cycles >= amount){
            cycles -= amount;
            let temp = await User.increaseCycles(amount); 
            return ("Success", true);
        };
        return ("Failure - Transfer Amount Exceeds Supply", false); 
    };

//To User1 Canister

    public func transferICPUser1 (amount : Float) : async (Text, Bool){
        if (icp >= amount){
            icp -= amount;
            let temp = await User1.increaseICP(amount);
            return ("Success", true);
        };
        return ("Failure - Transfer Amount Exceeds Supply", false); 
    };


    public func transferCyclesUser1 (amount : Float) : async (Text, Bool){
        if (cycles >= amount){
            cycles -= amount;
            let temp = await User1.increaseCycles(amount); 
            return ("Success", true);
        };
        return ("Failure - Transfer Amount Exceeds Supply", false); 
    };  


};
