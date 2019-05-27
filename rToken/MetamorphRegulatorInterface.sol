pragma solidity ^0.4.25;

/// @notice Standard interface for `MetamoprhRegulatorService`
contract MetamorphRegulatorInterface {

  /**
   * @notice This method *MUST* be called by `MetamorphRegulatedToken`s during `transfer()`, `transferFrom()` and `mint()`.
   *         The implementation *SHOULD* check whether or not a transfer or mint can be approved.
   *
   * @dev    This method *MAY* call back to the token contract specified by `_token` for
   *         more information needed to enforce trade approval.
   *
   * @param  _token The address of the token to be transfered
   * @param  _spender The address of the spender of the token
   * @param  _from The address of the sender account
   * @param  _to The address of the receiver account
   * @param  _amount The amount of the token to trade
   *
   * @return uint8 The reason code: 0 means success.  Non-zero values are left to the implementation
   *               to assign meaning.
   */
  function check(address _token, address _spender, address _from, address _to, uint256 _amount) public returns (uint8);
}