# Making-arbitrage-between-wuickswap-and-Sushiswap
you can change exchange (dex) by changing factory and router addresss and abi but it support only uniswap forked dex 


Making arbitrage between Uniswap V2 and Sushiswap

What its included in this repo?

there is an Smartcontract which can be deployed on mainnet using remix IDE

watcher.js is a bot which monitor price 27*7 on sushiswap nd quickswap when bot finds an opportunity to make a profit it take a flashloan from aave lending pool 
and make a arbitrage swap on both exchange 

Running on a ethereum network
Need to set up a provider, the code its setted up to use Infura but you can easily change it.

Deploy the arbitrager contract if you gonna use watcher.js and in both cases you need to deploy the utils contract.

Assuming you own an account with the enough eth for paying the gas and fees (and if you use normal swap the tokens as well) you are ready to run the bots. Remember that as they are, the bots are not ready for production and even with the changes proposed bellow I dont recommend use them for that porpuse, do it at your own risk.

Notes
10/07/21 -> If u are having gas issues, check out this tiny thread

14/06/21 -> I realize that the arbitrage, in the manner that I did it, its not rigth conceptually. The proper way, I think, it would have been using a CEX (Centralized EXchange) like Binance or Coinbase as off-chain oracle and use Avee flashloans (similar to how flashswaps works) to arbitrage whatever DEX (Decentralized EXchanges) I wished. The only 'drawback' that I can see with this approach is that you must pay back the flashloan in the same asset you borrow so you probably need and extra trade. Personally I only understand how Uniswap like exchanges works, in other words, AMMs that uses the constant product formula to set the price. What Im trying to say its that I dont know if other kind of AMMs are arbitrageable (I remember hear about a DEX that auto regulates its prices), so keep that in mind. But, that said, I think it is a good project to get confidence with the ethereum blackchain, understand how it works, the software stack and learn how one of the most important protocols that the network has, Uniswap, works. Good luck!

Installation
clone the repo
npm install 
