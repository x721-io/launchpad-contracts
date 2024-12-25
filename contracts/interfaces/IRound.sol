// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma abicoder v2;

import "../libraries/LibStructs.sol";

interface IRound {
  function transferOwnership(address newOwner) external;
  function getRound() external view returns (LibStructs.Round memory);
  function receiveAndIncreaseMaxAmountNFT(uint amount, uint newMaxNFTPerWallet) external;
  function receiveTokensAndIncreaseMaxAmountNFT(uint amount, uint newMaxNFTPerWallet, LibStructs.Token[] memory tokens) external;
  function setCollection(LibStructs.Collection memory newCollection) external;
}