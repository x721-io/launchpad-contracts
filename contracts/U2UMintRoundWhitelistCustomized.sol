// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IERC721Modified.sol";
import "./interfaces/IERC1155Modified.sol";
import "./interfaces/IERC721U2UMinimal.sol";
import "./interfaces/IERC1155U2U.sol";

import "./U2UBuyBase.sol";

import "./libraries/LibStructs.sol";

contract U2UMintRoundWhitelistCustomized is Ownable, U2UBuyBase {
  
  mapping(address => bool) private _isUserWhitelisted;
  mapping(address => bool) public isAdmin;

  modifier onlyWhitelisted() {
    require(_isUserWhitelisted[msg.sender], "U2U: caller not whitelisted");
    _;
  }

  modifier onlyAdmin() {
    require(isAdmin[msg.sender] == true);
    _;
  }

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

  function setAdmin(address admin, bool status) external onlyOwner {
    isAdmin[admin] = status;
  }

  event BuyERC721(address buyer, uint projectId, address collection, uint tokenId);
  function buyERC721()
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyBelowMaxAmount721
    onlyBelowMaxAmountUser721
    onlyWhitelisted
    onlyUnlocked
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

    _round.soldAmountNFT = _round.soldAmountNFT + 1;
    _amountBought[sender] = _amountBought[sender] + 1;

    IERC721Modified erc721Modified = IERC721Modified(_collection.collectionAddress);
    uint tokenId;
    if (_round.startClaim == 0) {
      tokenId = erc721Modified.mintNFT(sender);
    } else {
      tokenId = erc721Modified.mintNFT(address(this));
    }

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
  function buyERC1155()
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyBelowMaxAmount1155(1)
    onlyBelowMaxAmountUser1155(1)
    onlyWhitelisted
    onlyUnlocked
  {
    require(!_collection.isERC721, "U2U: project collection is not ERC1155");
    bool isTimeframe = checkOnlyInTimeframe();
    require(isTimeframe, "U2U: not in timeframe");

    address sender = msg.sender;
    uint value = msg.value;
    uint totalPrice = _round.price;

    require(
      value >= totalPrice,
      "U2U: amount to transfer must be equal or greater than whitelist price"
    );
    
    _checkAndAddNewUser(sender);

    _round.soldAmountNFT = _round.soldAmountNFT + 1;
    _amountBought[sender] = _amountBought[sender] + 1;

    IERC1155Modified erc1155Modified = IERC1155Modified(_collection.collectionAddress);
    uint tokenId;
    if (_round.startClaim == 0) {
      tokenId = erc1155Modified.mintNFT(sender, 1);
    } else {
      tokenId = erc1155Modified.mintNFT(address(this), 1);
    }

    LibStructs.Token memory newToken = LibStructs.Token(tokenId, 1);
    _ownerOfAmount[sender].push(newToken);

    _transferValueAndFee(value, totalPrice);

    emit BuyERC1155(sender, _projectId, _collection.collectionAddress, tokenId, 1);
  }

  event AddWhitelistOwner(uint projectId, address[] users);
  function addWhitelistOwner(address[] calldata users)
    external
    onlyOwner
  {
    for (uint i = 0; i < users.length; i = i + 1) {
      _isUserWhitelisted[users[i]] = true;
    }

    emit AddWhitelistOwner(_projectId, users);
  }

  event AddWhitelistAdmin(uint projectId, address[] users);
  function addWhitelistAdmin(address[] calldata users)
    external
    onlyAdmin
  {
    require(
      _round.roundType == LibStructs.RoundType.RoundWhitelist,
      "U2U: admin can only call this function if this is a non-staking whitelist round"
    );
    for (uint i = 0; i < users.length; i = i + 1) {
      _isUserWhitelisted[users[i]] = true;
    }

    emit AddWhitelistAdmin(_projectId, users);
  }

  event RemoveWhitelistOwner(uint projectId, address[] users);
  function removeWhitelistOwner(address[] calldata users)
    external
    onlyOwner
  {
    for (uint i = 0; i < users.length; i = i + 1) {
      _isUserWhitelisted[users[i]] = false;
    }

    emit RemoveWhitelistOwner(_projectId, users);
  }

  event RemoveWhitelistAdmin(uint projectId, address[] users);
  function removeWhitelistAdmin(address[] calldata users)
    external
    onlyAdmin
  {
    require(
      _round.roundType == LibStructs.RoundType.RoundWhitelist,
      "U2U: admin can only call this function if this is a non-staking whitelist round"
    );
    for (uint i = 0; i < users.length; i = i + 1) {
      _isUserWhitelisted[users[i]] = false;
    }

    emit RemoveWhitelistAdmin(_projectId, users);
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