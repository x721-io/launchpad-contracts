// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "./interfaces/IProjectManager.sol";
import "./interfaces/IRound.sol";
import "./interfaces/IERC721U2UMinimal.sol";
import "./interfaces/IERC721Modified.sol";
import "./interfaces/IERC1155U2U.sol";
import "./interfaces/IERC1155Modified.sol";

import "./libraries/LibStructs.sol";

abstract contract U2UBuyBase is Ownable, IERC721Receiver, IERC1155Receiver, ERC165 {
  using LibStructs for LibStructs.RoundType;
  using LibStructs for LibStructs.Round;
  using LibStructs for LibStructs.Collection;

  constructor(address initialOwner) Ownable(initialOwner) {}

  uint internal _projectId;
  uint internal _amountUser;
  LibStructs.Collection internal _collection;
  LibStructs.Round internal _round;

  address public projectManager;                      // This is just a placeholder address
  address public feeReceiver;
  uint16 public feePercent = 500;  // 5%
  bool public isLocked = false;
  bool public isInitialized = false;

  mapping(address => bool) public isUserJoined;
  mapping(address => uint) internal _amountBought;       // User's address => Amount bought
  mapping(address => uint) internal _amountClaimed;      // User's address => Amount claimed
  mapping(address => LibStructs.Token[]) internal _ownerOfAmount;

  LibStructs.Timeframe[] internal _timeframes;

  modifier onlyUnlocked {
    require(!isLocked, "U2U: locked");
    _;
  }

  modifier onlyBelowMaxAmount721() {
    require(
      _round.soldAmountNFT < _round.maxAmountNFT || _round.maxAmountNFT == 0,
      "U2U: no supply"
    );
    _;
  }

  modifier onlyBelowMaxAmountUser721() {
    require(
      _amountBought[msg.sender] < _round.maxAmountNFTPerWallet || _round.maxAmountNFTPerWallet == 0,
      "U2U: your amount reached"
    );
    _;
  }

  modifier onlyBelowMaxAmount1155(uint amount) {
    require(
      _round.soldAmountNFT + amount <= _round.maxAmountNFT || _round.maxAmountNFT == 0,
      "U2U: no supply"
    );
    _;
  }

  modifier onlyBelowMaxAmountUser1155(uint amount) {
    require(
      _amountBought[msg.sender] + amount <= _round.maxAmountNFTPerWallet || _round.maxAmountNFTPerWallet == 0,
      "U2U: your amount reached"
    );
    _;
  }

  modifier onlyBeforeEnd() {
    require(block.timestamp < _round.end, "U2U: ended");
    _;
  }

  modifier onlyAfterEnd() {
    require(block.timestamp > _round.end, "U2U: not ended");
    _;
  }

  modifier onlyAfterStart() {
    require(block.timestamp > _round.start, "U2U: not started");
    _;
  }

  modifier onlyBeforeStart() {
    require(
      block.timestamp < _round.start, "U2U: started"
    );
    _;
  }

  modifier onlyAfterStartClaim() {
    require(
      block.timestamp > _round.startClaim || _round.startClaim == 0, "U2U: can't claim now"
    );
    _;
  }

  modifier onlyRoundContract() {
    address sender = msg.sender;
    address[] memory roundAddresses = IProjectManager(projectManager).getProject(_projectId).roundAddresses;
    bool isSenderARound = false;

    for (uint i = 0; i < roundAddresses.length; i = i + 1) {
      if (roundAddresses[i] == sender) {
        isSenderARound = true;
      }
    }

    require(isSenderARound, "U2U: caller not contract round");
    _;
  }

  function checkOnlyInTimeframe() public view returns (bool) {
    (uint8 currentHour, uint8 currentMinute) = _getCurrentTime();
    for (uint i = 0; i < uint(_timeframes.length); i = i + 1) {
      if (
        currentHour >= _timeframes[i].hourStart &&
        currentMinute >= _timeframes[i].minuteStart &&
        currentHour <= _timeframes[i].hourEnd &&
        currentMinute <= _timeframes[i].minuteEnd
      ) {
        return true;
      }
    }

    return false;
  }

  function _getCurrentTime() internal view returns (uint8, uint8) {
    uint8 currentHour = uint8((uint32(block.timestamp) / 3600) % 24);
    uint8 currentMinute = uint8((uint32(block.timestamp) / 60) % 60);
    return (currentHour, currentMinute);
  }

  function setTimeframes(LibStructs.Timeframe[] memory timeframes) public {
    require(msg.sender == owner() || isInitialized == false, "U2U: not owner");
    isInitialized = true;
    delete _timeframes;
    for (uint i = 0; i < timeframes.length; i = i + 1) {
      _timeframes.push(timeframes[i]);
    }
  }

  function claimERC721()
    external
    onlyAfterEnd
    onlyAfterStartClaim
  {
    require(
      _ownerOfAmount[msg.sender].length > 0, "U2U: claimed enough"
    );
    require(_collection.isERC721, "U2U: project collection is ERC1155");
    address sender = msg.sender;
    LibStructs.Token[] memory ownerOfAmount = _ownerOfAmount[sender];
    delete _ownerOfAmount[sender];
    _amountClaimed[sender] = _amountClaimed[sender] + ownerOfAmount.length;
    for (uint i = 0; i < ownerOfAmount.length; i = i + 1) {
      // _amountClaimed[sender] = ownerOfAmount.length;

      if (_collection.isU2UCollection) {
        IERC721U2UMinimal erc721Minimal = IERC721U2UMinimal(_collection.collectionAddress);
        erc721Minimal.safeTransferFrom(address(this), sender, ownerOfAmount[i].id);
      } else {
        IERC721Modified erc721Modified = IERC721Modified(_collection.collectionAddress);
        erc721Modified.safeTransferNFTFrom(address(this), sender, ownerOfAmount[i].id);
      }
    }
  }

  function claimERC1155()
    external
    onlyAfterEnd
    onlyAfterStartClaim
  {
    require(
      _ownerOfAmount[msg.sender].length > 0, "U2U: claimed enough"
    );
    require(!_collection.isERC721, "U2U: project collection is ERC721");
    address sender = msg.sender;
    LibStructs.Token[] memory ownerOfAmount = _ownerOfAmount[sender];
    delete _ownerOfAmount[sender];
    for (uint i = 0; i < ownerOfAmount.length; i = i + 1) {
      _amountClaimed[sender] = _amountClaimed[sender] + ownerOfAmount[i].amount;

      if (_collection.isU2UCollection) {
        bytes memory _data;
        IERC1155U2U erc1155 = IERC1155U2U(_collection.collectionAddress);
        erc1155.safeTransferFrom(address(this), sender, ownerOfAmount[i].id, ownerOfAmount[i].amount, _data);
      } else {
        IERC1155Modified erc1155Modified = IERC1155Modified(_collection.collectionAddress);
        erc1155Modified.safeTransferNFTFrom(address(this), sender, ownerOfAmount[i].id, ownerOfAmount[i].amount);
      }
    }
  }

  function transferNFTsToNextRound(
    address nextRound,
    uint newMaxNFTPerWallet
  ) external virtual onlyOwner onlyAfterEnd {
    IRound(nextRound).receiveAndIncreaseMaxAmountNFT(
      _round.maxAmountNFT - _round.soldAmountNFT,
      newMaxNFTPerWallet
    );
  }

  function receiveAndIncreaseMaxAmountNFT(
    uint amount,
    uint newMaxNFTPerWallet
  ) external onlyRoundContract {
    _round.maxAmountNFT = _round.maxAmountNFT + amount;
    _round.maxAmountNFTPerWallet = newMaxNFTPerWallet;
  }

  function _transferValueAndFee(uint value, uint price) internal {
    uint fee = price * feePercent / 10000;

    payable(feeReceiver).transfer(fee);
    payable(_collection.owner).transfer(price - fee);
    payable(msg.sender).transfer(value - price);
  }

  function _checkAndAddNewUser(address sender) internal {
    if (!isUserJoined[sender]) {
      isUserJoined[sender] = true;
      _amountUser = _amountUser + 1;
    }
  }

  function setTime(uint start, uint end) external onlyOwner onlyBeforeStart {
    require(start != 0, "U2U: start=0");
    require(end > start, "U2U: end<start");
    address[] memory roundAddresses = IProjectManager(projectManager).getProject(_projectId).roundAddresses;
    if (roundAddresses.length > 1) {
      for (uint i = 0; i < roundAddresses.length; i++) {
        if(roundAddresses[i] == address(this) && i == 0) {
          LibStructs.Round memory roundAfter = U2UBuyBase(roundAddresses[i + 1]).getRound();
          require(end < roundAfter.start, "U2U: end>roundAfter.start");
        } else if (
          roundAddresses[i] == address(this)
          && i >= 1
          && i + 1 < roundAddresses.length
        ) {
          LibStructs.Round memory roundBefore = U2UBuyBase(roundAddresses[i - 1]).getRound();
          LibStructs.Round memory roundAfter = U2UBuyBase(roundAddresses[i + 1]).getRound();
          require(start > roundBefore.end, "U2U: start<roundBefore.end");
          require(end < roundAfter.start, "U2U: end>roundAfter.start");
        } else if (
          roundAddresses[i] == address(this)
          && i + 1 == roundAddresses.length
        ) {
          LibStructs.Round memory roundBefore = U2UBuyBase(roundAddresses[i - 1]).getRound();
          require(start > roundBefore.end, "U2U: start<roundBefore.end");
        }
      }
    }

    _round.start = start;
    _round.end = end;
  }

  function setClaimTime(uint startClaim) external onlyOwner onlyBeforeStart {
    require(startClaim != 0, "U2U: startClaim=0");
    require(startClaim > _round.end, "U2U: startClaim<_round.end");
    _round.startClaim = startClaim;
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
    onlyBeforeStart
  {
    require(msg.sender == projectManager, "U2U: caller not project manager");
    _collection = newCollection;
  }

  function setFee(uint16 fee) external onlyOwner {
    feePercent = fee;
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

  function getAmountClaimed(address user) external onlyUnlocked view returns (uint) {
    return _amountClaimed[user];
  }

  function getClaimableAmount(address user) external onlyUnlocked view returns (uint) {
    return _amountBought[user] - _amountClaimed[user];
  }

  function getOwnerOfAmount(address user)
    external
    onlyUnlocked
    view
    returns (LibStructs.Token[] memory)
  {
    return _ownerOfAmount[user];
  }

  function getCollection()
    external
    onlyUnlocked
    view
    returns (LibStructs.Collection memory)
  {
    return _collection;
  }

  function getTimeframes(uint index) external view returns (LibStructs.Timeframe memory) {
    // LibStructs.Timeframe[] memory timeframes = new LibStructs.Timeframe[](_timeframes.length);
    // for (uint i = 0; i < _timeframes.length; i = i.add(1)) {
    //   timeframes[i] = _timeframes[i];
    // }

    return _timeframes[index];
  }

  function getTimeframesLength() external view returns (uint) {
    return _timeframes.length;
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external pure override returns (bytes4) {
    return IERC721Receiver.onERC721Received.selector;
  }

  function onERC1155Received(
    address operator,
    address from,
    uint256 id,
    uint256 value,
    bytes calldata data
  ) external pure override returns (bytes4) {
    return IERC1155Receiver.onERC1155Received.selector;
  }

  function onERC1155BatchReceived(
    address operator,
    address from,
    uint256[] calldata ids,
    uint256[] calldata values,
    bytes calldata data
  ) external pure override returns (bytes4) {
    return IERC1155Receiver.onERC1155BatchReceived.selector;
  }

  function supportsInterface(bytes4 interfaceID)
    public
    view
    override(ERC165, IERC165)
    returns (bool)
  {
    return super.supportsInterface(interfaceID);
  }
}
