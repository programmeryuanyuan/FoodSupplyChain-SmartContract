// SPDX - License - Identifier : UNLICENSED

pragma solidity >=0.8.00 <0.9.0;
import"remix_tests.sol";    // this import is automatically injected by Remix .
import"remix_accounts.sol";
import"../contracts/LunchVenue_updated.sol";

contract LunchVenueTest is LunchVenue {

    // Variables used to emulate different accounts
    address acc0;
    address acc1;
    address acc2;
    address acc3;
    address acc4;

    /// ’beforeAll ’ runs before all other tests
    /// More special functions are : ’ beforeEach ’, ’beforeAll ’, ’afterEach ’ & ’afterAll ’
    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0);
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
        acc3 = TestsAccounts.getAccount(3);
        acc4 = TestsAccounts.getAccount(4);
    }

    /// Account at zero index ( account -0) is default account , so manager will be set to acc0
    function managerTest() public {
        Assert.equal(manager, acc0, 'Manager should be acc0');
    }

    /// Add lunch venue as manager
    /// When msg. sender isn ’t specified , default account (i.e., account -0) is considered as the sender
    function setLunchVenue() public {
        Assert.equal(addVenue('Courtyard Cafe'), 1, 'Should be equal to 1');
        Assert.equal(addVenue('Uni Cafe'), 2, 'Should be equal to 2');
    }

    /// Try to add lunch venue as a user other than manager . This should fail
    /// # sender : account -1
    function setLunchVenueFailure() public {
        try this.addVenue('Atomic Cafe') returns (uint v) {
            Assert.ok(false, 'Method execution should fail');
        } catch Error(string memory reason) {
            Assert.equal(reason, 'Can only be executed by the manager', 'Failed with unexpected reason');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'Failed unexpected');
        }
    }

    /// Set friends as account -0
    /// # sender doesn ’t need to be specified explicitly for account -0
    function setFriend() public {
        Assert.equal(addFriend(acc0, 'Alice'), 1, 'Should be equal to 1');
        Assert.equal(addFriend(acc1, 'Bob'), 2, 'Should be equal to 2');
        Assert.equal(addFriend(acc2, 'Charlie'), 3, 'Should be equal to 3');
        Assert.equal(addFriend(acc3, 'Eve'), 4, 'Should be equal to 4');
    }

    /// Try adding friend as a user other than manager . This should fail
    /// # sender : account -2
    function setFriendFailure() public {
        try this.addFriend(acc4, 'Daniels') returns (uint f) {
            Assert.ok(false, 'Method execution should fail');
        } catch Error(string memory reason) {
            Assert.equal(reason, 'Can only be executed by the manager', 'Failed with unexpected reason');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'Failed unexpected');
        }
    }

    /// Start voting
    /// # sender : account -0
    function startVote() public {
        try this.startVoting() {
            Assert.ok(true, 'Voting should be open');
        } catch Error(string memory reason) {
            Assert.equal(reason, 'Can only be executed by the manager', 'Failed with unexpected reason');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'Failed unexpected');
        }
    }

    /// Start voting
    /// # sender : account -2
    function startVoteFailure() public {
        try this.startVoting() {
            Assert.ok(false, 'Voting should be close');
        } catch Error(string memory reason) {
            Assert.equal(reason, 'Can only be executed by the manager', 'Failed with unexpected reason');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'Failed unexpected');
        }
    }

    /// Vote as Bob ( acc1 )
    /// # sender : account -1
    function vote() public {
        try this.doVote(2) returns (bool validVote) {
            Assert.ok(true, "Voting result should be true!");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Can vote only while phase is ongoing!", 'Failed with unexpected reason');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'Failed unexpected');
        }
    }

    /// Vote as Charlie
    /// # sender : account -2
    function vote2() public {
        try this.doVote(1) returns (bool validVote) {
            Assert.ok(true, "Voting result should be true!");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Can vote only while phase is ongoing!", 'Failed with unexpected reason');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'Failed unexpected');
        }
    }

    /// Try voting as a user not in the friends list . This should fail
    /// # sender : account -4
    function voteNotInListFailure() public {
        try this.doVote(4) returns (bool validVote) {
            Assert.ok(false, "Voting result should be false - Not in friends list");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(true, 'Failed unexpected');
        }
    }

    /// Vote as Eve
    /// # sender : account -3
    function vote3() public {
        try this.doVote(2) returns (bool validVote) {
            Assert.ok(true, "Voting result should be true!");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Can vote only while phase is ongoing!", 'Failed with unexpected reason');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'Failed unexpected');
        }
    }

    /// Verify lunch venue is set correctly
    function lunchVenueTest() public {
        Assert.equal(votedVenue, 'Uni Cafe', 'Selected venue should be Uni Cafe');
    }

    /// Verify voting is now closed
    /*function voteOpenTest() public {
        Assert.equal(status, Status.end, 'Voting should be closed');     
    }*/

    /// Verify voting after vote closed . This should fail
    /// # sender : account -2
    function voteAfterClosedFailure() public {
        try this.doVote(1) returns (bool validVote) {
            Assert.ok(false, 'Method Execution Should Fail');
        } catch Error(string memory reason) {
            Assert.equal(reason, "Can vote only while phase is ongoing!", 'Failed with unexpected reason');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'Failed unexpectedly');
        }
    }

    /// This should success.
    /// # sender : account -0
    function destroyContractTest() public {
        Assert.ok(msg.sender == acc0, 'caller should be manager');
    }

    /// This should fail.
    /// # sender : account -1
    function destroyContractFailure() public {
        try this.destroyContract() {
            Assert.ok(false, "This should be false!");
        } catch Error(string memory reason) {
            Assert.equal(reason, 'Can only be executed by the manager', 'Failed with unexpected reason');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(true, 'Failed unexpectedly');
        }
    }
}