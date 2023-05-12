import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Type "Types";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

actor class Homework() {
  type Homework = Type.Homework;
  var homeworkDairy=Buffer.Buffer<Homework>(0);

  // Add a new homework task
  public shared func addHomework(homework : Homework) : async Nat {
    homeworkDairy.add(homework);
    let i:Nat=homeworkDairy.size()-1;
    return i;
  };

  // Get a specific homework task by id
  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    if (id < homeworkDairy.size()){#ok(homeworkDairy.get(id))} else{#err("Homework not found")}
  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
    if (id < homeworkDairy.size()){
        var newHomework:Homework={
            title = homework.title;
            dueDate=homework.dueDate;
            description=homework.description;
            completed=homeworkDairy.get(id).completed;
        };
        
        homeworkDairy.put(id,newHomework);
        #ok()
    } else{
        #err("Homework not found")
    };
  };

  // Mark a homework task as completed
  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    if (id < homeworkDairy.size()){
        var newHomework:Homework={
            title = homeworkDairy.get(id).title;
            dueDate=homeworkDairy.get(id).dueDate;
            description=homeworkDairy.get(id).description;
            completed=true;
        };
        
        homeworkDairy.put(id,newHomework);
        #ok()
    } else{
        #err("Homework not found")
    };
  };

  // Delete a homework task by id
  public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
    if (id < homeworkDairy.size()){
        let x = homeworkDairy.remove(id);
        #ok()
    } else{
        #err("Homework not found")
    };
  };

  // Get the list of all homework tasks
  public shared query func getAllHomework() : async [Homework] {
    var homeworkList = Buffer.toArray<Homework>(homeworkDairy);
    return homeworkList;
  };

  // Get the list of pending (not completed) homework tasks
  public shared query func getPendingHomework() : async [Homework] {
    var homeworkList:[Homework] = Buffer.toArray<Homework>(homeworkDairy);
    let pendingHomeworkList = Array.filter<Homework>(homeworkList, func x = x.completed == false);
    return pendingHomeworkList;
  };

  // Search for homework tasks based on a search terms
  public shared query func searchHomework(searchTerm : Text) : async [Homework] {
    var homeworkList:[Homework] = Buffer.toArray<Homework>(homeworkDairy);
    let filteredHomeworkList = Array.filter<Homework>(homeworkList, func x = Text.contains(x.title,#text searchTerm) or Text.contains(x.description,#text searchTerm));
    return filteredHomeworkList;
  };
};