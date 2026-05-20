// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract SimpleAMM {
    IERC20 public token0;
    IERC20 public token1;

    uint256 public reserve0;
    uint256 public reserve1;
    uint256 public k;

    // TODO: constructor. Store _token0 and _token1.
    constructor(address _token0, address _token1) {
        require(_token0 != address(0) && _token1 != address(0), "Invalid token addresses");
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function addLiquidity(uint256 amount0, uint256 amount1) external {
        // TODO:
        // 1. Reject if either amount is 0.
        require(amount0 > 0 && amount1 > 0, "Amounts must be greater than 0");
        // 2. If reserves already exist, enforce the same ratio.
        if (reserve0 > 0 || reserve1 > 0) {
            require(amount0 * reserve1 == amount1 * reserve0, "Invalid liquidity ratio");
        }
        //    Hint: cross-multiply to avoid division.
        //    amount0 * reserve1 == amount1 * reserve0
        // 3. Pull both tokens from msg.sender using transferFrom.
        require(token0.transferFrom(msg.sender, address(this), amount0), "Token0 transfer failed");
        require(token1.transferFrom(msg.sender, address(this), amount1), "Token1 transfer failed");
        // 4. Update reserve0 and reserve1.
        reserve0 += amount0;
        reserve1 += amount1;
        // 5. Update k = reserve0 * reserve1.
        k = reserve0 * reserve1;
    }

    function getSwapAmountOut(uint256 amountIn, bool isToken0In)
        public
        view
        returns (uint256 amountOut)
    {
        // TODO:
        // 1. Reject if amountIn is 0 or if there is no liquidity (k == 0).
        require(amountIn == 0 || k > 0 , "Invalid amountIn or liquidity");
        // 2. If isToken0In:
        if(isToken0In)
        {
            uint256 newReserve0 = reserve0 + amountIn;
            uint256 newReserve1 = k / newReserve0;
            amountOut   = reserve1 - newReserve1;
        }
        else{
            uint256 newReserve1 = reserve1 + amountIn;
            uint256 newReserve0 = k / newReserve1;
            amountOut   = reserve0 - newReserve0;
        }
        //      
        //    Else do the mirror math for token1 -> token0.
    }

    function swap(uint256 amountIn, bool isToken0In) external {
        // TODO:
        // 1. Call getSwapAmountOut to know the output.
        uint256 amountOut = getSwapAmountOut( amountIn,  isToken0In);

        // 2. Reject if amountOut is 0.
        require (amountOut > 0, "null amountOut");

        // 3. Use transferFrom to pull the input token from the user.
        // 4. Use transfer to push the output token to the user.
        // 5. Update the reserves.
        if(isToken0In){
            require(token0.transferFrom(msg.sender, address(this), amountIn), "transferFrom token 0 failed");
            require(token1.transfer(msg.sender, amountOut), "transfer token 1 failed");
            reserve0 += amountIn;
            reserve1 -= amountOut;
        }
        else{
            require(token1.transferFrom(msg.sender, address(this), amountIn), "transferFrom token 1 failed");
            require(token0.transfer(msg.sender,amountOut), "transfer token 0 failed");
            reserve1 += amountIn;
            reserve0 -= amountOut;
        }
        
        
    }

    function getReserves() external view returns (uint256, uint256) {
        return (reserve0, reserve1);
    }
}