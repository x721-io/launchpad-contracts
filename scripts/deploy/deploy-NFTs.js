async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const nft721 = await ethers.deployContract("NFT");
  const nft1155 = await ethers.deployContract("NFT1155");

  console.log("nft721 address:", await nft721.getAddress());
  console.log("nft1155 address:", await nft1155.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });