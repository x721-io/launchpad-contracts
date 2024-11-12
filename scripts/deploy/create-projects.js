const abi = require('../../abis/U2UProjectManager.json')
const ethers = require('ethers')

async function main() {
  const provider = new ethers.JsonRpcProvider('https://rpc-nebulas-testnet.uniultra.xyz');
  const signer = new ethers.Wallet(process.env.PRIVATE_KEY_1, provider);

  const u2uProjectManager = new ethers.Contract("0x0F57c56f9C34A767Fdc11C23E7221Fbf9B8a6f62", abi, signer);
  const dataAddressOwner = "0x0d3C3d95dF3c9e71d39fd00Eb842026713ad64fE"

  const dataRounds = [
    {
      roundType: '2',
      price: '500000000000000000',
      start: '1731344400',
      end: '1739034000',
      startClaim: '0',
      maxAmountNFT: '100000000000000',
      soldAmountNFT: '0',
      maxAmountNFTPerWallet: '1'
    }
  ];


  const dataCollection = {
    // isERC721: true,
    isERC721: true,
    isU2UCollection: false,
    // isPreminted: true,
    isPreminted: false,
    // collectionAddress: '0xf4a18De962F5b1444f7ff9357cC9EBff610cA01a',   //NFT721
    collectionAddress: '0x2AC49144a804E1f8652e1A0C1bAD90606AC2094A',      // NFT1155
    // collectionAddress: '0x37CfaDbbAA9fFfD1bf491dC2EdAd470cD88EfB3c',  // U2U NFT Campaign (U2UNFT_CAMPAIGN)
    owner: dataAddressOwner
  };

  const txCreateProject = await u2uProjectManager.createProject(dataRounds, dataCollection, dataAddressOwner);
  await txCreateProject.wait();

  console.log('======', txCreateProject)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
