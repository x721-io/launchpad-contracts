# Test flow for Remix IDE

- Step 1: deploy `U2UProjectManager`.
- Step 2: if collection has `isPreminted == true`, then deploy `U2UDeployerPremintRoundZero.sol`, `U2UDeployerPremintRoundWhitelist.sol`, `U2UDeployerPremintRoundFCFS.sol`. If not, then deploy `U2UDeployerMintRoundZero.sol`, `U2UDeployerMintRoundWhitelist.sol`, `U2UDeployerMintRoundFCFS.sol`.
- Step 3: use `owner` account to call to `createRound()` of `U2UProjectManager`.
- Step 4: call to `deploy()` of each `U2UDeployer*` respectively.
- Step 5: get the deployed `U2U*Round*` contract addresses using the `deployedContracts` array inside `U2UDeployer*`.
- Step 6: add addresses got from step 5 to `U2UProjectManager` by calling to `setRoundContracts()` of `U2UProjectManager`
- Step 7: use the function "At Address" with the addresses got from step 5 with respective `U2U*Round*` contracts.
- Step 8: test the buy flow.