# Load environment variables
source .env

# sign with private key (not recommended)
#forge script ./script/TestWhitelistAndMint.s.sol:TestWhitelistAndMint --sig "run(bool)" true --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --slow --ffi -vvvvv

# sign with key stored encrypted in foundry keystore. Note: in this case the sender MUST also be passed, as otherwise forge uses the DEFAULT_SENDER
forge script ./script/TestWhitelistAndMint.s.sol:TestWhitelistAndMint --sig "run(bool)" true --rpc-url $SEPOLIA_RPC_URL --account $SIGNER_ACCOUNT_NAME --sender $SENDER_ADDRESS --slow --ffi -vvvvv