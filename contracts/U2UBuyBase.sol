// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

// For Remix IDE use
// import "@openzeppelin/contracts@3.4/math/SafeMath.sol";
// import "@openzeppelin/contracts@3.4/access/Ownable.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IWETH.sol";
import "./interfaces/IProjectManager.sol";
import "./interfaces/IRound.sol";

import "./libraries/LibStructs.sol";

abstract contract U2UBuyBase is Ownable {
    using SafeMath for uint256;
    using LibStructs for LibStructs.RoundType;
    using LibStructs for LibStructs.Round;
    using LibStructs for LibStructs.Collection;

    bool public isLocked = false;
    bool internal _isRequiredCollectionERC721 = false;
    uint internal _projectId;
    uint internal _amountUser;
    LibStructs.Collection internal _collection;
    LibStructs.Round internal _round;

    IWETH public weth = IWETH(0x79538ce1712498fD1b9A9861E62acB257d7506fC);                          // This is just a placeholder address
    address public projectManager = 0x1978ae68C93ec49D5E9E401Ef7f02adC94bd9059;                      // This is just a placeholder address

    mapping(address => bool) public isUserJoined;
    mapping(address => bool) public isAdmin;
    mapping(address => uint) internal _amountBought;       // User's address => Amount bought

    modifier onlyProjectManager() {
        require(msg.sender == projectManager, "U2U: this function can only be called by project manager");
        _;
    }

    modifier onlyUnlocked {
        require(!isLocked, "U2U: project is removed or this contract is being locked");
        _;
    }

    modifier onlyBelowMaxAmount721() {
        require(_round.soldAmountNFT < _round.maxAmountNFT, "U2U: supply for whitelist NFTs ran out");
        _;
    }

    modifier onlyBelowMaxAmountUser721() {
        require(
            _amountBought[msg.sender] < _round.maxAmountNFTPerWallet,
            "U2U: you've reached your dedicated amount"
        );
        _;
    }

    modifier onlyBelowMaxAmount1155(uint amount) {
        require(_round.soldAmountNFT.add(amount) <= _round.maxAmountNFT, "U2U: supply for whitelist NFTs ran out");
        _;
    }

    modifier onlyBelowMaxAmountUser1155(uint amount) {
        require(
            _amountBought[msg.sender].add(amount) <= _round.maxAmountNFTPerWallet,
            "U2U: you've reached your dedicated amount"
        );
        _;
    }

    modifier onlyBeforeEnd() {
        require(block.timestamp < _round.end, "U2U: can't perform this action after project ended");
        _;
    }

    modifier onlyAfterEnd() {
        require(block.timestamp > _round.end, "U2U: can't perform this action before project ended");
        _;
    }

    modifier onlyAfterStart() {
        require(block.timestamp > _round.start, "U2U: can't perform this action before project start");
        _;
    }

    modifier onlyBeforeStart() {
        require(
            block.timestamp < _round.start, "U2U: can't perform this action after project started"
        );
        _;
    }

    modifier onlyRoundContract() {
        address sender = msg.sender;
        address[] memory roundAddresses = IProjectManager(projectManager).getProject(_projectId).roundAddresses;
        bool isSenderARound = false;

        for (uint i = 0; i < roundAddresses.length; i = i.add(1)) {
            if (roundAddresses[i] == sender) {
                isSenderARound = true;
            }
        }

        require(isSenderARound, "U2U: only contract round can call this function");
        _;
    }

    function transferNFTsToNextRound(
        address nextRound,
        uint newMaxNFTPerWallet
    ) external onlyOwner onlyAfterEnd {
        IRound(nextRound).receiveAndIncreaseMaxAmountNFT(
            _round.maxAmountNFT.sub(_round.soldAmountNFT),
            newMaxNFTPerWallet
        );
    }

    function receiveAndIncreaseMaxAmountNFT(
        uint amount,
        uint newMaxNFTPerWallet
    ) external onlyRoundContract {
        _round.maxAmountNFT = _round.maxAmountNFT.add(amount);
        _round.maxAmountNFTPerWallet = newMaxNFTPerWallet;
    }

    function _checkAndAddNewUser(address sender) internal {
        if (!isUserJoined[sender]) {
            isUserJoined[sender] = true;
            _amountUser = _amountUser.add(1);
        }
    }

    function setPrice(uint price) external onlyOwner onlyBeforeStart {
        _round.price = price;
    }

    function setMaxAmountNFT(uint max) external onlyOwner onlyBeforeStart {
        _round.maxAmountNFT = max;
    }

    function setMaxAmountNFTPerWallet(uint max) external onlyOwner onlyBeforeStart {
        _round.maxAmountNFTPerWallet = max;
    }

    function setCollection(LibStructs.Collection calldata newCollection)
        external
        onlyProjectManager
        onlyBeforeStart
    {
        _collection = newCollection;
    }

    function lock() external onlyOwner {
        isLocked = true;
    }

    function getRound() external onlyUnlocked view returns (LibStructs.Round memory) {
        return _round;
    }

    function getProjectId() external onlyUnlocked view returns (uint) {
        return _projectId;
    }

    function getAmountUser() external onlyUnlocked view returns (uint) {
        return _amountUser;
    }

    function getAmountBought(address user) external onlyUnlocked view returns (uint) {
        return _amountBought[user];
    }

    function getCollection()
        external
        onlyUnlocked
        view
        returns (LibStructs.Collection memory)
    {
        return _collection;
    }
}