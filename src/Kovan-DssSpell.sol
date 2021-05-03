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

struct Collateral {
    bytes32 ilk;
    address vat;
    address vow;
    address spotter;
    address cat;
    address dog;
    address end;
    address esm;
    address flipperMom;
    address clipperMom;
    address ilkRegistry;
    address pip;
    address clipper;
    address flipper;
    address calc;
    uint256 hole;
    uint256 chop;
    uint256 buf;
    uint256 tail;
    uint256 cusp;
    uint256 chip;
    uint256 tip;
    uint256 cut;
    uint256 step;
    uint256 tolerance;
    bytes32 clipKey;
    bytes32 calcKey;
    bytes32 flipKey;
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

    address constant MCD_CLIP_BAT_A             = 0x332B44A24e2CF8A258E8A1932b13296b9316a74c;
    address constant MCD_CLIP_CALC_BAT_A        = 0x4AB9058A9cAB0B18B4b40621Fa44B2131836Ad32;
    address constant MCD_CLIP_USDC_A            = 0x09D45087c035DbcD8d6fB5e9d4c5341b9101E626;
    address constant MCD_CLIP_CALC_USDC_A       = 0xF8D26c26Ac481794E4Aebf4F35B10d8E9748086a;
    address constant MCD_CLIP_USDC_B            = 0xedFc36f75faafa80e39cd4623def15da6CF2B5C0;
    address constant MCD_CLIP_CALC_USDC_B       = 0x275076c9c101AF880BD944991258d564FA31D61B;
    address constant MCD_CLIP_TUSD_A            = 0x9D547d599489B3950485cBa119FC37Bba9c15c13;
    address constant MCD_CLIP_CALC_TUSD_A       = 0x4AE93701287b8C86f17E5a0Cb4D0732b5ae6EFBD;
    address constant MCD_CLIP_ZRX_A             = 0x9072C477FEb67eEFd8865737206e87570444885E;
    address constant MCD_CLIP_CALC_ZRX_A        = 0xCd8Aa54176A333C3B668f65Ff8F11ee909f9A698;
    address constant MCD_CLIP_KNC_A             = 0x09EA13E49885C29dD270B5c3F557D71A30479333;
    address constant MCD_CLIP_CALC_KNC_A        = 0x8D11DC42F5Cc6fE19FeE799e3e24b506cEadAB4b;
    address constant MCD_CLIP_MANA_A            = 0xFd79e5881CC59F4637ddb3799D302BF089dEE832;
    address constant MCD_CLIP_CALC_MANA_A       = 0x14cd62bB700d3cDe2bC45Db2875b58200DDD2503;
    address constant MCD_CLIP_USDT_A            = 0xBDd2d10dAF8D86dA1f02bB7c7C7841bC9A4F62D4;
    address constant MCD_CLIP_CALC_USDT_A       = 0xa3a5163Fa4d46D799fE4B036349f0289D69A4445;
    address constant MCD_CLIP_PAXUSD_A          = 0x3939B686a0A7265512D38Ea3fe700812A703BF31;
    address constant MCD_CLIP_CALC_PAXUSD_A     = 0x784863edC4C28D73192bf56944D8803c0b5E0CbF;
    address constant MCD_CLIP_COMP_A            = 0xCDe79465D0B98775c1831957b88BFa12b8A3f020;
    address constant MCD_CLIP_CALC_COMP_A       = 0x3e41fCB2DC5370F8612884CB2928E74FED77Cb4B;
    address constant MCD_CLIP_LRC_A             = 0xaF94A206A3f3948c0BDB6a195a119862F26F5e92;
    address constant MCD_CLIP_CALC_LRC_A        = 0xD47DF2Cae1a86fC22e8A8b9B06b22f27860Cb333;
    address constant MCD_CLIP_BAL_A             = 0x8F6C48A26ebf4006Ab542d030D4090DfeC39652E;
    address constant MCD_CLIP_CALC_BAL_A        = 0xd041ED45EC5e4539BbbCd91B97D36C76F9d678C9;
    address constant MCD_CLIP_GUSD_A            = 0x448eD0ff4e154C1cBefE2c8057906Dd3dA194dA5;
    address constant MCD_CLIP_CALC_GUSD_A       = 0x4DD8AaB74a710E7a95937ef1b2618ee76F829Ba6;
    address constant MCD_CLIP_UNI_A             = 0xed3D15e390750f0808E64e0Af1F791e6c5b47c2e;
    address constant MCD_CLIP_CALC_UNI_A        = 0x1ee2ecD5149F4b46257a37195994337F4a35E5e8;
    address constant MCD_CLIP_RENBTC_A          = 0xEf9EEb37CDB15eaD336440BebC30C4CD37Da1891;
    address constant MCD_CLIP_CALC_RENBTC_A     = 0xF47749299BCCe427cFd9d015D543aEF83D3BD4Da;
    address constant MCD_CLIP_AAVE_A            = 0xC8D2d6692981abc7DC5Bf4E345ce3Ce462FA90c9;
    address constant MCD_CLIP_CALC_AAVE_A       = 0x0FdF9CecFF267a49f4e9f67014AFEc873143677D;
    address constant MCD_CLIP_PSM_USDC_A        = 0xC8Ca47D0AE4193b3f7F813E95669cfB15d922D56;
    address constant MCD_CLIP_CALC_PSM_USDC_A   = 0x22C3286711bD63D04Da2Ea95C4d7B556B9502a70;


