require('dotenv').config();
const ethers = require('ethers');

const abiU2UProjectManager = require('../../abis/U2UProjectManager.json');
const abiU2UDeployer = require('../../abis/U2UDeployer.json');
const abiU2UMintRoundZero = require('../../abis/U2UMintRoundZero.json');
const abiU2UMintRoundWhitelist = require('../../abis/U2UMintRoundWhitelist.json');
const abiU2UMintRoundFCFS = require('../../abis/U2UMintRoundFCFS.json');

const addressU2UProjectManager = '0x7CD840C81A17fAE6C0761F9bbF8666F929ace029';
const addressU2UDeployerMintRoundZero = '0xa6A20894e0255Ec59BAf12B04dd0C23939071972';
const addressU2UDeployerMintRoundWhitelist = '0x08ab0baf5CA5EB37655edD8D27D7909826401D90';
const addressU2UDeployerMintRoundFCFS = '0xDc51De965f53c55e7c5a027bc640a03ca873DdE5';

const addressCollectionOwner = '0x7c5d333f2ce3e919E5B17a237f223D6bAa35a345';
// const addressCollectionOwner = '0xE4B8f63C111EF118587D30401e1Db99f4CfBD900';
const addressAccount3 = '0x34f2Cecf1d7cf55A8D2B392Ba9EAb0770304478F';
const addressAccount4 = '0xda874Bf03fA9C3B4065EFa14AfBc3bd97582800b';
const addressAccount5 = '0xf11a15b0d71a37B1D3A1eD6A6d1EfC818140D911';
const addressAccount6 = '0xdEc03F9919c086f5B6cE18fD622c2c0D9eCBEF31';
const addressAccount7 = '0x25AbEbC5A3cAF856512440E52124E38a88aC5AE6';

