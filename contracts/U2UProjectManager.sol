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

  modifier onlyValidRoundAmount(uint length) {
    require(length >= 1 && length <= 6, "U2U: invalid round amount");
    _;
  }

  event CreateProject(
    address creator,
    uint projectId,
    LibStructs.Collection collection
  );
  function createProject(
    LibStructs.Round[] calldata rounds,
    LibStructs.Collection calldata collection,
    address projectOwner
  ) external onlyOwner onlyValidRoundAmount(rounds.length) {
    require(collection.collectionAddress != address(0), "U2U: collection address invalid");
    for (uint i = 0; i < rounds.length; i++) {
      _checkTimeRoundCurrent(rounds[i].start, rounds[i].end, rounds[i].startClaim);
      if (i + 1 < rounds.length) {
        _checkTimeRoundBeforeLast(rounds[i].end, rounds[i + 1].start);
      }
    }

    address[] memory roundAddresses = new address[](rounds.length);
    _projectCount.increment();

    LibStructs.Project storage newProject = _projects[_projectCount.current()];
    newProject.projectOwner = projectOwner;
    newProject.roundAddresses = roundAddresses;
    newProject.collection = collection;
    _projects[_projectCount.current()] = newProject;

    emit CreateProject(projectOwner, _projectCount.current(), collection);
  }

  // Order of array: round zero addresses -> round whitelist addresses -> round FCFS addresses
  function setRoundContracts(
    uint projectId,
    address[] calldata roundAddresses
  ) external onlyOwner onlyValidRoundAmount(roundAddresses.length) {
    LibStructs.Project storage project = _projects[projectId];
    project.roundAddresses = roundAddresses;
  }

  function _checkTimeRoundCurrent(uint start, uint end, uint startClaim) private pure {
    require(start != 0, "U2U: start time cannot be 0");
    require(end > start, "U2U: end time must be higher than start time");
    // require(startClaim != 0, "U2U: start time for claim period cannot be 0");
    require(startClaim > end || startClaim == 0, "U2U: startClaim != 0 & < end");
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