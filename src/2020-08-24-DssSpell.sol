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

pragma solidity 0.5.12;

import "lib/dss-interfaces/src/dapp/DSPauseAbstract.sol";
import "lib/dss-interfaces/src/dss/VatAbstract.sol";
import "lib/dss-interfaces/src/dss/CatAbstract.sol";
import "lib/dss-interfaces/src/dss/JugAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipAbstract.sol";
import "lib/dss-interfaces/src/dss/SpotAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmMomAbstract.sol";
import "lib/dss-interfaces/src/dss/MedianAbstract.sol";
import "lib/dss-interfaces/src/dss/GemJoinAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipperMomAbstract.sol";

contract SpellAction {

    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    // against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/1.0.9/contracts.json
    address constant MCD_VAT             = 0xbA987bDB501d131f766fEe8180Da5d81b34b69d9; // kovan
    address constant MCD_CAT             = 0x0511674A67192FE51e86fE55Ed660eB4f995BDd6;
    address constant MCD_JUG             = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;
    address constant MCD_SPOT            = 0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D;
    address constant MCD_END             = 0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F;
    address constant FLIPPER_MOM         = 0xf3828caDb05E5F22844f6f9314D99516D68a0C84;
    address constant OSM_MOM             = 0x5dA9D1C3d4f1197E5c52Ff963916Fe84D2F5d8f3;

    // LRC-A specific
    address constant LRC                 = 0xF070662e48843934b5415f150a18C250d4D7B8aB;
    address constant MCD_JOIN_LRC_A      = 0x436286788C5dB198d632F14A20890b0C4D236800;
    address constant MCD_FLIP_LRC_A      = 0xbeb5f3c9FEE1ae008F04656cf094996d366e5F31;
    address constant PIP_LRC             = 0x4Ef3fde085c7046121A4a5773756c84F82056F91;

    // Decimals & precision
    uint256 constant THOUSAND = 10 ** 3;
    uint256 constant MILLION  = 10 ** 6;
    uint256 constant WAD      = 10 ** 18;
    uint256 constant RAY      = 10 ** 27;
    uint256 constant RAD      = 10 ** 45;

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    uint256 constant THREE_PCT_RATE     = 1000000000937303470807876289;

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/cc819c75fc8f1b622cbe06acfd0d11bf64545622/governance/votes/Executive%20vote%20-%20July%2027%2C%202020%20.md -q -O - 2>/dev/null)"
    string constant public description =
        "2020-08-24 MakerDAO Executive Spell | KOVAN DEPLOYMENT OF LRC-A";

    function execute() external {
        // TODO: UPDATE THIS IS A 6 MILLION ASSUMPTION
        VatAbstract(MCD_VAT).file("Line", add(VatAbstract(MCD_VAT).Line(), 3 * MILLION * RAD));

        ////////////////////////////////////////////////////////////////////////////////
        // LRC-A collateral deploy

        // Set ilk bytes32 variable
        bytes32 ilkLRCA = "LRC-A";

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_LRC_A).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_LRC_A).ilk() == ilkLRCA, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_LRC_A).gem() == LRC,     "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_LRC_A).dec() == 18,      "join-dec-not-match");
        require(FlipAbstract(MCD_FLIP_LRC_A).vat()    == MCD_VAT, "flip-vat-not-match");
        require(FlipAbstract(MCD_FLIP_LRC_A).ilk()    == ilkLRCA, "flip-ilk-not-match");

        // Set price feed for LRC-A
        SpotAbstract(MCD_SPOT).file(ilkLRCA, "pip", PIP_LRC);

        // Set the LRC-A flipper in the cat
        CatAbstract(MCD_CAT).file(ilkLRCA, "flip", MCD_FLIP_LRC_A);

        // Init LRC-A in Vat 
        VatAbstract(MCD_VAT).init(ilkLRCA);
        // Init LRC-A in Jug
        JugAbstract(MCD_JUG).init(ilkLRCA);

        // Allow LRC-A Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_LRC_A);

        // Allow cat to kick auctions in LRC-A Flipper
        FlipAbstract(MCD_FLIP_LRC_A).rely(MCD_CAT);

        // Allow End to yank auctions in LRC-A Flipper
        FlipAbstract(MCD_FLIP_LRC_A).rely(MCD_END);

        // Allow FlipperMom to access the LRC-A Flipper
        FlipAbstract(MCD_FLIP_LRC_A).rely(FLIPPER_MOM);

        // Update OSM
        MedianAbstract(OsmAbstract(PIP_LRC).src()).kiss(PIP_LRC);
        OsmAbstract(PIP_LRC).rely(OSM_MOM);
        OsmAbstract(PIP_LRC).kiss(MCD_SPOT);
        OsmAbstract(PIP_LRC).kiss(MCD_END);
        OsmMomAbstract(OSM_MOM).setOsm(ilkLRCA, PIP_LRC);

        // src for below numbers: 
        // https://forum.makerdao.com/t/lrc-mip12c2-sp2-collateral-onboarding-risk-evaluation/3549
        VatAbstract(MCD_VAT).file( ilkLRCA, "line", 3 * MILLION * RAD    ); // 3m debt ceiling
        VatAbstract(MCD_VAT).file( ilkLRCA, "dust", 20 * RAD             ); // 20 Dai dust
        CatAbstract(MCD_CAT).file( ilkLRCA, "lump", 200 * THOUSAND * WAD ); // 200,000 lot size
        CatAbstract(MCD_CAT).file( ilkLRCA, "chop", 113 * RAY / 100      ); // 13% liq. penalty
        JugAbstract(MCD_JUG).file( ilkLRCA, "duty", THREE_PCT_RATE       ); // 3% stability fee

        FlipAbstract(MCD_FLIP_LRC_A).file("beg",  103 * WAD / 100   ); // 3% bid increase
        FlipAbstract(MCD_FLIP_LRC_A).file("ttl",  6 hours           ); // 6 hours ttl
        FlipAbstract(MCD_FLIP_LRC_A).file("tau",  6 hours           ); // 6 hours tau

        SpotAbstract(MCD_SPOT).file(ilkLRCA, "mat",  175 * RAY / 100     ); // 175% coll. ratio

        // immediately initial poke of OSM
        OsmAbstract(PIP_LRC).poke();
        SpotAbstract(MCD_SPOT).poke(ilkLRCA);
    }
}

contract DssSpell {
    DSPauseAbstract public pause = 
        DSPauseAbstract(0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189);
    address         public action;
    bytes32         public tag;
    uint256         public eta;
    bytes           public sig;
    uint256         public expiration;
    bool            public done;

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        // Extra window of 2 hours to get the spell set up in the Governance Portal and communicated
        expiration = now + 4 days + 2 hours; 
    }

    modifier officeHours {
        uint day = (now / 1 days + 3) % 7;
        require(day < 5, "Can only be cast on a weekday");
        uint hour = now / 1 hours % 24;
        require(hour >= 14 && hour < 21, "Outside office hours");
        _;
    }

    function description() public view returns (string memory) {
        return SpellAction(action).description();
    }

    function schedule() public {
        require(now <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = now + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }

    // removing office hours for kovan deploy
    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}

