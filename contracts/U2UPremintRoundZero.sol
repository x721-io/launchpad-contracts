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

contract U2UPremintRoundZero is Ownable, U2UBuyBase {
    using SafeMath for uint256;
    
    IERC721Modified private _requiredCollection721 = IERC721Modified(0x02bbf482d7a8b027a5B1b8A84f4BccC1ab67D276);           // This is just a placeholder address
    // IERC1155 private _requiredCollection1155 = IERC1155(0x7088316151cf49E1F9cD93Acd1B4dfed0a9f8Ece);        // This is just a placeholder address

    mapping(address => bool) private _isUserWhitelisted;

    modifier onlyHolderOrWhitelisted() {
        require(
            _requiredCollection721.balanceOf(msg.sender) > 0 || _isUserWhitelisted[msg.sender],
            "U2U: only NFT holders can buy"
        );
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

    event BuyERC721Rarible(address buyer, uint projectId, address collection, uint tokenId);
    function buyERC721Rarible(uint tokenId)
        external
        payable
        onlyAfterStart
        onlyBeforeEnd
        onlyHolderOrWhitelisted
        onlyBelowMaxAmount721
        onlyBelowMaxAmountUser721
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
        erc721Minimal.safeTransferFrom(_collection.owner, sender, tokenId);

        weth.deposit{value: value}();
        weth.transfer(_collection.owner, _round.price);
        weth.transfer(sender, value.sub(_round.price));

        emit BuyERC721Rarible(sender, _projectId, _collection.collectionAddress, tokenId);
    }

    event BuyERC721(address buyer, uint projectId, address collection, uint tokenId);
    function buyERC721(uint tokenId)
        external
        payable
        onlyAfterStart
        onlyBeforeEnd
        onlyHolderOrWhitelisted
        onlyBelowMaxAmount721
        onlyBelowMaxAmountUser721
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
        erc721Modified.safeTransferNFTFrom(_collection.owner, sender, tokenId);

        weth.deposit{value: value}();
        weth.transfer(_collection.owner, _round.price);
        weth.transfer(sender, value.sub(_round.price));

        emit BuyERC721(sender, _projectId, _collection.collectionAddress, tokenId);
    }

    event BuyERC1155Rarible(
        address buyer,
        uint projectId,
        address collection,
        uint tokenId,
        uint amount
    );
    function buyERC1155Rarible(uint tokenId, uint amount)
        external
        payable
        onlyAfterStart
        onlyBeforeEnd
        onlyHolderOrWhitelisted
        onlyBelowMaxAmount1155(amount)
        onlyBelowMaxAmountUser1155(amount)
        onlyUnlocked
    {
        require(!_collection.isERC721, "U2U: project collection is not ERC1155");
        require(
            _collection.isRaribleCollection,
            "U2U: this function only works with NFTs created from Rarible contracts"
        );

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

        IERC1155Rarible erc1155 = IERC1155Rarible(_collection.collectionAddress);
        bytes memory _data;
        erc1155.safeTransferFrom(_collection.owner, sender, tokenId, amount, _data);

        weth.deposit{value: value}();
        weth.transfer(_collection.owner, totalPrice);
        weth.transfer(sender, value.sub(totalPrice));

        emit BuyERC1155Rarible(
            sender,
            _projectId,
            _collection.collectionAddress,
            tokenId,
            tokenId
        );
    }

    event BuyERC1155(
        address buyer,
        uint projectId,
        address collection,
        uint tokenId,
        uint amount
    );
    function buyERC1155(uint tokenId, uint amount)
        external
        payable
        onlyAfterStart
        onlyBeforeEnd
        onlyHolderOrWhitelisted
        onlyBelowMaxAmount1155(amount)
        onlyBelowMaxAmountUser1155(amount)
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
        erc1155Modified.safeTransferNFTFrom(_collection.owner, sender, tokenId, amount);
        
        weth.deposit{value: value}();
        weth.transfer(_collection.owner, totalPrice);
        weth.transfer(sender, value.sub(totalPrice));

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

    function checkIsUserWhitelisted(address user)
        external
        onlyUnlocked
        view
        returns (bool)
    {
        return _isUserWhitelisted[user];
    }
}