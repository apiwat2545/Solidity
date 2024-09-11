// SPDX-License-Identifier: None license
pragma solidity ^0.8.15;

import "./modifier.sol";  // Importing the modifier file

contract Logistic is Modifier {
    enum StateType { Idle, Created, InTransit, Complete, Cancel }
    
    struct Order {
        address customer;
        address transporter;
        uint256 price;
        uint256 minTemperature;
        uint256 maxTemperature;
        string productName;
        bool cancelable;
    }

    Order public currentOrder;
    StateType public transportState;
    
    constructor() {
        _resetDeal();
    }

    /*
        Function to initalize a new deal
        @param : customer's address, price (in Ether), minimum and maximum temperature allowed
    */
    function initDeal(
        address _customer, 
        uint256 _price, 
        uint256 _minTemperature, 
        uint256 _maxTemperature, 
        string memory _productName
    ) public onlyOwner {
        require(transportState == StateType.Idle, "invalid transportState");
        require(_minTemperature <= _maxTemperature, "invalid maxTemperature");
        
        currentOrder = Order({
            customer: _customer,
            transporter: address(0),
            price: _price,
            minTemperature: _minTemperature,
            maxTemperature: _maxTemperature,
            productName: _productName,
            cancelable: false
        });
        
        transportState = StateType.Created;
    }
    
    /*
        Function to transport to customer
        @param : transporter's address
    */
    function transport(address payable _transporter) public onlyOwner {
        require(transportState == StateType.Created, "invalid transportState");
        
        currentOrder.transporter = _transporter;
        transportState = StateType.InTransit;
    }
    
    /*
        Function to update sensor from transporter
        @param : current temp
    */
    function updateTemp(uint256 _temp) public {
        require(msg.sender == currentOrder.transporter, "unauthorized");
        require(transportState == StateType.InTransit, "invalid transportState");

        if(_temp > currentOrder.maxTemperature || _temp < currentOrder.minTemperature) {
            currentOrder.cancelable = true;
        }
    }
    
    /*
        Function to cancel current deal if measured temperature is out of range
        @param: -
    */
    function cancelDeal() public {
        require(msg.sender == currentOrder.customer || msg.sender == owner, "unauthorized");
        require(transportState == StateType.InTransit, "invalid transportState");
        require(currentOrder.cancelable == true, "not cancelable");

        transportState = StateType.Cancel;
        _resetDeal();
    }
    
    /*
        Function to complete and pay for deal
        @param : -
        This function requires ether to be transferred.
    */
    function pay() public payable {
        require(msg.sender == currentOrder.customer, "unauthorized");
        require(transportState == StateType.InTransit, "invalid transportState");
        require(msg.value == currentOrder.price, "unmatched price");
        
        transportState = StateType.Complete;
    }
    
    /*
        Function for owner to get ether from contract 
        10% goes to transporter, 90% goes to owner
    */
    function clearance() public onlyOwner {
        require(transportState == StateType.Complete || transportState == StateType.Cancel, "invalid transportState");
        
        if (transportState == StateType.Complete) {
            uint256 transporterShare = currentOrder.price / 10;  // 10% to transporter
            uint256 ownerShare = currentOrder.price - transporterShare;  // 90% to owner
            
            //payable(currentOrder.transporter).transfer(transporterShare);
            //payable(owner).transfer(ownerShare);
            (bool successTransporter, ) = currentOrder.transporter.call{value: transporterShare}("");
            require(successTransporter, "Transfer to transporter failed");

            (bool successOwner, ) = owner.call{value: ownerShare}("");
            require(successOwner, "Transfer to owner failed");
        }

        transportState = StateType.Idle;
        _resetDeal();
    }
    
    function _resetDeal() internal {
        currentOrder = Order({
            customer: address(0),
            transporter: address(0),
            price: 0,
            minTemperature: 0,
            maxTemperature: 0,
            productName: "",
            cancelable: false
        });
    }
}
