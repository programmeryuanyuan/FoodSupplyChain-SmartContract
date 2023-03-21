 // SPDX - License - Identifier : UNLICENSED
pragma solidity ^0.8.0;

/// @title Contract to agree on the lunch venue
contract LunchVenue {
    struct Friend {
        string name;
        bool voted;
    }

    struct Vote {
        address voterAddress;
        uint venue;
    }

    mapping(uint => string) public venues;
    mapping(address => Friend) public friends;
    uint public numVenues = 0;
    uint public numFriends = 0;
    uint public numVotes = 0;
    address public manager;
    string public votedVenue = "";
    uint public startTime = 0;
    // 9.5 "constant" saves Gas
    uint public constant voteLasts = 10800;  // Duration of voting, 3 hours = 10800 seconds

    mapping (uint => Vote) private votes;
    mapping (uint => uint) private results;

// 9.2 Set 3 status to divide the whole process into 3 phases
    enum Status {create, ongoing, end}
    Status public status = Status.create; // default status is "create".

    constructor () {
        manager = msg.sender;
    }

    function addVenue(string memory name) public restricted returns (uint) {
        require(status == Status.create);
        numVenues++;
        venues[numVenues] = name;
        return numVenues;
    }

    function addFriend(address friendAddress, string memory name) public restricted returns (uint) {
        require(status == Status.create);
        Friend memory f;
        f.name = name;
        f.voted = false;
        friends[friendAddress] = f;
        numFriends++;
        return numFriends;
    }

    // 9.2 Change the phase to "ongoing"
    function startVoting() public restricted {
        status = Status.ongoing;
        // 9.3 Set start time.
        startTime = block.timestamp;
    }

    // 9.5 Opitimize Gas costs: external costs less Gas than public.
    function doVote(uint venue) external returns (bool validVote) {
        require(status == Status.ongoing, "Can vote only while phase is ongoing!");
        // 9.1 Each person can vote only once.
        require(friends[msg.sender].voted == false, "Already voted!");

        validVote = false;
        if (bytes(friends[msg.sender].name).length != 0) {
            if(bytes(venues[venue]).length != 0) {
                validVote = true;
                friends[msg.sender].voted = true;
                Vote memory v;
                v.voterAddress = msg.sender;
                v.venue = venue;
                numVotes++;
                votes[numVotes] = v;
            }
        }
    // 9.3 When the time exceeds Lunch time, voting will be automatically terminated.
    // 9.5 Gas opitimization: To let the former operation be cheaper than the latter
        if ((block.timestamp > startTime + voteLasts) || (numVotes >= numFriends/2 + 1)){
            status = Status.end;
            finalResult();
        }
        return validVote;
    }

    function finalResult() private {
        uint highestVotes = 0;
        uint highestVenue = 0;
        for (uint i = 1; i <= numVotes; i++) {
            uint voteCount = 1;
            if(results[votes[i].venue] > 0) {
                voteCount += results[votes[i].venue];
            }
            results[votes[i].venue] = voteCount;

            if(voteCount > highestVotes) {
                highestVotes = voteCount;
                highestVenue = votes[i].venue;
            }
        }
        votedVenue = venues[highestVenue];
    }

// 9.4 Allow the manager to disable the contract.
    function destroyContract() public restricted {
        selfdestruct(payable(msg.sender));
    }

    modifier restricted() {
        require(msg.sender == manager, "Can only be executed by the manager");
        _;
    }
}