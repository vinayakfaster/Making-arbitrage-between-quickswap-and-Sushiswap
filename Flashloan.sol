// contracts/FlashLoan.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;


import {IUniswapV2Router01} from "./IUniswapV2Router01.sol";
import {IUniswapV2Factory} from "./IUniswapV2Factory.sol";
import {FlashLoanSimpleReceiverBase} from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

contract BADBOY is FlashLoanSimpleReceiverBase {
    address payable owner;

    address private constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619; ////// weth MAINNET


    address private constant UNISWAP_FACTORY =
    0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f; // same on TESTNET GOERLI                                   ////////////////goreli
    address private constant UNISWAP_ROUTER =
    0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // same on TESTNET GOERLI

    address private constant SUSHISWAP_FACTORY =
    0xc35DADB65012eC5796536bD9864eD8773aBc74C4; // same on TESTNET GOERLI                                   ////////////////goreli
    address private constant SUSHISWAP_ROUTER =
    0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506; // same on TESTNET GOERLI

    address private constant QUICKSWAP_FACTORY = 
    0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32; // same on TESTNET GOERLI                                   ////////////////goreli
    address private constant QUICKSWAP_ROUTER =
    0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff; // same on TESTNET GOERLI 

    // address SUSHISWAP;

    bytes arbdata;
    enum Direction { SUSHISWAPTOQUICKSWAP, QUICKSWAPTOSUSHISWAP } 

    struct ArbInfo {
    Direction direction;
    }

    constructor(
        address _addressProvider
    )
        FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider))
    {
        owner = payable(msg.sender);
       
    }

    // Trade Variables
    uint256 private deadline = block.timestamp + 1 days;
    uint256 private constant MAX_INT =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    // Executed placing a trade
    function placeTrade(
        address _fromToken,
        address _toToken,
        uint256 _amountIn,
        address factory,
        address router
    ) private returns (uint256) {
        address pair = IUniswapV2Factory(factory).getPair(_fromToken, _toToken);
        require(pair != address(0), "Pool does'S not exist");

        // Calculate Amount Out
        address[] memory path = new address[](2);
        path[0] = _fromToken;
        path[1] = _toToken;

        uint256 amountRequired = IUniswapV2Router01(router).getAmountsOut(
            _amountIn,
            path
        )[1];

        // console.log("amountRequired", amountRequired);

        // Perform Arbitrage - Swap for another token
        uint256 amountReceived = IUniswapV2Router01(router)

            .swapExactTokensForTokens(
                _amountIn, // amountIn
                amountRequired, // amountOutMin
                path, // path
                address(this), // address to
                deadline // deadline
            )[1];
        // console.log("amountRecieved", amountReceived);

        require(amountReceived > 0, "Aborted Tx: Trade returned zero");

        return amountReceived;
    }



    function executeOperation(
        address fromToken,
        uint256 amount,
        uint256 premium,
        address /* initiator*/,
        bytes calldata params
    ) external override returns (bool) {

        uint256 amountOwed = amount + premium;
        
        // // Place Trades
        // uint256 loanAmount = amount + premium;

        ArbInfo memory arbInfo = abi.decode(arbdata, (ArbInfo));


        IERC20(fromToken).approve(address(SUSHISWAP_ROUTER), MAX_INT);
        IERC20(fromToken).approve(address(QUICKSWAP_ROUTER), MAX_INT); 
        IERC20(fromToken).approve(address(SUSHISWAP_FACTORY), MAX_INT);
        IERC20(fromToken).approve(address(QUICKSWAP_FACTORY), MAX_INT); 
        
        IERC20(WETH).approve(address(SUSHISWAP_ROUTER), MAX_INT);
        IERC20(WETH).approve(address(QUICKSWAP_ROUTER), MAX_INT);
        IERC20(WETH).approve(address(SUSHISWAP_FACTORY), MAX_INT);
        IERC20(WETH).approve(address(QUICKSWAP_FACTORY), MAX_INT);
        
  
    if (arbInfo.direction == Direction.SUSHISWAPTOQUICKSWAP){


        uint256 trade1Acquired = placeTrade(
            fromToken,
            WETH,
            amount,                                             
            SUSHISWAP_FACTORY,
            SUSHISWAP_ROUTER
        );

        // Trade 2 // SELL                                                                                                      //susisap to quickswap 
        uint256 trade2Acquired = placeTrade(
            WETH,
            fromToken,
            trade1Acquired,
            QUICKSWAP_FACTORY,
            QUICKSWAP_ROUTER
        );
    require(amountOwed >= trade2Acquired, "not sufficieant balance /SUSHISWAP to QUICKSWAP");
    
    } 

    
    if (arbInfo.direction == Direction.QUICKSWAPTOSUSHISWAP){

        uint256 trade1Acquired = placeTrade(
            fromToken,
            WETH,
            amount,
            QUICKSWAP_FACTORY,
            QUICKSWAP_ROUTER
        );

        // Trade 2 // SELL                                                              //QUICKSWAP TO SUSHISWAP
        uint256 trade2Acquired = placeTrade(
            WETH,
            fromToken,
            trade1Acquired,
            SUSHISWAP_FACTORY,
            SUSHISWAP_ROUTER
        );
        require(amountOwed >= trade2Acquired, "not sufficieant balance /QUICKSWAP TO SUSHISWAP");
    }
        

        IERC20(fromToken).approve(address(POOL), amountOwed);

        return true;
    }



    function requestFlashLoan(address _token, uint256 _amount, Direction _direction) public {

        arbdata = abi.encode(ArbInfo({direction: _direction}));

        address receiverAddress = address(this);
        address fromToken = _token;
        uint256 amount = _amount;
        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoanSimple(
            receiverAddress,
            fromToken,
            amount,
            params,
            referralCode
        );
    }

    // GET CONTRACT BALANCE
    // Allows public view of balance for contract
    function getBalanceOfToken(address _address) public view returns (uint256) {
        return IERC20(_address).balanceOf(address(this));
    }


    address me = 0x0000000000000000000000000000000000000000; // replace with your address where you want to send profit ///////////////// IMP

     function withdrawToken(address _tokenContract, uint256 _amount) external onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        
        // transfer the token from address of this contract
        // to address of the user (executing the withdrawToken() function)
        tokenContract.transfer(me, _amount);
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "FU*K...! you are not owner. do not dare again"
        );
        _;
    }

    receive() external payable {}
}