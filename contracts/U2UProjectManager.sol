// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

// For Remix IDE use
// import "@openzeppelin/contracts@3.4/math/SafeMath.sol";
// import "@openzeppelin/contracts@3.4/access/Ownable.sol";
// import "@openzeppelin/contracts@3.4/utils/Counters.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./interfaces/IRound.sol";
import "./interfaces/IDeployer.sol";

import "./libraries/LibStructs.sol";

contract U2UProjectManager is Ownable {
  using SafeMath for uint256;
  using LibStructs for LibStructs.Round;
  using LibStructs for LibStructs.Collection;
  using Counters for Counters.Counter;

  Counters.Counter private _projectCount;
  mapping(uint => LibStructs.Project) private _projects;
  address[] public deployers;

  modifier onlyDeployersSet {
    require(deployers.length == 6, "U2U: deployers not deployed");
    _;
  }
    
  modifier onlyExistingProject(uint projectId) {
    require(_projects[projectId].projectOwner != address(0), "U2U: project does not exist");
    _;
  }

  modifier onlyBeforeStart(uint projectId) {
    IRound roundAddress = IRound(_projects[projectId].roundAddresses[0]);
    LibStructs.Round memory round = roundAddress.getRound();
    require(
      block.timestamp < round.start, "U2U: can't perform this action after project started"
    );
    _;
  }

  // Addresses passed in MUST follow this order
  // address u2uDeployerMintRoundZero
  // address u2uDeployerMintRoundWhitelist
  // address u2uDeployerMintRoundFCFS
  // address u2uDeployerPremintRoundZero
  // address u2uDeployerPremintRoundWhitelist
  // address u2uDeployerPremintRoundFCFS
  // function setDeployers(address[] calldata deployerAddresses) external onlyOwner {
  //   require(deployerAddresses.length == 6, "U2U: there must be exactly 6 deployer addresses");
  //   for (uint i = 0; i < 6; i++) {
  //     require(deployerAddresses[i] != address(0), "U2U: deployer addresses must not be address(0)");
  //     deployers.push(deployerAddresses[i]);
  //   }
  // }

  event CreateProject(
    address creator,
    uint projectId,
    LibStructs.Collection collection
  );
  function createProject(
    LibStructs.Round[] calldata rounds,
    LibStructs.Collection calldata collection,
    address projectOwner
  // ) external onlyOwner onlyDeployersSet {
  ) external onlyOwner {
    require(rounds.length >= 2 && rounds.length <= 6, "U2U: invalid round amount");
    require(collection.collectionAddress != address(0), "U2U: collection address invalid");
    address[] memory roundAddresses = new address[](rounds.length);
    for (uint i = 0; i < rounds.length; i++) {
      // require(rounds[i].start != 0, "U2U: start time cannot be 0");
      // require(
      //     rounds[i].end > rounds[i].start,
      //     "U2U: end time must be higher than start time"
      // );
      // if (i + 1 < rounds.length) {
      //     require(
      //         rounds[i + 1].start > rounds[i].end,
      //         "U2U: later round must start after previous round ends"
      //     );
      // }
      _checkTimeRoundCurrent(rounds[i].start, rounds[i].end);
      if (i + 1 < rounds.length) {
        _checkTimeRoundBeforeLast(rounds[i].end, rounds[i + 1].start);
      }
      // roundAddresses[i] = _createRound(rounds[i], collection);
      // IRound(roundAddresses[i]).transferOwnership(owner());
    }

    _projectCount.increment();
      
    LibStructs.Project storage newProject = _projects[_projectCount.current()];
    newProject.projectOwner = projectOwner;
    newProject.roundAddresses = roundAddresses;
    newProject.collection = collection;
    _projects[_projectCount.current()] = newProject;

    emit CreateProject(projectOwner, _projectCount.current(), collection);
  }

  function setRoundContracts(
    uint projectId,
    address[] calldata roundAddresses
  ) external onlyOwner {
    LibStructs.Project storage project = _projects[projectId];
    project.roundAddresses = roundAddresses;
  }

  // function _createRound(
  //   LibStructs.Round calldata round,
  //   LibStructs.Collection calldata collection
  // ) private returns (address) {
  //   address deployed;
  //   if (!collection.isPreminted) {
  //     if (round.roundType == LibStructs.RoundType.RoundZero) {
  //       deployed = IDeployer(deployers[0]).deploy(
  //         _projectCount.current(),
  //         round,
  //         collection
  //       );
  //       return deployed;
  //       // return deployers[0];
  //     }

  //     if (
  //       round.roundType == LibStructs.RoundType.RoundWhitelist
  //       || round.roundType == LibStructs.RoundType.RoundStaking
  //     ) {
  //       deployed = IDeployer(deployers[1]).deploy(
  //         _projectCount.current(),
  //         round,
  //         collection
  //       );
  //       return deployed;
  //       // return deployers[1];
  //     }

  //     // if (round.roundType == LibStructs.RoundType.RoundFCFS) {
  //     // }
  //     deployed = IDeployer(deployers[2]).deploy(
  //       _projectCount.current(),
  //       round,
  //       collection
  //     );
  //     return deployed;
  //     // return deployers[2];
  //   } else {
  //     if (round.roundType == LibStructs.RoundType.RoundZero) {
  //       deployed = IDeployer(deployers[3]).deploy(
  //         _projectCount.current(),
  //         round,
  //         collection
  //       );
  //       return deployed;
  //       // return deployers[3];
  //     }

  //     if (
  //       round.roundType == LibStructs.RoundType.RoundWhitelist
  //       || round.roundType == LibStructs.RoundType.RoundStaking
  //     ) {
  //       deployed = IDeployer(deployers[4]).deploy(
  //         _projectCount.current(),
  //         round,
  //         collection
  //       );
  //       return deployed;
  //       // return deployers[4];
  //     }

  //     // if (round.roundType == LibStructs.RoundType.RoundFCFS) {
  //     // }
  //     deployed = IDeployer(deployers[5]).deploy(
  //       _projectCount.current(),
  //       round,
  //       collection
  //     );
  //     return deployed;
  //     // return deployers[5];
  //   }
  // }

  function _checkTimeRoundCurrent(uint start, uint end) private pure {
    require(start != 0, "U2U: start time cannot be 0");
    require(end > start, "U2U: end time must be higher than start time");
  }

  function _checkTimeRoundBeforeLast(uint endRoundBefore, uint startRoundAfter) private pure {
    require(
      startRoundAfter > endRoundBefore,
      "U2U: later round must start after previous round ends"
    );
  }

  function setCollection(uint projectId, LibStructs.Collection calldata newCollection)
    external
    onlyOwner
    onlyExistingProject(projectId)
    onlyBeforeStart(projectId)
  {
    address[] memory roundAddresses = _projects[projectId].roundAddresses;
    for (uint i = 0; i < roundAddresses.length; i = i.add(1)) {
      IRound(roundAddresses[i]).setCollection(newCollection);
    }
    _projects[projectId].collection = newCollection;
  }

  function getProject(uint projectId)
    external
    view
    onlyExistingProject(projectId)
    returns (LibStructs.Project memory)
  {
    return _projects[projectId];
  }

  function getProjectCount() external view returns (uint) {
    return _projectCount.current();
  }
}