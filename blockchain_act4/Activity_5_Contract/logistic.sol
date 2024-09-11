// SPDX-License-Identifier: None license
pragma solidity ^0.8.15;

contract Logistic{
    enum StateType { Idle, Created, InTransit, Complete } 
    
    address public owner;
    address public customer;
    address public transporter;
    
    uint256 public minTemperature;
    uint256 public maxTemperature;
    uint256 public price;
    string public productName;
    bool public cancelable;
    
    StateType public transportState;
    
    constructor() {
        owner = msg.sender;
        _resetDeal();
    }
    
    /*
        Function to initalize a initDeal
        @param : customer's address, price (in Ether), minimum and maximum temperature allow
    */
    function initDeal(
        address _customer, 
        uint256 _price, 
        uint256 _minTemperature, 
        uint256 _maxTemperature, 
        string memory _productName
    ) public {

        require(msg.sender == owner, "unauthorized");
        require(transportState == StateType.Idle, "invalid transportState");
        require(_minTemperature <= _maxTemperature, "invalid maxTemperature");
        
        customer = _customer;
        minTemperature = _minTemperature;
        maxTemperature = _maxTemperature;
        price = _price;
        productName = _productName;
        cancelable = false;
        transportState = StateType.Created;
    }
    
    /*
        Function to transport to customer
        @param : transporter's address
    */
    function transport(address payable _transporter) public {
        require(msg.sender == owner, "unauthorized");
        require(transportState == StateType.Created, "invalid transportState");
        
        transporter = _transporter;
        transportState = StateType.InTransit;
    }
    
    /*
        Function to update sensor from transporter
        @param : current temp
    */
    function updateTemp(uint256 _temp) public {
        require(msg.sender == transporter, "unauthorized");
        require(transportState == StateType.InTransit, "invalid transportState");

        if(_temp > maxTemperature || _temp < minTemperature) {
            cancelable = true;
        }
    }
    
    /*
        Function to cancel current deal if measured temperature is out of range
        @param: -
    */
    function cancelDeal() public {

    }
    
    /*
        Function to complete and pay for deal
        @param : -
        This function require ether to be transfered.
    */
    function pay() public payable {
        require(msg.sender == customer, "unauthorized");
        require(transportState == StateType.InTransit, "invalid transportState");
        require(msg.value == price, "unmatched price");
        
        transportState = StateType.Complete;
    }
    
    /*
        Function for owner to get ether from contract 
        @param : -
    */
    function clearance() public {
        require(msg.sender == owner, "unauthorized");
        require(transportState == StateType.Complete, "invalid transportState");
        
        payable(owner).transfer(price);

        _resetDeal();
        transportState = StateType.Idle;
    }
    
    function _resetDeal() internal {
        customer = address(0);
        transporter = address(0);
        productName = "";
        maxTemperature = 0;
        minTemperature = 0;
        price = 0;
        cancelable = false;
    }

}