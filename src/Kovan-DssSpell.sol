// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2021 Maker Ecosystem Growth Holdings, INC.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

contract DssSpellAction is DssAction {

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/TODO -q -O - 2>/dev/null)"
    string public constant override description = "Add MATIC";

    address constant MATIC                 = 0x688E1A8830Ea8dd8fe389FA2228997C663b3807A;
    address constant MCD_JOIN_MATIC_A      = 0x4Af8801fbDD5ae4FDe2cbC9F844b09c6777525CE;
    address constant MCD_CLIP_MATIC_A      = 0x75FE5CD0c23894C8424ac835C054aCA92B994445;
    address constant MCD_CLIP_CALC_MATIC_A = 0x0AB67AA706F1cECD3df457016E822a09bFf18f23;
    address constant PIP_MATIC             = 0x13594bF4E0C61946936674217c415c6d555Fec50;

    uint256 constant THOUSAND   = 10**3;
    uint256 constant MILLION    = 10**6;

    function actions() public override {

        // values taken from https://forum.makerdao.com/t/matic-collateral-onboarding-risk-evaluation/9069

        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_MATIC_A, 90 seconds, 9900);

        CollateralOpts memory MATIC_A = CollateralOpts({
            ilk:                   "MATIC-A",
            gem:                   MATIC,
            join:                  MCD_JOIN_MATIC_A,
            clip:                  MCD_CLIP_MATIC_A,
            calc:                  MCD_CLIP_CALC_MATIC_A,
            pip:                   PIP_MATIC,
            isLiquidatable:        true,
            isOSM:                 true,
            whitelistOSM:          true,
            ilkDebtCeiling:        3 * MILLION,
            minVaultAmount:        100, // TODO: test value, adjust value on mainnet spell (10 * THOUSAND)
            maxLiquidationAmount:  5 * THOUSAND, // TODO: test value, adjust value om mainnet spell (3 * MILLION)
            liquidationPenalty:    1300,
            ilkStabilityFee:       1000000000937303470807876289,
            startingPriceFactor:   13000,
            breakerTolerance:      5000, // Allows for a 50% hourly price drop before disabling liquidations
            auctionDuration:       140 minutes,
            permittedDrop:         4000,
            liquidationRatio:      17500,
            kprFlatReward:         1, // TODO: test value, adjust value om mainnet spell (300)
            kprPctReward:          10 // 0.1%
        });

        DssExecLib.addNewCollateral(MATIC_A);
        DssExecLib.setIlkAutoLineParameters("MATIC-A", 10 * MILLION, 3 * MILLION, 8 hours);

        DssExecLib.setChangelogAddress("MATIC", MATIC);
        DssExecLib.setChangelogAddress("MCD_JOIN_MATIC_A", MCD_JOIN_MATIC_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_MATIC_A", MCD_CLIP_MATIC_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_MATIC_A", MCD_CLIP_CALC_MATIC_A);
        DssExecLib.setChangelogAddress("PIP_MATIC", PIP_MATIC);

        // Bump version, assuming 1.9.3 version passes
        DssExecLib.setChangelogVersion("1.9.4");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
