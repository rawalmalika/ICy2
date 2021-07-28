import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Principal "mo:base/Principal";
import Float "mo:base/Float";
import Types "./Types";

module {

type Account = Types.Account;

  public func principalEq(lhs: Principal, rhs: Principal) : Bool {
    return lhs == rhs;
  };

/*
  // TODO: Not the best.
  public func accountEq(lhs: Account, rhs: Account) : Bool {
    return lhs.balance == rhs.balance and
            List.equal<Txn>(lhs.txns, rhs.txns, txnEq) and
            lhs.lockedFunds == rhs.lockedFunds;
  };
*/

  public func safeSub(x: Nat, y: Nat) : (Nat) {
    if (x > y) { x - y }
    else 0
  };

  public func newAccount(initialAmount : Float) : Account {
    {
      var icp = initialAmount;
      var cycles = initialAmount;
      var aICP = initialAmount;
      var aCycles = initialAmount;
    }
  };

};