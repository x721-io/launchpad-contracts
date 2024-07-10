const isPremint = false;

async function main() {
  const [deployer] = await ethers.getSigners();
  const contractNames = ["U2UDeployerMintRoundZero", "U2UDeployerMintRoundWhitelist", "U2UDeployerMintRoundFCFS"];
  const preMintContractNames = ["U2UDeployerPremintRoundZero", "U2UDeployerPremintRoundWhitelist", "U2UDeployerPremintRoundFCFS"];

  console.log("Deploying contracts with the account:", deployer.address);

  for(let i = 0; i < contractNames.length; i++) {
    const name = contractNames[i];
    const u2uDeployer = await ethers.deployContract(name);
    const address = await u2uDeployer.getAddress();
    await new Promise(resolve => setTimeout(resolve, 5000));
    try {
      const verificationId = await hre.run("verify:verify", {
        address: address,
        contract: `contracts/deployers/${name}.sol:${name}`,
        constructorArguments: [],
      });
    } catch(err) {
      console.log(err)
    }
    console.log('Deployed: ', address);
  }
  
  
  if(isPremint) {
    for(let i = 0; i < preMintContractNames.length; i++) {
      const name = contractNames[i];
      const u2uDeployer = await ethers.deployContract(name);
      const address = await u2uDeployer.getAddress();
      await new Promise(resolve => setTimeout(resolve, 5000));
      try {
        const verificationId = await hre.run("verify:verify", {
          address: address,
          contract: `contracts/deployers/${name}.sol:${name}`,
          constructorArguments: [],
        });
      } catch(err) {
        console.log(err)
      }
      console.log('Deployed Premint: ', address);
    }
    console.log('Premint Deployed: ', premintU2uDeployer)
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });