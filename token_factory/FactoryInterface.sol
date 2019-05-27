pragma solidity ^0.4.25;

import "../utils/FundsHolder.sol";

/**
 * @title TokenReserve interface
 */
contract FactoryInterface {

    address public metmToken;
    address[] issuers;
    address[] tokens;

    uint256 public price;

    FundsHolder internal fundsHolder;

    struct TokenSettings {
        uint256 price;
        string name;
        string symbol;
        address tokenAddress;
    }

    /**
    * @dev array of tokens issued by the issuer
    */
    mapping(address => address[]) issuerTokens;

    /**
    * @dev in the form of issuerTokensData[userAddress][tokenAddress] = TokenSettings
    */
    mapping(address => mapping(address => TokenSettings)) issuerTokensData;

    /**
    * @dev Throws if called by any account other than the owner.
    * @param  _token The address of the Metamoprh token
    * @param  _price The price of the Regulated token
    * @param  _fundsHolder The address of contract holding the funds
    */

    /**
    * @dev Function to set price of the token function, onlyowner
    * @param _price New price of the reserve.
    */
    function setPrice(uint256 _price) external;

    /**
    * @dev Function to get info of all tokens created by the issuer
    * @param _issuer The address of the issuer.
    */
    function getAlltokens(address _issuer) public view returns (address[]);

    /**
    * @dev Function to get info of a tokens created by the issuer, returns TokenSettings structure
    * @param _issuer The address of the issuer.
    * @param _token The address of the token.
    */
    function getInfo(address _issuer, address _token) public view returns (uint256, string, string);

    /**
    * @dev num of tokens created on the platform
    */
    function getNumOfTokens() public view returns (uint256);

    /**
    * @dev num of issuers who created tokens on the platform
    */
    function getNumOfIssuers() public view returns (uint256);

    /**
    * @dev address of the funds holder, onlyOwner
    */
    function getFundsHolderAddress() public view returns (address);
}