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

import "lib/dss-interfaces/src/Interfaces.sol";

contract SpellAction {
    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    //  against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/1.1.1/contracts.json

    address constant public MCD_VAT         = 0xbA987bDB501d131f766fEe8180Da5d81b34b69d9;
    address constant public MCD_CAT         = 0xdDb5F7A3A5558b9a6a1f3382BD75E2268d1c6958;
    address constant public MCD_JUG         = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;
    address constant public MCD_POT         = 0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb;

    address constant public MCD_SPOT        = 0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D;
    address constant public MCD_END         = 0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F;
    address constant public FLIPPER_MOM     = 0x50dC6120c67E456AdA2059cfADFF0601499cf681;
    address constant public OSM_MOM         = 0x5dA9D1C3d4f1197E5c52Ff963916Fe84D2F5d8f3;

    // COMP specific addresses
    // COMP token address 0x1dDe24ACE93F9F638Bfd6fCE1B38b842703Ea1Aa
    address constant public MCD_JOIN_COMP_A = 0x16D567c1F6824ffFC460A11d48F61E010ae43766;
    address constant public PIP_COMP        = 0x08F29dCC1f4e6FD194c163FC9398742B3fF2BbE0;
    address constant public MCD_FLIP_COMP_A = 0x2917a962BC45ED48497de85821bddD065794DF6C;
    address constant public COMP            = 0x1dDe24ACE93F9F638Bfd6fCE1B38b842703Ea1Aa;

    // Decimals & precision
    uint256 constant public THOUSAND = 10 ** 3;
    uint256 constant public MILLION  = 10 ** 6;
    uint256 constant public WAD      = 10 ** 18;
    uint256 constant public RAY      = 10 ** 27;
    uint256 constant public RAD      = 10 ** 45;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.01)/(60 * 60 * 24 * 365) )'
    //
    uint256 constant public ONE_PERCENT_RATE = 1000000000315522921573372069;

    function execute() external {
        // Set the global debt ceiling to
        VatAbstract(MCD_VAT).file("Line", VatAbstract(MCD_VAT).Line() + 7 * MILLION * RAD);

        // Set ilk bytes32 variable
        bytes32 COMP_A_ILK = "COMP-A";

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_COMP_A).vat() == MCD_VAT,    "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_COMP_A).ilk() == COMP_A_ILK, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_COMP_A).gem() == COMP,       "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_COMP_A).dec() == 18,         "join-dec-not-match");
        require(FlipAbstract(MCD_FLIP_COMP_A).vat() == MCD_VAT,       "flip-vat-not-match");
        require(FlipAbstract(MCD_FLIP_COMP_A).cat() == MCD_CAT,       "flip-cat-not-match");
        require(FlipAbstract(MCD_FLIP_COMP_A).ilk() == COMP_A_ILK,    "flip-ilk-not-match");

        // Set price feed for COMP-A
        SpotAbstract(MCD_SPOT).file(COMP_A_ILK, "pip", PIP_COMP);

        // Set the COMP-A flipper in the cat
        CatAbstract(MCD_CAT).file(COMP_A_ILK, "flip", MCD_FLIP_COMP_A);

        // Init COMP-A in Vat & Jug
        VatAbstract(MCD_VAT).init(COMP_A_ILK);
        JugAbstract(MCD_JUG).init(COMP_A_ILK);

        // Allow COMP-A Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_COMP_A);

        // Allow cat to kick auctions in COMP-A Flipper
        // NOTE: this will be reverse later in spell, and is done only for explicitness.
        FlipAbstract(MCD_FLIP_COMP_A).rely(MCD_CAT);

        // Allow End to yank auctions in COMP-A Flipper
        FlipAbstract(MCD_FLIP_COMP_A).rely(MCD_END);

        // Allow FlipperMom to access the COMP-A Flipper
        FlipAbstract(MCD_FLIP_COMP_A).rely(FLIPPER_MOM);

        // Update OSM (TODO: Add back once real PIP is deployed)
        // MedianAbstract(OsmAbstract(PIP_COMP).src()).kiss(PIP_COMP);
        // OsmAbstract(PIP_COMP).rely(OSM_MOM);
        // OsmAbstract(PIP_COMP).kiss(MCD_SPOT);
        // OsmAbstract(PIP_COMP).kiss(MCD_END);
        // OsmMomAbstract(OSM_MOM).setOsm(COMP_A_ILK, PIP_COMP);

        VatAbstract(MCD_VAT).file(COMP_A_ILK,   "line"  , 7 * MILLION * RAD    ); // 7 MM debt ceiling
        VatAbstract(MCD_VAT).file(COMP_A_ILK,   "dust"  , 100 * RAD            ); // 100 Dai dust
        CatAbstract(MCD_CAT).file(COMP_A_ILK,   "dunk"  , 500 * RAD            ); // 500 dunk
        CatAbstract(MCD_CAT).file(COMP_A_ILK,   "chop"  , 113 * WAD / 100      ); // 13% liq. penalty
        JugAbstract(MCD_JUG).file(COMP_A_ILK,   "duty"  , ONE_PERCENT_RATE     ); // 1% stability fee
        FlipAbstract(MCD_FLIP_COMP_A).file(     "beg"   , 103 * WAD / 100      ); // 3% bid increase
        FlipAbstract(MCD_FLIP_COMP_A).file(     "ttl"   , 1 hours              ); // 1 hours ttl
        FlipAbstract(MCD_FLIP_COMP_A).file(     "tau"   , 1 hours              ); // 1 hours tau
        SpotAbstract(MCD_SPOT).file(COMP_A_ILK, "mat"   , 175 * RAY / 100      ); // 175% coll. ratio
        SpotAbstract(MCD_SPOT).poke(COMP_A_ILK);

        // Execute the first poke in the Osm for the next value (TODO: Add back once real PIP is used)
        // OsmAbstract(PIP_COMP).poke();

        // Update COMP-A spot value in Vat
        SpotAbstract(MCD_SPOT).poke(COMP_A_ILK);
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
