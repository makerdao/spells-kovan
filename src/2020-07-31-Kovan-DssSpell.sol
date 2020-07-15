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
import "lib/dss-interfaces/src/dss/PotAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipperMomAbstract.sol";

contract SpellAction {
    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    string constant public description = "2020-07-27 MakerDAO Executive Spell";

    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    //  against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/1.0.8/contracts.json

    address constant public MCD_VAT             = 0xbA987bDB501d131f766fEe8180Da5d81b34b69d9;
    address constant public MCD_CAT             = 0x0511674A67192FE51e86fE55Ed660eB4f995BDd6;
    address constant public MCD_JUG             = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;
    address constant public MCD_POT             = 0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb;

    address constant public MCD_SPOT            = 0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D;
    address constant public MCD_END             = 0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F;
    address constant public FLIPPER_MOM         = 0xf3828caDb05E5F22844f6f9314D99516D68a0C84;

    // LEND specific addresses
    address constant public MCD_JOIN_LEND_A     = 0x0Dd1a7BD9BB1E81935AC128D9af48e1288cBb2f8;
    address constant public PIP_LEND            = 0x03E4D947888AADC7ab2BB39785EE806274d46810;
    address constant public MCD_FLIP_LEND_A     = 0xf97CDb0432943232B0b98a790492a3344eCB5256;

    // decimals & precision
    uint256 constant public THOUSAND            = 10 ** 3;
    uint256 constant public MILLION             = 10 ** 6;
    uint256 constant public WAD                 = 10 ** 18;
    uint256 constant public RAY                 = 10 ** 27;
    uint256 constant public RAD                 = 10 ** 45;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    uint256 constant public SIX_PCT_RATE        = 1000000001847694957439350562;

    function execute() external {

        PotAbstract(MCD_POT).drip();
        JugAbstract(MCD_JUG).drip("ETH-A");
        JugAbstract(MCD_JUG).drip("BAT-A");
        JugAbstract(MCD_JUG).drip("USDC-A");
        JugAbstract(MCD_JUG).drip("USDC-B");
        JugAbstract(MCD_JUG).drip("WBTC-A");
        JugAbstract(MCD_JUG).drip("ZRX-A");
        JugAbstract(MCD_JUG).drip("KNC-A");
        JugAbstract(MCD_JUG).drip("TUSD-A");

        ////////////////////////////////////////////////////////////////////////////////
        // GLOBAL 

        // set the global debt ceiling to TODO: ???
        // VatAbstract(MCD_VAT).file("Line", 246 * MILLION * RAD);

        ////////////////////////////////////////////////////////////////////////////////
        // LEND-A 

        // set ilk bytes32 variable
        bytes32 constant LEND_A_ILK = "LEND-A";

        // Init USDC-B in Vat & Jug
        VatAbstract(MCD_VAT).init(LEND_A_ILK);
        JugAbstract(MCD_JUG).init(LEND_A_ILK);

        // Allow LEND-A Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_LEND_A);

        // set price feed for LEND-A
        SpotAbstract(MCD_SPOT).file(LEND_A_ILK, "pip", PIP_USDC);

        // set the USDC-B flipper in the cat
        CatAbstract(MCD_CAT).file(LEND_A_ILK, "flip", MCD_FLIP_LEND_A);

        // Allow cat to kick auctions in USDC-B Flipper 
        // NOTE: this will be reverse later in spell, and is done only for explicitness.
        FlipAbstract(MCD_FLIP_LEND_A).rely(MCD_CAT);

        // Allow End to yank auctions in USDC-B Flipper
        FlipAbstract(MCD_FLIP_LEND_A).rely(MCD_END);

        // Allow FlipperMom to access the USDC-B Flipper
        FlipAbstract(MCD_FLIP_LEND_A).rely(FLIPPER_MOM);

        VatAbstract(MCD_VAT).file(LEND_A_ILK,   "line"  , 1 * MILLION * RAD    ); // 1 MM debt ceiling
        VatAbstract(MCD_VAT).file(LEND_A_ILK,   "dust"  , 20 * RAD             ); // 20 Dai dust
        CatAbstract(MCD_CAT).file(LEND_A_ILK,   "lump"  , 200 * THOUSAND * WAD ); // 200,000 lot size
        CatAbstract(MCD_CAT).file(LEND_A_ILK,   "chop"  , 113 * RAY / 100      ); // 13% liq. penalty
        JugAbstract(MCD_JUG).file(LEND_A_ILK,   "duty"  , SIX_PCT_RATE         ); // 6% stability fee
        FlipAbstract(MCD_FLIP_LEND_A).file(     "beg"   , 103 * WAD / 100      ); // 3% bid increase
        FlipAbstract(MCD_FLIP_LEND_A).file(     "ttl"   , 6 hours              ); // 6 hours ttl
        FlipAbstract(MCD_FLIP_LEND_A).file(     "tau"   , 6 hours              ); // 3 days tau
        SpotAbstract(MCD_SPOT).file(LEND_A_ILK, "mat"   , 120 * RAY / 100      ); // 120% coll. ratio
        SpotAbstract(MCD_SPOT).poke(LEND_A_ILK);

        // consequently, deny USDC-A Flipper
        FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_LEND_A);

    }
}

contract DssSpell {
    DSPauseAbstract  public pause =
        DSPauseAbstract(0xbE286431454714F511008713973d3B053A2d38f3);
    address          public action;
    bytes32          public tag;
    uint256          public eta;
    bytes            public sig;
    uint256          public expiration;
    bool             public done;

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        expiration = now + 30 days;
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

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}

