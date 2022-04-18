// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import hre from "hardhat";

async function main() {
    await hre.run("verify:verify", {
        address: "0x0A0463220fceeAA5f46CBcdbc240D7147682c17F",
        constructorArguments: [
          "0x87682fEE6dbC7A4475b5E1352c7C663306B2e028",
          "0x488177c42bD58104618cA771A674Ba7e4D5A2FBB",
          { 
            vaultName: "TestVault", 
            nTokenName: "LP Token", 
            nTokenSymbol: "LPT",  
            tokenAddresses: ["0xae13d989dac2f0debff460ac112a837c89baa7cd", "0xfe38af83f6ac838bfadc6f584fbde937484dba7c", "0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47"],  
            percents: [30, 40, 30] 
          },
          10,
          5,
          5,
          "0x7386F3434D1365F55EF19724c742E7906f8A4cB1",
        ],
    });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
