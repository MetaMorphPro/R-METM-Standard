pragma solidity ^0.4.25;

import "./FactoryInterface.sol";
import "../rToken/MetamorphRegulatorRegistry.sol";

/**
 * @title TokenReserve interface
 */
contract RegulatorFactoryInterface is FactoryInterface {

    event Issued(address indexed _issuer, string _symbol, string _name);

    /**
    * @dev mapping to save tickers pointing to the owner's address
    */
    mapping(uint256 => address) public tickers;
    /**
    * @dev Function to release token
    * @param _symbol Symbol of the new token.
    * @param _name Name of the new token.
    * @param _regulatorRegistry Address of the regulator that will do the checks.
    */
    function createToken(string _symbol, string _name, address _regulatorRegistry) external;

    /**
    * @dev Returns the address of the issuer
    * @param _symbol Symbol of the token to check.
    */
    function getIssuer(string _symbol) public view returns (address);
}