// SPDX-License-Identifier: None license
pragma solidity 0.8.15;

contract Ownable {
    
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    function getOwnerPublic() public view returns(address){
        return owner;
    }
    
    function getOwnerPrivete() private view returns(address){
        return owner;
    }
    
    function getOwnerInternal() internal view returns(address){
        return owner;
    }
    
    function getOwnerExternal() external view returns(address){
        return owner;
    }
    
    function getOwnerPublic2() public view returns(address){
        return getOwnerPublic();
    }
    
    function getOwnerPrivete2() private view returns(address){
        return getOwnerPrivete();
    }
    
    function getOwnerInternal2() internal view returns(address){
        return getOwnerInternal();
    }
    
    // function getOwnerExternal2() external view returns(address){
    //     return getOwnerExternal();
    // }
}

contract Visibility is Ownable{
    
    constructor() {
        owner = msg.sender;
    }
    
    function getOwnerPublic3() public view returns(address){
        return getOwnerPublic();
    }
    
    // function getOwnerPrivete3() private view returns(address){
    //     return getOwnerPrivete();
    // }
    
    function getOwnerInternal3() internal view returns(address){
        return getOwnerInternal();
    }
    
    // function getOwnerExternal3() external view returns(address){
    //     return getOwnerExternal();
    // }
}

contract Visibility2{
    Ownable ownable;
    
    constructor(address _address) {
        ownable = Ownable(_address);
    }
    
    function getOwnerPublic3() public view returns(address){
        return ownable.getOwnerPublic();
    }
    
    // function getOwnerPrivete3() private view returns(address){
    //     return ownable.getOwnerPrivete();
    // }
    
    // function getOwnerInternal3() internal view returns(address){
    //     return ownable.getOwnerInternal();
    // }
    
    function getOwnerExternal3() external view returns(address){
        return ownable.getOwnerExternal();
    }
}