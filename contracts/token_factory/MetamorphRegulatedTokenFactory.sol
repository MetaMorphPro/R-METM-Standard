pragma solidity ^0.4.25;

import "../utils/Ownable.sol";
import "./RegulatorFactoryInterface.sol";
import "../ERC20/ERC20.sol";
import "../ERC20/R_ERC20Detailed.sol";
import "../rToken/MetamorphRegulatedToken.sol";
import "../rToken/MetamorphRegulatorRegistry.sol";

/**
* @title TokenReserve interface
*/
contract MetamorphRegulatedTokenFactory is RegulatorFactoryInterface, Ownable {

    /**
    * @dev Throws if called by any account other than the owner.
    * @param  _token The address of the Metamoprh token
    * @param  _price The price of the Regulated token
    * @param  _fundsHolder The address of contract holding the funds
    */
    constructor(address _token, uint256 _price, address _fundsHolder) public {
        require(_token != address(0), "Token address cannot be 0");
        require(_price > 0, "price should be more than 0");
        require(_fundsHolder != address(0), "FundsHolder address cannot be zero");
        metmToken = _token;
        price = _price;
        fundsHolder = FundsHolder(_fundsHolder);
    }

    function setFundsHolderAddress(address _fundsHolder) external onlyOwner {
        require(_fundsHolder!=address(0), "address cannot be 0x");
        fundsHolder = FundsHolder(_fundsHolder);
    }


    function setPrice(uint256 _price) external onlyOwner {
        require(_price > 0, "Price cannot be 0");
        price = _price;
    }

    function createToken(string _symbol, string _name, address _regulatorRegistry) external {
        require(bytes(_symbol).length >= 2 && bytes(_symbol).length <= 4, "Symbol length should be more than 2");
        require(bytes(_name).length >= 2, "Name length should be more than 2");
        require(_regulatorRegistry != address(0), "Regulator registry address cannot be zero");
        require(IERC20(metmToken).allowance(msg.sender, address(this)) >= price, "Insufficent allowance");
        require(IERC20(metmToken).transferFrom(msg.sender, address(fundsHolder), price), "EVM Error");
        uint256 ticker = uint256(keccak256(abi.encodePacked(_symbol)));
        require(tickers[ticker] == address(0), "Ticker is already taken");
        MetamorphRegulatorRegistry registryContract = MetamorphRegulatorRegistry(_regulatorRegistry);
        MetamorphRegulatedToken rToken = new MetamorphRegulatedToken(registryContract, _name, _symbol);
        TokenSettings memory settings = TokenSettings({
            ts: now,
            price: price,
            name: _name,
            symbol: _symbol,
            tokenAddress: address(rToken)
        });
        issuerTokens[msg.sender].push(address(rToken));
        issuerTokensData[msg.sender][address(rToken)] = settings;
        issuers.push(msg.sender);
        tokens.push(address(rToken));
        tickers[ticker] = msg.sender;
        rToken.transferOwnership(msg.sender);
        emit Issued(msg.sender, _symbol, _name);
    }

    function getAlltokens(address _issuer) public view returns (address[]) {
        return issuerTokens[_issuer];
    }

    function getInfo(address _issuer, address _token) public view returns (uint256, string, string, uint8, uint256, uint256) {
        TokenSettings memory settings = issuerTokensData[_issuer][_token];
        R_ERC20Detailed rToken = R_ERC20Detailed(_token);
        return(
            settings.price,
            settings.name,
            settings.symbol,
            rToken.decimals(),
            rToken.totalSupply(),
            settings.ts
        );
    }

    function getNumOfTokens() public view returns (uint256) {
        return tokens.length;
    }

    function getNumOfIssuers() public view returns (uint256) {
        return issuers.length;
    }

    function getFundsHolderAddress() public view returns (address) {
        return address(fundsHolder);
    }

    function getIssuer(string _symbol) public view returns (address issuer) {
        uint256 ticker = uint256(keccak256(abi.encodePacked(_symbol)));
        issuer = tickers[ticker];
    }
}