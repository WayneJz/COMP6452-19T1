pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

// 1. quorum is the number of all voters
// 2. contract creator can add choices in the middle of polling, unless quorum met
// 3. voters can not only see the choices, but also see the current polling results
// 4. first contract operator (in address) becomes the creator
// 5. get result shall return all tied winners

contract LunchVote {

    struct Voter {
        bool isVoted;
        uint voteId;
    }

    struct Lunch {
        uint id;
        string name;
        uint voteCount;
    }

    uint public quorum;
    uint public voteAcceptedCount;
    uint private maxVote;

    bool public voteAcceptable;

    address public contractCreator;
    Lunch[] public lunchVotes;
    mapping(address => Voter) public voters;
    
    constructor(uint quorumSet) public{
        voteAcceptable = true;
        quorum = quorumSet;
        voteAcceptedCount = 0;
        maxVote = 0;
        contractCreator = msg.sender;
    }

    function choiceCreator(string[] lunchChoicesAdd) public{
        require(
            contractCreator == msg.sender,
            "Lunch choices must be added by the creator!"
        );
        uint lastId = lunchVotes.length;
        for (uint index = 0; index < lunchChoicesAdd.length; index ++){
            lunchVotes.push(Lunch({
                id: lastId,
                name: lunchChoicesAdd[index],
                voteCount : 0
            }));
            lastId += 1;
        }
    }

    function authorizeVoter(address newVoterAddress) public{
        require(
            contractCreator == msg.sender,
            "Voter authorization must be executed by the creator!"
        );
        require(
            voters[newVoterAddress].isVoted == false,
            "Authorizing a voter who has voted is not permitted!"
        );
        voters[newVoterAddress].isVoted = false;
    }

    function getResult() public returns (Lunch[]) {
        return lunchVotes;
    }

    function vote(uint lunchId) public returns (string) {
        Voter storage validVoter = voters[msg.sender];
        require(
            validVoter.isVoted == false,
            "You can only vote once!"
        );
        require(
            voteAcceptable == true,
            "Vote not yet accepted because this vote reaches the quorum."
        );
        require(
            lunchId < lunchVotes.length,
            "Invalid vote! Your vote does not match any given choice ID."
        );
        validVoter.isVoted = true;
        validVoter.voteId = lunchId;
        voteAcceptedCount += 1;
        lunchVotes[lunchId].voteCount += 1;
        if (lunchVotes[lunchId].voteCount > maxVote){
            maxVote = lunchVotes[lunchId].voteCount;
        }
        if (voteAcceptedCount >= quorum){
            voteAcceptable = false;
        }
        return "Vote accepted.";
    }

    function deconstructor() public{
        require(
            contractCreator == msg.sender,
            "Only the creator can deconstructor the vote."
        );
        selfdestruct(contractCreator);
    }
}
