import { ethers } from "hardhat";
import chai from "chai";
import { Signer } from "ethers";
import { TestEnv, makeSuite, unlockAccount } from "./_setup";

const { expect } = chai;

makeSuite('Swap test', (testEnv: TestEnv) => {
  let whaleSigner: Signer;
  const whaleAddress = "0xDb6F5FB9311aE8885620Ee893887C3D85C8293d6";

  before(async () => {
    await unlockAccount(whaleAddress);
    whaleSigner = await ethers.provider.getSigner(whaleAddress);
  });

  it("swap BNB into ADA", async() => {
    const ADA = "0x3ee2200efb3400fabb9aacf31297cbdd1d435d47";
    const AMOUNT_OUT_MIN = 0;
    const tokenOut = await testEnv.erc20.attach(ADA);

    const beforeBalance = await tokenOut.balanceOf(await testEnv.investors[0].getAddress());
    console.log("Before ADA Balance: ", beforeBalance.toString());
    
    await testEnv.swap
      .connect(whaleSigner)
      .swapBNBForTokens(
        tokenOut.address, 
        AMOUNT_OUT_MIN, 
        await testEnv.investors[0].getAddress(), 
        {
          value: ethers.utils.parseEther("0.1")
        }
      );

    const afterBalance = await tokenOut.balanceOf(await testEnv.investors[0].getAddress());
    console.log("After ADA Balance: ", afterBalance.toString());
  });

  /* it("swap BUSD into ETH", async() => {
    const BUSD = "0xe9e7cea3dedca5984780bafc599bd69add087d56";
    const ETH = "0x2170ed0880ac9a755fd29b2688956bd959f933f8";

    const AMOUNT_IN = ethers.utils.parseUnits("100", 18);
    const AMOUNT_OUT_MIN = 0;

    const tokenIn = await testEnv.erc20.attach(BUSD);
    const tokenOut = await testEnv.erc20.attach(ETH);

    await tokenIn
      .connect(whaleSigner)
      .approve(testEnv.swap.address, ethers.utils.parseUnits("1000", 18));

    await testEnv.swap
      .connect(whaleSigner)
      .swapTokensForTokens(
        tokenIn.address, 
        tokenOut.address, 
        AMOUNT_IN, 
        AMOUNT_OUT_MIN, 
        await testEnv.investors[1].getAddress()
      );
    
    const balance = await tokenOut.balanceOf(await testEnv.investors[1].getAddress());
    console.log('swapped ETH amount', balance.toString());
  }); */

  /* it("swap ADA into BNB", async() => {
    const ADA = "0x3ee2200efb3400fabb9aacf31297cbdd1d435d47";
    const AMOUNT_IN = ethers.utils.parseUnits("30", 18);
    const AMOUNT_OUT_MIN = 0;

    const tokenIn = await testEnv.erc20.attach(ADA);

    const beforeBalance = await tokenIn.balanceOf(await testEnv.investors[0].getAddress());
    console.log("Before ADA Balance: ", beforeBalance.toString());
    
    const beforeBnbBalance = await ethers.provider.getBalance(await testEnv.investors[0].getAddress());
    console.log("Before BNB Balance: ", beforeBnbBalance.toString());

    await tokenIn
      .connect(testEnv.investors[0])
      .approve(testEnv.swap.address, ethers.utils.parseUnits("1000", 18));

    await testEnv.swap
      .connect(testEnv.investors[0])
      .swapTokensForBNB(
        tokenIn.address, 
        AMOUNT_IN,
        AMOUNT_OUT_MIN, 
        await testEnv.investors[0].getAddress()
      );

    const afterBalance = await tokenIn.balanceOf(await testEnv.investors[0].getAddress());
    console.log("After ADA Balance: ", afterBalance.toString());
    
    const afterBnbBalance = await ethers.provider.getBalance(await testEnv.investors[0].getAddress());
    console.log("After BNB Balance: ", afterBnbBalance.toString());
  }); */
});