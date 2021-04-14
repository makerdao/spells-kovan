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
import "dss-interfaces/dss/IlkRegistryAbstract.sol";
import "dss-interfaces/dss/VatAbstract.sol";
import "dss-interfaces/dss/GemJoinAbstract.sol";
import "dss-interfaces/dss/JugAbstract.sol";
import "dss-interfaces/dss/SpotAbstract.sol";
import "dss-interfaces/dapp/DSTokenAbstract.sol";

interface RwaLiquidationLike {
    function ilks(bytes32) external returns (bytes32,address,uint48,uint48);
    function init(bytes32, uint256, string calldata, uint48) external;
}

interface RwaUrnLike {
    function hope(address) external;
}

contract DssSpellAction is DssAction {

    string public constant description = "Kovan Spell";

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    address constant RWA002_OPERATOR           = 0x2474F297214E5d96Ba4C81986A9F0e5C260f445D;
    address constant RWA002                    = 0x038D3804e17ED7A3B927DF3D5078a794c37Cbf98;
    address constant MCD_JOIN_RWA002_A         = 0xBC077F8A49eA38592B90E5A0F21bc211BB62138C;
    address constant RWA002_A_URN              = 0x9f5A541C53D1E588F4d6Cb8dDBe1c2c91a20eFc6;
    address constant RWA002_A_INPUT_CONDUIT    = 0x2474F297214E5d96Ba4C81986A9F0e5C260f445D;
    address constant RWA002_A_OUTPUT_CONDUIT   = 0x2474F297214E5d96Ba4C81986A9F0e5C260f445D;

    uint256 constant RWA002_THREEPOINTFIVE_PERCENT_RATE = 1000000001090862085746321732;
    uint256 constant RWA002_A_INITIAL_DC    = 5 * MILLION * RAD;
    uint256 constant RWA002_A_INITIAL_PRICE = 5_366_480 * WAD; // 5,366,480

    string constant DOC = "QmSwZzhzFgsbduBxR4hqCavDWPjvAHbNiqarj1fbTwpevR";

    // precision
    uint256 constant public MILLION  = 10 ** 6;
    uint256 constant public WAD      = 10 ** 18;
    uint256 constant public RAY      = 10 ** 27;
    uint256 constant public RAD      = 10 ** 45;


    function actions() public override {
        // --------------------- Replace MIP22 ---------------------

        // Remove old one

        address MCD_VAT      = DssExecLib.vat();
        address ILK_REGISTRY = DssExecLib.reg();
        ChainlogLike CHANGELOG = ChainlogLike(DssExecLib.getChangelogAddress("CHANGELOG"));

        bytes32 oldIlk = "NS2DRP-A";

        VatAbstract(MCD_VAT).file(oldIlk, "line", 0);
        VatAbstract(MCD_VAT).deny(DssExecLib.getChangelogAddress("MCD_JOIN_NS2DRP_A"));

        CHANGELOG.removeAddress("NS2DRP");
        CHANGELOG.removeAddress("MCD_JOIN_NS2DRP_A");
        CHANGELOG.removeAddress("NS2DRP_A_URN");
        CHANGELOG.removeAddress("NS2DRP_A_INPUT_CONDUIT");
        CHANGELOG.removeAddress("NS2DRP_A_OUTPUT_CONDUIT");

        IlkRegistryAbstract(ILK_REGISTRY).remove(oldIlk);

        // Add new one

        address MCD_JUG  = DssExecLib.jug();
        address MCD_SPOT = DssExecLib.spotter();
        address MIP21_LIQUIDATION_ORACLE = CHANGELOG.getAddress("MIP21_LIQUIDATION_ORACLE");

        // Set ilk bytes32 variable
        bytes32 ilk = "RWA002-A";

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_RWA002_A).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA002_A).ilk() == ilk, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA002_A).gem() == RWA002, "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_RWA002_A).dec() == DSTokenAbstract(RWA002).decimals(), "join-dec-not-match");

        // init the RwaLiquidationOracle
        // doc: "IPFS Hash"
        // tau: 5 minutes
        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(
            ilk, RWA002_A_INITIAL_PRICE, DOC, 300
        );

        (, address pip,,) = RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).ilks(ilk);

        // Set price feed for RWA002
        SpotAbstract(MCD_SPOT).file(ilk, "pip", pip);

        // Init RWA002 in Vat
        VatAbstract(MCD_VAT).init(ilk);
        // Init RWA002 in Jug
        JugAbstract(MCD_JUG).init(ilk);

        // Allow RWA002 Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_RWA002_A);

        // 5 Million debt ceiling (no need of global debt ceiling as we are replacing the collateral)
        VatAbstract(MCD_VAT).file(ilk, "line", RWA002_A_INITIAL_DC);

        // 3.5% stability fee
        JugAbstract(MCD_JUG).file(ilk, "duty", RWA002_THREEPOINTFIVE_PERCENT_RATE);

        // Set the RWA002-A min collateralization ratio (e.g. 105% => X = 105)
        SpotAbstract(MCD_SPOT).file(ilk, "mat", 100 * RAY / 100);

        // poke the spotter to pull in a price
        SpotAbstract(MCD_SPOT).poke(ilk);

        // give the urn permissions on the join adapter
        GemJoinAbstract(MCD_JOIN_RWA002_A).rely(RWA002_A_URN);

        // set up the urn
        RwaUrnLike(RWA002_A_URN).hope(RWA002_OPERATOR);

        // Add collateral in IlkRegistry
        IlkRegistryAbstract(ILK_REGISTRY).put(
            ilk,
            MCD_JOIN_RWA002_A,
            RWA002,
            18,
            3,
            pip,
            address(0),
            "RWA-002",
            "RWA002"
        );

        // add NS2DRP contract to the changelog
        DssExecLib.setChangelogAddress("RWA002", RWA002);
        DssExecLib.setChangelogAddress("PIP_RWA002", pip);
        DssExecLib.setChangelogAddress("MCD_JOIN_RWA002_A", MCD_JOIN_RWA002_A);
        DssExecLib.setChangelogAddress("RWA002_A_URN", RWA002_A_URN);
        DssExecLib.setChangelogAddress("RWA002_A_INPUT_CONDUIT", RWA002_A_INPUT_CONDUIT);
        DssExecLib.setChangelogAddress("RWA002_A_OUTPUT_CONDUIT", RWA002_A_OUTPUT_CONDUIT);

        DssExecLib.setChangelogVersion("1.2.11");


        // --------------------- Remove ESM_BUG ---------------------
        address MCD_ESM          = DssExecLib.getChangelogAddress("MCD_ESM_ATTACK");
        address MCD_ESM_BUG      = DssExecLib.getChangelogAddress("MCD_ESM_BUG");
        address MCD_END          = DssExecLib.end();

        DssExecLib.deauthorize(MCD_END, MCD_ESM_BUG);

        CHANGELOG.removeAddress("MCD_ESM_BUG");
        CHANGELOG.removeAddress("MCD_ESM_ATTACK");
        DssExecLib.setChangelogAddress("MCD_ESM", MCD_ESM);

        DssExecLib.setChangelogVersion("1.3.0");
    }

}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}
