// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import "@aave-v3-core/contracts/mocks/flashloan/MockFlashLoanReceiver.sol";
import "@aave-v3-core/contracts/interfaces/IPool.sol";
import "@aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import "@aave-v3-core/contracts/mocks/helpers/MockPool.sol";
import "../src/FlashLoanArbitrage.sol";

contract FlashLoanArbitrageTest is Test {
    // Mocks and contracts
    MockPool private mockPool;
    MockFlashLoanReceiver private mockFlashLoanReceiver;
    FlashLoanArbitrage private flashLoanArbitrage;

    // Token addresses and test variables
    address private weth;
    address private dai;
    address private user;
    address private profitWallet;
    uint256 private initialBalance = 100 ether;

    function setUp() public {
        // Deploy mock pool and flash loan receiver
        mockPool = new MockPool();
        mockFlashLoanReceiver = new MockFlashLoanReceiver();

        // Deploy the FlashLoanArbitrage contract
        profitWallet = address(0x123); // Simulated profit wallet
        flashLoanArbitrage = new FlashLoanArbitrage(
            address(mockPool),
            address(0), // Uniswap Router (mocked if needed)
            address(0), // Sushiswap Router (mocked if needed)
            profitWallet
        );

        // Set up WETH and DAI mock tokens
        weth = address(new ERC20Mock("Wrapped Ether", "WETH", 18));
        dai = address(new ERC20Mock("Dai Stablecoin", "DAI", 18));

        // Assign initial balance to test user
        user = address(this);
        deal(weth, user, initialBalance);
        deal(dai, user, initialBalance);

        // Approve FlashLoanArbitrage contract to spend WETH and DAI
        IERC20(weth).approve(address(flashLoanArbitrage), type(uint256).max);
        IERC20(dai).approve(address(flashLoanArbitrage), type(uint256).max);

        // Set up MockPool and FlashLoanReceiver
        mockPool.setFlashLoanReceiver(address(mockFlashLoanReceiver));
    }

    function testFlashLoanExecutionStartToFinish() public {
        uint256 flashLoanAmount = 10 ether;

        deal(weth, address(mockPool), flashLoanAmount);

        mockFlashLoanReceiver.executeOperation(
            weth,
            flashLoanAmount,
            0,
            user,
            abi.encode("Test data")
        );

        assertEq(IERC20(weth).balanceOf(address(mockPool)), flashLoanAmount);
    }

    function testFeeRepayment() public {
        uint256 flashLoanAmount = 10 ether;
        uint256 fee = 0.01 ether;

        deal(weth, address(mockPool), flashLoanAmount);
        deal(weth, user, fee);

        mockFlashLoanReceiver.executeOperation(
            weth,
            flashLoanAmount,
            fee,
            user,
            abi.encode("Fee repayment test")
        );

        assertEq(IERC20(weth).balanceOf(address(mockPool)), flashLoanAmount + fee);
    }

    function testArbitrageProfitRealization() public {
        uint256 tradeAmount = 5 ether;
        uint256 expectedProfit = 1 ether;

        deal(weth, address(flashLoanArbitrage), tradeAmount);
        deal(dai, address(flashLoanArbitrage), tradeAmount * 2);

        flashLoanArbitrage.executeArbitrage(weth, dai, tradeAmount);

        assertEq(IERC20(weth).balanceOf(profitWallet), expectedProfit);
    }

    function testProfitWalletTransfer() public {
        uint256 profit = 1 ether;
        deal(weth, address(flashLoanArbitrage), profit);

        flashLoanArbitrage.sendProfitToWallet(weth);

        assertEq(IERC20(weth).balanceOf(profitWallet), profit);
    }

    function testInsufficientLiquidityRevert() public {
        uint256 flashLoanAmount = 10 ether;

        vm.expectRevert("Insufficient liquidity");
        flashLoanArbitrage.flashLoan(weth, flashLoanAmount);
    }

    function testGasUsageOptimization() public {
        uint256 flashLoanAmount = 10 ether;

        deal(weth, address(mockPool), flashLoanAmount);
        uint256 gasStart = gasleft();

        mockFlashLoanReceiver.executeOperation(
            weth,
            flashLoanAmount,
            0,
            user,
            abi.encode("Gas test")
        );

        uint256 gasUsed = gasStart - gasleft();
        assertLt(gasUsed, 500000); // Ensure gas usage is reasonable
    }

    function testMultipleFlashLoans() public {
        uint256 flashLoanAmount = 5 ether;

        deal(weth, address(mockPool), flashLoanAmount * 2);

        mockFlashLoanReceiver.executeOperation(
            weth,
            flashLoanAmount,
            0,
            user,
            abi.encode("First flash loan")
        );

        mockFlashLoanReceiver.executeOperation(
            weth,
            flashLoanAmount,
            0,
            user,
            abi.encode("Second flash loan")
        );

        assertEq(IERC20(weth).balanceOf(address(mockPool)), flashLoanAmount * 2);
    }

    function testTradeFailureReverts() public {
        uint256 tradeAmount = 5 ether;

        deal(weth, address(flashLoanArbitrage), tradeAmount);

        vm.expectRevert("Trade failed");
        flashLoanArbitrage.executeArbitrage(weth, dai, tradeAmount);
    }

    function testFlashLoanArbitrageLifecycle() public {
        uint256 flashLoanAmount = 10 ether;
        uint256 tradeAmount = 5 ether;
        uint256 fee = 0.01 ether;

        deal(weth, address(mockPool), flashLoanAmount);
        deal(weth, user, fee);

        flashLoanArbitrage.flashLoan(weth, flashLoanAmount);
        flashLoanArbitrage.executeArbitrage(weth, dai, tradeAmount);

        assertEq(IERC20(weth).balanceOf(address(mockPool)), flashLoanAmount + fee);
        assertGt(IERC20(weth).balanceOf(profitWallet), 0);
    }

    function testNoProfitScenario() public {
        uint256 tradeAmount = 5 ether;

        deal(weth, address(flashLoanArbitrage), tradeAmount);

        flashLoanArbitrage.executeArbitrage(weth, dai, tradeAmount);

        assertEq(IERC20(weth).balanceOf(profitWallet), 0);
    }
}
