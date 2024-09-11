// SPDX-License-Identifier: None license
pragma solidity 0.8.15;


struct Vault {
    address addr;
    uint value;
}

contract Test{
    
    Vault v;
    
    constructor()  {
        v = Vault({
            addr: msg.sender,
            value: 0
        });
    }
    
    function setVaultWithStorage(uint number) public returns(Vault memory) {
        Vault storage vault = v;
        
        require(vault.addr == msg.sender,"unauthorize");
        
        vault.value = number;
        
        return vault;
    }
    
    function setVaultWithMemory(uint number) public returns(Vault memory) {
        Vault memory vault = v;
        
        require(vault.addr == msg.sender,"unauthorize");
        
        vault.value = number;
        
        return vault;
    }
    
    function getVault() public view returns(Vault memory) {
        return v;
    }
}