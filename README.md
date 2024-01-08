# Test flow for Remix IDE

- Step 1: deploy `U2UProjectManager`.
- Step 2: if collection has `isPreminted == true`, then deploy `U2UDeployerPremintRoundZero.sol`, `U2UDeployerPremintRoundWhitelist.sol`, `U2UDeployerPremintRoundFCFS.sol`. If not, then deploy `U2UDeployerMintRoundZero.sol`, `U2UDeployerMintRoundWhitelist.sol`, `U2UDeployerMintRoundFCFS.sol`.
- Step 3: use `owner` account to call to `createRound()` of `U2UProjectManager`.
- Step 4: call to `deploy()` of each `U2UDeployer*` respectively.
- Step 5: get the deployed `U2U*Round*` contract addresses using the `deployedContracts` array inside `U2UDeployer*`.
- Step 6: add addresses got from step 5 to `U2UProjectManager` by calling to `setRoundContracts()` of `U2UProjectManager`
- Step 7: use the function "At Address" with the addresses got from step 5 with respective `U2U*Round*` contracts.
- Step 8: test the buy flow.
---
# Structs
```
enum RoundType {
    RoundZero,
    RoundStaking,
    RoundWhitelist,
    RoundFCFS
}
struct Collection {
    bool isERC721;
    bool isRaribleCollection;
    bool isPreminted;
    address collectionAddress;
    address owner;
}
struct Round {
    RoundType roundType;
    uint price;
    uint start;
    uint end;
    uint maxAmountNFT;
    uint soldAmountNFT;
    uint maxAmountNFTPerWallet;
}
struct Project {
    address projectOwner;
    address[] roundAddresses;
    Collection collection;
}
```
---
# Main flow

### `U2UProjectManager`
```
function createProject(
    LibStructs.Round[] calldata rounds,
    LibStructs.Collection calldata collection,
    address projectOwner
  ) external onlyOwner onlyValidRoundAmount(rounds.length)
```
- This function is used to create a new project, the `rounds` must be in ascending chrononological order (Zero Rounds-> Whitelist Rounds -> FCFS rounds).

### `U2UBuyBase`

```
function transferNFTsToNextRound(
    address nextRound,
    uint newMaxNFTPerWallet
) external onlyOwner onlyAfterEnd
```
- This function is used to transfer leftover NFTs from ended rounds to a next round. Can only be called by contract owner.

```
function receiveAndIncreaseMaxAmountNFT(
    uint amount,
    uint newMaxNFTPerWallet
) external onlyRoundContract
```
- This function is used to update new amounts of max NFT available for a round, and max amount of NFTs per wallet. Can only be called by other round contracts.

```
function claimERC721(uint tokenId)
    external
    onlyAfterEnd
    onlyAfterStartClaim
    onlyClaimableAmount(tokenId, 1)
```
- This function is used to let users claim their ERC-721 NFT(s) from `*Round*` contracts.

```
function claimERC1155(uint tokenId, uint amount)
    external
    onlyAfterEnd
    onlyAfterStartClaim
    onlyClaimableAmount(tokenId, amount)
```
- This function is used to let uesrs claim their ERC-1155 NFT(s) from `*Round*` contracts.
### `U2UDeployer*`

```
function deploy(
    uint projectCount,
    LibStructs.Round calldata round,
    LibStructs.Collection calldata 
) external onlyOwner override returns (address)
```
- This function is used to deploy round contracts. Can only be called by contract owner.

### `U2U*RoundZero`
```
function buyERC721Rarible(uint tokenId)
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyHolderOrWhitelisted
    onlyBelowMaxAmount721
    onlyBelowMaxAmountUser721
    onlyUnlocked
```
- This function is used to buy ERC-721 tokens, whose collection was created from the Rarible Factory contract. Only NFT holders or whitelisted users can call this function.

```
function buyERC721(uint tokenId)
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyHolderOrWhitelisted
    onlyBelowMaxAmount721
    onlyBelowMaxAmountUser721
    onlyUnlocked
```
- This function is used to buy ERC-721 tokens, whose collection was NOT created from the Rarible Factory contract. Only NFT holders or whitelisted users can call this function.

```
function buyERC1155Rarible(uint tokenId, uint amount)
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyHolderOrWhitelisted
    onlyBelowMaxAmount1155(amount)
    onlyBelowMaxAmountUser1155(amount)
    onlyUnlocked
```
- This function is used to buy ERC-1155 tokens, whose collection was created from the Rarible Factory contract. Only NFT holders or whitelisted users can call this function.

```
function buyERC1155(uint tokenId, uint amount)
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyHolderOrWhitelisted
    onlyBelowMaxAmount1155(amount)
    onlyBelowMaxAmountUser1155(amount)
    onlyUnlocked
```
- This function is used to buy ERC-1155 tokens, whose collection was NOT created from the Rarible Factory contract. Only NFT holders or whitelisted users can call this function.

```
function addWhitelistOwner(address[] calldata users)
    external
    onlyUnlocked
    onlyOwner
    onlyBeforeStart
```
- This function is used to add whitelist users, can only be called by contract owners.

```
function removeWhitelistOwner(address[] calldata users)
    external
    onlyUnlocked
    onlyOwner
    onlyBeforeStart
```
- This function is used to remove whitelist users, can only be called by contract owners.

### `U2U*RoundWhitelist`

```
function buyERC721WhitelistRarible(uint tokenId)
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyBelowMaxAmount721
    onlyBelowMaxAmountUser721
    onlyWhitelisted
    onlyUnlocked
```
- This function is used to buy ERC-721 tokens, whose collection was created from the Rarible Factory contract. Only whitelisted users can call this function.

