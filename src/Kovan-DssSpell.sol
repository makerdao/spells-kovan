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
import "lib/dss-interfaces/src/dss/CatAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipAbstract.sol";
import "lib/dss-interfaces/src/dss/IlkRegistryAbstract.sol";
import "lib/dss-interfaces/src/dss/GemJoinAbstract.sol";
import "lib/dss-interfaces/src/dss/JugAbstract.sol";
import "lib/dss-interfaces/src/dss/MedianAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmAbstract.sol";
import "lib/dss-interfaces/src/dss/OsmMomAbstract.sol";
import "lib/dss-interfaces/src/dss/SpotAbstract.sol";
import "lib/dss-interfaces/src/dss/VatAbstract.sol";
import "lib/dss-interfaces/src/dss/FaucetAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipperMomAbstract.sol";

interface PsmAbstract {
    function wards(address) external returns (uint256);
    function vat() external returns (address);
    function gemJoin() external returns (address);
    function dai() external returns (address);
    function daiJoin() external returns (address);
    function ilk() external returns (bytes32);
    function vow() external returns (address);
    function tin() external returns (uint256);
    function tout() external returns (uint256);
    function file(bytes32 what, uint256 data) external;
    function sellGem(address usr, uint256 gemAmt) external;
    function buyGem(address usr, uint256 gemAmt) external;
}

interface LerpAbstract {
    function wards(address) external returns (uint256);
    function target() external returns (address);
    function what() external returns (bytes32);
    function start() external returns (uint256);
    function end() external returns (uint256);
    function duration() external returns (uint256);
    function started() external returns (bool);
    function done() external returns (bool);
    function startTime() external returns (uint256);
    function init() external;
    function tick() external;
}

