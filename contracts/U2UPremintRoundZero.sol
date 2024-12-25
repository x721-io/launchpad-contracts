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

contract U2UPremintRoundZero is Ownable, U2UPremintBase {
  
  IERC721Modified private _requiredCollection721;
  mapping(address => bool) private _isUserWhitelisted;

  constructor(
    uint projectId,
    LibStructs.Round memory round,
    LibStructs.Collection memory collection,
    LibStructs.Timeframe[] memory timeframes,
    address _projectManager,
    address _feeReceiver,
    address requiredCollection721
  ) U2UBuyBase(msg.sender) {
    _projectId = projectId;
    _round = round;
    _collection = collection;
    projectManager = _projectManager;
    feeReceiver = _feeReceiver;
    _requiredCollection721 = IERC721Modified(requiredCollection721);
    setTimeframes(timeframes);
  }

  event BuyERC721(address buyer, uint projectId, address collection, uint tokenId);
  function buyERC721()
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyBelowMaxAmount721
    onlyBelowMaxAmountUser721
    onlyUnlocked
  {
    require(_collection.isERC721, "U2U: project collection not ERC721");
    bool isTimeframe = checkOnlyInTimeframe();
    require(isTimeframe, "U2U: not in timeframe");

    address sender = msg.sender;
    uint value = msg.value;

    require(
      _requiredCollection721.balanceOf(sender) > 0 || _isUserWhitelisted[sender],
      "U2U: only NFT holders"
    );
    require(value >= _round.price, "U2U: value not enough");
    _checkAndAddNewUser(sender);

    uint tokenIndex = _pickTokenByIndex();
    uint tokenId = _tokens[tokenIndex].id;
    _round.soldAmountNFT = _round.soldAmountNFT + 1;
    _amountBought[sender] = _amountBought[sender] + 1;
    
    LibStructs.Token memory newToken = LibStructs.Token(tokenId, 1);
    _ownerOfAmount[sender].push(newToken);

    IERC721Modified erc721Modified = IERC721Modified(_collection.collectionAddress);
    erc721Modified.safeTransferNFTFrom(_collection.owner, address(this), tokenId);
    _removeTokenAtIndex(tokenIndex, 1);

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
    require(!_collection.isERC721, "U2U: project collection is ERC721");
    bool isTimeframe = checkOnlyInTimeframe();
    require(isTimeframe, "U2U: not in timeframe");

    address sender = msg.sender;
    uint value = msg.value;
    uint totalPrice = amount * _round.price;

    require(
      _requiredCollection721.balanceOf(sender) > 0 || _isUserWhitelisted[sender],
      "U2U: only NFT holders"
    );
    require(value >= totalPrice, "U2U: value not enough");

    _checkAndAddNewUser(sender);
    
    uint tokenId = _tokens[0].id;
    _round.soldAmountNFT = _round.soldAmountNFT + amount;
    _amountBought[sender] = _amountBought[sender] + amount;
    _removeTokenAtIndex(0, amount);
    
    LibStructs.Token memory newToken = LibStructs.Token(tokenId, amount);
    _ownerOfAmount[sender].push(newToken);

    IERC1155Modified erc1155Modified = IERC1155Modified(_collection.collectionAddress);
    erc1155Modified.safeTransferNFTFrom(_collection.owner, address(this), tokenId, amount);

    _transferValueAndFee(value, totalPrice);

    emit BuyERC1155(sender, _projectId, _collection.collectionAddress, tokenId, amount);
  }

  event AddWhitelistOwner(uint projectId, address[] users);
  function addWhitelistOwner(address[] calldata users)
    external
    onlyUnlocked
    onlyOwner
    onlyBeforeStart
  {
    for (uint i = 0; i < users.length; i = i + 1) {
      _isUserWhitelisted[users[i]] = true;
    }

    emit AddWhitelistOwner(_projectId, users);
  }

  event RemoveWhitelistOwner(uint projectId, address[] users);
  function removeWhitelistOwner(address[] calldata users)
    external
    onlyUnlocked
    onlyOwner
    onlyBeforeStart
  {
    for (uint i = 0; i < users.length; i = i + 1) {
      _isUserWhitelisted[users[i]] = false;
    }

    emit RemoveWhitelistOwner(_projectId, users);
  }

  function checkIsUserWhitelisted(address user)
    external
    onlyUnlocked
    view
    returns (bool)
  {
    return _isUserWhitelisted[user];
  }
}