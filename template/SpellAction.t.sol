    // add a TOKEN-LETTER specific section with the correct addressess
    DSTokenAbstract            token = DSTokenAbstract();
    GemJoinAbstract  joinTOKENLETTER = GemJoinAbstract();
    OsmAbstract             pipTOKEN = OsmAbstract();
    FlipAbstract     flipTOKENLETTER = FlipAbstract();
    MedianAbstract    medTOKENLETTER = MedianAbstract();

        // add to the end of the list of collateral tests
        // change the values as appropriate
        afterSpell.collaterals["TOKEN-LETTER"] = CollateralValues({
            line:         4 * MILLION * RAD,
            dust:         100 * RAD,
            pct:          5 * 1000,
            chop:         113 * WAD / 100,
            dunk:         500 * RAD,
            mat:          175 * RAY / 100,
            beg:          103 * WAD / 100,
            ttl:          1 hours,
            tau:          1 hours,
            liquidations: 1
        });

    // this will tests a new collateral addition. Reaplace all occurences
    // of TOKEN with the appropriate collateral, and LETTER with the appropriate
    // letter.  Also replace lowercase token with the appropriate letter.
    function testSpellIsCast_TOKEN_INTEGRATION() public {
        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

        pipTOKEN.poke();
        hevm.warp(now + 3601);
        pipTOKEN.poke();
        spot.poke("TOKEN-LETTER");

        hevm.store(
            address(TOKEN),
            keccak256(abi.encode(address(this), uint256(1))),
            bytes32(uint256(1 * THOUSAND * WAD))
        );

        // Check faucet amount
        assertEq(faucet.amt(address(TOKEN)), 30 * WAD);

        // Check median matches pip.src()
        assertEq(pipTOKEN.src(), address(medTOKENLETTER));

        // Authorization
        assertEq(joinTOKENLETTER.wards(pauseProxy), 1);
        assertEq(vat.wards(address(joinTOKENLETTER)), 1);
        assertEq(flipTOKENLETTER.wards(address(end)), 1);
        assertEq(flipTOKENLETTER.wards(address(flipMom)), 1);
        assertEq(pipTOKEN.wards(address(osmMom)), 1);
        assertEq(pipTOKEN.bud(address(spot)), 1);
        assertEq(pipTOKEN.bud(address(end)), 1);
        assertEq(MedianAbstract(pipTOKEN.src()).bud(address(pipTOKEN)), 1);

        // Join to adapter
        assertEq(token.balanceOf(address(this)), 1 * THOUSAND * WAD);
        assertEq(vat.gem("TOKEN-LETTER", address(this)), 0);
        token.approve(address(joinTOKENLETTER), 1 * THOUSAND * WAD);
        joinTOKENLETTER.join(address(this), 1 * THOUSAND * WAD);
        assertEq(token.balanceOf(address(this)), 0);
        assertEq(vat.gem("TOKEN-LETTER", address(this)), 1 * THOUSAND * WAD);

        // Deposit collateral, generate DAI
        assertEq(vat.dai(address(this)), 0);
        vat.frob("TOKEN-LETTER", address(this), address(this), address(this), int(1 * THOUSAND * WAD), int(100 * WAD));
        assertEq(vat.gem("TOKEN-LETTER", address(this)), 0);
        assertEq(vat.dai(address(this)), 100 * RAD);

        // Payback DAI, withdraw collateral
        vat.frob("TOKEN-LETTER", address(this), address(this), address(this), -int(1 * THOUSAND * WAD), -int(100 * WAD));
        assertEq(vat.gem("TOKEN-LETTER", address(this)), 1 * THOUSAND * WAD);
        assertEq(vat.dai(address(this)), 0);

        // Withdraw from adapter
        joinTOKENLETTER.exit(address(this), 1 * THOUSAND * WAD);
        assertEq(token.balanceOf(address(this)), 1 * THOUSAND * WAD);
        assertEq(vat.gem("TOKEN-LETTER", address(this)), 0);

        // Generate new DAI to force a liquidation
        token.approve(address(joinTOKENLETTER), 1 * THOUSAND * WAD);
        joinTOKENLETTER.join(address(this), 1 * THOUSAND * WAD);
        (,,uint256 spotV,,) = vat.ilks("TOKEN-LETTER");
        // dart max amount of DAI
        vat.frob("TOKEN-LETTER", address(this), address(this), address(this), int(1 * THOUSAND * WAD), int(mul(1 * THOUSAND * WAD, spotV) / RAY));
        hevm.warp(now + 1);
        jug.drip("TOKEN-LETTER");
        assertEq(flipTOKENLETTER.kicks(), 0);
        cat.bite("TOKEN-LETTER", address(this));
        assertEq(flipTOKENLETTER.kicks(), 1);
    }

