// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

library LibStructs {
    enum RoundType {
        RoundZero,
        RoundStaking,
        RoundWhitelist,
        RoundFCFS
    }

    struct Collection {
        // string name;
        // string symbol;
        // string baseURI;
        // string contractURI;
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
}