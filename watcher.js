const { Console } = require('console');
const Web3 = require('web3');
const abis = require('./abis');
// const Flashloan = require('./flashloan.json')

const infuraurl = 'your-infura-api';
const PRIVATE_KEY = 'your-privatekey-here';

const web3 = new Web3(
  new Web3.providers.WebsocketProvider(infuraurl)
);

const { address: admin } = web3.eth.accounts.wallet.add(PRIVATE_KEY);

let Faddress = ('address-of-privatekey');

const flashloan = new web3.eth.Contract(
  abis.flashloan.abi,
  "0x157E7B63c10A9060be339F41d41DaA9276e9FaF9"
);

const DIRECTION = {
  SUSHISWAPTOQUICKSWAP: 0,
  QUICKSWAPTOSUSHISWAP: 1
};






async function checkBal(args) {

     const { inputTokenSymbol, inputTokenAddress, outputTokenSymbol, outputTokenAddress, inputAmount } = args

        const sushi = new web3.eth.Contract(
          abis.sushiswap.sushi,
          "0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506" // mainnet
        );

        const quickswap = new web3.eth.Contract(
          abis.quickswap.Quick,
          "0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff" // mainnet
        );



        const buyquickswapex = await quickswap.methods.getAmountsOut(inputAmount, [inputTokenAddress, outputTokenAddress]).call(); //buy on quick
        const buysushiex = await sushi.methods.getAmountsOut(inputAmount, [inputTokenAddress, outputTokenAddress]).call(); // buy on sushi
        
        const sellquickswapex = await quickswap.methods.getAmountsOut(buysushiex[1], [outputTokenAddress, inputTokenAddress]).call();
        const sellsushiex = await sushi.methods.getAmountsOut(buyquickswapex[1], [outputTokenAddress, inputTokenAddress]).call();


        console.table([{
          'Input Token': inputTokenSymbol,
          'Output Token': outputTokenSymbol,
          'Input Amount': web3.utils.fromWei(inputAmount, 'Ether'),
          'quickswap.ex Return on buy': web3.utils.fromWei(buyquickswapex[1], 'Ether'), // return in eth
          'Sushiswap.ex Return on buy': web3.utils.fromWei(buysushiex[1], 'Ether'),
          'quickswap.ex Return on sell': web3.utils.fromWei(sellquickswapex[1], 'Ether'), // return in eth
          'Sushiswap.ex Return on sell': web3.utils.fromWei(sellsushiex[1], 'Ether') // return in dai
          // 'Timestamp': moment().tz('America/Chicago').format()
        }])

        // const maxe = Math.max(quickswapex[1],sushiex[1],apeswapex[1])

        // const mine = Math.min(quickswapex[1],sushiex[1],apeswapex[1])
        // console.log(inputAmount);

        const AMOUNT_DAI_WEI = web3.utils.toBN(web3.utils.toWei(inputAmount));

        const ETHFromQuickswapex = web3.utils.toBN(sellquickswapex[1])
        const ETHFromsushiex = web3.utils.toBN(sellsushiex[1])
        // const ETHFromapeswapex = web3.utils.toBN(quickswapex[1])

        if (ETHFromQuickswapex.gt(AMOUNT_DAI_WEI)) {
          console.log('QUICKSWAP')

            const tx1 = flashloan.methods.requestFlashLoan(
            '0xDF1742fE5b0bFc12331D8EAec6b478DfDbD31464',
            AMOUNT_DAI_WEI,
            DIRECTION.SUSHISWAPTOQUICKSWAP
          );
          const [gasPrice, gasCost1] = await Promise.all([
            web3.eth.getGasPrice(),
            tx1.estimateGas({ from: admin })
          ]);
          const data = tx1.encodeABI();
          const txData = {
            from: admin,
            to: Faddress,
            data,
            gas: gasCost1,
            gasPrice
          };
          const receipt = await web3.eth.sendTransaction(txData);
          console.log(`Transaction hash: ${receipt.transactionHash}`);

        }


        if (ETHFromsushiex.gt(AMOUNT_DAI_WEI)) {
          console.log('QUICKSWAP')
          const tx1 = flashloan.methods.requestFlashLoan(
            '0xDF1742fE5b0bFc12331D8EAec6b478DfDbD31464',
            AMOUNT_DAI_WEI,
            DIRECTION.QUICKSWAPTOSUSHISWAP
          );
          const [gasPrice, gasCost1] = await Promise.all([
            web3.eth.getGasPrice(),
            tx1.estimateGas({ from: admin })
          ]);
          const data = tx1.encodeABI();
          const txData = {
            from: admin,
            to: Faddress,
            data,
            gas: gasCost1,
            gasPrice
          };
          const receipt = await web3.eth.sendTransaction(txData);
          console.log(`Transaction hash: ${receipt.transactionHash}`);

      }

}





web3.eth.subscribe('newBlockHeaders')
  .on('data', async block => {
    console.log(`New block Mining. Block # ${block.number}`);


    try {

      await checkBal({
        inputTokenSymbol: 'DAI',
        inputTokenAddress: '0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063',
        outputTokenSymbol: 'ETH',
        outputTokenAddress: '0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619',
        inputAmount: web3.utils.toWei('1400', 'ETHER'),
      })


      // await checkBal({
      //   inputTokenSymbol: 'ETH',
      //   inputTokenAddress: '0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619',
      //   outputTokenSymbol: 'DAI',
      //   outputTokenAddress: '0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063',
      //   inputAmount: web3.utils.toWei('1.1', 'ETHER'),
      //   out: '1400.349852560194921864'
      // })
      
    } catch (error) {
      console.error(error)
      return
    }

  })
  .on('error', error => {
    console.log(error);
  });