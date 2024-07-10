async function main() {
  const [deployer] = await ethers.getSigners();
  const contractName = "NFT"

  console.log("Deploying contracts with the account:", deployer.address);

  const nft721 = await ethers.deployContract(contractName);
  // const nft1155 = await ethers.deployContract("NFT1155");

  const address = await nft721.getAddress();

  console.log("nft721 address:", address);
  await new Promise(resolve => setTimeout(resolve, 2000));
  // console.log("nft1155 address:", await nft1155.getAddress());
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