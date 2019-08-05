pragma solidity ^0.4.25;

import '../utils/Ownable.sol';
import './MetamorphRegulatorInterface.sol';
import '../ERC20/R_ERC20Detailed.sol';

/**
 * @title  On-chain RegulatorService implementation for approving trades
 */
contract MetamorphTokenRegulator is MetamorphRegulatorInterface, Ownable {
  /**
   * @dev Throws if called by any account other than the admin
   */
  modifier onlyAdmins() {
    require(admins[msg.sender], "sender is not admin");
    _;
  }

  /// @dev Settings that affect token trading at a global level
  struct Settings {

    /**
     * @dev Toggle for locking/unlocking trades at a token level.
     *      The default will be set to to locked
     */
    bool unlocked;

    /**
     * @dev Toggle for allowing/disallowing fractional token trades at a token level.
     *      The default state when this contract is created `false` (or no partial
     *      transfers allowed).
     */
    bool partialTransfers;

    /**
    * @dev We set the maximum of minting allowance
    */
    uint256 mintAllowance;
}

  // @dev Check success code
  uint8 constant private CHECK_SUCCESS = 0;

  // @dev Check error reason: Token is locked
  uint8 constant private CHECK_ELOCKED = 1;

  // @dev Check error reason: Token can not trade partial amounts
  uint8 constant private CHECK_EDIVIS = 2;

  // @dev Check error reason: Sender is not allowed to send the token
  uint8 constant private CHECK_ESEND = 3;

  // @dev Check error reason: Receiver is not allowed to receive the token
  uint8 constant private CHECK_ERECV = 4;

  /// @dev Permission bits for allowing a participant to send tokens
  uint8 constant private PERM_SEND = 0x1;

  /// @dev Permission bits for allowing a participant to receive tokens
  uint8 constant private PERM_RECEIVE = 0x2;

  // @dev mapping of the administrators
  mapping(address => bool) public admins;

  /// @notice Permissions that allow/disallow token trades on a per token level
  mapping(address => Settings) public settings;

  /// @dev Permissions that allow/disallow token trades on a per participant basis.
  ///      The format for key based access is `participants[participantAddress]`
  ///      which returns the permission bits of a participant
  mapping(address => uint8) public participants;

  /// @dev Event raised when a token's locked setting is set
  event LogLockSet(address indexed token, bool locked);

  /// @dev Event raised when a participant permissions are set
  event LogPermissionSet(address indexed participant, uint8 permission);

   /// @dev Event raised when a token's partial transfer setting is set
  event LogPartialTransferSet(address indexed token, bool enabled);

  /// @dev Event raised when the admin priviledges changes
  event LogAdmin(address indexed admin, bool isAdmin);

  /// @dev Mint Allowance
  event MintAllowance(address indexed token, uint256 mintAllowance);

  constructor() public {
    admins[msg.sender] = true;
  }

  /**
   * @notice Locks the ability to trade a token
   *
   * @dev    This method can only be called by this contract's owner
   *
   * @param  _token The address of the token to lock
   * @param  _unlocked true to allow trades, false to lock to lock the token
   */
  function setUnlocked(address _token, bool _unlocked) public onlyAdmins {
    settings[_token].unlocked = _unlocked;
    emit LogLockSet(_token, _unlocked);
  }

  function setMintAllowance(address _token, uint256 _mintAllowance) public onlyAdmins {
    uint256 totalSupply = R_ERC20Detailed(_token).totalSupply();
    require(_mintAllowance > totalSupply, "minting allowance should be greater than the supply");
    settings[_token].mintAllowance = _mintAllowance;
    emit MintAllowance(_token, _mintAllowance);
  }

  /**
   * @notice Sets the trade permissions for a participant on a token
   *
   * @dev    The `_permission` bits overwrite the previous trade permissions and can
   *         only be called by the admins.  `_permissions` can be bitwise
   *         `|`'d together to allow for more than one permission bit to be set.
   *
   * @param  _participant The address of the trade participant
   * @param  _permission Permission bits to be set
   */
  function setPermission(address _participant, uint8 _permission) public onlyAdmins {
    participants[_participant] = _permission;
    emit LogPermissionSet(_participant, _permission);
  }

  /**
   * @notice Allows the ability to trade a fraction of a token
   *
   * @dev    This method can only be called by this contract's owner
   *
   * @param  _token The address of the token to allow partial transfers
   */
  function setPartialTransfers(address _token, bool _enabled) onlyOwner public {
   settings[_token].partialTransfers = _enabled;

   emit LogPartialTransferSet(_token, _enabled);
  }

  /**
   * @dev Allows the owner to transfer admin controls to newAdmin.
   *
   * @param _admin The address to transfer admin rights to.
   */
  function setAdmin(address _admin, bool _permission) public onlyOwner {
    require(_admin != address(0), "address cannot be 0x");
    admins[_admin] = _permission;
    emit LogAdmin(_admin, _permission);
  }

  /**
   * @dev Allows the owner mint tokens depending of the allowance set.
   *
   * @param _token The address of the token to mint
   * @param _amount The amount to mint
   */
  function checkMint(address _token, uint256 _amount) public view returns (bool) {
    uint256 totalSupply = R_ERC20Detailed(_token).totalSupply();
    return(totalSupply + _amount <= settings[_token].mintAllowance);
  }

  /**
   * @notice Checks whether or not a trade should be approved
   *
   * @dev    This method calls back to the token contract specified by `_token` for
   *         information needed to enforce trade approval if needed
   *
   * @param  _token The address of the token to be transfered
   * @param  _spender The address of the spender of the token (unused in this implementation)
   * @param  _from The address of the sender account
   * @param  _to The address of the receiver account
   * @param  _amount amoun to be transfered
   *
   * @return `true` if the trade should be approved and `false` if the trade should not be approved
   */
  function check(address _token, address _spender, address _from, address _to, uint256 _amount) public returns (uint8) {
     if (!settings[_token].unlocked) {
      return CHECK_ELOCKED;
    }

    if (participants[_from] & PERM_SEND == 0) {
      return CHECK_ESEND;
    }

    if (participants[_to] & PERM_RECEIVE == 0) {
      return CHECK_ERECV;
    }

    if (!settings[_token].partialTransfers) {
      if(_amount % _wholeToken(_token) != 0){
        return CHECK_EDIVIS;
      }
    }

    return CHECK_SUCCESS;
  }

  /**
   * @notice Retrieves the whole token value from a token that this `MetamorphTokenRegulator` manages
   *
   * @param  _token The token address of the managed token
   *
   * @return The uint256 value that represents a single whole token
   */
  function _wholeToken(address _token) public view returns (uint256) {
    return uint256(10)**R_ERC20Detailed(_token).decimals();
  }

  function isAdmin(address _admin) public view returns (bool) {
    return admins[_admin];
  }

  function getStatus(address _token, address _from, address _to) public view returns (bool, bool, uint8, uint8, uint256) {
    return(
      settings[_token].unlocked,
      settings[_token].partialTransfers,
      participants[_from],
      participants[_to],
      settings[_token].mintAllowance
    );
  }

  function checkPartialTransfer(address _token, uint256 _amount) public view returns (uint256) {
    return _amount % _wholeToken(_token);
  }
}