async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer)

  console.log("Deploying contracts with the account:", deployer.address);

  const u2uProjectManager = await ethers.deployContract("U2UProjectManager", ["0x2743eEC46576f76f47334569074242F3D9a90B44"]);

  console.log("u2uProjectManager address:", await u2uProjectManager.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });