// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2020 Maker Ecosystem Growth Holdings, INC.
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

import "lib/dss-interfaces/src/dapp/DSPauseAbstract.sol";
import "lib/dss-interfaces/src/dapp/DSTokenAbstract.sol";
import "lib/dss-interfaces/src/dss/ChainlogAbstract.sol";
import "lib/dss-interfaces/src/dss/VatAbstract.sol";
import "lib/dss-interfaces/src/dss/SpotAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipAbstract.sol";
import "lib/dss-interfaces/src/dss/JugAbstract.sol";
import "lib/dss-interfaces/src/dss/CatAbstract.sol";
import "lib/dss-interfaces/src/dss/IlkRegistryAbstract.sol";
import "lib/dss-interfaces/src/dss/GemJoinAbstract.sol";
import "lib/dss-interfaces/src/dss/LPOsmAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmMomAbstract.sol";
import "lib/dss-interfaces/src/dss/MedianAbstract.sol";

contract SpellAction {
    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    //  against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/active/contracts.json
    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    // UNIV2USDCETH-A
    address constant UNIV2USDCETH             = 0x44892ab8F7aFfB7e1AdA4Fb956CCE2a2f3049619;
    address constant MCD_JOIN_UNIV2USDCETH_A  = 0x0f059B1CfFbf851845a594fa591D2BBfb9dDA350;
    address constant MCD_FLIP_UNIV2USDCETH_A  = 0x56142F4BE05BD9FD921D2b328f9Ec7B4fdAd474E;
    address constant PIP_UNIV2USDCETH         = 0x627969F6fe0651a703B2d0e3a5758F9fF9B7547A;
    bytes32 constant ILK_UNIV2USDCETH_A       = "UNIV2USDCETH-A";

    // decimals & precision
    uint256 constant THOUSAND = 10 ** 3;
    uint256 constant MILLION  = 10 ** 6;
    uint256 constant WAD      = 10 ** 18;
    uint256 constant RAY      = 10 ** 27;
    uint256 constant RAD      = 10 ** 45;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmefQMseb3AiTapiAKKexdKHig8wroKuZbmLtPLv4u2YwW
    //
    uint256 constant ONE_PERCENT_RATE             = 1000000000315522921573372069;

    function execute() external {
        address MCD_VAT      = CHANGELOG.getAddress("MCD_VAT");
        address MCD_CAT      = CHANGELOG.getAddress("MCD_CAT");
        address MCD_JUG      = CHANGELOG.getAddress("MCD_JUG");
        address MCD_SPOT     = CHANGELOG.getAddress("MCD_SPOT");
        address MCD_END      = CHANGELOG.getAddress("MCD_END");
        address FLIPPER_MOM  = CHANGELOG.getAddress("FLIPPER_MOM");
        address OSM_MOM      = CHANGELOG.getAddress("OSM_MOM"); // Only if PIP_TOKEN = Osm
        address ILK_REGISTRY = CHANGELOG.getAddress("ILK_REGISTRY");

        // Set the global debt ceiling
        // + 10 M for UNIV2USDCETH-A
        VatAbstract(MCD_VAT).file("Line", VatAbstract(MCD_VAT).Line() + 10 * MILLION * RAD);

        //
        // Add UniswapV2 USDC/ETH
        //

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_UNIV2USDCETH_A).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_UNIV2USDCETH_A).ilk() == ILK_UNIV2USDCETH_A, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_UNIV2USDCETH_A).gem() == UNIV2USDCETH, "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_UNIV2USDCETH_A).dec() == DSTokenAbstract(UNIV2USDCETH).decimals(), "join-dec-not-match");
        require(FlipAbstract(MCD_FLIP_UNIV2USDCETH_A).vat() == MCD_VAT, "flip-vat-not-match");
        require(FlipAbstract(MCD_FLIP_UNIV2USDCETH_A).cat() == MCD_CAT, "flip-cat-not-match");
        require(FlipAbstract(MCD_FLIP_UNIV2USDCETH_A).ilk() == ILK_UNIV2USDCETH_A, "flip-ilk-not-match");

        // Set the UNIV2USDCETH PIP in the Spotter
        SpotAbstract(MCD_SPOT).file(ILK_UNIV2USDCETH_A, "pip", PIP_UNIV2USDCETH);

        // Set the UNIV2USDCETH-A Flipper in the Cat
        CatAbstract(MCD_CAT).file(ILK_UNIV2USDCETH_A, "flip", MCD_FLIP_UNIV2USDCETH_A);

        // Init UNIV2USDCETH-A ilk in Vat & Jug
        VatAbstract(MCD_VAT).init(ILK_UNIV2USDCETH_A);
        JugAbstract(MCD_JUG).init(ILK_UNIV2USDCETH_A);

        // Allow UNIV2USDCETH-A Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_UNIV2USDCETH_A);
        // Allow the UNIV2USDCETH-A Flipper to reduce the Cat litterbox on deal()
        CatAbstract(MCD_CAT).rely(MCD_FLIP_UNIV2USDCETH_A);
        // Allow Cat to kick auctions in UNIV2USDCETH-A Flipper
        FlipAbstract(MCD_FLIP_UNIV2USDCETH_A).rely(MCD_CAT);
        // Allow End to yank auctions in UNIV2USDCETH-A Flipper
        FlipAbstract(MCD_FLIP_UNIV2USDCETH_A).rely(MCD_END);
        // Allow FlipperMom to access to the UNIV2USDCETH-A Flipper
        FlipAbstract(MCD_FLIP_UNIV2USDCETH_A).rely(FLIPPER_MOM);
        // Disallow Cat to kick auctions in UNIV2USDCETH-A Flipper
        // !!!!!!!! Only for certain collaterals that do not trigger liquidations like USDC-A)
        //FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_UNIV2USDCETH_A);

        // Allow OsmMom to access to the UNIV2USDCETH Osm
        // !!!!!!!! Only if PIP_UNIV2USDCETH = Osm and hasn't been already relied due a previous deployed ilk
        LPOsmAbstract(PIP_UNIV2USDCETH).rely(OSM_MOM);
        // Whitelist Osm to read the Median data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_UNIV2USDCETH = Osm, its src is a Median and hasn't been already whitelisted due a previous deployed ilk
        MedianAbstract(LPOsmAbstract(PIP_UNIV2USDCETH).orb1()).kiss(PIP_UNIV2USDCETH);
        // Whitelist Spotter to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_UNIV2USDCETH = Osm or PIP_UNIV2USDCETH = Median and hasn't been already whitelisted due a previous deployed ilk
        LPOsmAbstract(PIP_UNIV2USDCETH).kiss(MCD_SPOT);
        // Whitelist End to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_UNIV2USDCETH = Osm or PIP_UNIV2USDCETH = Median and hasn't been already whitelisted due a previous deployed ilk
        LPOsmAbstract(PIP_UNIV2USDCETH).kiss(MCD_END);
        // Set UNIV2USDCETH Osm in the OsmMom for new ilk
        // !!!!!!!! Only if PIP_UNIV2USDCETH = Osm
        OsmMomAbstract(OSM_MOM).setOsm(ILK_UNIV2USDCETH_A, PIP_UNIV2USDCETH);

        // Set the UNIV2USDCETH-A debt ceiling
        VatAbstract(MCD_VAT).file(ILK_UNIV2USDCETH_A, "line", 10 * MILLION * RAD);
        // Set the UNIV2USDCETH-A dust
        VatAbstract(MCD_VAT).file(ILK_UNIV2USDCETH_A, "dust", 100 * RAD);
        // Set the Lot size
        CatAbstract(MCD_CAT).file(ILK_UNIV2USDCETH_A, "dunk", 500 * RAD);
        // Set the UNIV2USDCETH-A liquidation penalty (e.g. 13% => X = 113)
        CatAbstract(MCD_CAT).file(ILK_UNIV2USDCETH_A, "chop", 113 * WAD / 100);
        // Set the UNIV2USDCETH-A stability fee (e.g. 1% = 1000000000315522921573372069)
        JugAbstract(MCD_JUG).file(ILK_UNIV2USDCETH_A, "duty", ONE_PERCENT_RATE);
        // Set the UNIV2USDCETH-A percentage between bids (e.g. 3% => X = 103)
        FlipAbstract(MCD_FLIP_UNIV2USDCETH_A).file("beg", 103 * WAD / 100);
        // Set the UNIV2USDCETH-A time max time between bids
        FlipAbstract(MCD_FLIP_UNIV2USDCETH_A).file("ttl", 1 hours);
        // Set the UNIV2USDCETH-A max auction duration to
        FlipAbstract(MCD_FLIP_UNIV2USDCETH_A).file("tau", 1 hours);
        // Set the UNIV2USDCETH-A min collateralization ratio (e.g. 150% => X = 150)
        SpotAbstract(MCD_SPOT).file(ILK_UNIV2USDCETH_A, "mat", 125 * RAY / 100);

        // Update UNIV2USDCETH-A spot value in Vat
        SpotAbstract(MCD_SPOT).poke(ILK_UNIV2USDCETH_A);

        // Add new ilk to the IlkRegistry
        IlkRegistryAbstract(ILK_REGISTRY).add(MCD_JOIN_UNIV2USDCETH_A);

        // Update the changelog
        CHANGELOG.setAddress("UNIV2USDCETH", UNIV2USDCETH);
        CHANGELOG.setAddress("MCD_JOIN_UNIV2USDCETH_A", MCD_JOIN_UNIV2USDCETH_A);
        CHANGELOG.setAddress("MCD_FLIP_UNIV2USDCETH_A", MCD_FLIP_UNIV2USDCETH_A);
        CHANGELOG.setAddress("PIP_UNIV2USDCETH", PIP_UNIV2USDCETH);
        // Bump version
        CHANGELOG.setVersion("1.2.4");
    }
}

contract DssSpell {
    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    DSPauseAbstract immutable public pause;
    address         immutable public action;
    bytes32         immutable public tag;
    uint256         immutable public expiration;
    uint256         public eta;
    bytes           public sig;
    bool            public done;

    string constant public description = "Kovan Spell Deploy";

    constructor() public {
        pause = DSPauseAbstract(CHANGELOG.getAddress("MCD_PAUSE"));
        sig = abi.encodeWithSignature("execute()");
        bytes32 _tag;
        address _action = action = address(new SpellAction());
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        expiration = block.timestamp + 30 days;
    }

    function schedule() external {
        require(block.timestamp <= expiration, "DSSSpell/spell-has-expired");
        require(eta == 0, "DSSSpell/spell-already-scheduled");
        eta = block.timestamp + pause.delay();
        pause.plot(action, tag, sig, eta);
    }

    function cast() external {
        require(!done, "DSSSpell/spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}
