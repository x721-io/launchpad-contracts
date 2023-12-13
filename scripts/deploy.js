async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const u2uDeployerMintRoundZero = await ethers.deployContract("U2UDeployerMintRoundZero");
  const u2uDeployerMintRoundWhitelist = await ethers.deployContract("U2UDeployerMintRoundWhitelist");
  const u2uDeployerMintRoundFCFS = await ethers.deployContract("U2UDeployerMintRoundFCFS");
  const u2uDeployerPremintRoundZero = await ethers.deployContract("U2UDeployerPremintRoundZero");
  const u2uDeployerPremintRoundWhitelist = await ethers.deployContract("U2UDeployerPremintRoundWhitelist");
  const u2uDeployerPremintRoundFCFS = await ethers.deployContract("U2UDeployerPremintRoundFCFS");

  console.log("u2uDeployerMintRoundZero address:", await u2uDeployerMintRoundZero.getAddress());
  console.log("u2uDeployerMintRoundWhitelist address:", await u2uDeployerMintRoundWhitelist.getAddress());
  console.log("u2uDeployerMintRoundFCFS address:", await u2uDeployerMintRoundFCFS.getAddress());
  console.log("u2uDeployerPremintRoundZero address:", await u2uDeployerPremintRoundZero.getAddress());
  console.log("u2uDeployerPremintRoundWhitelist address:", await u2uDeployerPremintRoundWhitelist.getAddress());
  console.log("u2uDeployerPremintRoundFCFS address:", await u2uDeployerPremintRoundFCFS.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });