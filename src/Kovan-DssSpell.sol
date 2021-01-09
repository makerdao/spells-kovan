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

import "lib/dss-interfaces/src/dss/ChainlogAbstract.sol";
import "lib/dss-interfaces/src/dss/GemJoinAbstract.sol";
import "lib/dss-interfaces/src/dapp/DSTokenAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipAbstract.sol";
import "lib/dss-interfaces/src/dss/VatAbstract.sol";
import "lib/dss-interfaces/src/dss/JugAbstract.sol";
import "lib/dss-interfaces/src/dss/SpotAbstract.sol";
import "lib/dss-interfaces/src/dss/CatAbstract.sol";
import "lib/dss-interfaces/src/dss/IlkRegistryAbstract.sol";
import "lib/dss-interfaces/src/dapp/DSPauseAbstract.sol";
import "lib/dss-interfaces/src/dss/LPOsmAbstract.sol";
import "lib/dss-interfaces/src/dss/MedianAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmMomAbstract.sol";

contract SpellAction {
    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    //  against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/active/contracts.json
    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    bytes32 constant ILK  = "UNIV2USDCETH-A";
    address constant GEM  = 0x44892ab8F7aFfB7e1AdA4Fb956CCE2a2f3049619;
    address constant PIP  = 0x627969F6fe0651a703B2d0e3a5758F9fF9B7547A;
    address constant JOIN = 0x642009AA5373F7eAFE4BC02CBdBb65a3621fB70e;
    address constant FLIP = 0x7cFCc9CC7045C86aA0505808218451127dED9CCe;

    // decimals & precision
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
    uint256 constant ONE_PERCENT_RATE = 1000000000315522921573372069;

    function execute() external {
        address MCD_VAT      = CHANGELOG.getAddress("MCD_VAT");
        address MCD_CAT      = CHANGELOG.getAddress("MCD_CAT");
        address MCD_JUG      = CHANGELOG.getAddress("MCD_JUG");
        address MCD_SPOT     = CHANGELOG.getAddress("MCD_SPOT");
        address MCD_END      = CHANGELOG.getAddress("MCD_END");
        address FLIPPER_MOM  = CHANGELOG.getAddress("FLIPPER_MOM");
        address OSM_MOM      = CHANGELOG.getAddress("OSM_MOM");
        address ILK_REGISTRY = CHANGELOG.getAddress("ILK_REGISTRY");

        //
        // Add UNI-V2-USDC-ETH
        //

        // Sanity checks
        require(GemJoinAbstract(JOIN).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(JOIN).ilk() == ILK, "join-ilk-not-match");
        require(GemJoinAbstract(JOIN).gem() == GEM, "join-gem-not-match");
        require(GemJoinAbstract(JOIN).dec() == DSTokenAbstract(GEM).decimals(), "join-dec-not-match");
        require(FlipAbstract(FLIP).vat() == MCD_VAT, "flip-vat-not-match");
        require(FlipAbstract(FLIP).cat() == MCD_CAT, "flip-cat-not-match");
        require(FlipAbstract(FLIP).ilk() == ILK, "flip-ilk-not-match");

        // Vat
        VatAbstract(MCD_VAT).init(ILK);
        VatAbstract(MCD_VAT).rely(JOIN);
        VatAbstract(MCD_VAT).file("Line", VatAbstract(MCD_VAT).Line() + 10 * MILLION * RAD);
        VatAbstract(MCD_VAT).file(ILK, "line", 10 * MILLION * RAD);
        VatAbstract(MCD_VAT).file(ILK, "dust", 5000 * RAD);

        // Jug
        JugAbstract(MCD_JUG).init(ILK);
        JugAbstract(MCD_JUG).file(ILK, "duty", ONE_PERCENT_RATE);

        // Spotter
        SpotAbstract(MCD_SPOT).file(ILK, "pip", PIP);
        SpotAbstract(MCD_SPOT).file(ILK, "mat", 125 * RAY / 100);
        SpotAbstract(MCD_SPOT).poke(ILK);

        // Cat
        CatAbstract(MCD_CAT).file(ILK, "flip", FLIP);
        CatAbstract(MCD_CAT).rely(FLIP);
        CatAbstract(MCD_CAT).file(ILK, "chop", 113 * WAD / 100);
        CatAbstract(MCD_CAT).file(ILK, "dunk", 50000 * RAD);

        // Flipper
        FlipAbstract(FLIP).rely(MCD_CAT);
        FlipAbstract(FLIP).rely(MCD_END);
        FlipAbstract(FLIP).rely(FLIPPER_MOM);
        FlipAbstract(FLIP).file("beg", 103 * WAD / 100);
        FlipAbstract(FLIP).file("ttl", 6 hours);
        FlipAbstract(FLIP).file("tau", 6 hours);

        // PIP
        LPOsmAbstract(PIP).rely(OSM_MOM);
        LPOsmAbstract(PIP).kiss(MCD_SPOT);
        LPOsmAbstract(PIP).kiss(MCD_END);
        MedianAbstract(LPOsmAbstract(PIP).orb1()).kiss(PIP);
        OsmMomAbstract(OSM_MOM).setOsm(ILK, PIP);

        // IlkRegistry
        IlkRegistryAbstract(ILK_REGISTRY).add(JOIN);

        // Changelog
        CHANGELOG.setAddress("UNIV2USDCETH", GEM);
        CHANGELOG.setAddress("PIP_UNIV2USDCETH", PIP);
        CHANGELOG.setAddress("MCD_JOIN_UNIV2USDCETH_A", JOIN);
        CHANGELOG.setAddress("MCD_FLIP_UNIV2USDCETH_A", FLIP);
        CHANGELOG.setVersion("1.2.4");
    }
}

contract DssSpell {
    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);
    DSPauseAbstract public pause =
        DSPauseAbstract(CHANGELOG.getAddress("MCD_PAUSE"));

    address         public action;
    bytes32         public tag;
    uint256         public eta;
    bytes           public sig;
    uint256         public expiration;
    bool            public done;

    string constant public description = "Kovan Spell Deploy";

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        expiration = now + 30 days;
    }

    function schedule() public {
        require(now <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = now + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}
