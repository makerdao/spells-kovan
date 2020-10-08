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

interface FaucetAbstract {
    function setAmt(address, uint256) external;
}

contract SpellAction {
    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    //  against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/1.1.1/contracts.json

    address constant MCD_VAT         = 0xbA987bDB501d131f766fEe8180Da5d81b34b69d9;
    address constant MCD_CAT         = 0xdDb5F7A3A5558b9a6a1f3382BD75E2268d1c6958;
    address constant MCD_JUG         = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;
    address constant MCD_SPOT        = 0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D;
    address constant MCD_POT         = 0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb;
    address constant MCD_END         = 0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F;
    address constant FLIPPER_MOM     = 0x50dC6120c67E456AdA2059cfADFF0601499cf681;
    address constant OSM_MOM         = 0x5dA9D1C3d4f1197E5c52Ff963916Fe84D2F5d8f3;
    address constant ILK_REGISTRY    = 0xedE45A0522CA19e979e217064629778d6Cc2d9Ea;
    address constant FAUCET          = 0x57aAeAE905376a4B1899bA81364b4cE2519CBfB3;

    // COMP-A specific addresses
    address constant COMP            = 0x1dDe24ACE93F9F638Bfd6fCE1B38b842703Ea1Aa;
    address constant MCD_JOIN_COMP_A = 0x16D567c1F6824ffFC460A11d48F61E010ae43766;
    address constant MCD_FLIP_COMP_A = 0x2917a962BC45ED48497de85821bddD065794DF6C;
    address constant PIP_COMP        = 0xcc10b1C53f4BFFEE19d0Ad00C40D7E36a454D5c4;

    // LRC-A specific addresses
    address constant LRC             = 0xF070662e48843934b5415f150a18C250d4D7B8aB;
    address constant MCD_JOIN_LRC_A  = 0x436286788C5dB198d632F14A20890b0C4D236800;
    address constant MCD_FLIP_LRC_A  = 0xfC9496337538235669F4a19781234122c9455897;
    address constant PIP_LRC         = 0xcEE47Bb8989f625b5005bC8b9f9A0B0892339721;

    // LINK specific addresses
    address constant LINK            = 0xa36085F69e2889c224210F603D836748e7dC0088;
    address constant MCD_JOIN_LINK_A = 0xF4Df626aE4fb446e2Dcce461338dEA54d2b9e09b;
    address constant MCD_FLIP_LINK_A = 0xfbDCDF5Bd98f68cEfc3f37829189b97B602eCFF2;
    address constant PIP_LINK        = 0x20D5A457e49D05fac9729983d9701E0C3079Efac;

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
    // $ bc -l <<< 'scale=27; e( l(1.01)/(60 * 60 * 24 * 365) )'
    //
    uint256 constant   ZERO_PERCENT_RATE = 1000000000000000000000000000;
    uint256 constant    ONE_PERCENT_RATE = 1000000000315522921573372069;
    uint256 constant    TWO_PERCENT_RATE = 1000000000627937192491029810;
    uint256 constant  THREE_PERCENT_RATE = 1000000000937303470807876289;
    uint256 constant   FOUR_PERCENT_RATE = 1000000001243680656318820312;
    uint256 constant  EIGHT_PERCENT_RATE = 1000000002440418608258400030;
    uint256 constant TWELVE_PERCENT_RATE = 1000000003593629043335673582;
    uint256 constant  FIFTY_PERCENT_RATE = 1000000012857214317438491659;

    function execute() external {
        /*** Risk Parameter Adjustments ***/

        /*** ETH-A ***/
        // Set Stability Fee to 0%
        JugAbstract(MCD_JUG).drip("ETH-A");
        JugAbstract(MCD_JUG).file("ETH-A", "duty", ZERO_PERCENT_RATE);

        /*** BAT-A ***/
        // Set Stability Fee to 4%
        JugAbstract(MCD_JUG).drip("BAT-A");
        JugAbstract(MCD_JUG).file("BAT-A", "duty", FOUR_PERCENT_RATE);

        /*** USDC-A ***/
        // Set Stability Fee to 0%
        JugAbstract(MCD_JUG).drip("USDC-A");
        JugAbstract(MCD_JUG).file("USDC-A", "duty", FOUR_PERCENT_RATE);
        // Set Debt Ceiling to $400 million
        VatAbstract(MCD_VAT).file("USDC-A", "line", 400 * MILLION * RAD);
        // Set Liquidation Ratio to 101%
        SpotAbstract(MCD_SPOT).file("USDC-A", "mat", 101 * RAY / 100);

        /*** USDC-B ***/
        // Set Stability Fee to 50%
        JugAbstract(MCD_JUG).drip("USDC-B");
        JugAbstract(MCD_JUG).file("USDC-B", "duty", FIFTY_PERCENT_RATE);

        /*** WBTC-A ***/
        // Set Stability Fee to 4%
        JugAbstract(MCD_JUG).drip("WBTC-A");
        JugAbstract(MCD_JUG).file("WBTC-A", "duty", FOUR_PERCENT_RATE);

        /*** TUSD-A ***/
        // Set Stability Fee to 0%
        JugAbstract(MCD_JUG).drip("TUSD-A");
        JugAbstract(MCD_JUG).file("TUSD-A", "duty", FOUR_PERCENT_RATE);
        // Set Debt Ceiling to $400 million
        VatAbstract(MCD_VAT).file("TUSD-A", "line", 50 * MILLION * RAD);
        // Set Liquidation Ratio to 101%
        SpotAbstract(MCD_SPOT).file("TUSD-A", "mat", 101 * RAY / 100);

        /*** KNC-A ***/
        // Set Stability Fee to 4%
        JugAbstract(MCD_JUG).drip("KNC-A");
        JugAbstract(MCD_JUG).file("KNC-A", "duty", FOUR_PERCENT_RATE);

        /*** ZRX-A ***/
        // Set Stability Fee to 4%
        JugAbstract(MCD_JUG).drip("ZRX-A");
        JugAbstract(MCD_JUG).file("ZRX-A", "duty", FOUR_PERCENT_RATE);

        /*** MANA-A ***/
        // Set Stability Fee to 12%
        JugAbstract(MCD_JUG).drip("MANA-A");
        JugAbstract(MCD_JUG).file("MANA-A", "duty", TWELVE_PERCENT_RATE);

        /*** USDT-A ***/
        // Set Stability Fee to 8%
        JugAbstract(MCD_JUG).drip("USDT-A");
        JugAbstract(MCD_JUG).file("USDT-A", "duty", EIGHT_PERCENT_RATE);

        /*** PAXUSD-A ***/
        // Set Stability Fee to 0%
        JugAbstract(MCD_JUG).drip("PAXUSD-A");
        JugAbstract(MCD_JUG).file("PAXUSD-A", "duty", FOUR_PERCENT_RATE);
        // Set Debt Ceiling to $400 million
        VatAbstract(MCD_VAT).file("PAXUSD-A", "line", 30 * MILLION * RAD);
        // Set Liquidation Ratio to 101%
        SpotAbstract(MCD_SPOT).file("PAXUSD-A", "mat", 101 * RAY / 100);

        // Set the global debt ceiling
        VatAbstract(MCD_VAT).file("Line", 1196 * MILLION * RAD);


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
