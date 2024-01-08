// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

// For Remix IDE use
// import "@openzeppelin/contracts@3.4/math/SafeMath.sol";
// import "@openzeppelin/contracts@3.4/access/Ownable.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IERC721Modified.sol";
import "./interfaces/IERC1155Modified.sol";
import "./interfaces/IERC721U2UMinimal.sol";
import "./interfaces/IERC1155U2U.sol";

import "./U2UBuyBase.sol";

import "./libraries/LibStructs.sol";

contract U2UMintRoundWhitelist is Ownable, U2UBuyBase {
  using SafeMath for uint256;
  
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
    LibStructs.Collection memory collection
  ) {
    _projectId = projectId;
    _round = round;
    _collection = collection;
  }

  function setAdmin(address admin, bool status) external onlyOwner {
    isAdmin[admin] = status;
  }

  event BuyERC721U2U(address buyer, uint projectId, address collection, uint tokenId);
  function buyERC721U2U(IERC721U2UMinimal.Mint721Data calldata data)
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
    require(
      _collection.isU2UCollection,
      "U2U: this function only works with NFTs created from U2U contracts"
    );

    address sender = msg.sender;
    uint value = msg.value;

    require(
      value >= _round.price,
      "U2U: amount to transfer must be equal or greater than whitelist price"
    );

    _checkAndAddNewUser(sender);

    _round.soldAmountNFT = _round.soldAmountNFT.add(1);
    _amountBought[sender] = _amountBought[sender].add(1);

    IERC721U2UMinimal erc721Minimal = IERC721U2UMinimal(_collection.collectionAddress);
    if (_round.startClaim == 0) {
      erc721Minimal.mintAndTransfer(data, sender);
    } else {
      erc721Minimal.mintAndTransfer(data, address(this));
    }

    LibStructs.Token memory newToken = LibStructs.Token(data.tokenId, 1);
    _ownerOfAmount[sender].push(newToken);

    _transferValueAndFee(value, _round.price);

    emit BuyERC721U2U(sender, _projectId, _collection.collectionAddress, data.tokenId);
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

    address sender = msg.sender;
    uint value = msg.value;

    require(
      value >= _round.price,
      "U2U: amount to transfer must be equal or greater than whitelist price"
    );

    _checkAndAddNewUser(sender);

    _round.soldAmountNFT = _round.soldAmountNFT.add(1);
    _amountBought[sender] = _amountBought[sender].add(1);

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

  event BuyERC1155U2U(
    address buyer,
    uint projectId,
    address collection,
    uint tokenId,
    uint amount
  );
  function buyERC1155U2U(IERC1155U2U.Mint1155Data calldata data)
    external
    payable
    onlyAfterStart
    onlyBeforeEnd
    onlyBelowMaxAmount1155(data.supply)
    onlyBelowMaxAmountUser1155(data.supply)
    onlyWhitelisted
    onlyUnlocked
  {
    require(!_collection.isERC721, "U2U: project collection is not ERC1155");
    require(
      _collection.isU2UCollection,
      "U2U: this function only works with NFTs created from U2U contracts"
    );

    address sender = msg.sender;
    uint value = msg.value;
    uint totalPrice = data.supply.mul(_round.price);

    require(
      value >= totalPrice,
      "U2U: amount to transfer must be equal or greater than whitelist price"
    );
    
    _checkAndAddNewUser(sender);

    _round.soldAmountNFT = _round.soldAmountNFT.add(data.supply);
    _amountBought[sender] = _amountBought[sender].add(data.supply);

    IERC1155U2U erc1155 = IERC1155U2U(_collection.collectionAddress);
    if (_round.startClaim == 0) {
      erc1155.mintAndTransfer(data, sender, data.supply);
    } else {
      erc1155.mintAndTransfer(data, address(this), data.supply);
    }

    LibStructs.Token memory newToken = LibStructs.Token(data.tokenId, data.supply);
    _ownerOfAmount[sender].push(newToken);

    _transferValueAndFee(value, totalPrice);

    emit BuyERC1155U2U(
      sender,
      _projectId,
      _collection.collectionAddress,
      data.tokenId,
      data.supply
    );
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
    onlyWhitelisted
    onlyUnlocked
  {
    require(!_collection.isERC721, "U2U: project collection is not ERC1155");

    address sender = msg.sender;
    uint value = msg.value;
    uint totalPrice = amount.mul(_round.price);

    require(
      value >= totalPrice,
      "U2U: amount to transfer must be equal or greater than whitelist price"
    );
    
    _checkAndAddNewUser(sender);

    _round.soldAmountNFT = _round.soldAmountNFT.add(amount);
    _amountBought[sender] = _amountBought[sender].add(amount);

    IERC1155Modified erc1155Modified = IERC1155Modified(_collection.collectionAddress);
    uint tokenId;
    if (_round.startClaim == 0) {
      tokenId = erc1155Modified.mintNFT(sender, amount);
    } else {
      tokenId = erc1155Modified.mintNFT(address(this), amount);
    }

    LibStructs.Token memory newToken = LibStructs.Token(tokenId, amount);
    _ownerOfAmount[sender].push(newToken);

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
    for (uint i = 0; i < users.length; i = i.add(1)) {
      _isUserWhitelisted[users[i]] = true;
    }

    emit AddWhitelistOwner(_projectId, users);
  }

  event AddWhitelistAdmin(uint projectId, address[] users);
  function addWhitelistAdmin(address[] calldata users)
    external
    onlyUnlocked
    onlyAdmin
    onlyBeforeStart
  {
    require(
      _round.roundType == LibStructs.RoundType.RoundWhitelist,
      "U2U: admin can only call this function if this is a non-staking whitelist round"
    );
    for (uint i = 0; i < users.length; i = i.add(1)) {
      _isUserWhitelisted[users[i]] = true;
    }

    emit AddWhitelistAdmin(_projectId, users);
  }

  event RemoveWhitelistOwner(uint projectId, address[] users);
  function removeWhitelistOwner(address[] calldata users)
    external
    onlyUnlocked
    onlyOwner
    onlyBeforeStart
  {
    for (uint i = 0; i < users.length; i = i.add(1)) {
      _isUserWhitelisted[users[i]] = false;
    }

    emit RemoveWhitelistOwner(_projectId, users);
  }

  event RemoveWhitelistAdmin(uint projectId, address[] users);
  function removeWhitelistAdmin(address[] calldata users)
    external
    onlyUnlocked
    onlyAdmin
    onlyBeforeStart
  {
    require(
      _round.roundType == LibStructs.RoundType.RoundWhitelist,
      "U2U: admin can only call this function if this is a non-staking whitelist round"
    );
    for (uint i = 0; i < users.length; i = i.add(1)) {
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