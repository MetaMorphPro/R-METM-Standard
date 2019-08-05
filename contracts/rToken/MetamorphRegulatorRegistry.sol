pragma solidity ^0.4.25;

import './MetamorphRegulatorInterface.sol';
import '../utils/Ownable.sol';

/// @notice A service that points to a `MetamorphRegulatorInterface`
contract MetamorphRegulatorRegistry is Ownable {
  address public service;

  /**
   * @notice Triggered when service address is replaced
   */
  event ReplaceService(address oldService, address newService);

  /**
   * @dev Validate contract address
   * Credit: https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/ERC223_Token.sol#L107-L114
   *
   * @param _addr The address of a smart contract
   */
  modifier withContract(address _addr) {
    uint length;
    assembly { length := extcodesize(_addr) }
    require(length > 0, "not a contract address");
    _;
  }

  /**
   * @notice Constructor
   *
   * @param _service The address of the `MetamorphRegulatorInterface`
   *
   */
  constructor(address _service) public {
    service = _service;
  }

  /**
   * @notice Replaces the address pointer to the `MetamorphRegulatorInterface`
   *
   * @dev This method is only callable by the contract's owner
   *
   * @param _service The address of the new `MetamorphRegulatorInterface`
   */
  function replaceService(address _service) onlyOwner withContract(_service) public {
    address oldService = service;
    service = _service;
    emit ReplaceService(oldService, service);
  }
}