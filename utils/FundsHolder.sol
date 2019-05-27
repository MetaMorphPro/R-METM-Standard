pragma solidity ^0.4.25;

import "./SafeMath.sol";
import "./Ownable.sol";
import "../ERC20/ERC20.sol";

/**
 * @title Contract to hold long term persistent data
 */
contract FundsHolder is Ownable {
    using SafeMath for uint256;

    address public token;
    address[6] public owners = [
        0x535145e644d8d25E50DdA49Fb80c37D08C9862fE,
        0x4dc782F14bd27e63f1e0339B582a96d53df6C55f,
        0xa68358C42626f4e31820C30B09B27c4649670DE6,
        0x18f7e6B5A9b39895B7f38D696C702Cd290d5D77C,
        0x32a18b166ab8178fd021a4f36ce60a73a0536c57,
        0x1baCaE51d1AFf3B16E0392a31CbA07E1dF8eab95
    ];

    mapping (address => uint256) public balance;
    mapping(address => bool) isOwner; /** All involved on the project that will get revenue */


    modifier onlyOwners() {
        require(isOwner[msg.sender], "Sender is not owner");
        _;
    }

    constructor(address _token) public {
        require(_token != address(0), "Token address cannot be zero");
        token = _token;
        isOwner[owners[0]] = true; //DAN
        isOwner[owners[1]] = true; //Soren
        isOwner[owners[2]] = true; //Mark
        isOwner[owners[3]] = true; //Marwan
        isOwner[owners[4]] = true; //Santiago
        isOwner[owners[5]] = true; //Tom
    }

    function withdraw() external onlyOwners {
        require(ERC20(token).balanceOf(this) > 0, "Contract does not have any balance");
        uint256 amount = ERC20(token).balanceOf(this)/6;
         ERC20(token).transfer(owners[0], amount);
         ERC20(token).transfer(owners[1], amount);
         ERC20(token).transfer(owners[2], amount);
         ERC20(token).transfer(owners[3], amount);
         ERC20(token).transfer(owners[4], amount);
         ERC20(token).transfer(owners[5], amount);
    }

    function isAddressOwner(address _address) public view returns (bool) {
        return isOwner[_address];
    }
}