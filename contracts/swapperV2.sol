/// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.6.6;

import "./swapper.sol";
import "hardhat/console.sol";

contract SwapperV2 is Swapper {
    using SafeERC20 for IERC20;

    /// Constants
    address constant AUGUST_SWAPPER_ADDRESS = 0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57;
    address constant TOKEN_PROXY_ADDRESS = 0x216B4B4Ba9F3e719726886d34a177484278Bfcae;
    address constant ETH_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// Functions
    function swapWithParaswap(string memory _data, address _tokenFrom, address _tokenTo, uint _amountFrom) public payable {
        uint tokenAmount;
        address tokenFromAddress = _tokenFrom;

        if (_tokenFrom == ETH_TOKEN_ADDRESS) {
            (bool success, ) = recipientAddress.call{value: msg.value * swapFee / 10000}("");
            require(success, "Transfer fee failed");
            tokenAmount = msg.value * (10000 - swapFee) / 10000;
        } else {
            IERC20 tokenFrom = IERC20(_tokenFrom);
            tokenFrom.safeTransferFrom(msg.sender, recipientAddress, _amountFrom * swapFee / 10000);
            tokenAmount = _amountFrom * (10000 - swapFee) / 10000;
        }

        if (tokenFromAddress == ETH_TOKEN_ADDRESS) {
            (bool success, bytes memory returnData) = AUGUST_SWAPPER_ADDRESS.call(
                abi.encodeWithSignature("simpleSwap", _data)
            );
            if (!success) {
                if (returnData.length < 68) revert();
                assembly {
                    returnData := add(returnData, 0x04)
                }
                revert(abi.decode(returnData, (string)));
            }
        } else {
            IERC20 tokenFrom = IERC20(tokenFromAddress);
            tokenFrom.safeTransferFrom(msg.sender, address(this), tokenAmount);
            tokenFrom.approve(TOKEN_PROXY_ADDRESS, tokenAmount);
            
            if (_tokenTo == ETH_TOKEN_ADDRESS) {
                (bool success, bytes memory returnData) = AUGUST_SWAPPER_ADDRESS.call(
                    abi.encodeWithSignature("simpleSwap", _data)
                );
                if (!success) {
                    // Next 5 lines from https://ethereum.stackexchange.com/a/83577
                    if (returnData.length < 68) revert();
                    assembly {
                        returnData := add(returnData, 0x04)
                    }
                    revert(abi.decode(returnData, (string)));
                }
            } else {
                (bool success, bytes memory returnData) = AUGUST_SWAPPER_ADDRESS.call(
                    abi.encodeWithSignature("simpleSwap", _data)
                );
                if (!success) {
                    // Next 5 lines from https://ethereum.stackexchange.com/a/83577
                    if (returnData.length < 68) revert();
                    assembly {
                        returnData := add(returnData, 0x04)
                    }
                    revert(abi.decode(returnData, (string)));
                }
            }
        }
    }
}