// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./roles.sol";

contract Inventory is Roles {

    address owner;

    // Executing when this contract is deployed
    constructor () {
        // Set contract deployer as contract owner
        owner = msg.sender;
        // Give contract deployer admin role
        roles.admin[msg.sender] = true;
    }

    //Roles.Role private _roles;

    struct Milk {
        uint productID;
        address registrant;
        string productName;
        uint price;
        uint produceDate;
        uint expirationDate;
        string textInfo;
        string ipfsHash; // This store product picture in IPFS (Off-chain storage)
        uint inventoryAllowance; // Inventory allowance of this product
    }

    // Count total product amount
    uint public product_counter = 0;

    //mapping( uint => hash) public milks //public can see the hash/picture of milk product
    // Mapping productID to each product
    Milk[] public milks;
    //mapping(uint => Milk[]) public ID_to_info;

    /// events
    // Display Item info
    event displayItem(
        uint productID,
        address registrant,
        string productName,
        uint price,
        uint produceDate,
        uint expirationDate,
        string textInfo,
        string ipfsHash,
        uint inventoryAllowance
    );
    // Display product ID
    event displayProductID(uint productID);
    // Expiration reminder
    event expirationReminder(uint validTime, uint expirationDate);

    function register() public returns (bool) {
        roles.customer[msg.sender] = true;
        return true;
    }

    // Set the new product into the inventory
    function setItem(string memory productName, uint price, uint produceDate, uint expirationDate, string memory textInfo, string memory ipfsHash, uint inventoryAllowance) public returns (bool) {
        require(((roles.admin[msg.sender] == true)||(roles.supplier[msg.sender] == true)),"YOU ARE NOT SUPPLIER OR ADMIN");
        milks.push(Milk(product_counter, msg.sender, productName, price, produceDate, expirationDate, textInfo, ipfsHash, inventoryAllowance));
        product_counter = product_counter + 1;
        // Success setItem
        return true;
    }

    // Update the product info
    function updatePrice(uint product_id, uint price) public returns (bool) {
        require(roles.admin[msg.sender] == true,"YOU ARE NOT ADMIN");
        milks[product_id].price = price;
        // Success
        return true;
    }

    function updateTextInfo(uint product_id,string memory textInfo) public returns (bool) {
        require(roles.admin[msg.sender] == true,"YOU ARE NOT ADMIN");
        // Only these info can be updated
        milks[product_id].textInfo = textInfo;
        // Success
        return true;
    }

    function updateIpfsHash(uint product_id, string memory ipfsHash) public returns (bool) {
        require(roles.admin[msg.sender] == true,"YOU ARE NOT ADMIN");
        milks[product_id].ipfsHash = ipfsHash;
        // Success
        return true;
    }

    function updateInventoryAllowance(uint product_id, uint inventoryAllowance) public returns (bool) {
        require(roles.admin[msg.sender] == true,"YOU ARE NOT ADMIN");
        milks[product_id].inventoryAllowance = inventoryAllowance;
        // Success
        return true;
    }

    // Search the product ID based on the given product name
    function searchProductID(string memory productName) public returns (bool) {
        for (uint i = 1; i <= milks.length; i++) {
            if (keccak256(abi.encodePacked(milks[i].productName)) == keccak256(abi.encodePacked(productName))) {
                emit displayProductID(i);
                return true;
            }
        }
        return false;
    }
    
    // customer can order with given product ID and amount
    // return true if successful
    function requestItem(uint product_id, uint amount, uint money) public onlyCustomer returns (bool) {
        // Only customers can request
        require(roles.customer[msg.sender] == true,"YOU ARE NOT A CUSTOMER");
        // This product id does not exist.
        require(milks[product_id].productID >= 0, "THIS_ID_DOESN'T_EXIST");
        // Out of stock
        require(milks[product_id].inventoryAllowance >= amount, "OUT OF STOCK");
        // Check whether the msg.sender has enough balance to pay
        require(money <= address(msg.sender).balance, "NO ENOUGH BALANCE");
        // Pay Ether
        _transfer(payable(owner), money);
        // Inventory allowance of this product reduce
        milks[product_id].inventoryAllowance -= amount;
        // Success
        return true;
    }

    // private function that transfer certain amount of Ether
    function _transfer(address payable to, uint money) private {
        to.transfer(money);
    }

    // Display the product information with given product ID
    function showItem(uint product_id) public returns(bool) {
        require(milks[product_id].productID >= 0, "THIS_ITEM_DOESN'T_EXIST");
        // Display item info
        emit displayItem(
            milks[product_id].productID,
            milks[product_id].registrant,
            milks[product_id].productName,
            milks[product_id].price,
            milks[product_id].produceDate,
            milks[product_id].expirationDate,
            milks[product_id].textInfo,
            milks[product_id].ipfsHash,
            milks[product_id].inventoryAllowance
        );
        return true;
    }

    // Oracle component - update date with oracle
    event dateRequest(string location);
    uint public date = 20220101;

    function requestDatetime(string memory location) private {
        emit dateRequest(location);
    }

    function respondDatePhase(uint dt) public {
        date = dt;
    }

    function updateDate(string memory location) public{
        requestDatetime(location);
    }
    //end oracle component


    // Off-chain computation component
    event checkRequest(uint);
    uint256 public checkIndex = 0;
    int public dayexpire = 0;
    function requestCheck()private{
        emit checkRequest(0);
    }
    function checkInventory() public {
        requestCheck();
    }
    function checkresponsePhase(uint256 i,int256 d) public {
        checkIndex = i;
        dayexpire = d;
    }
    function getExpiredate(uint id)public view returns(uint){
        return milks[id].expirationDate;
    }
    //end off-chain computation component


    // Destruct when inventory unused
    function selfDestruct() public onlyAdmin {
        selfdestruct(payable(msg.sender));
    }
    ///end
}