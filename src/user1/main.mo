import Nat "mo:base/Nat";
import Text "mo:base/Text";
import D "mo:base/Debug";
import Float "mo:base/Float";
import Principal "mo:base/Principal";


actor user1 {

    var userId : Text = "User1";

    var cycle_token : Float = 0.0;
    var icp_token : Float = 0.0;
    //var aCycle : Float = 0.0;
    //var aICP : Float = 0.0;

    //Eventually just want these getter functions
    //gets ID of user canister and turns it into text and is assigned to id variable 
    //public func get_id(): Principal{
     //   var p : Principal = Principal.fromActor(user);
        //id := Principal.toText(p);
     //   return p;
    //};

    public func get_id_text(): async Text{
        return userId;
    };
  
    public func icp_tokenbalance(): async Float {
        return icp_token;
    };

    public func cycle_tokenbalance(): async Float {
        return cycle_token;
    };

//used by treasury Eventually want to get rid of these!! and use a map for balances!!
    public func increaseCycles(amount: Float) : async (Text, Bool){
        cycle_token += amount;
        return ("Success", true);
    };

    //used by treasury
    public func increaseICP(amount: Float) : async (Text, Bool){
        icp_token += amount;
        return ("Success", true);
    };

    public func decreaseCycles(amount: Float) : async (Text, Bool){
        cycle_token -= amount;
        return ("Success", true);
    };

    //used by treasury
    public func decreaseICP(amount: Float) : async (Text, Bool){
        icp_token -= amount;
        return ("Success", true);
    };

};