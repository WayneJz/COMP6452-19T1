pragma solidity ^0.4.24;

contract LunchVote {

    struct Voter {
        bool isVoted;
        bytes32 voteName;
    }

    struct Lunch {
        bytes32 name;
        uint voteCount;
    }

    uint quorum;
    bool voteAcceptable;
    bytes32 resultName;

    address public contractCreator;
    mapping(address => Voter) public voters;
    Lunch[] public lunchVotes;

    constructor(bytes32[] lunchChoicesAdd, uint quorumSet) public{
        require(
            contractCreator == msg.sender,
            "Lunch choices must be added by the creator!"
        );
        voteAcceptable = true;
        quorum = quorumSet;
        for (uint index = 0; index < lunchChoicesAdd.length; index ++){
            lunchVotes.push(Lunch({
                name: lunchChoicesAdd[index],
                voteCount : 0
            }));
        }
    }

    function authorizeVoter(address newVoterAddress) public{
        require(
            contractCreator == msg.sender,
            "Voter authorization must be executed by the creator!"
        );
        require(
            voters[newVoterAddress].isVoted == false,
            "Authorize a voter who has voted is not permitted!"
        );
        voters[newVoterAddress].isVoted = false;
    }

    function getResult() public view returns (bytes32) {
        require(
            voteAcceptable == false,
            "Result cannot be displayed! Voting still in progress."
        );
        return resultName;
    }

    function vote(bytes32 lunchName) public returns (string) {
        Voter storage validVoter = voters[msg.sender];
        require(
            validVoter.isVoted == false,
            "You can only vote once!"
        );
        require(
            voteAcceptable == true,
            "Vote not yet accepted because a lunch vote count reaches the quorum."
        );
        validVoter.isVoted = true;
        validVoter.voteName = lunchName;
        for (uint index = 0; index < lunchVotes.length; index ++){
            if (lunchVotes[index].name == lunchName){
                lunchVotes[index].voteCount += 1;
                if (lunchVotes[index].voteCount >= quorum){
                    voteAcceptable = false;
                    resultName = lunchVotes[index].name;
                    return "Vote not yet accepted because the lunch you vote reaches the quorum.";
                }
                return "Vote accepted.";
            }
        }
        return "Invalid vote! Your vote does not match any given choices.";
    }

    function deconstructor() public{
        require(
            contractCreator == msg.sender,
            "Only the creator can deconstructor the vote"
        );
        selfdestruct(contractCreator);
    }
}
