/// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.6.6;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract Swapper is AccessControlUpgradeable {
    using SafeERC20 for IERC20;

    /// CONSTANTS
    /**
     *  @notice address used for store the Uniswap router(UNISWAP_ROUTER_ADDRESS) address in the mainnet
     */
    address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

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

    /// EVENTS

    /**
     *  @notice Event fired every time that a Swap is maded
     *  @param swapper is the address of the user who made the swap
     *  @param tokenGiven is the address of the token given for the swap
     *  @param tokenReceived is the address of the token received for the swap
     *  @param amountGiven is the amount of the token given for the swap
     *  @param amountReceived is the amount of the token received for the swap
     */
    event Swap(
        address swapper,
        address tokenGiven,
        address tokenReceived,
        uint amountGiven,
        uint amountReceived
    );

    /// MODIFIERS

    /**
     *  @notice Modifier function that check if the user has an specific role
     *  @param _role is the bytes32 representing the role that the user must have
     */
    modifier onlyRole(bytes32 _role) {
        require(hasRole(_role, msg.sender));
        _;
    }

    /// FUNCTIONS
    /**
     *  @notice Constructor function that initialice the contract
     */
    function initialize() public initializer {
        __AccessControl_init();
        _setupRole(ADMIN_ROLE, msg.sender);

        setRecipientAddress(msg.sender);
        setSwapFee(10);
    }

    /**
     *  @notice Function that allows swap one token to several tokens desired by the user
     *  @param _tokenFrom is the address of the token which the user wants to give in the swap
     *  @param _tokenAmount is the amount of the token which the user wants to give in the swap
     *  @param _tokens is the address of the tokens which the user wants to change in the swap
     *  @param _percentages is the percentage of the tokens which the user wants to change in the swap
     */
    function swap(
        address _tokenFrom,
        uint _tokenAmount,
        address[] memory _tokens,
        uint[] memory _percentages
    ) public payable {
        uint tokenAmount;
        address tokenFromAddress = _tokenFrom;

        if (_tokenFrom == address(0)) {
            tokenFromAddress = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS).WETH();
            (bool success, ) = recipientAddress.call{value: msg.value * swapFee / 10000}("");
            require(success, "Transfer fee failed");
            tokenAmount = msg.value * (10000 - swapFee) / 10000;
        } else {
            IERC20 tokenFrom = IERC20(_tokenFrom);
            tokenFrom.safeTransferFrom(msg.sender, recipientAddress, _tokenAmount * swapFee / 10000);
            tokenAmount = _tokenAmount * (10000 - swapFee) / 10000;
        }

        for(uint i = 0; i <_tokens.length; i++) {
            if (_tokens[i] == address(0)) _tokens[i] = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS).WETH();
            uint amount = tokenAmount * _percentages[i] / 10000;
            uint[] memory amounts;

            address[] memory path = new address[](2);
            path[0] = tokenFromAddress;
            path[1] = _tokens[i];

            if (tokenFromAddress == IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS).WETH()) {
                amounts = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS).swapExactETHForTokens{ value: amount }(amount, path, msg.sender, block.timestamp);
            } else {
                IERC20 tokenFrom = IERC20(tokenFromAddress);
                tokenFrom.safeTransferFrom(msg.sender, address(this), amount);
                tokenFrom.approve(UNISWAP_ROUTER_ADDRESS, amount);
                
                if (_tokens[i] == IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS).WETH()) {
                    amounts = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS).swapExactTokensForETH(amount, 0, path, msg.sender, block.timestamp);
                } else {
                    amounts = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS).swapExactTokensForTokens(amount, 0, path, msg.sender, block.timestamp);
                }
            }

            emit Swap(msg.sender, path[0], path[1], amounts[0], amounts[1]);
        }
    }

    /**
     *  @notice Set function that allows the admin to set the swap fee
     *  @param _swapFee is a uint which will be the new swap fee
     */
    function setSwapFee(uint _swapFee) public onlyRole(ADMIN_ROLE) {
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
    function isAdmin(address _address) public view returns (bool) {
        return(hasRole(ADMIN_ROLE, _address));
    }
}