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

import {Fileable, ChainlogLike} from "dss-exec-lib/DssExecLib.sol";
import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";
import "dss-interfaces/dss/IlkRegistryAbstract.sol";

interface ClipperMomLike {
    function setAuthority(address) external;
}

contract DssSpellAction is DssAction {

    string public constant description = "Kovan Spell";

    uint256 constant MILLION    = 10**6;
    uint256 constant WAD        = 10**18;
    uint256 constant RAY        = 10**27;
    uint256 constant RAD        = 10**45;

    address constant MCD_DOG              = address(0);
    address constant MCD_END              = address(0);
    address constant MCD_ESM              = address(0);
    // address constant ILK_REGISTRY         = address(0);
    address constant CLIPPER_MOM          = address(0);
    address constant MCD_CLIP_LINK_A      = address(0);
    address constant MCD_CLIP_CALC_LINK_A = address(0);

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    uint256 constant WAD        = 10**18;
    uint256 constant RAD        = 10**45;
    uint256 constant MILLION    = 10**6;

    function actions() public override {
        address MCD_VAT          = DssExecLib.vat();
        address MCD_CAT          = DssExecLib.cat();
        address MCD_VOW          = DssExecLib.vow();
        address MCD_POT          = DssExecLib.pot();
        address MCD_SPOT         = DssExecLib.spotter();
        address MCD_END_OLD      = DssExecLib.end();
        address MCD_ESM_OLD      = DssExecLib.getChangelogAddress("MCD_ESM");
        address MCD_FLIP_LINK_A  = DssExecLib.flip("LINK-A");
        address ILK_REGISTRY_OLD = DssExecLib.reg();

        // --------------------  END  --------------------

        // Set contracts in END
        DssExecLib.setContract(MCD_END,  "vat", MCD_VAT);
        DssExecLib.setContract(MCD_END,  "cat", MCD_CAT);
        DssExecLib.setContract(MCD_END,  "dog", MCD_DOG);
        DssExecLib.setContract(MCD_END,  "vow", MCD_VOW);
        DssExecLib.setContract(MCD_END,  "pot", MCD_POT);
        DssExecLib.setContract(MCD_END, "spot", MCD_SPOT);

        // Authorize the new END in contracts
        DssExecLib.authorize(MCD_VAT, MCD_END);
        DssExecLib.authorize(MCD_CAT, MCD_END);
        DssExecLib.authorize(MCD_DOG, MCD_END);
        DssExecLib.authorize(MCD_VOW, MCD_END);
        DssExecLib.authorize(MCD_POT, MCD_END);
        DssExecLib.authorize(MCD_SPOT, MCD_END);

        // Deauthorize the old END in contracts
        DssExecLib.deauthorize(MCD_VAT, MCD_END_OLD);
        DssExecLib.deauthorize(MCD_CAT, MCD_END_OLD);
        DssExecLib.deauthorize(MCD_DOG, MCD_END_OLD);
        DssExecLib.deauthorize(MCD_VOW, MCD_END_OLD);
        DssExecLib.deauthorize(MCD_POT, MCD_END_OLD);
        DssExecLib.deauthorize(MCD_SPOT, MCD_END_OLD);

        // Authorize new ESM to execute in new END
        DssExecLib.authorize(MCD_END, MCD_ESM);

        // Deuthorize old ESM to execute in old END
        DssExecLib.deauthorize(MCD_END_OLD, MCD_ESM_OLD);

        // ------------------  AUCTION  ------------------

        ClipperMomLike(CLIPPER_MOM).setAuthority(DssExecLib.getChangelogAddress("MCD_ADM"));

        // Set VOW in the DOG
        DssExecLib.setContract(MCD_DOG, "vow", MCD_VOW);

        // Set CLIP for LINK-A in the DOG
        DssExecLib.setContract(MCD_DOG, "LINK-A", "clip", MCD_CLIP_LINK_A);

        // Set VOW in the LINK-A CLIP
        DssExecLib.setContract(MCD_CLIP_LINK_A, "vow", MCD_VOW);

        // Set CALC in the LINK-A CLIP
        DssExecLib.setContract(MCD_CLIP_LINK_A, "calc", MCD_CLIP_CALC_LINK_A);

        // Authorize CLIP can access to VAT
        DssExecLib.authorize(MCD_VAT, MCD_CLIP_LINK_A);

        // Authorize CLIP can access to DOG
        DssExecLib.authorize(MCD_DOG, MCD_CLIP_LINK_A);

        // Authorize DOG can kick auctions on CLIP
        DssExecLib.authorize(MCD_CLIP_LINK_A, MCD_DOG);

        // Authorize CLIPPERMOM can set the stopped flag in CLIP
        DssExecLib.authorize(MCD_CLIP_LINK_A, CLIPPER_MOM);

        // We can't deauthorize the FLIP yet as there might be running auctions:
        // DssExecLib.deauthorize(MCD_CAT, MCD_FLIP_LINK_A); TODO in a future spell

        // No more auctions kicked via the CAT:
        DssExecLib.deauthorize(MCD_FLIP_LINK_A, MCD_CAT);

        // No more circuit breaker for the FLIP in LINK-A:
        DssExecLib.deauthorize(MCD_FLIP_LINK_A, DssExecLib.flipperMom());

        // Authorize the new END to access the LINK CLIP
        DssExecLib.authorize(MCD_CLIP_LINK_A, MCD_END);

        // Deauthorize the old END from all the FLIPS
        // Authorize the new END in all the FLIPS
        // (including MCD_FLIP_LINK_A as there might be still
        // running auctions and shutdown could happen)
        bytes32[] memory ilks = IlkRegistryAbstract(ILK_REGISTRY_OLD).list();
        for (uint256 i = 0; i < ilks.length; i++) {
            address flip = IlkRegistryAbstract(ILK_REGISTRY_OLD).flip(ilks[i]);
            DssExecLib.deauthorize(flip, MCD_END_OLD);
            DssExecLib.authorize(flip, MCD_END);
        }
        // DssExecLib.deauthorize(MCD_FLIP_LINK_A, MCD_END); TODO in a future spell

        // Set DOG values
        Fileable(MCD_DOG).file("Hole", 10 * MILLION * RAD);
        Fileable(MCD_DOG).file("LINK-A", "hole", 10 * MILLION * RAD);
        Fileable(MCD_DOG).file("LINK-A", "chop", 113 * WAD / 100);

        // Set LINK-A CLIP values
        Fileable(MCD_CLIP_LINK_A).file("buf", 120 * RAY / 100);
        Fileable(MCD_CLIP_LINK_A).file("tail", 1 hours);
        Fileable(MCD_CLIP_LINK_A).file("cusp", 60 * RAY / 100);
        Fileable(MCD_CLIP_LINK_A).file("chip", 2 * WAD / 100);
        Fileable(MCD_CLIP_LINK_A).file("tip", 50 * RAD);

        // TODO: Set CALC PARAMS
        // Fileable(MCD_CLIP_CALC_LINK_A).file("", );

        // ------------------  CHAINLOG  -----------------

        DssExecLib.setChangelogAddress("MCD_DOG", MCD_DOG);
        DssExecLib.setChangelogAddress("MCD_END", MCD_END);
        DssExecLib.setChangelogAddress("MCD_ESM", MCD_ESM);
        DssExecLib.setChangelogAddress("CLIPPER_MOM", CLIPPER_MOM);
        DssExecLib.setChangelogAddress("MCD_CLIP_LINK_A", MCD_CLIP_LINK_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_LINK_A", MCD_CLIP_CALC_LINK_A);
        // DssExecLib.setChangelogAddress("ILK_REGISTRY", ILK_REGISTRY); TODO in the following spell
        ChainlogLike(DssExecLib.LOG).removeAddress("MCD_FLIP_LINK_A");

        // DssExecLib.setChangelogVersion("1.3.0");
    }

}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}
