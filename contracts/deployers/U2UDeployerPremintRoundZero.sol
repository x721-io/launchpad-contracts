// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

import "../interfaces/IDeployer.sol";

import "../U2UPremintRoundZero.sol";
import "./U2UDeployerBase.sol";

import "../libraries/LibStructs.sol";

contract U2UDeployerPremintRoundZero is IDeployer, U2UDeployerBase {
  using LibStructs for LibStructs.Round;
  using LibStructs for LibStructs.Collection;

  function deploy(
    uint projectCount,
    LibStructs.Round calldata round,
    LibStructs.Collection calldata collection,
    LibStructs.Timeframe[] memory timeframes,
    address _projectManager,
    address _feeReceiver,
    address requiredCollection
  ) external onlyOwner override returns (address) {
    address deployed = address(
      new U2UPremintRoundZero(
        projectCount,
        round,
        collection,
        timeframes,
        _projectManager,
        _feeReceiver,
        requiredCollection
      )
    );
    deployedContracts.push(deployed);
    IRound(deployed).transferOwnership(msg.sender);
    return deployed;
  }
}