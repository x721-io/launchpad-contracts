// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma abicoder v2;

// For Remix IDE use
// import "@openzeppelin/contracts@3.4/math/SafeMath.sol";
// import "@openzeppelin/contracts@3.4/access/Ownable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IERC721Modified.sol";
import "./interfaces/IERC1155Modified.sol";
import "./interfaces/IERC721U2UMinimal.sol";
import "./interfaces/IERC1155U2U.sol";

import "./U2UPremintBase.sol";

import "./libraries/LibStructs.sol";

contract U2UPremintRoundFCFS is Ownable, U2UPremintBase {
  
  constructor(
    uint projectId,
    LibStructs.Round memory round,
    LibStructs.Collection memory collection,
    LibStructs.Timeframe[] memory timeframes,
    address _projectManager,
    address _feeReceiver
  ) U2UBuyBase(msg.sender) {
    _projectId = projectId;
    _round = round;
    _collection = collection;
    projectManager = _projectManager;
    feeReceiver = _feeReceiver;
    setTimeframes(timeframes);
  }

  // event BuyERC721U2U(address buyer, uint projectId, address collection, uint tokenId);
  // function buyERC721U2U()
  //   external
  //   payable
  //   onlyAfterStart
  //   onlyBeforeEnd
  //   onlyBelowMaxAmount721
  //   onlyBelowMaxAmountUser721
  //   onlyUnlocked
  //   onlyTokenIdsAvailable
  // {
  //   require(_collection.isERC721, "U2U: project collection is not ERC721");
  //   require(
  //     _collection.isU2UCollection,
  //     "U2U: this function only works with NFTs created from U2U contracts"
  //   );

  //   address sender = msg.sender;
  //   uint value = msg.value;

  //   require(
  //     value >= _round.price,
  //     "U2U: amount to transfer must be equal or greater than whitelist price"
  //   );

  //   _checkAndAddNewUser(sender);

  //   uint tokenIndex = _pickTokenByIndex();
  //   uint tokenId = _tokens[tokenIndex].id;
  //   _round.soldAmountNFT = _round.soldAmountNFT.add(1);
  //   _amountBought[sender] = _amountBought[sender].add(1);
  //   _removeTokenAtIndex(tokenIndex, 1);

  //   IERC721U2UMinimal erc721Minimal = IERC721U2UMinimal(_collection.collectionAddress);
  //   erc721Minimal.safeTransferFrom(_collection.owner, address(this), tokenId);

  //   LibStructs.Token memory newToken = LibStructs.Token(tokenId, 1);
  //   _ownerOfAmount[sender].push(newToken);

  //   _transferValueAndFee(value, _round.price);

  //   emit BuyERC721U2U(sender, _projectId, _collection.collectionAddress, tokenId);
  // }

  event BuyERC721(address buyer, uint projectId, address collection, uint tokenId);
  function buyERC721()
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyBelowMaxAmount721
    onlyBelowMaxAmountUser721
    onlyUnlocked
    onlyTokenIdsAvailable
  {
    require(_collection.isERC721, "U2U: project collection is not ERC721");
    bool isTimeframe = checkOnlyInTimeframe();
    require(isTimeframe, "U2U: not in timeframe");

    address sender = msg.sender;
    uint value = msg.value;

    require(
      value >= _round.price,
      "U2U: amount to transfer must be equal or greater than whitelist price"
    );

    _checkAndAddNewUser(sender);

    uint tokenIndex = _pickTokenByIndex();
    uint tokenId = _tokens[tokenIndex].id;
    _round.soldAmountNFT = _round.soldAmountNFT + 1;
    _amountBought[sender] = _amountBought[sender] + 1;
    _removeTokenAtIndex(tokenIndex, 1);

    IERC721Modified erc721Modified = IERC721Modified(_collection.collectionAddress);
    erc721Modified.safeTransferNFTFrom(_collection.owner, address(this), tokenId);

    LibStructs.Token memory newToken = LibStructs.Token(tokenId, 1);
    _ownerOfAmount[sender].push(newToken);

    _transferValueAndFee(value, _round.price);

    emit BuyERC721(sender, _projectId, _collection.collectionAddress, tokenId);
  }

  event BuyERC1155(
    address buyer,
    uint projectId,
    address collection,
    uint tokenId,
    uint amount
  );
  function buyERC1155(uint amount)
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyBelowMaxAmount1155(amount)
    onlyBelowMaxAmountUser1155(amount)
    onlyUnlocked
  {
    require(!_collection.isERC721, "U2U: project collection is not ERC1155");
    bool isTimeframe = checkOnlyInTimeframe();
    require(isTimeframe, "U2U: not in timeframe");

    address sender = msg.sender;
    uint value = msg.value;
    uint totalPrice = amount * _round.price;

    require(
      value >= totalPrice,
      "U2U: amount to transfer must be equal or greater than whitelist price"
    );

    _checkAndAddNewUser(sender);

    uint tokenId = _tokens[0].id;
    _round.soldAmountNFT = _round.soldAmountNFT + amount;
    _amountBought[sender] = _amountBought[sender] + amount;
    _removeTokenAtIndex(0, amount);

    IERC1155Modified erc1155Modified = IERC1155Modified(_collection.collectionAddress);
    erc1155Modified.safeTransferNFTFrom(_collection.owner, address(this), tokenId, amount);

    LibStructs.Token memory newToken = LibStructs.Token(tokenId, amount);
    _ownerOfAmount[sender].push(newToken);

    _transferValueAndFee(value, totalPrice);

    emit BuyERC1155(sender, _projectId, _collection.collectionAddress, tokenId, amount);
  }
}