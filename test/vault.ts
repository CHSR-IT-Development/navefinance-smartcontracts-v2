import { ethers } from "hardhat";
import chai from "chai";
import { Signer } from "ethers";
import { TestEnv, makeSuite, unlockAccount } from "./_setup";

const { expect } = chai;

makeSuite('Vault', (testEnv: TestEnv) => {
    const whaleAddress = "0xDb6F5FB9311aE8885620Ee893887C3D85C8293d6";
    let whaleSigner: Signer;
    let nToken: any;
    let nTokenAddress: string;
    let tokenOut1: any, tokenOut2: any, tokenOut3: any;

    const WBNB = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
    const ADA = "0x3ee2200efb3400fabb9aacf31297cbdd1d435d47";
    const ETH = "0x2170ed0880ac9a755fd29b2688956bd959f933f8";

    before(async() => {
        nTokenAddress = await testEnv.vault.nTokenAddress();
        console.log("NToken deployed to: ", nTokenAddress);
        await unlockAccount(whaleAddress);
        whaleSigner = await ethers.provider.getSigner(whaleAddress);
    });

    describe("Deposit", async() => {
        it("Creator deposits 0.2BNB", async() => {
            await testEnv.vault
                .connect(testEnv.creator)
                .deposit({
                    value: ethers.utils.parseEther("0.2")
                });
    
            tokenOut1 = await testEnv.erc20.attach(WBNB);
            tokenOut2 = await testEnv.erc20.attach(ADA);
            tokenOut3 = await testEnv.erc20.attach(ETH);

            const WBNBBalance = await tokenOut1.balanceOf(testEnv.vault.address);
            console.log('vault WBNB amount', WBNBBalance.toString());
    
            const ADABalance = await tokenOut2.balanceOf(testEnv.vault.address);
            console.log('vault ADA amount', ADABalance.toString());
    
            const ETHBalance = await tokenOut3.balanceOf(testEnv.vault.address);
            console.log('vault ETH amount', ETHBalance.toString());

            nToken = await testEnv.erc20.attach(nTokenAddress);
            const nTokenBalance = await nToken.balanceOf(whaleAddress);
            console.log("NToken balance: ", nTokenBalance.toString());
        });
    
        it("Investor1 deposits 0.5BNB", async() => {
            await testEnv.vault
                .connect(testEnv.investors[0])
                .deposit({
                    value: ethers.utils.parseEther("0.5")
                });
            
            const nTokenBalance = await nToken.balanceOf(await testEnv.investors[0].getAddress());
            console.log("Investor1 NToken balance: ", nTokenBalance.toString());
        });
    
        /* it("Investor2 deposits 0.3BNB", async() => {
            await testEnv.vault
                .connect(testEnv.investors[1])
                .deposit({
                    value: ethers.utils.parseEther("0.3")
                });
            
            const nTokenBalance = await nToken.balanceOf(await testEnv.investors[1].getAddress());
            console.log("Investor2 NToken balance: ", nTokenBalance.toString());
        }); */
    });

    describe("Withdraw", async() => {
        it("Creator withdraws 50 nToken", async() => {
            await testEnv.vault
                .connect(testEnv.creator)
                .withdraw(ethers.utils.parseEther("50"));

            const nTokenBalance = await nToken.balanceOf(await testEnv.creator.getAddress());
            console.log("Remaining nToken Balance: ", nTokenBalance.toString());

            const bnbBalance = await ethers.provider.getBalance(await testEnv.creator.getAddress());
            console.log("BNB amount withdrawn: ", bnbBalance.toString());
        });
    });

    describe("TakeFees", () => {
        it("calculate daily fees for vault creators & platform", async() => {
            await testEnv.vault
                .connect(testEnv.treasury)
                .takeFees(ethers.utils.parseEther("50"))
        });
    });

    describe("EditTokens", async() => {
        it("WBNB & ETH", async() => {
            await testEnv.vault
                .connect(testEnv.creator)
                .editTokens([WBNB, ETH], [55,45]);

            const WBNBBalance = await tokenOut1.balanceOf(testEnv.vault.address);
            console.log('vault WBNB amount', WBNBBalance.toString());
    
            const ADABalance = await tokenOut2.balanceOf(testEnv.vault.address);
            console.log('vault ADA amount', ADABalance.toString());
    
            const ETHBalance = await tokenOut3.balanceOf(testEnv.vault.address);
            console.log('vault ETH amount', ETHBalance.toString());
        });
    });
});