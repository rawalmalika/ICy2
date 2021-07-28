import Nat "mo:base/Nat";
import User "canister:user";
import Text "mo:base/Text";
import Float "mo:base/Float";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Types "./Types";
import Utils "./Utils";
import List "mo:base/List";

module {
    
    type Account = Types.Account;
    type UserId = Types.UserId;

    func isEq(x: UserId, y: UserId): Bool { x == y };
  
    // The "database" is just a local hash map
    public class Database() {
        let hashMap = HashMap.HashMap<UserId, Account>(1, isEq, Principal.hash);
        // attempt at the "database" is just a local hash map(value is a list or array) (tokens are always indexed 0: ICP, 1: cycles, 2: aICP, 3:aCycles)
        //var hashMap1 = HashMap.HashMap<UserId, Arrays>(1, isEq, Principal.hash);


        public func updateAccount(userId: UserId, account: Account) {
            hashMap.put(userId, account);
            //return("Successfully updated", true);
        };

        public func findAccount(userId: UserId) : ?Account {
            hashMap.get(userId);
        };
    
    };
};
