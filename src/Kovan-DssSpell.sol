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

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";
import "dss-interfaces/dss/LPOsmAbstract.sol";

contract DssSpellAction is DssAction {

    string public constant description = "Kovan Spell";

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    // TODO: It's a temporary address for testing the spell, needs to be replaced
    // by the definitive one
    address constant PIP_UNIV2DAIETH = 0xb43Ca4395Bf6Ef7774C20C1AF75360eE8a42f515;

    function actions() public override {
        address MCD_SPOT = DssExecLib.spotter();
        address MCD_END  = DssExecLib.end();
        address OSM_MOM  = DssExecLib.osmMom();

        // --------------------------------- UNIV2DAIETH-A ---------------------------------
        DssExecLib.setContract(MCD_SPOT, "UNIV2DAIETH-A", "pip", PIP_UNIV2DAIETH);
        DssExecLib.authorize(PIP_UNIV2DAIETH, OSM_MOM);
        DssExecLib.addReaderToMedianWhitelist(LPOsmAbstract(PIP_UNIV2DAIETH).orb1(), PIP_UNIV2DAIETH);
        DssExecLib.removeReaderFromMedianWhitelist(LPOsmAbstract(PIP_UNIV2DAIETH).orb1(), DssExecLib.getChangelogAddress("PIP_UNIV2DAIETH"));
        DssExecLib.addReaderToOSMWhitelist(PIP_UNIV2DAIETH, MCD_SPOT);
        DssExecLib.addReaderToOSMWhitelist(PIP_UNIV2DAIETH, MCD_END);
        DssExecLib.allowOSMFreeze(PIP_UNIV2DAIETH, "UNIV2DAIETH-A");
        DssExecLib.setChangelogAddress("PIP_UNIV2DAIETH", PIP_UNIV2DAIETH);

        // ---------------------------- Update Chainlog version ----------------------------
        DssExecLib.setChangelogVersion("1.7.0");
    }
}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}
