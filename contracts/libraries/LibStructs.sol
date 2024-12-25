// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library LibStructs {
  enum RoundType {
    RoundZero,
    RoundWhitelist,
    RoundFCFS
  }

  struct Collection {
    bool isERC721;
    bool isU2UCollection;
    bool isPreminted;
    address collectionAddress;
    address owner;
  }

  struct Round {
    RoundType roundType;
    uint price;
    uint start;
    uint end;
    uint startClaim;
    uint maxAmountNFT;
    uint soldAmountNFT;
    uint maxAmountNFTPerWallet;
  }

  struct Project {
    address projectOwner;
    address[] roundAddresses;
    Collection collection;
  }

  struct Token {
    uint id;
    uint amount;
  }

  struct Timeframe {
    uint8 hourStart;
    uint8 minuteStart;
    uint8 hourEnd;
    uint8 minuteEnd;
  }
}