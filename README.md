Arbitrage Between Uniswap V2 and Sushiswap
This repository contains a smart contract that can be deployed on the Ethereum mainnet using Remix IDE. Additionally, there's a bot (watcher.js) designed to monitor prices 24/7 on Sushiswap and Uniswap V2. When the bot identifies an opportunity to make a profit, it initiates a flash loan from the Aave lending pool and executes an arbitrage swap on both exchanges.

Features:
Smart contract for arbitrage trading between Uniswap V2 and Sushiswap.

watcher.js bot for continuous price monitoring and arbitrage execution.

Flexibility to change exchange (DEX) by adjusting factory and router addresses and ABIs.

Supports only Uniswap forked DEX.

Easily deployable on Ethereum mainnet using Remix IDE.

Requires setting up a provider, currently configured to use Infura, but easily adjustable.

Deploy the arbitrager contract for use with watcher.js. Additionally, deploy the utils contract.

Assumes ownership of an account with sufficient ETH for gas and fees.

Note: The bots are not production-ready. Use at your own risk.


Installation:
Clone the repository:


bash
Copy code
git clone <repository_url>
Install dependencies:

bash
Copy code
npm install
Usage:
Deploy the smart contract on Remix IDE for mainnet deployment.

Configure the provider to use Infura or any preferred Ethereum provider.

Ensure sufficient ETH balance in the account for gas and fees.

Run the watcher.js bot for continuous arbitrage monitoring and execution.

Adjust the settings and parameters as needed for your specific use case.

Notes:
If experiencing gas issues, refer to the provided thread for potential solutions.

Conceptual clarification: Arbitrage is not ideal in its current implementation. Consider using a centralized exchange (CEX) as an off-chain oracle and Aave flash loans for arbitrage execution.
Exercise caution and conduct thorough testing before deploying to production.