    function flipperToClipper(Collateral memory col) internal {
        // Check constructor values of Clipper
        require(ClipAbstract(col.clipper).vat() == col.vat, "DssSpell/clip-wrong-vat");
        require(ClipAbstract(col.clipper).spotter() == col.spotter, "DssSpell/clip-wrong-spotter");
        require(ClipAbstract(col.clipper).dog() == col.dog, "DssSpell/clip-wrong-dog");
        require(ClipAbstract(col.clipper).ilk() == col.ilk, "DssSpell/clip-wrong-ilk");
        // Set CLIP for the ilk in the DOG
        DssExecLib.setContract(col.dog, col.ilk, "clip", col.clipper);
        // Set VOW in the CLIP
        DssExecLib.setContract(col.clipper, "vow", col.vow);
        // Set CALC in the CLIP
        DssExecLib.setContract(col.clipper, "calc", col.calc);
        // Authorize CLIP can access to VAT
        DssExecLib.authorize(col.vat, col.clipper);
        // Authorize CLIP can access to DOG
        DssExecLib.authorize(col.dog, col.clipper);
        // Authorize DOG can kick auctions on CLIP
        DssExecLib.authorize(col.clipper, col.dog);
        // Authorize the END to access the CLIP
        DssExecLib.authorize(col.clipper, col.end);
        // Authorize ESM to execute in Clipper
        DssExecLib.authorize(col.clipper, col.esm);
        if (col.pip != address(0)) {
            // Authorize CLIPPERMOM can set the stopped flag in CLIP
            DssExecLib.authorize(col.clipper, col.clipperMom);
            // Whitelist CLIP in the osm
            DssExecLib.addReaderToOSMWhitelist(col.pip, col.clipper);
            // Whitelist clipperMom in the osm
            DssExecLib.addReaderToOSMWhitelist(col.pip, col.clipperMom);
        } else {
            ClipAbstract(col.clipper).file("stopped", 3);
        }
        // No more auctions kicked via the CAT:
        DssExecLib.deauthorize(col.flipper, col.cat);
        // No more circuit breaker for the FLIP:
        DssExecLib.deauthorize(col.flipper, col.flipperMom);
        // Set values
        Fileable(col.dog).file(col.ilk, "hole", col.hole);
        Fileable(col.dog).file(col.ilk, "chop", col.chop);
        Fileable(col.clipper).file("buf", col.buf);
        Fileable(col.clipper).file("tail", col.tail);
        Fileable(col.clipper).file("cusp", col.cusp);
        Fileable(col.clipper).file("chip", col.chip);
        Fileable(col.clipper).file("tip", col.tip);
        Fileable(col.calc).file("cut", col.cut);
        Fileable(col.calc).file("step", col.step);
        ClipperMomAbstract(col.clipperMom).setPriceTolerance(col.clipper, col.tolerance);
        // Update chost
        ClipAbstract(col.clipper).upchost();
        // Replace flip to clip in the ilk registry
        DssExecLib.setContract(col.ilkRegistry, col.ilk, "xlip", col.clipper);
        Fileable(col.ilkRegistry).file(col.ilk, "class", 1);
        // Update Chainlog
        DssExecLib.setChangelogAddress(col.clipKey, col.clipper);
        DssExecLib.setChangelogAddress(col.calcKey, col.calc);
        ChainlogLike(DssExecLib.LOG).removeAddress(col.flipKey);
    }

