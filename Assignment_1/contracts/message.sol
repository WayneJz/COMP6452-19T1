pragma solidity >=0.4.24;
pragma experimental ABIEncoderV2;

/*
    Contract Address: 0x10A5beA42E8cdF9297Ede410c522E9Eb2C152023
    Student: Zhou JIANG
    Student Number: z5146092
    COMP6452, 19T1, Assignment 1
*/


contract LunchVote {

    /* 
        Global Variables Definition:
        Voter struct: Stores whether he/she has voted, and whom he/she votes for.
        Lunch struct: Stores the id, name, and the number of votes received for this proposal.
        quorum: The number of votes that the contract will receive.
                Note if quorum reaches, all vote attempts will be rejected.
        voteAcceptedCount: The current number of votes.
        maxVote: The maximum vote count for lunch proposal(s).
                Note if two lunch proposals have same voteCount 3, the maxVote is also 3.
        contractCreator: Stores the contract creator's address.
        authorizedAddr array: Stores all authorized voters' address (including contract creator's).
        lunchVotes struct array: Stores all lunch proposals.
        voters mapping: Stores voters address.
    */

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
    address[] private authorizedAddr;
    Lunch[] private lunchVotes;
    mapping(address => Voter) private voters;
    
    /*
        Constructor: (Requirement 5)
        1. Allow this contract to accept votes.
        2. Set the quorum.
        3. Initialize other global variables. 
        4. Store the caller's address to the contract creator.
        5. Store the caller's address to the authorized address array.
    */

    constructor(uint quorumSet) public{
        voteAcceptable = true;
        quorum = quorumSet;
        voteAcceptedCount = 0;
        maxVote = 0;
        contractCreator = msg.sender;
        authorizedAddr.push(msg.sender);
    }

    /*
        choiceCreator Function: (Requirement 1,2)
        1. Check if the contract creator calls the function. If not, reject it.
        2. Store input of the string array into the construct array.
    */

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

    /*
        authorizedChecker Function: (Used by other functions)
        1. Check if the address is in the authorized address array.
        2. Return the result.
    */

    function authorizedChecker(address addressToCheck) private view returns (bool) {
        for (uint index = 0; index < authorizedAddr.length; index ++){
            if (authorizedAddr[index] == addressToCheck){
                return true;
            }
        }
        return false;
    }

    /*
        authorizeVoter Function: (Requirement 3,4)
        1. Check if the contract creator calls the function. If not, reject it.
        2. Check if the voter's address already in the authorized address array. If yes, reject it.
        3. Grant the right for the address to vote.
        4. Store the voter's address to the authorized address array.
    */

    function authorizeVoter(address newVoterAddress) public{
        require(
            contractCreator == msg.sender,
            "Voter authorization must be executed by the creator!"
        );
        require(
            authorizedChecker(newVoterAddress) == false,
            "This address is already authorized! Do not re-authorize it."
        );
        voters[newVoterAddress].isVoted = false;
        authorizedAddr.push(newVoterAddress);
    }

    /*
        getChoices Function: (Requirement 6)
        1. Initialize a temporary string array.
        2. Store all the proposal names from struct array to the temporary array.
        3. Return the temporary string array.
    */

    function getChoices() public view returns (string[] memory choice){
        choice = new string[](lunchVotes.length);
        for(uint i = 0; i < lunchVotes.length; i ++){
            choice[i] = lunchVotes[i].name;
        }
    }

    /*
        getResult Function: (Requirement 9)
        1. Initialize a string, a string array and an unsigned integer array.
            String: stores the message.
            String array: stores names of all the winners (tie winners or one winner).
            Unsigned integer array: stores their vote counts.
        2. Check if the voting is still in progress, if yes, message prompted without the results.
            Note that voters can ONLY get results until this voting is finished.
            Otherwise it is unfair, and it will make no differences with getChoices function.
        3. Store winners names and vote counts from struct array to the new arrays.
        4. The message prompts whether tie winners or not.
        5. Return the message and new arrays. 
    */

    function getResult() public view returns (string memory, string[] memory winners, uint[] memory votes) {
        string memory message;
        winners = new string[](lunchVotes.length);
        votes = new uint[](lunchVotes.length);

        if (voteAcceptable == true){
            message = "Voting still in progress! You can only use 'getChoices' function.";
            winners[0] = "Not yet determined";
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
        if (index >= 2){
            message = "The lunch vote has multiple tie winners:";
        }
        else{
            message = "The winner is:";
        }
        return (message, winners, votes);
    }

    /*
        vote Function: (Requirement 7,8)
        1. Check if the voter's address already in the authorized array, if not, reject it.
        2. Check if the voter has already voted, if yes, reject it.
        3. Check if the voting is still in progress, if not, reject it.
        4. Use a iteration to check if the input string matches any proposal names.
        5. If matches, stores the voteID, increment the vote counts, 
            check if this proposal becomes the most popular one, if yes, maxVote becomes the vote counts,
            check if the quorum reaches, if yes, set the vote is no more acceptable. 
        6. If not matches, this vote attempt will not be recorded,
            message will prompt, and the voter can try again.
    */

    function vote(string memory voterChoice) public returns (string memory) {
        require(
            authorizedChecker(msg.sender) == true,
            "You are not allowed to vote! Please check if you are authorized by the contract creator."
        );
        Voter memory validVoter = voters[msg.sender];
        require(
            validVoter.isVoted == false,
            "You can only vote once!"
        );
        require(
            voteAcceptable == true,
            "Vote not yet accepted because the quorum reaches. Use getResult() to see the result."
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

    /*
        Deconstructor: (Requirement 10)
        1. Check if the contract creator calls the function. If not, reject it.
        2. Destroy the contract.
    */

    function deconstructor() public{
        require(
            contractCreator == msg.sender,
            "Only the creator can deconstructor the vote."
        );
        selfdestruct(msg.sender);
    }
}