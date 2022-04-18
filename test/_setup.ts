import { ethers } from "hardhat";
import { Signer } from "ethers";
import hre from "hardhat";

import { 
    Registry,
    Vault,
    Swap
} from "../typechain";

export interface TestEnv {
    registry: Registry;
    vault: Vault;
    swap: Swap;
    investors: Signer[],
    erc20: any,
    treasury: Signer,
    creator: Signer
}

const testEnv: TestEnv = {
    registry: {} as Registry,
    vault: {} as Vault,
    swap: {} as Swap,
    investors: [] as Signer[],
    erc20: {} as any,
    treasury: {} as Signer,
    creator: {} as Signer
}

export const unlockAccount = async (address: string) => {
    await hre.network.provider.send("hardhat_impersonateAccount", [address]);
    return address;
};

export function makeSuite(name: string, tests: (testEnv: TestEnv) => void) {
    describe(name, () => {
      tests(testEnv);
    });
}

export async function initialize() {
    const WBNB = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
    const ADA = "0x3ee2200efb3400fabb9aacf31297cbdd1d435d47";
    const ETH = "0x2170ed0880ac9a755fd29b2688956bd959f933f8";

    [
        testEnv.treasury, 
        testEnv.creator, 
        ...testEnv.investors
    ] = await ethers.getSigners();

    testEnv.erc20 = await ethers.getContractAt(
        "@openzeppelin/contracts/token/ERC20/IERC20.sol:IERC20",
        ethers.constants.AddressZero
    );
    
    const RegistryFactory = await ethers.getContractFactory("Registry");
    testEnv.registry = await RegistryFactory.deploy();
    await testEnv.registry.deployed();
    console.log("Registry deployed to: ", testEnv.registry.address);

    const SwapFactory = await ethers.getContractFactory("Swap");
    testEnv.swap = await SwapFactory.deploy();
    await testEnv.swap.deployed();
    console.log("Swap deployed to: ", testEnv.swap.address);
    
    const vaultData = {
        vaultName: "TestVault",
        nTokenName: "Test LP Token",
        nTokenSymbol: "TLP",
        tokenAddresses: [WBNB, ADA, ETH],
        percents: [30, 40, 30],
    };

    await testEnv.registry
        .connect(testEnv.creator)
        .registerVault(
            vaultData,
            10,
            5,
            5,
            testEnv.swap.address,
        );
    
    const vaultAddress =  await testEnv.registry.vaultAddress("TestVault");
    console.log("Vault deployed to: ", vaultAddress);

    const VaultFactory = await ethers.getContractFactory("Vault");
    testEnv.vault = VaultFactory.attach(vaultAddress);
}

before(async () => {
    console.log('--> Deploying test environment...\n');
    await initialize();
    console.log('\n--> Setup finished...\n');
});