// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

import "../interfaces/IDeployer.sol";

import "../U2UMintRoundFCFS.sol";
import "./U2UDeployerBase.sol";

import "../libraries/LibStructs.sol";

contract U2UDeployerMintRoundFCFS is IDeployer, U2UDeployerBase {
  using LibStructs for LibStructs.Round;
  using LibStructs for LibStructs.Collection;

  function deploy(
    uint projectCount,
    LibStructs.Round calldata round,
    LibStructs.Collection calldata collection
  ) external onlyOwner override returns (address) {
    address deployed = address(
      new U2UMintRoundFCFS(
        projectCount,
        round,
        collection
      )
    );
    deployedContracts.push(deployed);
    IRound(deployed).transferOwnership(msg.sender);
    return deployed;
  }
}