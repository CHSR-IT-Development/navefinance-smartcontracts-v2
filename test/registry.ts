import chai from "chai";
import { TestEnv, makeSuite } from "./_setup";

const { expect } = chai;

makeSuite("Registry", (testEnv: TestEnv) => {
    
    it("isRegistered", async() => {
        const isRegistered = await testEnv.registry.isRegistered("TestVault");
        expect(isRegistered).to.equal(true);
    });

    it("vaultCreator", async() => {
        const vaultAddress =  await testEnv.registry.vaultAddress("TestVault");
        const vaultCreator = await testEnv.registry.vaultCreator(vaultAddress);
        expect(vaultCreator).to.equal(await testEnv.creator.getAddress());
    });

    it("getPlatformFee", async() => {
        const platformFee = await testEnv.registry.platformFeeRate();
        expect(platformFee.toString()).to.equal("15");
    });
});