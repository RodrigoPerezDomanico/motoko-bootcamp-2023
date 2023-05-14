// e35fa-wyaaa-aaaaj-qa2dq-cai
// e35fa-wyaaa-aaaaj-qa2dq-cai
import Type "Types";
import Principal "mo:base/Principal";
import Int "mo:base/Int";

actor class Verifier() {
  type CalculatorInterface = Type.CalculatorInterface;
  public type TestResult = Type.TestResult;
  public type TestError = Type.TestError;
  public func test() : async TestResult {

    let calculatorInterfaceActor: CalculatorInterface = actor("e35fa-wyaaa-aaaaj-qa2dq-cai");

    try{
      let x1: Int = await calculatorInterfaceActor.reset();
      let x2:Int= await calculatorInterfaceActor.add(2);
      let x3:Int= await calculatorInterfaceActor.sub(1);
      if (x1 != 0){
        return #err(#UnexpectedValue("Should return 0"));
      };
      
      
      if(x2 != 2){
        return #err(#UnexpectedValue("Should return 2"));
      };

      
      if(x3 != 1){
        return #err(#UnexpectedValue("Should return 1"));
      };
      return #ok()
    }catch(e){
      return #err(#UnexpectedError("Something went wrong"));
    };
  };
};