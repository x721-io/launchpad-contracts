require('dotenv').config();
const ethers = require('ethers');

const abiERC721 = require('../abis/ERC721.json');
const abiU2UProjectManager = require('../abis/U2UProjectManager.json');
const abiU2UDeployer = require('../abis/U2UDeployer.json');
const abiU2UPremintRoundZero = require('../abis/U2UPremintRoundZero.json');
const abiU2UPremintRoundWhitelist = require('../abis/U2UPremintRoundWhitelist.json');
const abiU2UPremintRoundFCFS = require('../abis/U2UPremintRoundFCFS.json');

const addressU2UProjectManager = '0xcCb0c2790F30AE2E806a49813A2a66037458d315';
const addressU2UDeployerPremintRoundZero = '0xf703A3ABECDC517fdA16cE285320639556e5399e';
const addressU2UDeployerPremintRoundWhitelist = '0x8fA92B85fD688c978BaB751B3F610be21c12939d';
const addressU2UDeployerPremintRoundFCFS = '0x6761628B33a3005040Ba4682dDf1fDd442e912ab';

const addressCollectionOwner = '0x7c5d333f2ce3e919E5B17a237f223D6bAa35a345';
const addressAccount3 = '0x34f2Cecf1d7cf55A8D2B392Ba9EAb0770304478F';
const addressAccount4 = '0xda874Bf03fA9C3B4065EFa14AfBc3bd97582800b';
const addressAccount5 = '0xf11a15b0d71a37B1D3A1eD6A6d1EfC818140D911';
const addressAccount6 = '0xdEc03F9919c086f5B6cE18fD622c2c0D9eCBEF31';
const addressAccount7 = '0x25AbEbC5A3cAF856512440E52124E38a88aC5AE6';

const tokens = [
  {
    id: '18',
    amount: '1',
  },
  {
    id: '19',
    amount: '1',
  },
  {
    id: '20',
    amount: '1',
  },
  {
    id: '21',
    amount: '1',
  },
  {
    id: '22',
    amount: '1',
  },
  {
    id: '23',
    amount: '1',
  },
  {
    id: '24',
    amount: '1',
  },
  {
    id: '25',
    amount: '1',
  },
  {
    id: '26',
    amount: '1',
  },
]

