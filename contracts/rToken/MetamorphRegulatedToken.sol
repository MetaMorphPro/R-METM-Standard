pragma solidity ^0.4.25;

import '../ERC20/R_ERC20Detailed.sol';
import '../ERC20/ERC20Mintable.sol';
import './MetamorphRegulatorRegistry.sol';
import './MetamorphRegulatorInterface.sol';

/// @notice An ERC-20 token that has the ability to check for trade validity
contract MetamorphRegulatedToken is R_ERC20Detailed, ERC20Mintable {

  /**
   * @notice R-Token decimals setting (used when constructing DetailedERC20)
   */
  uint8 constant public RTOKEN_DECIMALS = 18;

  /**
   * @notice Triggered when checking permissions
   */
  event CheckStatus(uint8 reason, address indexed spender, address indexed from, address indexed to, uint256 value);

  /**
   * @notice Address of the `MetamorphRegulatorRegistry` that has the location of the
   *         `MetamorphRegulatorInterface` contract responsible for checking trade
   *         permissions.
   */
  MetamorphRegulatorRegistry public registry;

  /**
   * @notice Constructor
   *
   * @param _registry Address of `MetamorphRegulatorRegistry` contract
   * @param _name Name of the token: See DetailedERC20
   * @param _symbol Symbol of the token: See DetailedERC20
   */
  constructor(MetamorphRegulatorRegistry _registry, string _name, string _symbol) public R_ERC20Detailed(_name, _symbol, RTOKEN_DECIMALS){
    require(_registry != address(0), "address cannot be 0x");
    registry = _registry;
  }

  /**
   * @notice ERC-20 overridden function that include logic to check for trade validity.
   *
   * @param _to The address of the receiver
   * @param _value The number of tokens to transfer
   *
   * @return `true` if successful and `false` if unsuccessful
   */
  function transfer(address _to, uint256 _value) public returns(bool) {
    require (_check(msg.sender, _to, _value), "Cannot transfer");
    return super.transfer(_to, _value);
  }

  /**
   * @notice ERC-20 overridden function that include logic to check for trade validity.
   *
   * @param _from The address of the sender
   * @param _to The address of the receiver
   * @param _value The number of tokens to transfer
   *
   * @return `true` if successful and `false` if unsuccessful
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
      require (_check(_from, _to, _value), "Cannot transferFrom");
      return super.transferFrom(_from, _to, _value);
  }

  /**
   * @notice ERC-20 overridden function that enforces mint to token owner.
   *
   * @param _to The address of whom will get the minted tokens (should be the owner)
   * @param _value The number of tokens to mint
   *
   * @return `true` if successful and `false` if unsuccessful
   */
  function mint(address _to, uint256 _value) public onlyOwner returns (bool) {
    require(_to == msg.sender, "Minting is only allowed in the owner's account");
    require(_service().checkMint(address(this), _value), "Cannot mint that amount");
    _mint(msg.sender, _value);
    return true;
}

  /**
   * @notice Performs the regulator check
   *
   * @dev This method raises a CheckStatus event indicating success or failure of the check
   *
   * @param _from The address of the sender
   * @param _to The address of the receiver
   *
   * @return `true` if the check was successful and `false` if unsuccessful
   */
  function _check(address _from, address _to, uint256 _value) private returns (bool) {
    uint8 reason = _service().check(this, msg.sender, _from, _to, _value);

    emit CheckStatus(reason, msg.sender, _from, _to, _value);

    return reason == 0;
}

  /**
   * @notice Retreives the address of the `MetamorphRegulatorInterface` that manages this token.
   *
   * @return The `MetamorphRegulatorInterface` that manages this token.
   */
  function _service() public view returns (MetamorphRegulatorInterface) {
    return MetamorphRegulatorInterface(registry.service());
  }

}