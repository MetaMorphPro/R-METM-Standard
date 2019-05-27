pragma solidity ^0.4.25;

import "../ERC20.sol"; 

/**
 * @title MyERC20Token
 * @dev this is just for testing purposes, we have to create a token we can use in order to reserve and release a security 
 * token, this would be used when testing on localhost
 */
contract MyERC20Token is ERC20 {

    string public name;
    string public symbol;
    uint256 public decimals = 18;

    constructor(string _name, string _symbol, uint256 _initialSupply) public {
        uint256 INITIAL_SUPPLY = _initialSupply * (10 ** uint256(decimals));
        _totalSupply = INITIAL_SUPPLY;  
        name = _name;
        symbol = _symbol;
        _balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }
}