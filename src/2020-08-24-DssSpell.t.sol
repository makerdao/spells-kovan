pragma solidity 0.5.12;

import "ds-math/math.sol";
import "ds-test/test.sol";
import "lib/dss-interfaces/src/Interfaces.sol";

import {DssSpell, SpellAction} from "./2020-08-24-DssSpell.sol";

contract Hevm {
    function warp(uint256) public;
    function store(address,bytes32,bytes32) public;
}

contract DssSpellTest is DSTest, DSMath {
    // populate with mainnet spell if needed
    address constant MAINNET_SPELL = address(0);
    // this needs to be updated
    uint256 constant SPELL_CREATED = 1595258877;

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

    SystemValues beforeSpell;
    SystemValues afterSpell;

    Hevm hevm;

    // KOVAN ADDRESSES
    DSPauseAbstract pause       = DSPauseAbstract(  0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189);
    address pauseProxy          =                   0x0e4725db88Bb038bBa4C4723e91Ba183BE11eDf3;
    DSChiefAbstract chief       = DSChiefAbstract(  0xbBFFC76e94B34F72D96D054b31f6424249c1337d);
    VatAbstract     vat         = VatAbstract(      0xbA987bDB501d131f766fEe8180Da5d81b34b69d9);
    CatAbstract     cat         = CatAbstract(      0x0511674A67192FE51e86fE55Ed660eB4f995BDd6);
    PotAbstract     pot         = PotAbstract(      0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb);
    JugAbstract     jug         = JugAbstract(      0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD);
    SpotAbstract    spot        = SpotAbstract(     0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D);
    DSTokenAbstract gov         = DSTokenAbstract(  0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD);
    EndAbstract     end         = EndAbstract(      0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F);
    FlipperMomAbstract flipMom  = FlipperMomAbstract(0xf3828caDb05E5F22844f6f9314D99516D68a0C84);
    OsmMomAbstract  osmMom      = OsmMomAbstract(   0x5dA9D1C3d4f1197E5c52Ff963916Fe84D2F5d8f3);

    // LRC-A specific
    GemAbstract lrc             = GemAbstract(      0xF070662e48843934b5415f150a18C250d4D7B8aB);
    GemJoinAbstract joinLRCA    = GemJoinAbstract(  0x436286788C5dB198d632F14A20890b0C4D236800);
    OsmAbstract pipLRC         = OsmAbstract(      0x4Ef3fde085c7046121A4a5773756c84F82056F91);
    FlipAbstract flipLRCA       = FlipAbstract(     0xbeb5f3c9FEE1ae008F04656cf094996d366e5F31);
    MedianAbstract medLRCA      = MedianAbstract(   0xffd6F86244d991a88adAFBa28d69bba622F14313);

    DssSpell spell;

    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE =
        bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    uint256 constant THOUSAND   = 10 ** 3;
    uint256 constant MILLION    = 10 ** 6;
    uint256 constant WAD        = 10 ** 18;
    uint256 constant RAY        = 10 ** 27;
    uint256 constant RAD        = 10 ** 45;

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

        hevm.store(
            address(gov),
            keccak256(abi.encode(address(this), uint256(1))),
            bytes32(uint256(999999999999 ether))
        );

        afterSpell = SystemValues({
            dsr: 1000000000000000000000000000,
            dsrPct: 0 * 1000,
            Line: add(173050 * THOUSAND * RAD, 3 * MILLION * RAD),
            pauseDelay: 60
        });
        afterSpell.collaterals["LRC-A"] = CollateralValues({
            line: 3 * MILLION * RAD,
            dust: 20 * RAD,
            duty: 1000000000937303470807876289,
            pct: 3 * 1000,
            chop: 113 * RAY / 100,
            lump: 200 * THOUSAND * WAD,
            mat: 175 * RAY / 100,
            beg: 103 * WAD / 100,
            ttl: 6 hours,
            tau: 6 hours
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

        (address flipper,,) = cat.ilks(ilk);
        FlipAbstract flip = FlipAbstract(flipper);
        assertEq(uint256(flip.beg()), values.collaterals[ilk].beg);
        assertEq(uint256(flip.ttl()), values.collaterals[ilk].ttl);
        assertEq(uint256(flip.tau()), values.collaterals[ilk].tau);
    }

    // this spell is intended to run as the MkrAuthority
    function canCall(address, address, bytes4) public pure returns (bool) {
        return true;
    }

    function testSpellIsCast() public {
        string memory description = new SpellAction().description();
        assertTrue(bytes(description).length > 0);
        // DS-Test can't handle strings directly, so cast to a bytes32.
        assertEq(stringToBytes32(spell.description()),
                stringToBytes32(description));

        if(address(spell) != address(MAINNET_SPELL)) {
            assertEq(spell.expiration(), (now + 4 days + 2 hours));
        } else {
            assertEq(spell.expiration(), (SPELL_CREATED + 30 days));
        }

        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        checkSystemValues(afterSpell);

        checkCollateralValues("LRC-A", afterSpell);
    }

    function testSpellIsCast_LRCA_INTEGRATION() public {
        vote();
        scheduleWaitAndCast();

        hevm.warp(now + 3601);
        pipLRC.poke();
        spot.poke("LRC-A");

        hevm.store(
            address(lrc),
            keccak256(abi.encode(address(this), uint256(0))),
            bytes32(uint256(600 ether))
        );

        // spell done
        assertTrue(spell.done());

        // check afterSpell parameters
        checkSystemValues(afterSpell);
        checkCollateralValues("LRC-A", afterSpell);

        // check median matches pip.src()
        assertEq(pipLRC.src(), address(medLRCA));

        // Authorization
        assertEq(joinLRCA.wards(pauseProxy), 1);
        assertEq(vat.wards(address(joinLRCA)), 1);
        assertEq(flipLRCA.wards(address(end)), 1);
        assertEq(flipLRCA.wards(address(flipMom)), 1);
        assertEq(pipLRC.wards(address(osmMom)), 1);
        assertEq(pipLRC.bud(address(spot)), 1);
        assertEq(MedianAbstract(pipLRC.src()).bud(address(pipLRC)), 1);

        // Start testing Vault
        uint256 current_dai = vat.dai(address(this));

        // Join to adapter
        assertEq(lrc.balanceOf(address(this)), 600 ether);
        assertEq(vat.gem("LRC-A", address(this)), 0);
        lrc.approve(address(joinLRCA), 600 ether);
        joinLRCA.join(address(this), 600 ether);
        assertEq(lrc.balanceOf(address(this)), 0);
        assertEq(vat.gem("LRC-A", address(this)), 600 * WAD);

        // Deposit collateral, generate DAI
        assertEq(vat.dai(address(this)), current_dai);
        vat.frob("LRC-A", address(this), address(this), address(this), int(600 * WAD), int(25 * WAD));
        assertEq(vat.gem("LRC-A", address(this)), 0);
        assertEq(vat.dai(address(this)), add(current_dai, 25 * RAD));

        // Payback DAI, withdraw collateral
        vat.frob("LRC-A", address(this), address(this), address(this), -int(600 * WAD), -int(25 * WAD));
        assertEq(vat.gem("LRC-A", address(this)), 600 * WAD);
        assertEq(vat.dai(address(this)), current_dai);

        // Withdraw from adapter
        joinLRCA.exit(address(this), 600 * 10 ** 18);
        assertEq(lrc.balanceOf(address(this)), 600 * 10 ** 18);
        assertEq(vat.gem("LRC-A", address(this)), 0);

        // Generate new DAI to force a liquidation
        lrc.approve(address(joinLRCA), 600 * 10 ** 18);
        joinLRCA.join(address(this), 600 * 10 ** 18);
        vat.frob("LRC-A", address(this), address(this), address(this), int(600 * WAD), int(20 * WAD)); // Max amount of DAI
        hevm.warp(now + 1000000000);
        jug.drip("LRC-A");
        assertEq(flipLRCA.kicks(), 0);
        cat.bite("LRC-A", address(this));
        assertEq(flipLRCA.kicks(), 1);
    }
}
