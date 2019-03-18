pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

// 1. quorum is the number of all voters
// 2. contract creator can add choices in the middle of polling, unless quorum met
// 3. voters can not only see the choices, but also see the current polling results
// 4. first contract operator (in address) becomes the creator
// 5. get result shall return all tied winners

// account address: small fox's addr
// contract address: deploy via Inject Web3, contract address

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

    address private contractCreator;
    Lunch[] private lunchVotes;
    mapping(address => Voter) private voters;
    
    constructor(uint quorumSet) public{
        voteAcceptable = true;
        quorum = quorumSet;
        voteAcceptedCount = 0;
        maxVote = 0;
        contractCreator = msg.sender;
    }

    function choiceCreator(string[] memory lunchChoicesAdd) public{
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

    function getChoices() public view returns (string[] memory choice){
        choice = new string[](lunchVotes.length);
        for(uint i = 0; i < lunchVotes.length; i ++){
            choice[i] = lunchVotes[i].name;
        }
    }

    function getResult() public view returns (string memory, string[] memory winners, uint[] memory votes) {
        string memory message;
        winners = new string[](lunchVotes.length);
        votes = new uint[](lunchVotes.length);

        if (voteAcceptable == true){
            message = "Vote still in progress! You can only use 'getChoices' function.";
            return (message, winners, votes);
        }

        uint index = 0;
        for(uint i = 0; i < lunchVotes.length; i ++){
            if (lunchVotes[i].voteCount == maxVote){
                winners[index] = lunchVotes[i].name;
                votes[index] = lunchVotes[i].voteCount;
                index += 1;
            }
        }
        if (index > 2){
            message = "This vote has several tie winners:";
        }
        else{
            message = "The winner is:";
        }
        return (message, winners, votes);
    }

    function vote(string memory voterChoice) public returns (string memory) {
        Voter memory validVoter = voters[msg.sender];
        require(
            validVoter.isVoted == false,
            "You can only vote once!"
        );
        require(
            voteAcceptable == true,
            "Vote not yet accepted because this vote reaches the quorum."
        );
        for (uint i = 0; i < lunchVotes.length; i ++){
            if (keccak256(abi.encodePacked(lunchVotes[i].name)) == keccak256(abi.encodePacked(voterChoice))){
                validVoter.isVoted = true;
                validVoter.voteId = lunchVotes[i].id;
                voteAcceptedCount += 1;
                lunchVotes[i].voteCount += 1;
                if (lunchVotes[i].voteCount > maxVote){
                    maxVote = lunchVotes[i].voteCount;
                }
                if (voteAcceptedCount >= quorum){
                    voteAcceptable = false;
                }
                return "Vote accepted.";
            }
        }
        return "Your vote does not match any given choices! Please try again.";
    }

    function deconstructor() public{
        require(
            contractCreator == msg.sender,
            "Only the creator can deconstructor the vote."
        );
        selfdestruct(contractCreator);
    }
}