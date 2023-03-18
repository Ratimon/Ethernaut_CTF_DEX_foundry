// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test} from "@forge-std/Test.sol";
import {StdInvariant} from "@forge-std/StdInvariant.sol";

import {Dex, SwappableToken} from "../src/Dex.sol";
import {Handler} from "./handlers/Handler.sol";

contract TokenSaleInvariants is StdInvariant, Test {

    address public alice = address(11);

    Dex dex;
    SwappableToken token1;
    SwappableToken token2;
    Handler public handler;

    function setUp() public {
        vm.label(address(this), "TokenSaleInvariants");
        vm.label(alice, "Alice");

        vm.startPrank(alice);
        dex = new Dex();
        token1 = new SwappableToken(address(dex), "Token 1", "T1", 110);
        token2 = new SwappableToken(address(dex), "Token 2", "T2", 110);
        vm.label(address(token1), "token1");
        vm.label(address(token2), "token2");

        dex.setTokens(address(token1),address(token2));

        token1.approve(address(dex),type(uint256).max);
        token2.approve(address(dex),type(uint256).max);

        dex.addLiquidity(address(token1),100);
        dex.addLiquidity(address(token2),100);
        vm.stopPrank();

        handler = new Handler(dex, alice);
        vm.label(address(handler), "Handler");

        bytes4[] memory selectors = new bytes4[](1);

        selectors[0] = Handler.exploit.selector;

        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));
        targetContract(address(handler));
    }

    function test_Constructor() public {
        assertEq( token1.balanceOf(address(dex)), 100 );
        assertEq( token2.balanceOf(address(dex)), 100 );

        assertEq(token1.balanceOf(alice), 10 );
        assertEq(token2.balanceOf(alice), 10 );

        assertEq(dex.token1(), address(token1));
        assertEq(dex.token2(), address(token2));
    }
    function invariant_is_dex_not_empty() public {
        assertEq(token1.balanceOf(address(dex)) != 0 && token2.balanceOf(address(dex)) != 0, true); 
    }

    function invariant_callSummary() public view {
        handler.callSummary();
    }

}