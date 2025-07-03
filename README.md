## Pluto Onchain Verifier

This is a simple contract that verifies signatures from a given notary.

The contract is deployed on Base Sepolia at [`0xb4C3FC8aE7f7a9DCc73108cd8F35f82110008189`](https://sepolia.basescan.org/address/0xb4c3fc8ae7f7a9dcc73108cd8f35f82110008189)

### Deployment & Verification

This command will deploy the contract and automatically verify it on Basescan.

1.  **Set your Private Key:** This is required to sign the deployment transaction.

    ```bash
    export PRIVATE_KEY="<YOUR_PRIVATE_KEY>"
    ```

2.  **Set your Basescan API Key:** You need an API key from Etherscan (which works for Basescan) to publish the source code. You can get one for free from the [Etherscan website](https://etherscan.io/register).

    ```bash
    export ETHERSCAN_API_KEY="<YOUR_ETHERSCAN_API_KEY>"
    ```

3.  **Run the deployment script:**

    ```bash
    forge script script/SignatureChecker.s.sol:VerifierScript \
      --rpc-url https://sepolia.base.org \
      --private-key $PRIVATE_KEY \
      --broadcast \
      --verify \
      --verifier etherscan \
      --etherscan-api-key $ETHERSCAN_API_KEY \
      -vvvv
    ```

### Manual Verification

If the deployment script succeeds but verification fails for some reason, you can verify it manually.

1.  **Find your contract address and constructor arguments:** After a successful deployment, Foundry saves a receipt in the `broadcast/` directory. Look inside `broadcast/SignatureChecker.s.sol/84532/run-latest.json`.

    - The contract address is under `receipts[0].contractAddress`.
    - The constructor arguments are the long hex string under `transactions[0].constructorArguments`.

2.  **Run the verify command:**

    ```bash
    forge verify-contract <CONTRACT_ADDRESS> src/Verifier.sol:Verifier \
      --chain base-sepolia \
      --verifier etherscan \
      --etherscan-api-key $ETHERSCAN_API_KEY \
      --constructor-args <CONSTRUCTOR_ARGS>
    ```
