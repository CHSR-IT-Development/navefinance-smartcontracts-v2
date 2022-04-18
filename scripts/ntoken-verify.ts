import hre from "hardhat";

async function main() {
    await hre.run("verify:verify", {
        address: "0x2F3c85216aC115DBf25b9233Bc470cdA20796D9E",
        constructorArguments: [
          "0x0A0463220fceeAA5f46CBcdbc240D7147682c17F",
          "LP Token",
          "LPT"
        ],
    });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