const setup = async () => {
  const provider = new ethers.JsonRpcProvider('https://rpc-nebulas-testnet.uniultra.xyz');
  const signer1 = new ethers.Wallet(process.env.PRIVATE_KEY_1, provider);
  const signer2 = new ethers.Wallet(process.env.PRIVATE_KEY_2, provider);
  
  const contractU2UProjectManager = new ethers.Contract(addressU2UProjectManager, abiU2UProjectManager, signer1);
  const contractU2UDeployerPremintRoundZero = new ethers.Contract(addressU2UDeployerPremintRoundZero, abiU2UDeployer, signer1);
  const contractU2UDeployerPremintRoundWhitelist = new ethers.Contract(addressU2UDeployerPremintRoundWhitelist, abiU2UDeployer, signer1);
  const contractU2UDeployerPremintRoundFCFS = new ethers.Contract(addressU2UDeployerPremintRoundFCFS, abiU2UDeployer, signer1);

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
      start: '1736276369',
      end: '1736362769',
      startClaim: '1736449169',
      maxAmountNFT: '3',
      soldAmountNFT: '0',
      maxAmountNFTPerWallet: '1'
    },
    {
      roundType: '2',
      price: '120',
      start: '1736535569',
      end: '1736621969',
      startClaim: '1736708369',
      maxAmountNFT: '3',
      soldAmountNFT: '0',
      maxAmountNFTPerWallet: '1'
    }
  ];

  const dataCollection = {
    isERC721: true,
    // isERC721: false,
    isU2UCollection: false,
    isPreminted: true,
    collectionAddress: '0xf4a18De962F5b1444f7ff9357cC9EBff610cA01a',   //NFT721
    // collectionAddress: '0x5ce32cDE213de3c074dF1c7Fc519adCCEce4Adce',      // NFT1155
    owner: addressCollectionOwner
  };

  const dataAddressOwner = addressCollectionOwner;
  const txCreateProject = await contractU2UProjectManager.createProject(dataRounds, dataCollection, dataAddressOwner);
  await txCreateProject.wait();
  const dataProjectCount = (await contractU2UProjectManager.getProjectCount()).toString();
  
  const dataRoundZero = dataRounds[0];
  const dataRoundWhitelist = dataRounds[1];
  // const dataRoundFCFS = dataRounds[1];
  const dataRoundFCFS = dataRounds[2];

  // ----------------------------------------------------------------------------------------------

  const txDeployPremintRoundZero = await contractU2UDeployerPremintRoundZero
    .deploy(dataProjectCount, dataRoundZero, dataCollection);
  await txDeployPremintRoundZero.wait();
  const dataDeployedContractsLengthPremintRoundZero = (
    await contractU2UDeployerPremintRoundZero.deployedContractsLength()
  ).toString();
  const dataAddressPremintRoundZero = await contractU2UDeployerPremintRoundZero
    .deployedContracts(dataDeployedContractsLengthPremintRoundZero - 1);

  const txDeployPremintRoundWhitelist = await contractU2UDeployerPremintRoundWhitelist
    .deploy(dataProjectCount, dataRoundWhitelist, dataCollection);
  await txDeployPremintRoundWhitelist.wait();
  const dataDeployedContractsLengthPremintRoundWhitelist = (
    await contractU2UDeployerPremintRoundWhitelist.deployedContractsLength()
  ).toString();
  const dataAddressPremintRoundWhitelist = await contractU2UDeployerPremintRoundWhitelist
    .deployedContracts(dataDeployedContractsLengthPremintRoundWhitelist - 1);

  const txDeployPremintRoundFCFS = await contractU2UDeployerPremintRoundFCFS
    .deploy(dataProjectCount, dataRoundFCFS, dataCollection);
  await txDeployPremintRoundFCFS.wait();
  const dataDeployedContractsLengthPremintRoundFCFS = (
    await contractU2UDeployerPremintRoundFCFS.deployedContractsLength()
  ).toString();
  const dataAddressPremintRoundFCFS = await contractU2UDeployerPremintRoundFCFS
    .deployedContracts(dataDeployedContractsLengthPremintRoundFCFS - 1);

  const txSetRoundContracts = await contractU2UProjectManager
  .setRoundContracts(dataProjectCount, [
    dataAddressPremintRoundZero,
    dataAddressPremintRoundWhitelist,
    dataAddressPremintRoundFCFS
  ]);
  await txSetRoundContracts.wait();

  console.log(
    'dataAddressPremintRoundZero: ', dataAddressPremintRoundZero,
    ' dataAddressPremintRoundWhitelist: ', dataAddressPremintRoundWhitelist,
    ' dataAddressPremintRoundFCFS: ', dataAddressPremintRoundFCFS
  );

  const contractU2UPremintRoundZero = new ethers.Contract(dataAddressPremintRoundZero, abiU2UPremintRoundZero, signer1);
  const contractU2UPremintRoundWhitelist = new ethers.Contract(dataAddressPremintRoundWhitelist, abiU2UPremintRoundWhitelist, signer1);
  const contractU2UPremintRoundFCFS = new ethers.Contract(dataAddressPremintRoundFCFS, abiU2UPremintRoundFCFS, signer1);

  const txAddWhitelistOwnerPremintRoundZero = await contractU2UPremintRoundZero.addWhitelistOwner([addressAccount7]);
  await txAddWhitelistOwnerPremintRoundZero.wait();

  const txAddWhitelistOwnerPremintRoundWhitelist = await contractU2UPremintRoundWhitelist
    .addWhitelistOwner([addressAccount3, addressAccount4, addressAccount5]);
  await txAddWhitelistOwnerPremintRoundWhitelist.wait();

  const txAddTokensPremintRoundZero = await contractU2UPremintRoundZero.addTokens([tokens[0], tokens[1], tokens[2]]);
  await txAddTokensPremintRoundZero.wait();
  const txAddTokensPremintRoundWhitelist = await contractU2UPremintRoundWhitelist.addTokens([tokens[3], tokens[4], tokens[5]]);
  await txAddTokensPremintRoundWhitelist.wait();
  const txAddTokensPremintRoundFCFS = await contractU2UPremintRoundFCFS.addTokens([tokens[6], tokens[7], tokens[8]]);
  await txAddTokensPremintRoundFCFS.wait();
  
  const contractERC721 = new ethers.Contract(dataCollection.collectionAddress, abiERC721, signer2);
  
  const txApproveForRoundZero = await contractERC721.setApprovalForAll(dataAddressPremintRoundZero, true);
  await txApproveForRoundZero.wait();
  const txApproveForRoundWhitelist = await contractERC721.setApprovalForAll(dataAddressPremintRoundWhitelist, true);
  await txApproveForRoundWhitelist.wait();
  const txApproveForRoundFCFS = await contractERC721.setApprovalForAll(dataAddressPremintRoundFCFS, true);
  await txApproveForRoundFCFS.wait();

  // ----------------------------------------------------------------------------------------------
  
  // const gasEstimate = await contractU2UProjectManager.getFunction('createProject').estimateGas(dataRounds, dataCollection, dataAddressOwner);
  // console.log('gasEstimate: ', gasEstimate);
  // console.log('projectCount: ', projectCount);
};

setup();