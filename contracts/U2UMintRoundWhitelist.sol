// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

// For Remix IDE use
// import "@openzeppelin/contracts@3.4/math/SafeMath.sol";
// import "@openzeppelin/contracts@3.4/access/Ownable.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IWETH.sol";
import "./interfaces/IERC721Modified.sol";
import "./interfaces/IERC1155Modified.sol";
import "./interfaces/IERC721RaribleMinimal.sol";
import "./interfaces/IERC1155Rarible.sol";

import "./U2UBuyBase.sol";

import "./libraries/LibStructs.sol";

contract U2UMintRoundWhitelist is Ownable, U2UBuyBase {
    using SafeMath for uint256;
    
    mapping(address => bool) private _isUserWhitelisted;

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

    event BuyERC721WhitelistRarible(address buyer, uint projectId, address collection, uint tokenId);
    function buyERC721WhitelistRarible(IERC721RaribleMinimal.Mint721Data calldata data)
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
            _collection.isRaribleCollection,
            "U2U: this function only works with NFTs created from Rarible contracts"
        );

        address sender = msg.sender;
        uint value = msg.value;

        require(
            value >= _round.price,
            "U2U: amount to transfer must be equal or greater than whitelist price"
        );

        _round.soldAmountNFT = _round.soldAmountNFT.add(1);
        _amountBought[sender] = _amountBought[sender].add(1);
        _checkAndAddNewUser(sender);

        IERC721RaribleMinimal erc721Minimal = IERC721RaribleMinimal(_collection.collectionAddress);
        erc721Minimal.mintAndTransfer(data, _collection.owner);
        erc721Minimal.safeTransferFrom(_collection.owner, sender, data.tokenId);

        weth.deposit{value: value}();
        weth.transfer(_collection.owner, _round.price);
        weth.transfer(sender, value.sub(_round.price));

        emit BuyERC721WhitelistRarible(sender, _projectId, _collection.collectionAddress, data.tokenId);
    }

    event BuyERC721Whitelist(address buyer, uint projectId, address collection, uint tokenId);
    function buyERC721Whitelist()
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

        _round.soldAmountNFT = _round.soldAmountNFT.add(1);
        _amountBought[sender] = _amountBought[sender].add(1);
        _checkAndAddNewUser(sender);

        IERC721Modified erc721Modified = IERC721Modified(_collection.collectionAddress);
        uint tokenId = erc721Modified.mintNFT(_collection.owner);
        erc721Modified.safeTransferNFTFrom(_collection.owner, sender, tokenId);

        weth.deposit{value: value}();
        weth.transfer(_collection.owner, _round.price);
        weth.transfer(sender, value.sub(_round.price));

        emit BuyERC721Whitelist(sender, _projectId, _collection.collectionAddress, tokenId);
    }

    event BuyERC1155WhitelistRarible(
        address buyer,
        uint projectId,
        address collection,
        uint tokenId,
        uint amount
    );
    function buyERC1155WhitelistRarible(IERC1155Rarible.Mint1155Data calldata data)
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
            _collection.isRaribleCollection,
            "U2U: this function only works with NFTs created from Rarible contracts"
        );

        address sender = msg.sender;
        uint value = msg.value;
        uint totalPrice = data.supply.mul(_round.price);

        require(
            value >= totalPrice,
            "U2U: amount to transfer must be equal or greater than whitelist price"
        );
        
        _round.soldAmountNFT = _round.soldAmountNFT.add(data.supply);
        _amountBought[sender] = _amountBought[sender].add(data.supply);
        _checkAndAddNewUser(sender);

        IERC1155Rarible erc1155 = IERC1155Rarible(_collection.collectionAddress);
        erc1155.mintAndTransfer(data, _collection.owner, data.supply);

        bytes memory _data;
        erc1155.safeTransferFrom(_collection.owner, sender, data.tokenId, data.supply, _data);
        
        weth.deposit{value: value}();
        weth.transfer(_collection.owner, totalPrice);
        weth.transfer(sender, value.sub(totalPrice));

        emit BuyERC1155WhitelistRarible(
            sender,
            _projectId,
            _collection.collectionAddress,
            data.tokenId,
            data.supply
        );
    }

    event BuyERC1155Whitelist(
        address buyer,
        uint projectId,
        address collection,
        uint tokenId,
        uint amount
    );
    function buyERC1155Whitelist(uint amount)
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
        
        _round.soldAmountNFT = _round.soldAmountNFT.add(amount);
        _amountBought[sender] = _amountBought[sender].add(amount);
        _checkAndAddNewUser(sender);

        IERC1155Modified erc1155Modified = IERC1155Modified(_collection.collectionAddress);
        uint tokenId = erc1155Modified.mintNFT(_collection.owner, amount);
        erc1155Modified.safeTransferNFTFrom(_collection.owner, sender, tokenId, amount);
        
        weth.deposit{value: value}();
        weth.transfer(_collection.owner, totalPrice);
        weth.transfer(sender, value.sub(totalPrice));

        emit BuyERC1155Whitelist(sender, _projectId, _collection.collectionAddress, tokenId, amount);
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