    function actions() public override {
        address MCD_VAT         = DssExecLib.vat();
        address MCD_CAT         = DssExecLib.cat();
        address MCD_DOG         = DssExecLib.getChangelogAddress("MCD_DOG");
        address MCD_VOW         = DssExecLib.vow();
        address MCD_SPOT        = DssExecLib.spotter();
        address MCD_END         = DssExecLib.end();
        address MCD_ESM         = DssExecLib.getChangelogAddress("MCD_ESM");
        address FLIPPER_MOM     = DssExecLib.getChangelogAddress("FLIPPER_MOM");
        address CLIPPER_MOM     = DssExecLib.getChangelogAddress("CLIPPER_MOM");
        address ILK_REGISTRY    = DssExecLib.getChangelogAddress("ILK_REGISTRY");

        // --------------------------------- BAT-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "BAT-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: DssExecLib.getChangelogAddress("PIP_BAT"),
            clipper: MCD_CLIP_BAT_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_BAT_A"),
            calc: MCD_CLIP_CALC_BAT_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_BAT_A",
            calcKey: "MCD_CLIP_CALC_BAT_A",
            flipKey: "MCD_FLIP_BAT_A"
        }));

        // --------------------------------- USDC-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "USDC-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: address(0),
            clipper: MCD_CLIP_USDC_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_USDC_A"),
            calc: MCD_CLIP_CALC_USDC_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_USDC_A",
            calcKey: "MCD_CLIP_CALC_USDC_A",
            flipKey: "MCD_FLIP_USDC_A"
        }));

        // --------------------------------- USDC-B ---------------------------------
        flipperToClipper(Collateral({
            ilk: "USDC-B",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: address(0),
            clipper: MCD_CLIP_USDC_B,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_USDC_B"),
            calc: MCD_CLIP_CALC_USDC_B,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_USDC_B",
            calcKey: "MCD_CLIP_CALC_USDC_B",
            flipKey: "MCD_FLIP_USDC_B"
        }));

        // --------------------------------- TUSD-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "TUSD-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: address(0),
            clipper: MCD_CLIP_TUSD_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_TUSD_A"),
            calc: MCD_CLIP_CALC_TUSD_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_TUSD_A",
            calcKey: "MCD_CLIP_CALC_TUSD_A",
            flipKey: "MCD_FLIP_TUSD_A"
        }));

        // --------------------------------- ZRX-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "ZRX-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: DssExecLib.getChangelogAddress("PIP_ZRX"),
            clipper: MCD_CLIP_ZRX_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_ZRX_A"),
            calc: MCD_CLIP_CALC_ZRX_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_ZRX_A",
            calcKey: "MCD_CLIP_CALC_ZRX_A",
            flipKey: "MCD_FLIP_ZRX_A"
        }));

        // --------------------------------- KNC-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "KNC-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: DssExecLib.getChangelogAddress("PIP_KNC"),
            clipper: MCD_CLIP_KNC_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_KNC_A"),
            calc: MCD_CLIP_CALC_KNC_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_KNC_A",
            calcKey: "MCD_CLIP_CALC_KNC_A",
            flipKey: "MCD_FLIP_KNC_A"
        }));

        // --------------------------------- MANA-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "MANA-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: DssExecLib.getChangelogAddress("PIP_MANA"),
            clipper: MCD_CLIP_MANA_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_MANA_A"),
            calc: MCD_CLIP_CALC_MANA_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_MANA_A",
            calcKey: "MCD_CLIP_CALC_MANA_A",
            flipKey: "MCD_FLIP_MANA_A"
        }));

        // --------------------------------- USDT-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "USDT-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: DssExecLib.getChangelogAddress("PIP_USDT"),
            clipper: MCD_CLIP_USDT_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_USDT_A"),
            calc: MCD_CLIP_CALC_USDT_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_USDT_A",
            calcKey: "MCD_CLIP_CALC_USDT_A",
            flipKey: "MCD_FLIP_USDT_A"
        }));

        // --------------------------------- PAXUSD-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "PAXUSD-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: address(0),
            clipper: MCD_CLIP_PAXUSD_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_PAXUSD_A"),
            calc: MCD_CLIP_CALC_PAXUSD_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_PAXUSD_A",
            calcKey: "MCD_CLIP_CALC_PAXUSD_A",
            flipKey: "MCD_FLIP_PAXUSD_A"
        }));

        // --------------------------------- COMP-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "COMP-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: DssExecLib.getChangelogAddress("PIP_COMP"),
            clipper: MCD_CLIP_COMP_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_COMP_A"),
            calc: MCD_CLIP_CALC_COMP_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_COMP_A",
            calcKey: "MCD_CLIP_CALC_COMP_A",
            flipKey: "MCD_FLIP_COMP_A"
        }));

        // --------------------------------- LRC-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "LRC-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: DssExecLib.getChangelogAddress("PIP_LRC"),
            clipper: MCD_CLIP_LRC_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_LRC_A"),
            calc: MCD_CLIP_CALC_LRC_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_LRC_A",
            calcKey: "MCD_CLIP_CALC_LRC_A",
            flipKey: "MCD_FLIP_LRC_A"
        }));

        // --------------------------------- BAL-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "BAL-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: DssExecLib.getChangelogAddress("PIP_BAL"),
            clipper: MCD_CLIP_BAL_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_BAL_A"),
            calc: MCD_CLIP_CALC_BAL_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_BAL_A",
            calcKey: "MCD_CLIP_CALC_BAL_A",
            flipKey: "MCD_FLIP_BAL_A"
        }));

        // --------------------------------- GUSD-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "GUSD-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: address(0),
            clipper: MCD_CLIP_GUSD_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_GUSD_A"),
            calc: MCD_CLIP_CALC_GUSD_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_GUSD_A",
            calcKey: "MCD_CLIP_CALC_GUSD_A",
            flipKey: "MCD_FLIP_GUSD_A"
        }));

        // --------------------------------- UNI-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "UNI-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: DssExecLib.getChangelogAddress("PIP_UNI"),
            clipper: MCD_CLIP_UNI_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_UNI_A"),
            calc: MCD_CLIP_CALC_UNI_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_UNI_A",
            calcKey: "MCD_CLIP_CALC_UNI_A",
            flipKey: "MCD_FLIP_UNI_A"
        }));

        // --------------------------------- RENBTC-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "RENBTC-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: DssExecLib.getChangelogAddress("PIP_RENBTC"),
            clipper: MCD_CLIP_RENBTC_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_RENBTC_A"),
            calc: MCD_CLIP_CALC_RENBTC_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_RENBTC_A",
            calcKey: "MCD_CLIP_CALC_RENBTC_A",
            flipKey: "MCD_FLIP_RENBTC_A"
        }));

        // --------------------------------- AAVE-A ---------------------------------
        flipperToClipper(Collateral({
            ilk: "AAVE-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: DssExecLib.getChangelogAddress("PIP_AAVE"),
            clipper: MCD_CLIP_AAVE_A,
            flipper: DssExecLib.getChangelogAddress("MCD_FLIP_AAVE_A"),
            calc: MCD_CLIP_CALC_AAVE_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_AAVE_A",
            calcKey: "MCD_CLIP_CALC_AAVE_A",
            flipKey: "MCD_FLIP_AAVE_A"
        }));

        // --------------------------------- PSM-USDC-A ---------------------------------
        // Fix wrong PSM keys (only for kovan)
        address flipperPSM = DssExecLib.getChangelogAddress("MCD_FLIP_USDC_PSM");
        DssExecLib.setChangelogAddress("MCD_JOIN_PSM_USDC_A", DssExecLib.getChangelogAddress("MCD_JOIN_USDC_PSM"));
        DssExecLib.setChangelogAddress("MCD_FLIP_PSM_USDC_A", flipperPSM);
        DssExecLib.setChangelogAddress("MCD_PSM_USDC_A", DssExecLib.getChangelogAddress("MCD_PSM_USDC_PSM"));
        ChainlogLike(DssExecLib.LOG).removeAddress("MCD_JOIN_USDC_PSM");
        ChainlogLike(DssExecLib.LOG).removeAddress("MCD_FLIP_USDC_PSM");
        ChainlogLike(DssExecLib.LOG).removeAddress("MCD_PSM_USDC_PSM");
        //
        flipperToClipper(Collateral({
            ilk: "PSM-USDC-A",
            vat: MCD_VAT,
            vow: MCD_VOW,
            spotter: MCD_SPOT,
            cat: MCD_CAT,
            dog: MCD_DOG,
            end: MCD_END,
            esm: MCD_ESM,
            flipperMom: FLIPPER_MOM,
            clipperMom: CLIPPER_MOM,
            ilkRegistry: ILK_REGISTRY,
            pip: address(0),
            clipper: MCD_CLIP_PSM_USDC_A,
            flipper: flipperPSM,
            calc: MCD_CLIP_CALC_PSM_USDC_A,
            hole: 5_000 * RAD,
            chop: 113 * WAD / 100,
            buf: 130 * RAY / 100,
            tail: 140 minutes,
            cusp: 40 * RAY / 100,
            chip: 1 * WAD / 1000,
            tip: 0,
            cut: 99 * RAY / 100,
            step: 90 seconds,
            tolerance: 50 * RAY / 100,
            clipKey: "MCD_CLIP_PSM_USDC_A",
            calcKey: "MCD_CLIP_CALC_PSM_USDC_A",
            flipKey: "MCD_FLIP_PSM_USDC_A"
        }));


        DssExecLib.setChangelogVersion("1.6.0");
    }
}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}
