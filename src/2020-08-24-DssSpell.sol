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

    // MAINNET ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    // against the current release list at:
    //     https://changelog.makerdao.com/releases/mainnet/1.0.9/contracts.json
    address constant MCD_VAT             = 0xbA987bDB501d131f766fEe8180Da5d81b34b69d9; // kovan
    address constant MCD_CAT             = 0x0511674A67192FE51e86fE55Ed660eB4f995BDd6;
    address constant MCD_JUG             = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;

    address constant MCD_SPOT            = 0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D;
    address constant MCD_END             = 0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F;
    address constant FLIPPER_MOM         = 0xf3828caDb05E5F22844f6f9314D99516D68a0C84;
    address constant OSM_MOM             = 0x5dA9D1C3d4f1197E5c52Ff963916Fe84D2F5d8f3;

    // TODO: update
    address constant MCD_JOIN_USDT_A     = ;
    address constant PIP_USDT            = ;
    address constant MCD_FLIP_USDT_A     = ;
    address constant USDT                = ;

    // Decimals & precision
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

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/cc819c75fc8f1b622cbe06acfd0d11bf64545622/governance/votes/Executive%20vote%20-%20July%2027%2C%202020%20.md -q -O - 2>/dev/null)"
    string constant public description =
        "2020-08-24 MakerDAO Executive Spell | Executive for August Governance Cycle | TODO ";

    function execute() external {
        // TODO: update
        VatAbstract(MCD_VAT).file("Line", VatAbstract(MCD_VAT).Line() + 41 * MILLION * RAD);

        // TODO: update
        bytes32 ilk = "ETH-A";
        VatAbstract(MCD_VAT).file(ilk, "line", 260 * MILLION * RAD); // 260 MM debt ceiling

        // Set ilk bytes32 variable
        ilk = "USDT-A";

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_USDT_A).vat() == MCD_VAT,  "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_USDT_A).ilk() == ilk,      "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_USDT_A).gem() == USDT,     "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_USDT_A).dec() == 18,       "join-dec-not-match");
        require(FlipAbstract(MCD_FLIP_USDT_A).vat()    == MCD_VAT,  "flip-vat-not-match");
        require(FlipAbstract(MCD_FLIP_USDT_A).ilk()    == ilk,      "flip-ilk-not-match");

        // Set price feed for USDT-A
        SpotAbstract(MCD_SPOT).file(ilk, "pip", PIP_USDT);

        // Set the USDT-A flipper in the cat
        CatAbstract(MCD_CAT).file(ilk, "flip", MCD_FLIP_USDT_A);

        // Init USDT-A in Vat & Jug
        VatAbstract(MCD_VAT).init(ilk);
        JugAbstract(MCD_JUG).init(ilk);

        // Allow USDT-A Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_USDT_A);

        // Allow cat to kick auctions in USDT-A Flipper
        FlipAbstract(MCD_FLIP_USDT_A).rely(MCD_CAT);

        // Allow End to yank auctions in USDT-A Flipper
        FlipAbstract(MCD_FLIP_USDT_A).rely(MCD_END);

        // Allow FlipperMom to access the USDT-A Flipper
        FlipAbstract(MCD_FLIP_USDT_A).rely(FLIPPER_MOM);

        // Update OSM
        MedianAbstract(OsmAbstract(PIP_USDT).src()).kiss(PIP_USDT);
        OsmAbstract(PIP_USDT).rely(OSM_MOM);
        OsmAbstract(PIP_USDT).kiss(MCD_SPOT);
        OsmAbstract(PIP_USDT).kiss(MCD_END);
        OsmMomAbstract(OSM_MOM).setOsm(ilk, PIP_USDT);

        VatAbstract(MCD_VAT).file( ilk, "line", 1 * MILLION * RAD    ); // 1m debt ceiling
        VatAbstract(MCD_VAT).file( ilk, "dust", 20 * RAD             ); // 20 Dai dust
        CatAbstract(MCD_CAT).file( ilk, "lump", 500 * THOUSAND * WAD ); // 500,000 lot size
        CatAbstract(MCD_CAT).file( ilk, "chop", 113 * RAY / 100      ); // 13% liq. penalty
        JugAbstract(MCD_JUG).file( ilk, "duty", TWELVE_PCT_RATE      ); // 12% stability fee

        FlipAbstract(MCD_FLIP_USDT_A).file("beg",  103 * WAD / 100   ); // 3% bid increase
        FlipAbstract(MCD_FLIP_USDT_A).file("ttl",  6 hours           ); // 6 hours ttl
        FlipAbstract(MCD_FLIP_USDT_A).file("tau",  6 hours           ); // 6 hours tau

        SpotAbstract(MCD_SPOT).file(ilk, "mat",  175 * RAY / 100     ); // 175% coll. ratio
        SpotAbstract(MCD_SPOT).poke(ilk);

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

