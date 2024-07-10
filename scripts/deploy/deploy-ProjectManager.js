async function main() {
  const [deployer] = await ethers.getSigners();
  const contractName = "U2UProjectManager"

  console.log("Deploying contracts with the account:", deployer.address);

  const u2uProjectManager = await ethers.deployContract(contractName);
  const address = await u2uProjectManager.getAddress();

  console.log("u2uProjectManager address:", address);

  await new Promise(resolve => setTimeout(resolve, 2000));
  try {
    const verificationId = await hre.run("verify:verify", {
      address: address,
      contract: `contracts/${contractName}.sol:${contractName}`,
      constructorArguments: [],
    });
  } catch(err) {
    console.log(err)
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });