async function main() {
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address);

  const u2uMintRoundWhitelistCustomized = await ethers.deployContract(
    'U2UMintRoundWhitelistCustomized',
    [
      7,
      {
        roundType: '1',
        price: '0',
        start: '1736362769',
        end: '1743292800',
        startClaim: '0',
        maxAmountNFT: '0',
        soldAmountNFT: '0',
        maxAmountNFTPerWallet: '0'
      },
      {
        isERC721: false,
        isU2UCollection: false,
        isPreminted: false,
        collectionAddress: '0x37CfaDbbAA9fFfD1bf491dC2EdAd470cD88EfB3c',  // U2U NFT Campaign (U2UNFT_CAMPAIGN)
        owner: '0xE4B8f63C111EF118587D30401e1Db99f4CfBD900'
      },
      [
        {
          hourStart: '2',
          minuteStart: '0',
          hourEnd: '3',
          minuteEnd: '59'
        }
      ],
      '0x7CD840C81A17fAE6C0761F9bbF8666F929ace029',
      '0xE4B8f63C111EF118587D30401e1Db99f4CfBD900'
    ]
  );

  console.log('u2uMintRoundWhitelistCustomized: ', await u2uMintRoundWhitelistCustomized.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
