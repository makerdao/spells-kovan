pragma solidity 0.5.12;

import "ds-math/math.sol";
import "ds-test/test.sol";
import "lib/dss-interfaces/src/Interfaces.sol";

import {DssSpell, SpellAction} from "./2020-07-27-Kovan-DssSpell.sol";

contract Hevm {
    function warp(uint256) public;
}

contract FlipMomLike {
    function setOwner(address) external;
    function setAuthority(address) external;
    function rely(address) external;
    function deny(address) external;
    function authority() public returns (address);
    function owner() public returns (address);
    function cat() public returns (address);
}

contract DssSpellTest is DSTest, DSMath {
    // populate with mainnet spell if needed
    address constant MAINNET_SPELL = address(0);

    struct CollateralValues {
        uint256 line;
        uint256 dust;
        uint256 duty;
        uint256 chop;
        uint256 lump;
        uint256 pct;
        uint256 mat;
        uint256 beg;
        uint48 ttl;
        uint48 tau;
    }

    struct SystemValues {
        uint256 dsr;
        uint256 dsrPct;
        uint256 Line;
        uint256 pauseDelay;
        mapping (bytes32 => CollateralValues) collaterals;
    }

    // SystemValues beforeSpell;
    SystemValues afterSpell;

    Hevm hevm;

    // KOVAN ADDRESSES
    DSPauseAbstract pause       = DSPauseAbstract(0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189);
    address pauseProxy          =                 0x0e4725db88Bb038bBa4C4723e91Ba183BE11eDf3;
    DSChiefAbstract chief       = DSChiefAbstract(0xbBFFC76e94B34F72D96D054b31f6424249c1337d);
    VatAbstract     vat         = VatAbstract(    0xbA987bDB501d131f766fEe8180Da5d81b34b69d9);
    CatAbstract     cat         = CatAbstract(    0x0511674A67192FE51e86fE55Ed660eB4f995BDd6);
    PotAbstract     pot         = PotAbstract(    0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb);
    JugAbstract     jug         = JugAbstract(    0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD);
    SpotAbstract    spot        = SpotAbstract(   0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D);
    MKRAbstract     gov         = MKRAbstract(    0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD);

    FlipAbstract    flip        = FlipAbstract(   0xf97CDb0432943232B0b98a790492a3344eCB5256); // ?

    EndAbstract     end         = EndAbstract(    0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F);
    address  flipperMom         =                 0xf3828caDb05E5F22844f6f9314D99516D68a0C84;

    address constant public MCD_FLAP        = 0xc6d3C83A080e2Ef16E4d7d4450A869d0891024F5;
    address constant public MCD_FLOP        = 0x52482a3100F79FC568eb2f38C4a45ba457FBf5fA;
    address constant public MCD_FLAP_OLD    = 0x064cd5f762851b1af81Fd8fcA837227cb3eC84b4;
    address constant public MCD_FLOP_OLD    = 0x145B00b1AC4F01E84594EFa2972Fce1f5Beb5CED;

    address constant public ETH_A_FLIP      = 0xc78EdADA7e8bEa29aCc3a31bBA1D516339deD350;
    address constant public ETH_A_FLIP_OLD  = 0xB40139Ea36D35d0C9F6a2e62601B616F1FfbBD1b;

    address constant public BAT_A_FLIP      = 0xcf4D650679a23ec4027f6675c7245d02fbFc7Da3;
    address constant public BAT_A_FLIP_OLD  = 0xC94014A032cA5fCc01271F4519Add7E87a16b94C;

    address constant public USDC_A_FLIP     = 0x157c2552165fE6e1003981076eAA20F6e0a2B30F;
    address constant public USDC_A_FLIP_OLD = 0x45d5b4A304f554262539cfd167dd05e331Da686E;

    address constant public USDC_B_FLIP     = 0x8ceC95bB1758Ff2126e63a85ffC3C3c0F3717ea1;
    address constant public USDC_B_FLIP_OLD = 0x93AE217b0C6bF52E9FFea6Ab191cCD438d9EC0de;

    address constant public WBTC_A_FLIP     = 0x21926b5aeC6732B87985376cCb9308823E7e377b;
    address constant public WBTC_A_FLIP_OLD = 0xc45A1b76D3316D56a0225fB02Ab6b7637403fF67;

    address constant public ZRX_A_FLIP      = 0xdc181998D4d4aF194a16b59a3a018017F624D5C4;
    address constant public ZRX_A_FLIP_OLD  = 0x1341E0947D03Fd2C24e16aaEDC347bf9D9af002F;

    address constant public KNC_A_FLIP      = 0x675597341Cb21Bdbb69A5Aa18C9638eaa5DC06d6;
    address constant public KNC_A_FLIP_OLD  = 0xf14Ec3538C86A31bBf576979783a8F6dbF16d571;

    address constant public TUSD_A_FLIP     = 0x72bE7125B1CFf0dA9D6AD98e9e14d560F57FaAd2;
    address constant public TUSD_A_FLIP_OLD = 0x51a8fB578E830c932A2D49927584C643Ad08d9eC;

    DssSpell spell;

    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE =
        bytes20(uint160(uint256(keccak256('hevm cheat code'))));
    
    uint256 constant THOUSAND = 10 ** 3;
    uint256 constant MILLION  = 10 ** 6;
    uint256 constant WAD      = 10 ** 18;
    uint256 constant RAY      = 10 ** 27;
    uint256 constant RAD      = 10 ** 45;

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
        return (100000 + percentValue) * (10 ** 22);
    }

    function diffCalc(uint256 expectedRate_, uint256 yearlyYield_) public pure returns (uint256) {
        return (expectedRate_ > yearlyYield_) ? expectedRate_ - yearlyYield_ : yearlyYield_ - expectedRate_;
    }

    function setUp() public {
        hevm = Hevm(address(CHEAT_CODE));

        spell = MAINNET_SPELL != address(0) ? DssSpell(MAINNET_SPELL) : new DssSpell();

        afterSpell = SystemValues({
            dsr: 1000000000000000000000000000,
            dsrPct: 0 * 1000,
            Line: 172050 * THOUSAND * RAD,
            pauseDelay: 60
        });

        address[] memory newFlips = new address[](8);
        newFlips[0] = ETH_A_FLIP;
        newFlips[1] = BAT_A_FLIP;
        newFlips[2] = USDC_A_FLIP;
        newFlips[3] = USDC_B_FLIP;
        newFlips[4] = WBTC_A_FLIP;
        newFlips[5] = ZRX_A_FLIP;
        newFlips[6] = KNC_A_FLIP;
        newFlips[7] = TUSD_A_FLIP;

        address[] memory oldFlips = new address[](8);
        oldFlips[0] = ETH_A_FLIP_OLD;
        oldFlips[1] = BAT_A_FLIP_OLD;
        oldFlips[2] = USDC_A_FLIP_OLD;
        oldFlips[3] = USDC_B_FLIP_OLD;
        oldFlips[4] = WBTC_A_FLIP_OLD;
        oldFlips[5] = ZRX_A_FLIP_OLD;
        oldFlips[6] = KNC_A_FLIP_OLD;
        oldFlips[7] = TUSD_A_FLIP_OLD;
    }

    function vote() private {
        if (chief.hat() != address(spell)) {
            gov.approve(address(chief), uint256(-1));
            chief.lock(sub(gov.balanceOf(address(this)), 1 ether));

            assertTrue(!spell.done());

            address[] memory yays = new address[](1);
            yays[0] = address(spell);

            chief.vote(yays);
            chief.lift(address(spell));
        }
        assertEq(chief.hat(), address(spell));
    }

    function scheduleWaitAndCast() public {
        spell.schedule();
        hevm.warp(now + pause.delay());
        spell.cast();
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function checkSystemValues(SystemValues storage values) internal {
        // dsr
        assertEq(pot.dsr(), values.dsr);
        assertTrue(diffCalc(expectedRate(values.dsrPct), yearlyYield(values.dsr)) <= TOLERANCE);

        // Line
        assertEq(vat.Line(), values.Line);

        // Pause delay
        assertEq(pause.delay(), values.pauseDelay);                
    }

    function checkCollateralValues(bytes32 ilk, SystemValues storage values) internal {
        (uint duty,)  = jug.ilks(ilk);
        assertEq(duty,   values.collaterals[ilk].duty);
        assertTrue(diffCalc(expectedRate(values.collaterals[ilk].pct), yearlyYield(values.collaterals[ilk].duty)) <= TOLERANCE);

        (,,, uint256 line, uint256 dust) = vat.ilks(ilk);
        assertEq(line, values.collaterals[ilk].line);
        assertEq(dust, values.collaterals[ilk].dust);

        (, uint256 chop, uint256 lump) = cat.ilks(ilk);
        assertEq(chop, values.collaterals[ilk].chop);
        assertEq(lump, values.collaterals[ilk].lump);

        (,uint256 mat) = spot.ilks(ilk);
        assertEq(mat, values.collaterals[ilk].mat);

        // (address flipper,,) = cat.ilks(ilk);
        // FlipAbstract flip = FlipAbstract(flipper);
        assertEq(uint256(flip.beg()), values.collaterals[ilk].beg);
        assertEq(uint256(flip.ttl()), values.collaterals[ilk].ttl);
        assertEq(uint256(flip.tau()), values.collaterals[ilk].tau);
    }

    // function checkFlipValues(address flip, FlipValues storage values) internal {

    // }

    function testSpellIsCast() public {
        string memory description = new SpellAction().description();
        assertTrue(bytes(description).length > 0);
        // DS-Test can't handle strings directly, so cast to a bytes32.
        assertEq(stringToBytes32(spell.description()),
                stringToBytes32(description));

        if(address(spell) != address(MAINNET_SPELL)) {
            assertEq(spell.expiration(), (now + 30 days));
        } else {
            assertEq(spell.expiration(), (1590773091 + 30 days));
        }

        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        checkSystemValues(afterSpell);
    }

    function testFlips() public {
        vote();
        scheduleWaitAndCast();

        // spell done
        assertTrue(spell.done());

        // check flip parameters
        // checkFlipValues(afterSpell);
    }

    // function testFlaps() public {
    //     vote();
    //     scheduleWaitAndCast();

    //     // spell done
    //     assertTrue(spell.done());

    //     // check afterSpell parameters
    //     checkSystemValues(afterSpell);
    // }

    // function testFlops() public {
    //     vote();
    //     scheduleWaitAndCast();

    //     // spell done
    //     assertTrue(spell.done());

    //     // check afterSpell parameters
    //     checkSystemValues(afterSpell);
    // }
}