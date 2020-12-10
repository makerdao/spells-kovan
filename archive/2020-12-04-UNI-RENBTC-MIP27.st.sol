pragma solidity 0.5.12;

import "ds-math/math.sol";
import "ds-test/test.sol";
import "lib/dss-interfaces/src/Interfaces.sol";
import "./test/rates.sol";

import {DssSpell, SpellAction} from "./Kovan-DssSpell.sol";

interface Hevm {
    function warp(uint) external;
    function store(address,bytes32,bytes32) external;
}

contract DssSpellTest is DSTest, DSMath {
    // populate with kovan spell if needed
    address constant KOVAN_SPELL = address(0x5788c625cCE1Faf2f40679351eb8b11ac1c3E7f2);
    // this needs to be updated
    uint256 constant SPELL_CREATED = 1607573512;

    struct CollateralValues {
        bool aL_enabled;
        uint256 aL_line;
        uint256 aL_gap;
        uint256 aL_ttl;
        uint256 line;
        uint256 dust;
        uint256 chop;
        uint256 dunk;
        uint256 pct;
        uint256 mat;
        uint256 beg;
        uint48 ttl;
        uint48 tau;
        uint256 liquidations;
    }

    struct SystemValues {
        uint256 pot_dsr;
        uint256 vat_Line;
        uint256 pause_delay;
        uint256 vow_wait;
        uint256 vow_dump;
        uint256 vow_sump;
        uint256 vow_bump;
        uint256 vow_hump;
        uint256 cat_box;
        uint256 ilk_count;
        address pause_authority;
        address osm_mom_authority;
        address flipper_mom_authority;
        mapping (bytes32 => CollateralValues) collaterals;
    }

    SystemValues afterSpell;

    Hevm hevm;
    Rates rates;

    // KOVAN ADDRESSES
    ChainlogAbstract changelog   = ChainlogAbstract(   0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);
    DSPauseAbstract      pause   = DSPauseAbstract(    0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189);
    address         pauseProxy   =                     0x0e4725db88Bb038bBa4C4723e91Ba183BE11eDf3;
    DSChiefAbstract      chief   = DSChiefAbstract(    0x27E0c9567729Ea6e3241DE74B3dE499b7ddd3fe6);
    VatAbstract            vat   = VatAbstract(        0xbA987bDB501d131f766fEe8180Da5d81b34b69d9);
    CatAbstract            cat   = CatAbstract(        0xdDb5F7A3A5558b9a6a1f3382BD75E2268d1c6958);
    VowAbstract            vow   = VowAbstract(        0x0F4Cbe6CBA918b7488C26E29d9ECd7368F38EA3b);
    PotAbstract            pot   = PotAbstract(        0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb);
    JugAbstract            jug   = JugAbstract(        0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD);
    SpotAbstract          spot   = SpotAbstract(       0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D);

    DSTokenAbstract        gov   = DSTokenAbstract(    0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD);
    EndAbstract            end   = EndAbstract(        0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F);
    IlkRegistryAbstract    reg   = IlkRegistryAbstract(0xedE45A0522CA19e979e217064629778d6Cc2d9Ea);

    OsmMomAbstract      osmMom   = OsmMomAbstract(     0x5dA9D1C3d4f1197E5c52Ff963916Fe84D2F5d8f3);
    FlipperMomAbstract flipMom   = FlipperMomAbstract( 0x50dC6120c67E456AdA2059cfADFF0601499cf681);
    DssAutoLineAbstract autoLine = DssAutoLineAbstract(0xe7D7d61c0ed9306B6c93E7C65F6C9DDF38b9320b);

    // Faucet
    FaucetAbstract      faucet   = FaucetAbstract(     0x57aAeAE905376a4B1899bA81364b4cE2519CBfB3);

    // UNI-A specific
    DSTokenAbstract       uni = DSTokenAbstract(       0x0C527850e5D6B2B406F1d65895d5b17c5A29Ce51);
    GemJoinAbstract  joinUNIA = GemJoinAbstract(       0xb6E6EE050B4a74C8cc1DfdE62cAC8C6d9D8F4CAa);
    FlipAbstract     flipUNIA = FlipAbstract(          0x6EE8a47eA5d7cF0C951eDc57141Eb9593A36e680);
    OsmAbstract        pipUNI = OsmAbstract(           0xe573a75BF4827658F6D600FD26C205a3fe34ee28);
    MedianAbstract    medUNIA = MedianAbstract(        0x8Bc53b706D5e20Ee3d8b9B68DE326B1953b11cC1);

    // Specific for this spell
    DSTokenAbstract       renbtc = DSTokenAbstract(    0xe3dD56821f8C422849AF4816fE9B3c53c6a2F0Bd);
    GemJoinAbstract  joinRENBTCA = GemJoinAbstract(    0x12F1F6c7E5fDF1B671CebFBDE974341847d0Caa4);
    FlipAbstract     flipRENBTCA = FlipAbstract(       0x2a2E2436370e98505325111A6b98F63d158Fedc4);
    OsmAbstract        pipRENBTC = OsmAbstract(        0x2f38a1bD385A9B395D01f2Cbf767b4527663edDB);
    // OsmAbstract        medRENBTC = MedianAbstract(     0x229508e7b3d18063CF8248f03CBbEd94e27Ec3da);

    DssSpell spell;

    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE =
        bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    uint256 constant HUNDRED    = 10 ** 2;
    uint256 constant THOUSAND   = 10 ** 3;
    uint256 constant MILLION    = 10 ** 6;
    uint256 constant BILLION    = 10 ** 9;
    uint256 constant WAD        = 10 ** 18;
    uint256 constant RAY        = 10 ** 27;
    uint256 constant RAD        = 10 ** 45;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.01)/(60 * 60 * 24 * 365) )'
    //
    // Rates table is in ./test/rates.sol

    // not provided in DSMath
    function rpow(uint x, uint n, uint b) internal pure returns (uint z) {
      assembly {
        switch x case 0 {switch n case 0 {z := b} default {z := 0}}
        default {
          switch mod(n, 2) case 0 { z := b } default { z := x }
          let half := div(b, 2)  // for rounding.
          for { n := div(n, 2) } n { n := div(n,2) } {
            let xx := mul(x, x)
            if iszero(eq(div(xx, x), x)) { revert(0,0) }
            let xxRound := add(xx, half)
            if lt(xxRound, xx) { revert(0,0) }
            x := div(xxRound, b)
            if mod(n,2) {
              let zx := mul(z, x)
              if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
              let zxRound := add(zx, half)
              if lt(zxRound, zx) { revert(0,0) }
              z := div(zxRound, b)
            }
          }
        }
      }
    }
    // 10^-5 (tenth of a basis point) as a RAY
    uint256 TOLERANCE = 10 ** 22;

    function yearlyYield(uint256 duty) public pure returns (uint256) {
        return rpow(duty, (365 * 24 * 60 *60), RAY);
    }

    function expectedRate(uint256 percentValue) public pure returns (uint256) {
        return (10000 + percentValue) * (10 ** 23);
    }

    function diffCalc(uint256 expectedRate_, uint256 yearlyYield_) public pure returns (uint256) {
        return (expectedRate_ > yearlyYield_) ? expectedRate_ - yearlyYield_ : yearlyYield_ - expectedRate_;
    }

    function setUp() public {
        hevm = Hevm(address(CHEAT_CODE));
        rates = new Rates();

        spell = KOVAN_SPELL != address(0) ? DssSpell(KOVAN_SPELL) : new DssSpell();

        //
        // Test for all system configuration changes
        //
        afterSpell = SystemValues({
            pot_dsr:               0,                   // In basis points
            vat_Line:              1244 * MILLION,      // In whole Dai units
            pause_delay:           60,                  // In seconds
            vow_wait:              3600,                // In seconds
            vow_dump:              2,                   // In whole Dai units
            vow_sump:              50,                  // In whole Dai units
            vow_bump:              10,                  // In whole Dai units
            vow_hump:              500,                 // In whole Dai units
            cat_box:               10 * THOUSAND,       // In whole Dai units
            ilk_count:             20,                  // Num expected in system
            pause_authority:       address(chief),      // Pause authority
            osm_mom_authority:     address(chief),      // OsmMom authority
            flipper_mom_authority: address(chief)       // FlipperMom authority
        });

        //
        // Test for all collateral based changes here
        //
        afterSpell.collaterals["ETH-A"] = CollateralValues({
            aL_enabled:   false,           // DssAutoLine is enabled?
            aL_line:      0 * MILLION,     // In whole Dai units
            aL_gap:       0 * MILLION,     // In whole Dai units
            aL_ttl:       0,               // In seconds
            line:         540 * MILLION,   // In whole Dai units
            dust:         100,             // In whole Dai units
            pct:          0,               // In basis points
            chop:         1300,            // In basis points
            dunk:         500,             // In whole Dai units
            mat:          15000,           // In basis points
            beg:          300,             // In basis points
            ttl:          1 hours,         // In seconds
            tau:          1 hours,         // In seconds
            liquidations: 1                // 1 if enabled
        });
        afterSpell.collaterals["ETH-B"] = CollateralValues({
            aL_enabled:   true,
            aL_line:      50 * MILLION,
            aL_gap:       5 * MILLION,
            aL_ttl:       12 hours,
            line:         0 * MILLION,     // Not being checked as there is auto line
            dust:         100,
            pct:          600,
            chop:         1300,
            dunk:         500,
            mat:          13000,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["BAT-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         5 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          15000,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["USDC-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         400 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          10100,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["USDC-B"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         30 * MILLION,
            dust:         100,
            pct:          5000,
            chop:         1300,
            dunk:         500,
            mat:          12000,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["WBTC-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         120 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          15000,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["TUSD-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         50 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          10100,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["KNC-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         5 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["ZRX-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         5 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["MANA-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         1 * MILLION,
            dust:         100,
            pct:          1200,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["USDT-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         10 * MILLION,
            dust:         100,
            pct:          800,
            chop:         1300,
            dunk:         500,
            mat:          15000,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["PAXUSD-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         30 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          10100,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["COMP-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         7 * MILLION,
            dust:         100,
            pct:          100,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["LRC-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         3 * MILLION,
            dust:         100,
            pct:          300,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["LINK-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         5 * MILLION,
            dust:         100,
            pct:          200,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["BAL-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         4 * MILLION,
            dust:         100,
            pct:          500,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["YFI-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         7 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["GUSD-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         5 * MILLION,
            dust:         100,
            pct:          400,
            chop:         1300,
            dunk:         500,
            mat:          10100,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 0
        });
        afterSpell.collaterals["UNI-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         15 * MILLION,
            dust:         100,
            pct:          300,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
        afterSpell.collaterals["RENBTC-A"] = CollateralValues({
            aL_enabled:   false,
            aL_line:      0 * MILLION,
            aL_gap:       0 * MILLION,
            aL_ttl:       0,
            line:         2 * MILLION,
            dust:         100,
            pct:          600,
            chop:         1300,
            dunk:         500,
            mat:          17500,
            beg:          300,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });
    }

    function vote() private {
        if (chief.hat() != address(spell)) {
            hevm.store(
                address(gov),
                keccak256(abi.encode(address(this), uint256(1))),
                bytes32(uint256(999999999999 ether))
            );
            gov.approve(address(chief), uint256(-1));
            chief.lock(999999999999 ether);

            address[] memory slate = new address[](1);

            if (chief.live() == 0) {
                // Launch system
                slate[0] = address(0);
                chief.vote(slate);
                if (chief.hat() != address(0)) {
                    chief.lift(address(0));
                }
                assertEq(chief.live(), 0);
                assertTrue(!chief.isUserRoot(address(0)));
                chief.launch();
                assertEq(chief.live(), 1);
                assertTrue(chief.isUserRoot(address(0)));
            }

            assertTrue(!spell.done());

            slate[0] = address(spell);

            chief.vote(slate);
            chief.lift(address(spell));
        }
        assertEq(chief.hat(), address(spell));
    }

    function scheduleWaitAndCast() public {
        spell.schedule();

        uint256 castTime = now + pause.delay();

        uint256 day = (castTime / 1 days + 3) % 7;
        if(day >= 5) {
            castTime += 7 days - day * 86400;
        }

        uint256 hour = castTime / 1 hours % 24;
        if (hour >= 21) {
            castTime += 24 hours - hour * 3600 + 14 hours;
        } else if (hour < 14) {
            castTime += 14 hours - hour * 3600;
        }

        hevm.warp(castTime);
        spell.cast();
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function checkSystemValues(SystemValues storage values) internal {
        // dsr
        uint expectedDSRRate = rates.rates(values.pot_dsr);
        // make sure dsr is less than 100% APR
        // bc -l <<< 'scale=27; e( l(2.00)/(60 * 60 * 24 * 365) )'
        // 1000000021979553151239153027
        assertTrue(
            pot.dsr() >= RAY && pot.dsr() < 1000000021979553151239153027
        );
        assertTrue(diffCalc(expectedRate(values.pot_dsr), yearlyYield(expectedDSRRate)) <= TOLERANCE);

        {
        // Line values in RAD
        uint normalizedLine = values.vat_Line * RAD;
        assertEq(vat.Line(), normalizedLine);
        assertTrue(
            (vat.Line() >= RAD && vat.Line() < 100 * BILLION * RAD) ||
            vat.Line() == 0
        );
        }

        // Pause delay
        assertEq(pause.delay(), values.pause_delay);

        // wait
        assertEq(vow.wait(), values.vow_wait);
        {
        // dump values in WAD
        uint normalizedDump = values.vow_dump * WAD;
        assertEq(vow.dump(), normalizedDump);
        assertTrue(
            (vow.dump() >= WAD && vow.dump() < 2 * THOUSAND * WAD) ||
            vow.dump() == 0
        );
        }
        {
        // sump values in RAD
        uint normalizedSump = values.vow_sump * RAD;
        assertEq(vow.sump(), normalizedSump);
        assertTrue(
            (vow.sump() >= RAD && vow.sump() < 500 * THOUSAND * RAD) ||
            vow.sump() == 0
        );
        }
        {
        // bump values in RAD
        uint normalizedBump = values.vow_bump * RAD;
        assertEq(vow.bump(), normalizedBump);
        assertTrue(
            (vow.bump() >= RAD && vow.bump() < HUNDRED * THOUSAND * RAD) ||
            vow.bump() == 0
        );
        }
        {
        // hump values in RAD
        uint normalizedHump = values.vow_hump * RAD;
        assertEq(vow.hump(), normalizedHump);
        assertTrue(
            (vow.hump() >= RAD && vow.hump() < HUNDRED * MILLION * RAD) ||
            vow.hump() == 0
        );
        }

        // box values in RAD
        {
            uint normalizedBox = values.cat_box * RAD;
            assertEq(cat.box(), normalizedBox);
        }

        // check number of ilks
        assertEq(reg.count(), values.ilk_count);

        // check Pause authority
        assertEq(pause.authority(), values.pause_authority);

        // check OsmMom authority
        assertEq(osmMom.authority(), values.osm_mom_authority);

        // check FlipperMom authority
        assertEq(flipMom.authority(), values.flipper_mom_authority);
    }

    function checkCollateralValues(SystemValues storage values) internal {
        uint256 sumlines;
        bytes32[] memory ilks = reg.list();
        for(uint256 i = 0; i < ilks.length; i++) {
            bytes32 ilk = ilks[i];
            (uint256 duty,)  = jug.ilks(ilk);

            assertEq(duty, rates.rates(values.collaterals[ilk].pct));
            // make sure duty is less than 1000% APR
            // bc -l <<< 'scale=27; e( l(10.00)/(60 * 60 * 24 * 365) )'
            // 1000000073014496989316680335
            assertTrue(duty >= RAY && duty < 1000000073014496989316680335);  // gt 0 and lt 1000%
            assertTrue(diffCalc(expectedRate(values.collaterals[ilk].pct), yearlyYield(rates.rates(values.collaterals[ilk].pct))) <= TOLERANCE);
            assertTrue(values.collaterals[ilk].pct < THOUSAND * THOUSAND);   // check value lt 1000%
            {
            (,,, uint256 line, uint256 dust) = vat.ilks(ilk);
            // Convert whole Dai units to expected RAD
            uint256 normalizedTestLine = values.collaterals[ilk].line * RAD;
            sumlines += values.collaterals[ilk].line;
            (uint256 aL_line, uint256 aL_gap, uint256 aL_ttl,,) = autoLine.ilks(ilk);
            if (!values.collaterals[ilk].aL_enabled) {
                assertTrue(aL_line == 0);
                assertEq(line, normalizedTestLine);
                assertTrue((line >= RAD && line < BILLION * RAD) || line == 0);  // eq 0 or gt eq 1 RAD and lt 1B
            } else {
                assertTrue(aL_line > 0);
                assertEq(aL_line, values.collaterals[ilk].aL_line * RAD);
                assertEq(aL_gap, values.collaterals[ilk].aL_gap * RAD);
                assertEq(aL_ttl, values.collaterals[ilk].aL_ttl);
                assertTrue((aL_line >= RAD && aL_line < BILLION * RAD) || aL_line == 0);  // eq 0 or gt eq 1 RAD and lt 1B
            }
            uint256 normalizedTestDust = values.collaterals[ilk].dust * RAD;
            assertEq(dust, normalizedTestDust);
            assertTrue((dust >= RAD && dust < 10 * THOUSAND * RAD) || dust == 0); // eq 0 or gt eq 1 and lt 10k
            }
            {
            (, uint256 chop, uint256 dunk) = cat.ilks(ilk);
            // Convert BP to system expected value
            uint256 normalizedTestChop = (values.collaterals[ilk].chop * 10**14) + WAD;
            assertEq(chop, normalizedTestChop);
            // make sure chop is less than 100%
            assertTrue(chop >= WAD && chop < 2 * WAD);   // penalty gt eq 0% and lt 100%
            // Convert whole Dai units to expected RAD
            uint256 normalizedTestDunk = values.collaterals[ilk].dunk * RAD;
            assertEq(dunk, normalizedTestDunk);
            // put back in after LIQ-1.2
            assertTrue(dunk >= RAD && dunk < MILLION * RAD);
            }
            {
            (,uint256 mat) = spot.ilks(ilk);
            // Convert BP to system expected value
            uint256 normalizedTestMat = (values.collaterals[ilk].mat * 10**23);
            assertEq(mat, normalizedTestMat);
            assertTrue(mat >= RAY && mat < 10 * RAY);    // cr eq 100% and lt 1000%
            }
            {
            (address flipper,,) = cat.ilks(ilk);
            FlipAbstract flip = FlipAbstract(flipper);
            // Convert BP to system expected value
            uint256 normalizedTestBeg = (values.collaterals[ilk].beg + 10000)  * 10**14;
            assertEq(uint256(flip.beg()), normalizedTestBeg);
            assertTrue(flip.beg() >= WAD && flip.beg() < 105 * WAD / 100);  // gt eq 0% and lt 5%
            assertEq(uint256(flip.ttl()), values.collaterals[ilk].ttl);
            assertTrue(flip.ttl() >= 600 && flip.ttl() < 10 hours);         // gt eq 10 minutes and lt 10 hours
            assertEq(uint256(flip.tau()), values.collaterals[ilk].tau);
            assertTrue(flip.tau() >= 600 && flip.tau() <= 3 days);          // gt eq 10 minutes and lt eq 3 days

            assertEq(flip.wards(address(cat)), values.collaterals[ilk].liquidations);  // liquidations == 1 => on
            // assertEq(flip.wards(address(makerDeployer06)), 0); // Check deployer denied
            assertEq(flip.wards(address(pauseProxy)), 1); // Check pause_proxy ward
            }
            {
            GemJoinAbstract join = GemJoinAbstract(reg.join(ilk));
            // assertEq(join.wards(address(makerDeployer06)), 0); // Check deployer denied
            assertEq(join.wards(address(pauseProxy)), 1); // Check pause_proxy ward
            }
        }
        assertEq(sumlines, values.vat_Line);
    }

    function testSpellIsCast() public {
        string memory description = new DssSpell().description();
        assertTrue(bytes(description).length > 0);
        // DS-Test can't handle strings directly, so cast to a bytes32.
        assertEq(stringToBytes32(spell.description()),
                stringToBytes32(description));

        if(address(spell) != address(KOVAN_SPELL)) {
            assertEq(spell.expiration(), (now + 30 days));
        } else {
            assertEq(spell.expiration(), (SPELL_CREATED + 30 days));
        }

        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        checkSystemValues(afterSpell);

        checkCollateralValues(afterSpell);
    }

    function testSpellAutoLineAuth() public {
        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        assertEq(vat.wards(address(autoLine)), 1);
    }

    function testSpellIsCast_UNI_INTEGRATION() public {
       vote();
       scheduleWaitAndCast();
       assertTrue(spell.done());

       pipUNI.poke();
       hevm.warp(now + 3601);
       pipUNI.poke();
       spot.poke("UNI-A");

       // Check faucet amount
       uint256 faucetAmount = faucet.amt(address(uni));
       uint256 faucetAmountWad = faucetAmount * (10 ** (18 - uni.decimals()));
       assertTrue(faucetAmount > 0);
       faucet.gulp(address(uni));
       assertEq(uni.balanceOf(address(this)), faucetAmount);

       // Check median matches pip.src()
       assertEq(pipUNI.src(), address(medUNIA));

       // Authorization
       assertEq(joinUNIA.wards(pauseProxy), 1);
       assertEq(vat.wards(address(joinUNIA)), 1);
       assertEq(flipUNIA.wards(address(end)), 1);
       assertEq(flipUNIA.wards(address(flipMom)), 1);
       assertEq(pipUNI.wards(address(osmMom)), 1);
       assertEq(pipUNI.bud(address(spot)), 1);
       assertEq(pipUNI.bud(address(end)), 1);
       assertEq(MedianAbstract(pipUNI.src()).bud(address(pipUNI)), 1);

       // Join to adapter
       assertEq(vat.gem("UNI-A", address(this)), 0);
       uni.approve(address(joinUNIA), faucetAmount);
       joinUNIA.join(address(this), faucetAmount);
       assertEq(uni.balanceOf(address(this)), 0);
       assertEq(vat.gem("UNI-A", address(this)), faucetAmountWad);

       // Deposit collateral, generate DAI
       assertEq(vat.dai(address(this)), 0);
       vat.frob("UNI-A", address(this), address(this), address(this), int(faucetAmountWad), int(100 * WAD));
       assertEq(vat.gem("UNI-A", address(this)), 0);
       assertEq(vat.dai(address(this)), 100 * RAD);

       // Payback DAI, withdraw collateral
       vat.frob("UNI-A", address(this), address(this), address(this), -int(faucetAmountWad), -int(100 * WAD));
       assertEq(vat.gem("UNI-A", address(this)), faucetAmountWad);
       assertEq(vat.dai(address(this)), 0);

       // Withdraw from adapter
       joinUNIA.exit(address(this), faucetAmount);
       assertEq(uni.balanceOf(address(this)), faucetAmount);
       assertEq(vat.gem("UNI-A", address(this)), 0);

       // Generate new DAI to force a liquidation
       uni.approve(address(joinUNIA), faucetAmount);
       joinUNIA.join(address(this), faucetAmount);
       (,,uint256 spotV,,) = vat.ilks("UNI-A");
       // dart max amount of DAI
       vat.frob("UNI-A", address(this), address(this), address(this), int(faucetAmountWad), int(mul(faucetAmountWad, spotV) / RAY));
       hevm.warp(now + 1);
       jug.drip("UNI-A");
       assertEq(flipUNIA.kicks(), 0);
       cat.bite("UNI-A", address(this));
       assertEq(flipUNIA.kicks(), 1);
   }

    function testSpellIsCast_RENBTC_A_INTEGRATION() public {
        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        pipRENBTC.poke();
        hevm.warp(now + 3601);
        pipRENBTC.poke();
        spot.poke("RENBTC-A");

        // Check faucet amount
        uint256 faucetAmount = faucet.amt(address(renbtc));
        uint256 faucetAmountWad = faucetAmount * (10 ** (18 - renbtc.decimals()));
        assertTrue(faucetAmount > 0);
        faucet.gulp(address(renbtc));
        assertEq(renbtc.balanceOf(address(this)), faucetAmount);

        // Check median matches pip.src()
        // assertEq(pipRENBTC.src(), address(medRENBTC));

        // Authorization
        assertEq(joinRENBTCA.wards(pauseProxy), 1);
        assertEq(vat.wards(address(joinRENBTCA)), 1);
        assertEq(flipRENBTCA.wards(address(end)), 1);
        assertEq(flipRENBTCA.wards(address(flipMom)), 1);
        assertEq(pipRENBTC.wards(address(osmMom)), 1);
        assertEq(pipRENBTC.bud(address(spot)), 1);
        assertEq(pipRENBTC.bud(address(end)), 1);
        // assertEq(MedianAbstract(pipRENBTC.src()).bud(address(pipRENBTC)), 1);

        // Join to adapter
        assertEq(vat.gem("RENBTC-A", address(this)), 0);
        renbtc.approve(address(joinRENBTCA), faucetAmount);
        joinRENBTCA.join(address(this), faucetAmount);
        assertEq(renbtc.balanceOf(address(this)), 0);
        assertEq(vat.gem("RENBTC-A", address(this)), faucetAmountWad);

        // Deposit collateral, generate DAI
        assertEq(vat.dai(address(this)), 0);
        vat.frob("RENBTC-A", address(this), address(this), address(this), int(faucetAmountWad), int(100 * WAD));
        assertEq(vat.gem("RENBTC-A", address(this)), 0);
        assertEq(vat.dai(address(this)), 100 * RAD);

        // Payback DAI, withdraw collateral
        vat.frob("RENBTC-A", address(this), address(this), address(this), -int(faucetAmountWad), -int(100 * WAD));
        assertEq(vat.gem("RENBTC-A", address(this)), faucetAmountWad);
        assertEq(vat.dai(address(this)), 0);

        // Withdraw from adapter
        joinRENBTCA.exit(address(this), faucetAmount);
        assertEq(renbtc.balanceOf(address(this)), faucetAmount);
        assertEq(vat.gem("RENBTC-A", address(this)), 0);

        // Generate new DAI to force a liquidation
        renbtc.approve(address(joinRENBTCA), faucetAmount);
        joinRENBTCA.join(address(this), faucetAmount);
        (,,uint256 spotV,,) = vat.ilks("RENBTC-A");
        // dart max amount of DAI
        vat.frob("RENBTC-A", address(this), address(this), address(this), int(faucetAmountWad), int(mul(faucetAmountWad, spotV) / RAY));
        hevm.warp(now + 1);
        jug.drip("RENBTC-A");
        assertEq(flipRENBTCA.kicks(), 0);
        cat.bite("RENBTC-A", address(this));
        assertEq(flipRENBTCA.kicks(), 1);
    }

}