contract SpellAction {
    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    //  against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/1.1.3/contracts.json

    address constant MCD_VAT      = 0xbA987bDB501d131f766fEe8180Da5d81b34b69d9;
    address constant MCD_CAT      = 0xdDb5F7A3A5558b9a6a1f3382BD75E2268d1c6958;
    address constant MCD_JUG      = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;
    address constant MCD_SPOT     = 0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D;
    address constant MCD_POT      = 0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb;
    address constant MCD_END      = 0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F;
    address constant MCD_DAI      = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    address constant MCD_JOIN_DAI = 0x5AA71a3ae1C0bd6ac27A1f28e1415fFFB6F15B8c;
    address constant MCD_VOW      = 0x0F4Cbe6CBA918b7488C26E29d9ECd7368F38EA3b;
    address constant FLIPPER_MOM  = 0x50dC6120c67E456AdA2059cfADFF0601499cf681;
    address constant OSM_MOM      = 0x5dA9D1C3d4f1197E5c52Ff963916Fe84D2F5d8f3;
    address constant ILK_REGISTRY = 0xedE45A0522CA19e979e217064629778d6Cc2d9Ea;

    address constant FAUCET       = 0x57aAeAE905376a4B1899bA81364b4cE2519CBfB3;

    address constant USDC               = 0xBD84be3C303f6821ab297b840a99Bd0d4c4da6b5;
    address constant MCD_JOIN_USDC_PSM  = 0x882916CC149eB669F9e9240C001C8C90Ab37974c;
    address constant MCD_FLIP_USDC_PSM  = 0xA79F07275eA9080829e77F9f399F9f42bb79a58a;
    address constant MCD_PSM_USDC_PSM   = 0x8D1B119fA7492C8c5b4125B53a44EA8b0e83d5e8;
    address constant LERP               = 0x06b55F7DF03aC8B21cA472612419571cfCe854E5;
    address constant PIP_USDC           = 0x4c51c2584309b7BF328F89609FDd03B3b95fC677;

    uint256 constant THOUSAND = 10**3;
    uint256 constant MILLION = 10**6;
    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;
    uint256 constant RAD = 10**45;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    uint256 constant ZERO_PERCENT_RATE = 1000000000000000000000000000;

    function execute() external {
        bytes32 ilk = "PSM-USDC-A";

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_USDC_PSM).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_USDC_PSM).ilk() == ilk, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_USDC_PSM).gem() == USDC, "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_USDC_PSM).dec() == 6, "join-dec-not-match");
        require(FlipAbstract(MCD_FLIP_USDC_PSM).vat() == MCD_VAT, "flip-vat-not-match");
        require(FlipAbstract(MCD_FLIP_USDC_PSM).cat() == MCD_CAT, "flip-cat-not-match");
        require(FlipAbstract(MCD_FLIP_USDC_PSM).ilk() == ilk, "flip-ilk-not-match");
        require(PsmAbstract(MCD_PSM_USDC_PSM).vat() == MCD_VAT, "psm-vat-not-match");
        require(PsmAbstract(MCD_PSM_USDC_PSM).gemJoin() == MCD_JOIN_USDC_PSM, "psm-join-not-match");
        require(PsmAbstract(MCD_PSM_USDC_PSM).dai() == MCD_DAI, "psm-dai-not-match");
        require(PsmAbstract(MCD_PSM_USDC_PSM).daiJoin() == MCD_JOIN_DAI, "psm-dai-join-not-match");
        require(PsmAbstract(MCD_PSM_USDC_PSM).ilk() == ilk, "psm-ilk-not-match");
        require(PsmAbstract(MCD_PSM_USDC_PSM).vow() == MCD_VOW, "psm-vow-not-match");
        require(LerpAbstract(LERP).target() == MCD_PSM_USDC_PSM, "lerp-target-not-match");
        require(LerpAbstract(LERP).what() == "tin", "lerp-what-not-match");
        require(LerpAbstract(LERP).start() == 1 * WAD / 100, "lerp-start-not-match");
        require(LerpAbstract(LERP).end() == 1 * WAD / 1000, "lerp-end-not-match");
        require(LerpAbstract(LERP).duration() ==  7 days, "lerp-duration-not-match");
        require(!LerpAbstract(LERP).started(), "lerp-not-started");
        require(!LerpAbstract(LERP).done(), "lerp-not-done");

        // Set the USDC PIP in the Spotter
        SpotAbstract(MCD_SPOT).file(ilk, "pip", PIP_USDC);

        // Set the PSM-USDC-A Flipper in the Cat
        CatAbstract(MCD_CAT).file(ilk, "flip", MCD_FLIP_USDC_PSM);

        // Init PSM-USDC-A ilk in Vat & Jug
        // VatAbstract(MCD_VAT).init(ilk);
        JugAbstract(MCD_JUG).init(ilk);

        // Allow PSM-USDC-A Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_USDC_PSM);
        // Allow the PSM-USDC-A Flipper to reduce the Cat litterbox on deal()
        CatAbstract(MCD_CAT).rely(MCD_FLIP_USDC_PSM);
        // Allow Cat to kick auctions in PSM-USDC-A Flipper
        FlipAbstract(MCD_FLIP_USDC_PSM).rely(MCD_CAT);
        // Allow End to yank auctions in PSM-USDC-A Flipper
        FlipAbstract(MCD_FLIP_USDC_PSM).rely(MCD_END);
        // Allow FlipperMom to access to the PSM-USDC-A Flipper
        FlipAbstract(MCD_FLIP_USDC_PSM).rely(FLIPPER_MOM);
        // Disallow Cat to kick auctions in PSM-USDC-A Flipper
        // !!!!!!!! Only for certain collaterals that do not trigger liquidations like USDC-A)
        FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_USDC_PSM);

        // Allow OsmMom to access to the USDC Osm
        // !!!!!!!! Only if PIP_USDC = Osm and hasn't been already relied due a previous deployed ilk
        // OsmAbstract(PIP_USDC).rely(OSM_MOM);
        // Whitelist Osm to read the Median data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_USDC = Osm, its src is a Median and hasn't been already whitelisted due a previous deployed ilk
        // MedianAbstract(OsmAbstract(PIP_USDC).src()).kiss(PIP_USDC);
        // Whitelist Spotter to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_USDC = Osm or PIP_USDC = Median and hasn't been already whitelisted due a previous deployed ilk
        // OsmAbstract(PIP_USDC).kiss(MCD_SPOT);
        // Whitelist End to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_USDC = Osm or PIP_USDC = Median and hasn't been already whitelisted due a previous deployed ilk
        // OsmAbstract(PIP_USDC).kiss(MCD_END);
        // Set USDC Osm in the OsmMom for new ilk
        // !!!!!!!! Only if PIP_USDC = Osm
        // OsmMomAbstract(OSM_MOM).setOsm(ilk, PIP_USDC);

        // Set the global debt ceiling
        VatAbstract(MCD_VAT).file("Line", 1632 * MILLION * RAD);
        // Set the PSM-USDC-A debt ceiling
        VatAbstract(MCD_VAT).file(ilk, "line", 400 * MILLION * RAD);
        // Set the PSM-USDC-A dust
        VatAbstract(MCD_VAT).file(ilk, "dust", 10 * RAD);
        // Set the Lot size
        CatAbstract(MCD_CAT).file(ilk, "dunk", 500 * RAD);
        // Set the PSM-USDC-A liquidation penalty (e.g. 13% => X = 113)
        CatAbstract(MCD_CAT).file(ilk, "chop", 100 * WAD / 100);
        // Set the PSM-USDC-A stability fee (e.g. 1% = 1000000000315522921573372069)
        JugAbstract(MCD_JUG).drip(ilk);
        JugAbstract(MCD_JUG).file(ilk, "duty", ZERO_PERCENT_RATE);
        // Set the PSM-USDC-A percentage between bids (e.g. 3% => X = 103)
        FlipAbstract(MCD_FLIP_USDC_PSM).file("beg", 103 * WAD / 100);
        // Set the PSM-USDC-A time max time between bids
        FlipAbstract(MCD_FLIP_USDC_PSM).file("ttl", 1 hours);
        // Set the PSM-USDC-A max auction duration to
        FlipAbstract(MCD_FLIP_USDC_PSM).file("tau", 1 hours);
        // Set the PSM-USDC-A min collateralization ratio (e.g. 150% => X = 150)
        SpotAbstract(MCD_SPOT).file(ilk, "mat", 100 * RAY / 100);
        // Set the PSM-USDC-A fee in (tin)
        PsmAbstract(MCD_PSM_USDC_PSM).file("tin", 1 * WAD / 100);
        // Set the PSM-USDC-A fee out (tout)
        PsmAbstract(MCD_PSM_USDC_PSM).file("tout", 1 * WAD / 1000);

        // Update PSM-USDC-A spot value in Vat
        SpotAbstract(MCD_SPOT).poke(ilk);

        // Add new ilk to the IlkRegistry
        IlkRegistryAbstract(ILK_REGISTRY).add(MCD_JOIN_USDC_PSM);

        // Set gulp amount in faucet on kovan
        // FaucetAbstract(FAUCET).setAmt(YFI, 1 * WAD);

        // Initialize the lerp module to start the clock
        LerpAbstract(LERP).init();
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
