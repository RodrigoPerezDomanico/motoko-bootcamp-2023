import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Account "Account";
// NOTE: only use for local dev,
// when deploying to IC, import from "rww3b-zqaaa-aaaam-abioa-cai"
import BootcampLocalActor "BootcampLocalActor";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Array "mo:base/Array";



actor class MotoCoin() {
  public type Account = Account.Account;
  public type Subaccount = Blob;
  
  func _getDefaultSubaccount() : Subaccount {
    Blob.fromArrayMut(Array.init(32, 0 : Nat8));
  };

  var ledger = TrieMap.TrieMap<Account,Nat>(Account.accountsEqual,Account.accountsHash);
  var totalCreatedSupply=10000000;
  // let creatorsubaccount:Subaccount=Blob.fromArrayMut(Array.init(32, 0 : Nat8));
  // let creator:Account={
  //   owner=Principal.fromText("pslpz-sl226-qc5nt-t4iej-dlu6l-gmko5-uaniz-ziojr-wmumo-oivbz-hae");
  //   subaccount=null;
  // };
  // ledger.put(creator,totalCreatedSupply);
  let studentsBoot: actor {
      getAllStudentsPrincipal : shared () -> async[Principal];
    } = actor("rww3b-zqaaa-aaaam-abioa-cai");
  
  // Returns the name of the token
  public query func name() : async Text {
    return "MotoCoin";
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {
    return "MOC";
  };

  // Returns the the total number of tokens on all accounts
  public func totalSupply() : async Nat {
    var totalCreatedSupply:Nat=0;
    for(amount in ledger.vals()){
      totalCreatedSupply+= amount;
    };
    return totalCreatedSupply;
  };

  // Returns the default transfer fee
  public query func balanceOf(account : Account) : async (Nat) {
    let balance:?Nat = ledger.get(account);
    switch(balance){
      case(null){return 0};
      case(?balance){return balance}
    }
  };

  // Transfer tokens to another account
  public shared ({ caller }) func transfer(
    from : Account,
    to : Account,
    amount : Nat,
  ) : async Result.Result<(), Text> {
    let balance = await balanceOf(from);
    if (balance < amount){
      #err("Insuficient Funds")
    }else{
      var recieverBalance= await balanceOf(to);
      recieverBalance+=amount;
      let senderBalance:Nat=balance-amount;
      ledger.put(to,recieverBalance);
      ledger.put(from,senderBalance);
      #ok()
    }
  };

  // Airdrop 1000 MotoCoin to any student that is part of the Bootcamp.
  public func airdrop() : async Result.Result<(), Text> {
    
    try{
      let accounts  = await studentsBoot.getAllStudentsPrincipal();
      // let accounts:[Principal] = await BootcampLocalActor.getAllStudentsPrincipal();
      

      for(principal in accounts.vals()){
        let studentAccount:Account={
          owner=principal;
          subaccount=null;
        };
        let studentBalance=await balanceOf(studentAccount);
        ledger.put(studentAccount,studentBalance+100);
      };
      return #ok()
    }catch (e){
      return #err("Something went wrong when calling the bootcamp canister")
    }
    

  };
};
