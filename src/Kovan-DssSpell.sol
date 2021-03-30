// SPDX-License-Identifier: GPL-3.0-or-later
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
pragma solidity 0.6.11;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";

contract DssSpellAction is DssAction {

    string public constant description = "Kovan Spell";

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.01)/(60 * 60 * 24 * 365) )'
    //
    uint256 constant FOUR_PCT = 1000000001243680656318820312;

    uint256 constant WAD        = 10**18;
    uint256 constant RAD        = 10**45;
    uint256 constant MILLION    = 10**6;

    // PAXG-A
    address constant PAXG = 0x3FAe07a1f8d3b92E7bEaED69A231040A98f2C112;
    address constant MCD_JOIN_PAXG_A = 0x9457B21B991aD0e4AE226e5E18c4f7080E91f350;
    address constant MCD_FLIP_PAXG_A = 0x29362182c7D1EEE16A960dF4b6cDE908Df64F88B;
    address constant PIP_PAXG = 0x31CceDBc45179f17CfD34967680C6560b6509C1A;

    function actions() public override {
        // Onboarding ETH-C
        CollateralOpts memory PAXG_A = CollateralOpts({
            ilk: "PAXG-A",
            gem: PAXG,
            join: MCD_JOIN_PAXG_A,
            flip: MCD_FLIP_PAXG_A,
            pip: PIP_PAXG,
            isLiquidatable: true,
            isOSM: true,
            whitelistOSM: true,
            ilkDebtCeiling: 5 * MILLION,
            minVaultAmount: 100,
            maxLiquidationAmount: 500,
            liquidationPenalty: 1300,
            ilkStabilityFee: FOUR_PCT,
            bidIncrease: 300,
            bidDuration: 1 hours,
            auctionDuration: 1 hours,
            liquidationRatio: 12500
        });
        addNewCollateral(PAXG_A);
        DssExecLib.setIlkAutoLineParameters("PAXG-A", 2000 * MILLION, 100 * MILLION, 12 hours);

        DssExecLib.setChangelogAddress("PAXG", PAXG);
        DssExecLib.setChangelogAddress("MCD_JOIN_PAXG_A", MCD_JOIN_PAXG_A);
        DssExecLib.setChangelogAddress("MCD_FLIP_PAXG_A", MCD_FLIP_PAXG_A);
        DssExecLib.setChangelogAddress("PIP_PAXG", PIP_PAXG);

        // bump changelog version
        DssExecLib.setChangelogVersion("1.2.11");
    }

}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}
