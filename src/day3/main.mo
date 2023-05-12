import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Hash "mo:base/Hash";
import Blob "mo:base/Blob";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Order "mo:base/Order";
import Int "mo:base/Int";


actor class StudentWall() {
  type Message = Type.Message;
  type Content = Type.Content;
  type Survey = Type.Survey;
  type Answer = Type.Answer;

  stable var messageIdCounter: Nat=0;
  var wall = HashMap.HashMap<Nat,Message>(1, Nat.equal, Hash.hash);




  // Add a new message to the wall
  public shared ({ caller }) func writeMessage(c : Content) : async Nat {
    let id :Nat = messageIdCounter;
    messageIdCounter+=1;
    let newMessage : Message = {
      content = c;
      vote=0;
      creator = caller;
    };
    wall.put(id, newMessage);
    return id;
    };
    




  // Get a specific message by ID
  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
    switch(let wallMessage:?Message=wall.get(messageId)){
      case(null){#err("Message not Found")};
      case(?wallMessage){#ok(wallMessage)};
      };
    
    };


  // Update the content for a specific message by ID
  public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
    let wallMessage:?Message=wall.get(messageId);
    
      switch(wallMessage){
        case(null){
          #err("Message not Found")
          };
        case(?wallMessage){
          if (caller == wallMessage.creator){
            let updatedMessage : Message = {
              content = c;
              vote=wallMessage.vote;
              creator = caller;
            };
            wall.put(messageId, updatedMessage);
            #ok()
          }else{
            #err("This message cant be edited by you")
          };

          };
        };
      
      };

  // Delete a specific message by ID
  public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
    let wallMessage:?Message=wall.get(messageId);
    switch(wallMessage){
      case(null){#err("Message not Found")};
      case(?wallMessage){

        if(caller == wallMessage.creator){
          ignore wall.remove(messageId);
          #ok();
        } else{
          #err("This message can't be erased by you")
        };

      };

    };
  };

  // Voting
  public func upVote(messageId : Nat) : async Result.Result<(), Text> {
    let wallMessage:?Message=wall.get(messageId);
    switch(wallMessage){
      case(null){#err("Message not found")};
      case(?wallMessage){
        let newMessage : Message = {
          content = wallMessage.content;
          vote=wallMessage.vote+1;
          creator = wallMessage.creator;
        };
        wall.put(messageId,newMessage);
        #ok()
      }
    }

    
  };

  public func downVote(messageId : Nat) : async Result.Result<(), Text> {
     let wallMessage:?Message=wall.get(messageId);
    switch(wallMessage){
      case(null){#err("Message not found")};
      case(?wallMessage){
        if (wallMessage.vote > 0){
        let newMessage : Message = {
          content = wallMessage.content;
          vote=wallMessage.vote-1;
          creator = wallMessage.creator;
        };
        wall.put(messageId,newMessage);
        #ok()
        } else{
          #err("This allready has 0 votes")
        };
      };
    };

  };

  // Get all messages
  public func getAllMessages() : async [Message] {
    var messagesBuffer=Buffer.Buffer<Message>(0);
    
    for ((id, message) in wall.entries()){

      let transformToMessage:Message = {
        content= message.content;
        vote= message.vote;
        creator= message.creator;
      };
      messagesBuffer.add(transformToMessage);
    };
   let messagesArray:[Message] = Buffer.toArray<Message>(messagesBuffer);
   return messagesArray;
  };
  private func compareObjects(obj1:Message,obj2:Message): Order.Order{
// if is text text.greater(...,) etc.
    switch(Int.compare(obj1.vote, obj2.vote)) {
        case (#greater) {return #less};
        case (#less) {return #greater};
        case(#equal) {return #equal};
    };
  };
  // Get all messages ordered by votes
  public func getAllMessagesRanked() : async [Message] {
    var messagesBuffer=Buffer.Buffer<Message>(0);
    
    for ((id, message) in wall.entries()){

      let transformToMessage:Message = {
        content= message.content;
        vote= message.vote;
        creator= message.creator;
      };
      messagesBuffer.add(transformToMessage);
    };
    messagesBuffer.sort(compareObjects);
    let messagesArray:[Message] = Buffer.toArray<Message>(messagesBuffer);
   return messagesArray;
  };
};