// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

import "./libraries/LibStructs.sol";

import "./U2UMintRoundWhitelist.sol";
import "./U2UMintRoundZero.sol";
import "./U2UMintRoundFCFS.sol";
import "./U2UPremintRoundWhitelist.sol";
import "./U2UPremintRoundZero.sol";
import "./U2UPremintRoundFCFS.sol";

contract U2UBuyFactory {
    using LibStructs for LibStructs.Round;
    using LibStructs for LibStructs.Collection;

    address public projectManager = 0x7088316151cf49E1F9cD93Acd1B4dfed0a9f8Ece;      // This is just a placeholder address

    modifier onlyProjectManager() {
        require(msg.sender == projectManager, "U2U: this function can only be called by project manager");
        _;
    }

    function deployBuyContract(
        uint projectCount,
        LibStructs.Round calldata round,
        LibStructs.Collection calldata collection
    ) external onlyProjectManager returns (address) {
        if (!collection.isPreminted) {
            if (
                round.roundType == LibStructs.RoundType.RoundWhitelist
                || round.roundType == LibStructs.RoundType.RoundStaking
            ) {
                return address(
                    new U2UMintRoundWhitelist(
                        projectCount,
                        round,
                        collection
                    )
                );
            }

            if (round.roundType == LibStructs.RoundType.RoundZero) {
                return address(
                    new U2UMintRoundZero(
                        projectCount,
                        round,
                        collection
                    )
                );
            }

            // if (round.roundType == LibStructs.RoundType.RoundFCFS) {
            // }
            return address(
                new U2UMintRoundFCFS(
                    projectCount,
                    round,
                    collection
                )
            );
        } else {
            if (
                round.roundType == LibStructs.RoundType.RoundWhitelist
                || round.roundType == LibStructs.RoundType.RoundStaking
            ) {
                return address(
                    new U2UPremintRoundWhitelist(
                        projectCount,
                        round,
                        collection
                    )
                );
            }

            if (round.roundType == LibStructs.RoundType.RoundZero) {
                return address(
                    new U2UPremintRoundZero(
                        projectCount,
                        round,
                        collection
                    )
                );
            }

            // if (round.roundType == LibStructs.RoundType.RoundFCFS) {
            // }
            return address(
                new U2UPremintRoundFCFS(
                    projectCount,
                    round,
                    collection
                )
            );
        }
    }
}