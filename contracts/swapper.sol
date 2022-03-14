/// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract Swapper is AccessControlUpgradeable {

    /// VARIABLES
    /**
     *  @notice uint's used for storage
     *  swapFee is the fee for every swap transaction
     */
    uint public swapFee;

    /**
     *  @notice Variable used for store the address for pay the fees
     */
    address public recipientAddress;

    /**
     *  @notice Bytes32 used for roles
     */
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /// STATES

    /// EVENTS

    /// MODIFIERS

    /// FUNCTIONS
    /**
     *  @notice Constructor function that initialice the contract
     */
    function initialize(address _recipientAddress) public initializer {
        __AccessControl_init();
        _grantRole(ADMIN_ROLE, msg.sender);

        setRecipientAddress(_recipientAddress);
    }

    /**
     *  @notice Set function that allows the admin to set the swap fee
     *  @param _swapFee is a uint which will be the new swap fee
     */
    function setSwapFee(uint _swapFee) external onlyRole(ADMIN_ROLE) {
        require(_swapFee >= 0 && _swapFee <= 1000, "Wrong fee!");

        swapFee = _swapFee;
    }

    /**
     *  @notice Set function that allows the admin to set the recipient address
     *  @param _recipientAddress is the address which will be the new recipient address
     */
    function setRecipientAddress(address _recipientAddress) public onlyRole(ADMIN_ROLE) {
        recipientAddress = _recipientAddress;
    }

    /**
     *  @notice Function that allow to know if an address has the ADMIN_ROLE role
     *  @param _address is the address for check
     *  @return a boolean, true if the user has the ADMIN_ROLE role or false otherwise
     */
    function isAdmin(address _address) external view returns (bool) {
        return(hasRole(ADMIN_ROLE, _address));
    }
}