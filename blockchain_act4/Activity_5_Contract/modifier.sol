// SPDX-License-Identifier: None license
pragma solidity 0.8.15;

contract Modifier{
    
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "unauthorized");
        _;
    }
    
    function updateOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}