const setup = async () => {
  const provider = new ethers.JsonRpcProvider('https://rpc-nebulas-testnet.uniultra.xyz');
  const signer = new ethers.Wallet(process.env.PRIVATE_KEY_1, provider);
  
  const contractU2UProjectManager = new ethers.Contract(addressU2UProjectManager, abiU2UProjectManager, signer);
  const contractU2UDeployerMintRoundZero = new ethers.Contract(addressU2UDeployerMintRoundZero, abiU2UDeployer, signer);
  const contractU2UDeployerMintRoundWhitelist = new ethers.Contract(addressU2UDeployerMintRoundWhitelist, abiU2UDeployer, signer);
  const contractU2UDeployerMintRoundFCFS = new ethers.Contract(addressU2UDeployerMintRoundFCFS, abiU2UDeployer, signer);

  const dataRounds = [
    {
      roundType: '0',
      price: '100',
      start: '1736017169',
      end: '1736103569',
      startClaim: '1736189969',
      maxAmountNFT: '3',
      soldAmountNFT: '0',
      maxAmountNFTPerWallet: '1'
    },
    {
      roundType: '1',
      price: '110',
      start: '1736362769',
      end: '1743292800',
      startClaim: '0',
      maxAmountNFT: '3',
      soldAmountNFT: '0',
      maxAmountNFTPerWallet: '1'
    },
    {
      roundType: '2',
      price: '120',
      start: '1743475500',
      end: '1743561900',
      startClaim: '0',
      maxAmountNFT: '3',
      soldAmountNFT: '0',
      maxAmountNFTPerWallet: '1'
    }
  ];

  const dataCollection = {
    // isERC721: true,
    isERC721: false,
    isU2UCollection: false,
    // isPreminted: true,
    isPreminted: false,
    // collectionAddress: '0xf4a18De962F5b1444f7ff9357cC9EBff610cA01a',   //NFT721
    collectionAddress: '0x5ce32cDE213de3c074dF1c7Fc519adCCEce4Adce',      // NFT1155
    // collectionAddress: '0x37CfaDbbAA9fFfD1bf491dC2EdAd470cD88EfB3c',  // U2U NFT Campaign (U2UNFT_CAMPAIGN)
    owner: addressCollectionOwner
  };

  const timeframes1 = [
    {
      hourStart: '2',
      minuteStart: '0',
      hourEnd: '3',
      minuteEnd: '59'
    }
  ];
  const timeframes2 = [
    {
      hourStart: '3',
      minuteStart: '0',
      hourEnd: '4',
      minuteEnd: '59',
    }
  ];
  const timeframes3 = [
    {
      hourStart: '5',
      minuteStart: '0',
      hourEnd: '6',
      minuteEnd: '59',
    }
  ];

  const dataAddressOwner = addressCollectionOwner;
  const txCreateProject = await contractU2UProjectManager.createProject(dataRounds, dataCollection, dataAddressOwner);
  await txCreateProject.wait();
  const dataProjectCount = (await contractU2UProjectManager.getProjectCount()).toString();
  
  const dataRoundZero = dataRounds[0];
  // const dataRoundWhitelist = dataRounds[0];
  const dataRoundWhitelist = dataRounds[1];
  // const dataRoundFCFS = dataRounds[0];
  // const dataRoundFCFS = dataRounds[1];
  const dataRoundFCFS = dataRounds[2];

  // ----------------------------------------------------------------------------------------------

  const txDeployMintRoundZero = await contractU2UDeployerMintRoundZero.deploy(
    dataProjectCount,
    dataRoundZero,
    dataCollection,
    timeframes1,
    addressU2UProjectManager,
    dataAddressOwner,
    '0x02bbf482d7a8b027a5B1b8A84f4BccC1ab67D276'
  );
  await txDeployMintRoundZero.wait();
  const dataDeployedContractsLengthMintRoundZero = (
    await contractU2UDeployerMintRoundZero.deployedContractsLength()
  ).toString();
  const dataAddressMintRoundZero = await contractU2UDeployerMintRoundZero
    .deployedContracts(dataDeployedContractsLengthMintRoundZero - 1);

  const txDeployMintRoundWhitelist = await contractU2UDeployerMintRoundWhitelist.deploy(
    dataProjectCount,
    dataRoundWhitelist,
    dataCollection,
    timeframes2,
    addressU2UProjectManager,
    dataAddressOwner,
    ethers.ZeroAddress
  );
  await txDeployMintRoundWhitelist.wait();
  const dataDeployedContractsLengthMintRoundWhitelist = (
    await contractU2UDeployerMintRoundWhitelist.deployedContractsLength()
  ).toString();
  const dataAddressMintRoundWhitelist = await contractU2UDeployerMintRoundWhitelist
    .deployedContracts(dataDeployedContractsLengthMintRoundWhitelist - 1);

  const txDeployMintRoundFCFS = await contractU2UDeployerMintRoundFCFS.deploy(
    dataProjectCount,
    dataRoundFCFS,
    dataCollection,
    timeframes3,
    addressU2UProjectManager,
    dataAddressOwner,
    ethers.ZeroAddress
  );
  await txDeployMintRoundFCFS.wait();
  const dataDeployedContractsLengthMintRoundFCFS = (
    await contractU2UDeployerMintRoundFCFS.deployedContractsLength()
  ).toString();
  const dataAddressMintRoundFCFS = await contractU2UDeployerMintRoundFCFS
    .deployedContracts(dataDeployedContractsLengthMintRoundFCFS - 1);

  const txSetRoundContracts = await contractU2UProjectManager
    .setRoundContracts(dataProjectCount, [
      dataAddressMintRoundZero,
      dataAddressMintRoundWhitelist,
      dataAddressMintRoundFCFS
    ]);
  await txSetRoundContracts.wait();

  console.log(
    'dataAddressMintRoundZero: ', dataAddressMintRoundZero,
    ' dataAddressMintRoundWhitelist: ', dataAddressMintRoundWhitelist,
    ' dataAddressMintRoundFCFS: ', dataAddressMintRoundFCFS
  );

  const contractU2UMintRoundZero = new ethers.Contract(dataAddressMintRoundZero, abiU2UMintRoundZero, signer);
  const contractU2UMintRoundWhitelist = new ethers.Contract(dataAddressMintRoundWhitelist, abiU2UMintRoundWhitelist, signer);
  const contractU2UMintRoundFCFS = new ethers.Contract(dataAddressMintRoundFCFS, abiU2UMintRoundFCFS, signer);

  const txAddWhitelistOwnerMintRoundZero = await contractU2UMintRoundZero.addWhitelistOwner([addressAccount7]);
  await txAddWhitelistOwnerMintRoundZero.wait();

  const txAddWhitelistOwnerMintRoundWhitelist = await contractU2UMintRoundWhitelist
    .addWhitelistOwner([addressAccount3, addressAccount4, addressAccount5]);
  await txAddWhitelistOwnerMintRoundWhitelist.wait();
  
  // const gasEstimate = await contractU2UProjectManager.getFunction('createProject').estimateGas(dataRounds, dataCollection, dataAddressOwner);
  // console.log('gasEstimate: ', gasEstimate);
  // console.log('projectCount: ', projectCount);
};

setup();