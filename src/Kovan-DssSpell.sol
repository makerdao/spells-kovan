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

import {Fileable, ChainlogLike} from "dss-exec-lib/DssExecLib.sol";
import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";
import "dss-interfaces/dss/ClipAbstract.sol";
import "dss-interfaces/dss/ClipperMomAbstract.sol";
import "dss-interfaces/dss/VowAbstract.sol";

interface LerpFabLike {
    function newLerp(bytes32, address, bytes32, uint256, uint256, uint256, uint256) external returns (address);
    function active(uint256) external returns (address);
    function lerps(bytes32) external returns (address);
    function tall() external;
    function count() external returns (uint256);
}

contract DssSpellAction is DssAction {

    string public constant description = "Kovan Spell";

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;
    uint256 constant RAD = 10**45;

    address constant MCD_CLIP_ETH_A       = 0x7dD1Fb6b9aFdBA9F28DB89c81723b8c6B27A2Fbe;
    address constant MCD_CLIP_CALC_ETH_A  = 0x11e43AD52827019F8f9458771459B358222720d6;
    address constant MCD_CLIP_ETH_B       = 0x004676c737FC75A2799dFe745d23F5597620Ad43;
    address constant MCD_CLIP_CALC_ETH_B  = 0x85e52B219b4bFDBFFC29c71ffF6eB9FdDD5D221E;
    address constant MCD_CLIP_ETH_C       = 0x86D5eA244cf6c79227CA73004C963b72431f23ac;
    address constant MCD_CLIP_CALC_ETH_C  = 0xeD58984595292Dd30f838e9A6f932d1acd8f979F;
    address constant MCD_CLIP_WBTC_A      = 0x5518C2f409Bed4bD5FF3542d9D5002251EEDA892;
    address constant MCD_CLIP_CALC_WBTC_A = 0xAEd4894E0965D37007B6970d13bDd013263a939A;

    function actions() public override {
        address MCD_VAT         = DssExecLib.vat();
        address MCD_CAT         = DssExecLib.cat();
        address MCD_DOG         = DssExecLib.getChangelogAddress("MCD_DOG");
        address MCD_VOW         = DssExecLib.vow();
        address MCD_SPOT        = DssExecLib.spotter();
        address MCD_END         = DssExecLib.end();
        address MCD_ESM         = DssExecLib.getChangelogAddress("MCD_ESM");
        address CLIPPER_MOM     = DssExecLib.getChangelogAddress("CLIPPER_MOM");
        address ILK_REGISTRY    = DssExecLib.getChangelogAddress("ILK_REGISTRY");
        address CHANGELOG       = DssExecLib.getChangelogAddress("CHANGELOG");
        address PIP_ETH         = DssExecLib.getChangelogAddress("PIP_ETH");
        address PIP_WBTC        = DssExecLib.getChangelogAddress("PIP_WBTC");

        // --------------------------------- ETH-A ---------------------------------
        {
            address MCD_FLIP_ETH_A  = DssExecLib.getChangelogAddress("MCD_FLIP_ETH_A");
            // Check constructor values of Clipper
            require(ClipAbstract(MCD_CLIP_ETH_A).vat() == MCD_VAT, "DssSpell/clip-wrong-vat");
            require(ClipAbstract(MCD_CLIP_ETH_A).spotter() == MCD_SPOT, "DssSpell/clip-wrong-spotter");
            require(ClipAbstract(MCD_CLIP_ETH_A).dog() == MCD_DOG, "DssSpell/clip-wrong-dog");
            require(ClipAbstract(MCD_CLIP_ETH_A).ilk() == "ETH-A", "DssSpell/clip-wrong-ilk");
            // Set CLIP for ETH-A in the DOG
            DssExecLib.setContract(MCD_DOG, "ETH-A", "clip", MCD_CLIP_ETH_A);
            // Set VOW in the ETH-A CLIP
            DssExecLib.setContract(MCD_CLIP_ETH_A, "vow", MCD_VOW);
            // Set CALC in the ETH-A CLIP
            DssExecLib.setContract(MCD_CLIP_ETH_A, "calc", MCD_CLIP_CALC_ETH_A);
            // Authorize CLIP can access to VAT
            DssExecLib.authorize(MCD_VAT, MCD_CLIP_ETH_A);
            // Authorize CLIP can access to DOG
            DssExecLib.authorize(MCD_DOG, MCD_CLIP_ETH_A);
            // Authorize DOG can kick auctions on CLIP
            DssExecLib.authorize(MCD_CLIP_ETH_A, MCD_DOG);
            // Authorize the new END to access the ETH CLIP
            DssExecLib.authorize(MCD_CLIP_ETH_A, MCD_END);
            // Authorize CLIPPERMOM can set the stopped flag in CLIP
            DssExecLib.authorize(MCD_CLIP_ETH_A, CLIPPER_MOM);
            // Authorize new ESM to execute in ETH-A Clipper
            DssExecLib.authorize(MCD_CLIP_ETH_A, MCD_ESM);
            // Whitelist CLIP in the ETH osm
            DssExecLib.addReaderToOSMWhitelist(PIP_ETH, MCD_CLIP_ETH_A);
            // Whitelist CLIPPER_MOM in the ETH osm
            DssExecLib.addReaderToOSMWhitelist(PIP_ETH, CLIPPER_MOM);
            // No more auctions kicked via the CAT:
            DssExecLib.deauthorize(MCD_FLIP_ETH_A, MCD_CAT);
            // No more circuit breaker for the FLIP in ETH-A:
            DssExecLib.deauthorize(MCD_FLIP_ETH_A, DssExecLib.flipperMom());
            // Set values
            Fileable(MCD_DOG).file("ETH-A", "hole", 5_000 * RAD);
            Fileable(MCD_DOG).file("ETH-A", "chop", 113 * WAD / 100);
            Fileable(MCD_CLIP_ETH_A).file("buf", 130 * RAY / 100);
            Fileable(MCD_CLIP_ETH_A).file("tail", 140 minutes);
            Fileable(MCD_CLIP_ETH_A).file("cusp", 40 * RAY / 100);
            Fileable(MCD_CLIP_ETH_A).file("chip", 1 * WAD / 1000);
            Fileable(MCD_CLIP_ETH_A).file("tip", 0);
            Fileable(MCD_CLIP_CALC_ETH_A).file("cut", 99 * RAY / 100); // 1% cut
            Fileable(MCD_CLIP_CALC_ETH_A).file("step", 90 seconds);
            //  Tolerance currently set to 50%.
            //   n.b. 600000000000000000000000000 == 40% acceptable drop
            ClipperMomAbstract(CLIPPER_MOM).setPriceTolerance(MCD_CLIP_ETH_A, 50 * RAY / 100);
            // Update chost
            ClipAbstract(MCD_CLIP_ETH_A).upchost();
            // Replace flip to clip in the ilk registry
            DssExecLib.setContract(ILK_REGISTRY, "ETH-A", "xlip", MCD_CLIP_ETH_A);
            Fileable(ILK_REGISTRY).file("ETH-A", "class", 1);
            // Update Chainlog
            DssExecLib.setChangelogAddress("MCD_CLIP_ETH_A", MCD_CLIP_ETH_A);
            DssExecLib.setChangelogAddress("MCD_CLIP_CALC_ETH_A", MCD_CLIP_CALC_ETH_A);
            ChainlogLike(CHANGELOG).removeAddress("MCD_FLIP_ETH_A");
        }

        // --------------------------------- ETH-B ---------------------------------

        {
            address MCD_FLIP_ETH_B  = DssExecLib.getChangelogAddress("MCD_FLIP_ETH_B");
            // Check constructor values of Clipper
            require(ClipAbstract(MCD_CLIP_ETH_B).vat() == MCD_VAT, "DssSpell/clip-wrong-vat");
            require(ClipAbstract(MCD_CLIP_ETH_B).spotter() == MCD_SPOT, "DssSpell/clip-wrong-spotter");
            require(ClipAbstract(MCD_CLIP_ETH_B).dog() == MCD_DOG, "DssSpell/clip-wrong-dog");
            require(ClipAbstract(MCD_CLIP_ETH_B).ilk() == "ETH-B", "DssSpell/clip-wrong-ilk");
            // Set CLIP for ETH-B in the DOG
            DssExecLib.setContract(MCD_DOG, "ETH-B", "clip", MCD_CLIP_ETH_B);
            // Set VOW in the ETH-B CLIP
            DssExecLib.setContract(MCD_CLIP_ETH_B, "vow", MCD_VOW);
            // Set CALC in the ETH-B CLIP
            DssExecLib.setContract(MCD_CLIP_ETH_B, "calc", MCD_CLIP_CALC_ETH_B);
            // Authorize CLIP can access to VAT
            DssExecLib.authorize(MCD_VAT, MCD_CLIP_ETH_B);
            // Authorize CLIP can access to DOG
            DssExecLib.authorize(MCD_DOG, MCD_CLIP_ETH_B);
            // Authorize DOG can kick auctions on CLIP
            DssExecLib.authorize(MCD_CLIP_ETH_B, MCD_DOG);
            // Authorize the new END to access the ETH CLIP
            DssExecLib.authorize(MCD_CLIP_ETH_B, MCD_END);
            // Authorize CLIPPERMOM can set the stopped flag in CLIP
            DssExecLib.authorize(MCD_CLIP_ETH_B, CLIPPER_MOM);
            // Authorize new ESM to execute in ETH-B Clipper
            DssExecLib.authorize(MCD_CLIP_ETH_B, MCD_ESM);
            // Whitelist CLIP in the ETH osm
            DssExecLib.addReaderToOSMWhitelist(PIP_ETH, MCD_CLIP_ETH_B);
            // Whitelist CLIPPER_MOM in the ETH osm
            DssExecLib.addReaderToOSMWhitelist(PIP_ETH, CLIPPER_MOM);
            // No more auctions kicked via the CAT:
            DssExecLib.deauthorize(MCD_FLIP_ETH_B, MCD_CAT);
            // No more circuit breaker for the FLIP in ETH-B:
            DssExecLib.deauthorize(MCD_FLIP_ETH_B, DssExecLib.flipperMom());
            // Set values
            Fileable(MCD_DOG).file("ETH-B", "hole", 5_000 * RAD);
            Fileable(MCD_DOG).file("ETH-B", "chop", 113 * WAD / 100);
            Fileable(MCD_CLIP_ETH_B).file("buf", 130 * RAY / 100);
            Fileable(MCD_CLIP_ETH_B).file("tail", 140 minutes);
            Fileable(MCD_CLIP_ETH_B).file("cusp", 40 * RAY / 100);
            Fileable(MCD_CLIP_ETH_B).file("chip", 1 * WAD / 1000);
            Fileable(MCD_CLIP_ETH_B).file("tip", 0);
            Fileable(MCD_CLIP_CALC_ETH_B).file("cut", 99 * RAY / 100); // 1% cut
            Fileable(MCD_CLIP_CALC_ETH_B).file("step", 90 seconds);
            //  Tolerance currently set to 50%.
            //   n.b. 600000000000000000000000000 == 40% acceptable drop
            ClipperMomAbstract(CLIPPER_MOM).setPriceTolerance(MCD_CLIP_ETH_B, 50 * RAY / 100);
            // Update chost
            ClipAbstract(MCD_CLIP_ETH_B).upchost();
            // Replace flip to clip in the ilk registry
            DssExecLib.setContract(ILK_REGISTRY, "ETH-B", "xlip", MCD_CLIP_ETH_B);
            Fileable(ILK_REGISTRY).file("ETH-B", "class", 1);
            // Update Chainlog
            DssExecLib.setChangelogAddress("MCD_CLIP_ETH_B", MCD_CLIP_ETH_B);
            DssExecLib.setChangelogAddress("MCD_CLIP_CALC_ETH_B", MCD_CLIP_CALC_ETH_B);
            ChainlogLike(CHANGELOG).removeAddress("MCD_FLIP_ETH_B");
        }

        // --------------------------------- ETH-C ---------------------------------

        {
            address MCD_FLIP_ETH_C  = DssExecLib.getChangelogAddress("MCD_FLIP_ETH_C");
            // Check constructor values of Clipper
            require(ClipAbstract(MCD_CLIP_ETH_C).vat() == MCD_VAT, "DssSpell/clip-wrong-vat");
            require(ClipAbstract(MCD_CLIP_ETH_C).spotter() == MCD_SPOT, "DssSpell/clip-wrong-spotter");
            require(ClipAbstract(MCD_CLIP_ETH_C).dog() == MCD_DOG, "DssSpell/clip-wrong-dog");
            require(ClipAbstract(MCD_CLIP_ETH_C).ilk() == "ETH-C", "DssSpell/clip-wrong-ilk");
            // Set CLIP for ETH-C in the DOG
            DssExecLib.setContract(MCD_DOG, "ETH-C", "clip", MCD_CLIP_ETH_C);
            // Set VOW in the ETH-C CLIP
            DssExecLib.setContract(MCD_CLIP_ETH_C, "vow", MCD_VOW);
            // Set CALC in the ETH-C CLIP
            DssExecLib.setContract(MCD_CLIP_ETH_C, "calc", MCD_CLIP_CALC_ETH_C);
            // Authorize CLIP can access to VAT
            DssExecLib.authorize(MCD_VAT, MCD_CLIP_ETH_C);
            // Authorize CLIP can access to DOG
            DssExecLib.authorize(MCD_DOG, MCD_CLIP_ETH_C);
            // Authorize DOG can kick auctions on CLIP
            DssExecLib.authorize(MCD_CLIP_ETH_C, MCD_DOG);
            // Authorize the new END to access the ETH CLIP
            DssExecLib.authorize(MCD_CLIP_ETH_C, MCD_END);
            // Authorize CLIPPERMOM can set the stopped flag in CLIP
            DssExecLib.authorize(MCD_CLIP_ETH_C, CLIPPER_MOM);
            // Authorize new ESM to execute in ETH-C Clipper
            DssExecLib.authorize(MCD_CLIP_ETH_C, MCD_ESM);
            // Whitelist CLIP in the ETH osm
            DssExecLib.addReaderToOSMWhitelist(PIP_ETH, MCD_CLIP_ETH_C);
            // Whitelist CLIPPER_MOM in the ETH osm
            DssExecLib.addReaderToOSMWhitelist(PIP_ETH, CLIPPER_MOM);
            // No more auctions kicked via the CAT:
            DssExecLib.deauthorize(MCD_FLIP_ETH_C, MCD_CAT);
            // No more circuit breaker for the FLIP in ETH-C:
            DssExecLib.deauthorize(MCD_FLIP_ETH_C, DssExecLib.flipperMom());
            // Set values
            Fileable(MCD_DOG).file("ETH-C", "hole", 5_000 * RAD);
            Fileable(MCD_DOG).file("ETH-C", "chop", 113 * WAD / 100);
            Fileable(MCD_CLIP_ETH_C).file("buf", 130 * RAY / 100);
            Fileable(MCD_CLIP_ETH_C).file("tail", 140 minutes);
            Fileable(MCD_CLIP_ETH_C).file("cusp", 40 * RAY / 100);
            Fileable(MCD_CLIP_ETH_C).file("chip", 1 * WAD / 1000);
            Fileable(MCD_CLIP_ETH_C).file("tip", 0);
            Fileable(MCD_CLIP_CALC_ETH_C).file("cut", 99 * RAY / 100); // 1% cut
            Fileable(MCD_CLIP_CALC_ETH_C).file("step", 90 seconds);
            //  Tolerance currently set to 50%.
            //   n.b. 600000000000000000000000000 == 40% acceptable drop
            ClipperMomAbstract(CLIPPER_MOM).setPriceTolerance(MCD_CLIP_ETH_C, 50 * RAY / 100);
            // Update chost
            ClipAbstract(MCD_CLIP_ETH_C).upchost();
            // Replace flip to clip in the ilk registry
            DssExecLib.setContract(ILK_REGISTRY, "ETH-C", "xlip", MCD_CLIP_ETH_C);
            Fileable(ILK_REGISTRY).file("ETH-C", "class", 1);
            // Update Chainlog
            DssExecLib.setChangelogAddress("MCD_CLIP_ETH_C", MCD_CLIP_ETH_C);
            DssExecLib.setChangelogAddress("MCD_CLIP_CALC_ETH_C", MCD_CLIP_CALC_ETH_C);
            ChainlogLike(CHANGELOG).removeAddress("MCD_FLIP_ETH_C");
        }

        // --------------------------------- WBTC-A ---------------------------------

        {
            address MCD_FLIP_WBTC_A = DssExecLib.getChangelogAddress("MCD_FLIP_WBTC_A");
            // Check constructor values of Clipper
            require(ClipAbstract(MCD_CLIP_WBTC_A).vat() == MCD_VAT, "DssSpell/clip-wrong-vat");
            require(ClipAbstract(MCD_CLIP_WBTC_A).spotter() == MCD_SPOT, "DssSpell/clip-wrong-spotter");
            require(ClipAbstract(MCD_CLIP_WBTC_A).dog() == MCD_DOG, "DssSpell/clip-wrong-dog");
            require(ClipAbstract(MCD_CLIP_WBTC_A).ilk() == "WBTC-A", "DssSpell/clip-wrong-ilk");
            // Set CLIP for WBTC-A in the DOG
            DssExecLib.setContract(MCD_DOG, "WBTC-A", "clip", MCD_CLIP_WBTC_A);
            // Set VOW in the WBTC-A CLIP
            DssExecLib.setContract(MCD_CLIP_WBTC_A, "vow", MCD_VOW);
            // Set CALC in the WBTC-A CLIP
            DssExecLib.setContract(MCD_CLIP_WBTC_A, "calc", MCD_CLIP_CALC_WBTC_A);
            // Authorize CLIP can access to VAT
            DssExecLib.authorize(MCD_VAT, MCD_CLIP_WBTC_A);
            // Authorize CLIP can access to DOG
            DssExecLib.authorize(MCD_DOG, MCD_CLIP_WBTC_A);
            // Authorize DOG can kick auctions on CLIP
            DssExecLib.authorize(MCD_CLIP_WBTC_A, MCD_DOG);
            // Authorize the new END to access the WBTC CLIP
            DssExecLib.authorize(MCD_CLIP_WBTC_A, MCD_END);
            // Authorize CLIPPERMOM can set the stopped flag in CLIP
            DssExecLib.authorize(MCD_CLIP_WBTC_A, CLIPPER_MOM);
            // Authorize new ESM to execute in WBTC-A Clipper
            DssExecLib.authorize(MCD_CLIP_WBTC_A, MCD_ESM);
            // Whitelist CLIP in the WBTC osm
            DssExecLib.addReaderToOSMWhitelist(PIP_WBTC, MCD_CLIP_WBTC_A);
            // Whitelist CLIPPER_MOM in the WBTC osm
            DssExecLib.addReaderToOSMWhitelist(PIP_WBTC, CLIPPER_MOM);
            // No more auctions kicked via the CAT:
            DssExecLib.deauthorize(MCD_FLIP_WBTC_A, MCD_CAT);
            // No more circuit breaker for the FLIP in WBTC-A:
            DssExecLib.deauthorize(MCD_FLIP_WBTC_A, DssExecLib.flipperMom());
            // Set values
            Fileable(MCD_DOG).file("WBTC-A", "hole", 5_000 * RAD);
            Fileable(MCD_DOG).file("WBTC-A", "chop", 113 * WAD / 100);
            Fileable(MCD_CLIP_WBTC_A).file("buf", 130 * RAY / 100);
            Fileable(MCD_CLIP_WBTC_A).file("tail", 140 minutes);
            Fileable(MCD_CLIP_WBTC_A).file("cusp", 40 * RAY / 100);
            Fileable(MCD_CLIP_WBTC_A).file("chip", 1 * WAD / 1000);
            Fileable(MCD_CLIP_WBTC_A).file("tip", 0);
            Fileable(MCD_CLIP_CALC_WBTC_A).file("cut", 99 * RAY / 100); // 1% cut
            Fileable(MCD_CLIP_CALC_WBTC_A).file("step", 90 seconds);
            //  Tolerance currently set to 50%.
            //   n.b. 600000000000000000000000000 == 40% acceptable drop
            ClipperMomAbstract(CLIPPER_MOM).setPriceTolerance(MCD_CLIP_WBTC_A, 50 * RAY / 100);
            // Update chost
            ClipAbstract(MCD_CLIP_WBTC_A).upchost();
            // Replace flip to clip in the ilk registry
            DssExecLib.setContract(ILK_REGISTRY, "WBTC-A", "xlip", MCD_CLIP_WBTC_A);
            Fileable(ILK_REGISTRY).file("WBTC-A", "class", 1);
            // Update Chainlog
            DssExecLib.setChangelogAddress("MCD_CLIP_WBTC_A", MCD_CLIP_WBTC_A);
            DssExecLib.setChangelogAddress("MCD_CLIP_CALC_WBTC_A", MCD_CLIP_CALC_WBTC_A);
            ChainlogLike(CHANGELOG).removeAddress("MCD_FLIP_WBTC_A");
        }

        DssExecLib.setChangelogVersion("1.5.0");
    }
}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}
