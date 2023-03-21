// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


contract Roles {

    struct Role {
        mapping (address => bool ) supplier;
        mapping (address => bool ) admin;
        mapping (address => bool ) customer;
    }

    Role roles;

    // add account as supplier
    function addAdmin(address account) public onlyAdmin {
        require(roles.admin[account] == false, "account already has role");
        roles.admin[account] = true;
    }

    // add account as supplier
    function addSupplier(address account) public onlyAdmin {
        require(roles.supplier[account] == false,"account already has role");
        roles.supplier[account] = true;
    }

    // add account as customer
    function addCustomer(address account) public onlyAdmin {
        require(roles.customer[account] == false,"account already has role");
        roles.customer[account] = true;
    }

    //remove account as admin
    function removeAdmin(address account) public onlyAdmin {
        require(roles.admin[account] == true,"account dose not have admin role");
        roles.admin[account] = false;
    }

    //remove account as supplier
    function removeSupplier(address account) public onlyAdmin {
        require(roles.supplier[account] == true,"account dose not have supplier role");
        roles.supplier[account] = false;
    }
    
    //remove account as customer
    function removeCustomer(address account) public onlyAdmin {
        require(roles.customer[account] == true,"account dose not have customer role");
        roles.customer[account] = false;
    }

    modifier onlyAdmin(){
        require(roles.admin[msg.sender] == true, "YOU ARE NOT AN ADMIN");
        _;
    }

    modifier onlyCustomer() {
        require(roles.customer[msg.sender] == true, "YOU ARE NOT A CUSTOMER");
        _;
    }
    modifier onlySupplier() {
        require(roles.supplier[msg.sender] == true, "YOU ARE NOT A SUPPLIER");
        _;
    }
}