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


        // bytes4[] memory selectors = new bytes4[](2);
        bytes4[] memory selectors = new bytes4[](1);

        selectors[0] = Handler.exploit.selector;

        // selectors[0] = Handler.swapFromToken2To1.selector;
        // selectors[1] = Handler.swapFromToken1To2.selector;

        

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

    // /**
    //  * @notice  // 
    //  */
    // function invariant_have_pool() public {
    //     // assertEq(token1.balanceOf(address(dex)) != 0 && token2.balanceOf(address(dex)) != 0, true);        assertEq(token1.balanceOf(address(dex)) != 0 && token2.balanceOf(address(dex)) != 0, true);
    //     // assertEq(token1.balanceOf(address(dex)) , 0);

    //     // tokenOne > 0
    //     // tokentwo > 0

    //     //  ~  ( token 1 of dex == X 

    //     // assertEq(token1.balanceOf(address(level)) == 0 || token2.balanceOf(address(level)) == 0, true);


    //     assertGt(token1.balanceOf(address(dex)) , 0);
    //     assertGt(token2.balanceOf(address(dex)) , 0);

    //     // if ( token1.balanceOf(address(dex)) == 0 ) {

    //     //      assertGt(token2.balanceOf(address(dex)) , 0);
    //     // } else {
    //     //     assertEq(token2.balanceOf(address(dex)) , 0);
    //     // }


    // }

    function invariant_is_dex_not_empty() public {
        assertEq(token1.balanceOf(address(dex)) != 0 && token2.balanceOf(address(dex)) != 0, true); 
    }

    // function test_drain() public {

    //     vm.startPrank(alice);

    //     // address token1 = dex.token1();
    //     // address token2 = dex.token2();

    //     swapMax(IERC20(token1), IERC20(token2));
    //     swapMax(IERC20(token2), IERC20(token1));
    //     swapMax(IERC20(token1), IERC20(token2));
    //     swapMax(IERC20(token2), IERC20(token1));

    //     // now token 1 is in the pool
    //     swapMax(IERC20(token1), IERC20(token2));

    //     // token2AmountIn = bound(token2AmountIn, 0, IERC20(token2).totalSupply());

    //     // dex.swap(token2, token1, token2AmountIn);

    //     assertEq( token1.balanceOf(alice), 0 );
    //     assertEq( token2.balanceOf(alice), 65 );

    //     assertEq( token1.balanceOf(address(dex)), 110 );
    //     assertEq( token2.balanceOf(address(dex)), 45 );

    //     vm.stopPrank();

    // }

    // function swapMax(IERC20 tokenIn, IERC20 tokenOut) internal {
    //     dex.swap(address(tokenIn), address(tokenOut), tokenIn.balanceOf(alice));
    // }

    // function invariant_is_pool_remained() public {

    //     uint256 token1RemainingPool = token1.balanceOf(address(dex));
    //     uint256 token1AmountOut = dex.getSwapPrice(address(token2),address(token1), token2.balanceOf(alice)  );


    //     assertGt(token1RemainingPool, token1AmountOut);

    // }

    function invariant_callSummary() public view {
        handler.callSummary();
    }



}