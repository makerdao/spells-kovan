pragma solidity 0.5.12;

import "ds-math/math.sol";
import "ds-test/test.sol";
import "lib/dss-interfaces/src/Interfaces.sol";

import {DssSpell, SpellAction} from "./Kovan-DssSpell.sol";

contract Hevm {
    function warp(uint256) public;
    function store(address,bytes32,bytes32) public;
}

contract USDTAbstract {
    function totalSupply() public view returns (uint256);
    function balanceOf(address) public view returns (uint256);
    function allowance(address, address) public view returns (uint256);
    function approve(address, uint256) public;               // nonstandard
    function transfer(address, uint256) public;              // nonstandard
    function transferFrom(address, address, uint256) public; // nonstandard
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
        uint256 dunk;
        uint256 pct;
        uint256 mat;
        uint256 beg;
        uint48 ttl;
        uint48 tau;
        uint256 liquidations;
    }

    struct SystemValues {
        uint256 dsr;
        uint256 dsrPct;
        uint256 Line;
        uint256 pauseDelay;
        mapping (bytes32 => CollateralValues) collaterals;
    }

    SystemValues afterSpell;

    Hevm hevm;

    // KOVAN ADDRESSES
    DSPauseAbstract pause        = DSPauseAbstract(  0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189);
    address pauseProxy           =                   0x0e4725db88Bb038bBa4C4723e91Ba183BE11eDf3;
    DSChiefAbstract chief        = DSChiefAbstract(  0xbBFFC76e94B34F72D96D054b31f6424249c1337d);
    VatAbstract     vat          = VatAbstract(      0xbA987bDB501d131f766fEe8180Da5d81b34b69d9);
    CatAbstract     cat          = CatAbstract(      0xdDb5F7A3A5558b9a6a1f3382BD75E2268d1c6958);
    PotAbstract     pot          = PotAbstract(      0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb);
    JugAbstract     jug          = JugAbstract(      0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD);
    SpotAbstract    spot         = SpotAbstract(     0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D);
    DSTokenAbstract gov          = DSTokenAbstract(  0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD);
    EndAbstract     end          = EndAbstract(      0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F);
    FlipperMomAbstract flipMom   = FlipperMomAbstract(0x50dC6120c67E456AdA2059cfADFF0601499cf681);
    OsmMomAbstract  osmMom       = OsmMomAbstract(   0x5dA9D1C3d4f1197E5c52Ff963916Fe84D2F5d8f3);

    // USDT-A specific
    USDTAbstract usdt            = USDTAbstract(     0x9245BD36FA20fcD292F4765c4b5dF83Dc3fD5e86);
    GemJoinAbstract joinUSDTA    = GemJoinAbstract(  0x9B011a74a690dFd9a1e4996168d3EcBDE73c2226);
    OsmAbstract pipUSDT          = OsmAbstract(      0x3588A7973D41AaeA7B203549553C991C4311951e);
    FlipAbstract flipUSDTA       = FlipAbstract(     0x1C5dce9d7583F3da2b787d694342D125731aE099);
    MedianAbstract medUSDTA      = MedianAbstract(   0x074EcAe0CD5c37f59D9b91E2994407418aCe05B7);

    // PAXUSD-A specific
    GemAbstract      paxusd      = GemAbstract(      0x4e4209e4981C54a6CB99aC20432E67C7cCC9794D);
    GemJoinAbstract  joinPAXUSDA = GemJoinAbstract(  0x96831F3eC88874cf6B2cCe604e7531bF1B55171f);
    OsmAbstract      pipPAXUSD   = OsmAbstract(      0xd2b75a3F7a9a627783d1c7934EC324c3d1B10749);
    FlipAbstract     flipPAXUSDA = FlipAbstract(     0x0815f202BC307F5c4097Cf57E23F1a86a8bf59D6);

    DssSpell spell;

    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE =
        bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    uint256 constant THOUSAND   = 10 ** 3;
    uint256 constant MILLION    = 10 ** 6;
    uint256 constant BILLION    = 10 ** 9;
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
            Line: 703 * MILLION * RAD,
            pauseDelay: 60
        });
        afterSpell.collaterals["USDT-A"] = CollateralValues({
            line: 10 * MILLION * RAD,
            dust: 100 * RAD,
            duty: 1000000002440418608258400030, // 8% SF
            pct: 8 * 1000,
            chop: 113 * WAD / 100,
            dunk: 50 * THOUSAND * RAD,
            mat: 150 * RAY / 100,
            beg: 103 * WAD / 100,
            ttl: 6 hours,
            tau: 6 hours,
            liquidations: 1
        });
        afterSpell.collaterals["PAXUSD-A"] = CollateralValues({
            line: 5 * MILLION * RAD,
            dust: 100 * RAD,
            duty: 1000000001243680656318820312, // 4% SF
            pct: 4 * 1000,
            chop: 113 * WAD / 100,
            dunk: 50 * THOUSAND * RAD,
            mat: 120 * RAY / 100,
            beg: 103 * WAD / 100,
            ttl: 6 hours,
            tau: 6 hours,
            liquidations: 0
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

    // function checkCollateralValues(bytes32 ilk, SystemValues storage values) internal {
    //     (uint duty,)  = jug.ilks(ilk);
    //     assertEq(duty,   values.collaterals[ilk].duty);
    //     // make sure duty is less than 1000% APR
    //     // bc -l <<< 'scale=27; e( l(10.00)/(60 * 60 * 24 * 365) )'
    //     // 1000000073014496989316680335
    //     assertTrue(duty >= RAY && duty < 1000000073014496989316680335);  // gt 0 and lt 1000%
    //     assertTrue(diffCalc(expectedRate(values.collaterals[ilk].pct), yearlyYield(values.collaterals[ilk].duty)) <= TOLERANCE);
    //     assertTrue(values.collaterals[ilk].pct < THOUSAND * THOUSAND);   // check value lt 1000%

    //     (,,, uint line, uint dust) = vat.ilks(ilk);
    //     assertEq(line, values.collaterals[ilk].line);
    //     assertTrue((line >= RAD && line < BILLION * RAD) || line == 0);  // eq 0 or gt eq 1 RAD and lt 1B
    //     assertEq(dust, values.collaterals[ilk].dust);
    //     assertTrue((dust >= RAD && dust < 10 * THOUSAND * RAD) || dust == 0); // eq 0 or gt eq 1 and lt 10k

    //     (, uint chop, uint dunk) = cat.ilks(ilk);
    //     assertEq(chop, values.collaterals[ilk].chop);
    //     // make sure chop is less than 100%
    //     assertTrue(chop >= WAD && chop < 2 * WAD);   // penalty gt eq 0% and lt 100%
    //     assertEq(dunk, values.collaterals[ilk].dunk);
    //     // put back in after LIQ-1.2
    //     assertTrue(dunk >= RAD && dunk < MILLION * RAD);

    //     (,uint mat) = spot.ilks(ilk);
    //     assertEq(mat, values.collaterals[ilk].mat);
    //     assertTrue(mat >= RAY && mat < 10 * RAY);    // cr eq 100% and lt 1000%

    //     (address flipper,,) = cat.ilks(ilk);
    //     FlipAbstract flip = FlipAbstract(flipper);
    //     assertEq(uint(flip.beg()), values.collaterals[ilk].beg);
    //     assertTrue(flip.beg() >= WAD && flip.beg() < 105 * WAD / 100);  // gt eq 0% and lt 5%
    //     assertEq(uint(flip.ttl()), values.collaterals[ilk].ttl);
    //     assertTrue(flip.ttl() >= 600 && flip.ttl() < 10 hours);         // gt eq 10 minutes and lt 10 hours
    //     assertEq(uint(flip.tau()), values.collaterals[ilk].tau);
    //     assertTrue(flip.tau() >= 600 && flip.tau() <= 1 hours);          // gt eq 10 minutes and lt eq 1 hours

    //     assertEq(flip.wards(address(cat)), values.collaterals[ilk].liquidations);  // liquidations == 1 => on
    // }

    function checkCollateralValues(bytes32 ilk, SystemValues storage values) internal {
        (uint duty,)  = jug.ilks(ilk);
        assertEq(duty,   values.collaterals[ilk].duty);
        assertTrue(diffCalc(expectedRate(values.collaterals[ilk].pct), yearlyYield(values.collaterals[ilk].duty)) <= TOLERANCE);

        (,,, uint256 line, uint256 dust) = vat.ilks(ilk);
        assertEq(line, values.collaterals[ilk].line);
        assertEq(dust, values.collaterals[ilk].dust);

        (, uint256 chop, uint256 dunk) = cat.ilks(ilk);
        assertEq(chop, values.collaterals[ilk].chop);
        assertEq(dunk, values.collaterals[ilk].dunk);

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

        checkCollateralValues("USDT-A", afterSpell);
        checkCollateralValues("PAXUSD-A", afterSpell);
    }

    function testSpellIsCast_USDTA_INTEGRATION() public {
        vote();
        scheduleWaitAndCast();
        // spell done
        assertTrue(spell.done());

        pipUSDT.poke();
        hevm.warp(now + 3601);
        pipUSDT.poke();
        spot.poke("USDT-A");

        hevm.store(
            address(usdt),
            keccak256(abi.encode(address(this), uint256(2))),
            bytes32(uint256(600 * 10 ** 6))
        );

        // check median matches pip.src()
        assertEq(pipUSDT.src(), address(medUSDTA));

        // Authorization
        assertEq(joinUSDTA.wards(pauseProxy), 1);
        assertEq(vat.wards(address(joinUSDTA)), 1);
        assertEq(flipUSDTA.wards(address(end)), 1);
        assertEq(flipUSDTA.wards(address(flipMom)), 1);
        assertEq(pipUSDT.wards(address(osmMom)), 1);
        assertEq(pipUSDT.bud(address(spot)), 1);
        assertEq(pipUSDT.bud(address(end)), 1);
        assertEq(MedianAbstract(pipUSDT.src()).bud(address(pipUSDT)), 1);

        // Join to adapter
        assertEq(usdt.balanceOf(address(this)), 600 * 10 ** 6);
        assertEq(vat.gem("USDT-A", address(this)), 0);
        usdt.approve(address(joinUSDTA), 600 * 10 ** 6);
        joinUSDTA.join(address(this), 600 * 10 ** 6);
        assertEq(usdt.balanceOf(address(this)), 0);
        assertEq(vat.gem("USDT-A", address(this)), 600 * WAD);

        // Deposit collateral, generate DAI
        assertEq(vat.dai(address(this)), 0);
        vat.frob("USDT-A", address(this), address(this), address(this), int(600 * WAD), int(100 * WAD));
        assertEq(vat.gem("USDT-A", address(this)), 0);
        assertEq(vat.dai(address(this)), 100 * RAD);

        // Payback DAI, withdraw collateral
        vat.frob("USDT-A", address(this), address(this), address(this), -int(600 * WAD), -int(100 * WAD));
        assertEq(vat.gem("USDT-A", address(this)), 600 * WAD);
        assertEq(vat.dai(address(this)), 0);

        // Withdraw from adapter
        joinUSDTA.exit(address(this), 600 * 10 ** 6);
        assertEq(usdt.balanceOf(address(this)), 600 * 10 ** 6);
        assertEq(vat.gem("USDT-A", address(this)), 0);

        // Generate new DAI to force a liquidation
        usdt.approve(address(joinUSDTA), 600 * 10 ** 6);
        joinUSDTA.join(address(this), 600 * 10 ** 6);
        (,,uint256 spotV,,) = vat.ilks("USDT-A");
        // dart max amount of DAI
        vat.frob("USDT-A", address(this), address(this), address(this), int(600 * WAD), int(mul(600 * WAD, spotV) / RAY));
        hevm.warp(now + 1);
        jug.drip("USDT-A");
        assertEq(flipUSDTA.kicks(), 0);
        cat.bite("USDT-A", address(this));
        assertEq(flipUSDTA.kicks(), 1);
    }

    function testSpellIsCast_PAXUSDA_INTEGRATION() public {
        vote();
        scheduleWaitAndCast();
        // spell done
        assertTrue(spell.done());

        // Authorization
        assertEq(joinPAXUSDA.wards(pauseProxy), 1);
        assertEq(vat.wards(address(joinPAXUSDA)), 1);
        assertEq(flipPAXUSDA.wards(address(end)), 1);
        assertEq(flipPAXUSDA.wards(address(flipMom)), 1);

        // Join to adapter
        hevm.store(
            address(paxusd),
            keccak256(abi.encode(address(this), uint256(1))),
            bytes32(uint256(600 * WAD))
        );
        assertEq(paxusd.balanceOf(address(this)), 600 * WAD);
        assertEq(vat.gem("PAXUSD-A", address(this)), 0);
        paxusd.approve(address(joinPAXUSDA), 600 * WAD);
        joinPAXUSDA.join(address(this), 600 * WAD);
        assertEq(paxusd.balanceOf(address(this)), 0);
        assertEq(vat.gem("PAXUSD-A", address(this)), 600 * WAD);

        // Deposit collateral, generate DAI
        assertEq(vat.dai(address(this)), 0);
        vat.frob("PAXUSD-A", address(this), address(this), address(this), int(600 * WAD), int(100 * WAD));
        assertEq(vat.gem("PAXUSD-A", address(this)), 0);
        assertEq(vat.dai(address(this)), 100 * RAD);

        // Payback DAI, withdraw collateral
        vat.frob("PAXUSD-A", address(this), address(this), address(this), -int(600 * WAD), -int(100 * WAD));
        assertEq(vat.gem("PAXUSD-A", address(this)), 600 * WAD);
        assertEq(vat.dai(address(this)), 0);

        // Withdraw from adapter
        joinPAXUSDA.exit(address(this), 600 * 10 ** 18);
        assertEq(paxusd.balanceOf(address(this)), 600 * 10 ** 18);
        assertEq(vat.gem("PAXUSD-A", address(this)), 0);
    }
}
