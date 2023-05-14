import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";

import ICan "ICan";
import HTTP "Http";
import Type "Types";

actor class Verifier() {
  type StudentProfile = Type.StudentProfile;
  var studentProfileStore=HashMap.HashMap<Principal,StudentProfile>(1, Principal.equal, Principal.hash);

  // STEP 1 - BEGIN
  public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    try{
      studentProfileStore.put(caller,profile);
      return #ok()
    }catch(e){
      return #err("Something went wrong")
    };
  };

  public shared ({ caller }) func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
    let student:?StudentProfile = studentProfileStore.get(p);
    switch(student){
      case(null){#err("Student don't found")};
      case(?student){
        return #ok(student)
      };
    };
  };

  public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    let student:?StudentProfile = studentProfileStore.get(caller);
    switch(student){
      case(null){#err("Student don't found")};
      case(?student){
        studentProfileStore.put(caller,profile);
        #ok()
      };
    };
  };

  public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
    let student:?StudentProfile = studentProfileStore.remove(caller);
    switch(student){
      case(null){#err("Student don't found")};
      case(?student){#ok()};
    };
  };
  // STEP 1 - END

  // STEP 2 - BEGIN
  type CalculatorInterface = Type.CalculatorInterface;
  public type TestResult = Type.TestResult;
  public type TestError = Type.TestError;

  public func test(canisterId : Principal) : async TestResult {
    let calculatorInterfaceActor: CalculatorInterface = actor(Principal.toText(canisterId));

    try{
      let x1: Int = await calculatorInterfaceActor.reset();
      if (x1 != 0){
        return #err(#UnexpectedValue("Sould return 0"));
      };
      
      let x2:Int= await calculatorInterfaceActor.add(2);
      if(x2 != 2){
        return #err(#UnexpectedValue("Sould return 2"));
      };

      let x3:Int= await calculatorInterfaceActor.sub(1);
      if(x3 != 1){
        return #err(#UnexpectedValue("Sould return 0"));
      };
      return #ok()
    }catch(e){
      // Debug.trap(e);
      return #err(#UnexpectedError("Something went wrong"));
    };
  };
  // STEP - 2 END

  // STEP 3 - BEGIN
  // NOTE: Not possible to develop locally,
  // as actor "aaaa-aa" (aka the IC itself, exposed as an interface) does not exist locally
  public func verifyOwnership(canisterId : Principal, p : Principal) : async Bool {
    try{
      let controllers = await ICan.getCanisterControllers(canisterId);
      var isOwner : ?Principal = Array.find<Principal>(controllers, func prin = prin == p);
      if (isOwner!=null){
        return true;
      };
      return false;

    }catch(e){
      return false
    };
  };
  // STEP 3 - END

  // STEP 4 - BEGIN
  public shared ({ caller }) func verifyWork(canisterId : Principal, p : Principal) : async Result.Result<(), Text> {
    try{
      let approved= await test(canisterId);
      if (approved!=#ok){
        return #err("The work has not passed the test");
      };
      let owner = await verifyOwnership(canisterId,p);
      if (not owner){
        return #err("This work doesn't belong to the given principal p");
      };

      let student:?StudentProfile = studentProfileStore.get(p);
      switch(student){
        case(null){#err("Student given doesn't belong to registered students")};
        case(?student){
          var updateStudent = {
            name=student.name;
            graduate=true;
            team= student.team;
          };
          studentProfileStore.put(p,updateStudent);
          return #ok();
        };
      };

    }catch(e){
      return #err("Unexpected Error");
    };
  };
  // STEP 4 - END

};