import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Float "mo:base/Float";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

module {

    public type UserId = Principal;

    public type Error = {
        #accountNotFound;
        #allowanceDiscrepancy;
        #insufficientBalance;
        #noPermission;
    };

    public type Account = {
        //var id: UserId;
        var icp: Float;
        var cycles: Float;
        var aICP: Float;
        var aCycles: Float;
    };


};