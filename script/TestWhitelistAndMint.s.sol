// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {BatchScript} from "src/BatchScript.sol";
import {console2} from "forge-std/console2.sol";

/// @notice A test for Gnosis Safe batching script to whitelist ERC1400 investors and mint tokens to him, all in the same batch. 
/// Checks also if the Gnosis Safe is allowed to mint, and if not also adds an additional transaction to the batch to assign minter right.
/// @dev    SEPOLIA
contract TestWhitelistAndMint is BatchScript {

    address private GNOSIS_MULTI_SIG_CONTRACT_ADDRESS = 0xeC5c6A2A00736559B949290bFd6BDd10E9cb1417;

    address private constant ERC1400_TOKEN = 0x113F4b63916706cA272Af45d5620b4ED04386574;
    address private constant EXTENSION_CONTRACT = 0x4eDF11a8e19aB716560C64Ef0EBF8f970576DfD2;

    /// @notice The main script entrypoint
    function run(bool send_) external isBatch(GNOSIS_MULTI_SIG_CONTRACT_ADDRESS) {

        address investor = 0x20ebBbd54f2b73cB457870Cf63E89CDB1ca76e79;
        uint256 tokenAmount = 1;
        address tokenAddress = ERC1400_TOKEN;
        address extensionAddress = EXTENSION_CONTRACT;

        // 1. whitelist
        //function addAllowlisted(address token, address account)
        bytes memory txn1 = abi.encodeWithSignature(
            "addAllowlisted(address,address)",
            tokenAddress,
            investor,
            [0]
        );
        addToBatch(extensionAddress, 0, txn1);

        //function isMinter(address account)
        bytes memory isMinterCall = abi.encodeWithSignature(
            "isMinter(address)",
            GNOSIS_MULTI_SIG_CONTRACT_ADDRESS
        );

        (bool success, bytes memory data) = tokenAddress.call(isMinterCall);
        bool isMinter;
        if (success) {
            (isMinter) = abi.decode(data, (bool));
            console2.log("IsMinter: ", isMinter);
        }
        else {
            revert("isMinter() call failed");
        }

        if (!isMinter) {
            console2.log("Gnosis safe not a minter. Adding safe %s as minter.", GNOSIS_MULTI_SIG_CONTRACT_ADDRESS);

            //function addMinter(address account)
            bytes memory addMinterTx = abi.encodeWithSignature(
                "addMinter(address)",
                GNOSIS_MULTI_SIG_CONTRACT_ADDRESS                
            );
            addToBatch(tokenAddress, 0, addMinterTx);
        }

        // 2. mint
        bytes memory emptyData;
        //function issue(address tokenHolder, uint256 value, bytes calldata data)
        bytes memory txn2 = abi.encodeWithSignature(
            "issue(address,uint256,bytes)",
            investor,
            tokenAmount,
            emptyData
        );
        addToBatch(tokenAddress, 0, txn2);

        // Execute batch
        executeBatch(send_);
    }
}