```
function buyERC721Whitelist(uint tokenId)
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyBelowMaxAmount721
    onlyBelowMaxAmountUser721
    onlyWhitelisted
    onlyUnlocked
```
- This function is used to buy ERC-721 tokens, whose collection was NOT created from the Rarible Factory contract. Only whitelisted users can call this function.

```
function buyERC1155WhitelistRarible(uint tokenId, uint amount)
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyBelowMaxAmount1155(amount)
    onlyBelowMaxAmountUser1155(amount)
    onlyWhitelisted
    onlyUnlocked
```
- This function is used to buy ERC-1155 tokens, whose collection was created from the Rarible Factory contract. Only whitelisted users can call this function.

```
function buyERC1155Whitelist(uint tokenId, uint amount)
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyBelowMaxAmount1155(amount)
    onlyBelowMaxAmountUser1155(amount)
    onlyWhitelisted
    onlyUnlocked
```
- This function is used to buy ERC-1155 tokens, whose collection was NOT created from the Rarible Factory contract. Only whitelisted users can call this function.

```
function addWhitelistAdmin(address[] calldata users)
    external
    onlyUnlocked
    onlyAdmin
    onlyBeforeStart
```
- This function is used to add whitelist users, can only be called by contract admins.

```
function removeWhitelistAdmin(address[] calldata users)
    external
    onlyUnlocked
    onlyAdmin
    onlyBeforeStart
```
- This function is used to remove whitelist users, can only be called by contract admins.
- Functions `addWhitelistOwner()` and `removeWhitelistOwner()` are the same as in `U2U*RoundZero`.

### `U2U*RoundFCFS`
```
function buyERC721Rarible(uint tokenId)
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyBelowMaxAmount721
    onlyBelowMaxAmountUser721
    onlyUnlocked
```
- This function is used to buy ERC-721 tokens, whose collection was created from the Rarible Factory contract. Anyone can call this function.

```
function buyERC721(uint tokenId)
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyBelowMaxAmount721
    onlyBelowMaxAmountUser721
    onlyUnlocked
```
- This function is used to buy ERC-721 tokens, whose collection was NOT created from the Rarible Factory contract. Anyone can call this function.

```
function buyERC1155Rarible(uint tokenId, uint amount)
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyBelowMaxAmount1155(amount)
    onlyBelowMaxAmountUser1155(amount)
    onlyUnlocked
```
- This function is used to buy ERC-1155 tokens, whose collection was created from the Rarible Factory contract. Anyone can call this function.

```
function buyERC1155(uint tokenId, uint amount)
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyBelowMaxAmount1155(amount)
    onlyBelowMaxAmountUser1155(amount)
    onlyUnlocked
```
- This function is used to buy ERC-1155 tokens, whose collection was NOT created from the Rarible Factory contract. Anyone can call this function.
---
# Getters
### `U2UProjectManager`
- `function getProject(uint projectId) external view onlyExistingProject(projectId) returns (LibStructs.Project memory)`: get info about a project with the given `projectId`.
- `function getProjectCount() external view returns (uint)`: get amount of projects created (this number also takes into account of removed projects).

### `U2UBuyBase`
- `function getRound() external onlyUnlocked view returns (LibStructs.Round memory)`: get info of a round.
- `function getProjectId() external onlyUnlocked view returns (uint)`: get project of the round
- `function getAmountUser() external onlyUnlocked view returns (uint)`: get amount of distinct users that have joined a round.
- `function getAmountBought(address user) external onlyUnlocked view returns (uint)`: get amount of NFTs a user has bought.
- `function getCollection() external onlyUnlocked view returns (LibStructs.Collection memory)`: get collection that is used for this this round.
- `mapping(address => bool) public isAdmin`: check if an address has admin rights for this round.
- `mapping(address => bool) public isUserJoined`: check if a user has joined (bought) in a round.

### `U2U*RoundWhitelist` and `U2U*RoundZero`
- `function checkIsUserWhitelisted(address user) external onlyUnlocked view returns (bool)`: check if `user` is whitelisted or not.

### `U2UDeployerBase`
- `address[] public deployedContracts`: get deployed round contracts, typically, the index to pass as parameter is `projectId - 1` (other cases where a round is removed/locked and then redeployed will have other index).
---
# Setters

### `U2UProjectManager`
- `function setRoundContracts(uint projectId, address[] calldata roundAddresses) external onlyOwner onlyValidRoundAmount(roundAddresses.length)`: set the given `roundAddresses` as rounds for the given `projectId`. The `roundAddresses` must be in ascending chrononological order (Zero Rounds-> Whitelist Rounds -> FCFS rounds).
- `function setCollection(uint projectId, LibStructs.Collection calldata newCollection) external onlyOwner onlyExistingProject(projectId) onlyBeforeStart(projectId)`: set `newCollection` as a collection for the given `projectId`.

### `U2UBuyBase`
- `function setTime(uint start, uint end) external onlyOwner onlyBeforeStart`: set time of a round.
- `function setPrice(uint price) external onlyOwner onlyBeforeStart`: set price of a round.
- `function setMaxAmountNFT(uint max) external onlyOwner onlyBeforeStart`: set max mount available NFT for purchasing of a round.
- `function setMaxAmountNFTPerWallet(uint max) external onlyOwner onlyBeforeStart`: set max amount of NFTs a wallet can buy of a round.
- `function setCollection(LibStructs.Collection calldata newCollection) external onlyProjectManager onlyBeforeStart`: set collection of a round. This function can only be called by `U2UProjectManager` contract.
- `function lock() external onlyOwner`: lock/remove a round. This function should not be called in the current state. If called, then the entire project must be recreated to ensure integrity.
 
### `U2U*RoundWhitelist`
- `function setAdmin(address admin, bool status) external onlyOwner`: set admin rights for the an account.