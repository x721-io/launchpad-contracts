const { expect } = require('chai');
const hre = require('hardhat');
const {
  loadFixture,
  time,
} = require('@nomicfoundation/hardhat-toolbox/network-helpers');

describe('Premint', function () {
  async function deployFixture() {
    const [acc1, acc2, acc3, acc4, acc5, acc6, acc7] =
      await ethers.getSigners();

      const contractNFT = await ethers.deployContract('NFT');
      const contractNFT1155 = await ethers.deployContract('NFT1155');
      const contractNFTRequired = await ethers.deployContract('NFT');

    const projectManager = await ethers.deployContract('U2UProjectManager');

    const contractU2UDeployerPremintRoundZero = await ethers.deployContract(
      'U2UDeployerPremintRoundZero'
    );
    const contractU2UDeployerPremintRoundWhitelist = await ethers.deployContract(
      'U2UDeployerPremintRoundWhitelist'
    );
    const contractU2UDeployerPremintRoundFCFS = await ethers.deployContract(
      'U2UDeployerPremintRoundFCFS'
    );

    const dataCollection721 = {
      isERC721: true,
      isU2UCollection: false,
      isPreminted: false,
      collectionAddress: contractNFT.target,
      owner: acc2
    };

    const dataCollection1155 = {
      isERC721: false,
      isU2UCollection: false,
      isPreminted: false,
      collectionAddress: contractNFT1155.target,
      owner: acc2
    }

    const dataRounds = [
      {
        roundType: '0',
        price: '100',
        // price: hre.ethers.parseEther('1'),
        // start: await time.latest() + 3600,
        // end: await time.latest() + 7200,
        // startClaim: await time.latest() + 7201,
        start: 1705449600,
        end: 1706572800,
        startClaim: 1706572801,
        maxAmountNFT: '3',
        soldAmountNFT: '0',
        maxAmountNFTPerWallet: '1'
      },
      {
        roundType: '1',
        price: '110',
        // start: await time.latest() + 7202,
        // end: await time.latest() + 10802,
        // startClaim: await time.latest() + 10803,
        start: 1706745600,
        end: 1709164800,
        startClaim: 1709164801,
        maxAmountNFT: '3',
        soldAmountNFT: '0',
        maxAmountNFTPerWallet: '1'
      },
      {
        roundType: '2',
        price: '120',
        // start: await time.latest() + 10804,
        // end: await time.latest() + 14404,
        // startClaim: await time.latest() + 14405,
        start: 1709251200,
        end: 1711756800,
        startClaim: 1711756801,
        maxAmountNFT: '3',
        soldAmountNFT: '0',
        maxAmountNFTPerWallet: '1'
      }
    ];
    const dataRoundZero = dataRounds[0];
    const dataRoundWhitelist = dataRounds[1];
    const dataRoundFCFS = dataRounds[2];

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

    await projectManager.createProject(dataRounds, dataCollection721, acc2);
    // await projectManager.createProject(dataRounds, dataCollection1155, acc2);
    const projectCount = (await projectManager.getProjectCount()).toString();
    
    await contractU2UDeployerPremintRoundZero.deploy(
      projectCount,
      dataRoundZero,
      dataCollection721,
      // dataCollection1155,
      timeframes1,
      projectManager.target,
      acc4.address,
      contractNFTRequired.target
    );
    const deployedContractsLengthRoundZero = (await contractU2UDeployerPremintRoundZero.deployedContractsLength()).toString();
    const addressPremintRoundZero = await contractU2UDeployerPremintRoundZero.deployedContracts(deployedContractsLengthRoundZero - 1);

    await contractU2UDeployerPremintRoundWhitelist.deploy(
      projectCount,
      dataRoundWhitelist,
      dataCollection721,
      // dataCollection1155,
      timeframes2,
      projectManager.target,
      acc2.address,
      hre.ethers.ZeroAddress
    );
    const deployedContractsLengthRoundWhitelist = (await contractU2UDeployerPremintRoundWhitelist.deployedContractsLength()).toString();
    const addressPremintRoundWhitelist = await contractU2UDeployerPremintRoundWhitelist.deployedContracts(deployedContractsLengthRoundWhitelist - 1);

    await contractU2UDeployerPremintRoundFCFS.deploy(
      projectCount,
      dataRoundFCFS,
      dataCollection721,
      // dataCollection1155,
      timeframes3,
      projectManager.target,
      acc2.address,
      hre.ethers.ZeroAddress
    );
    const deployedContractsLengthRoundFCFS = (await contractU2UDeployerPremintRoundFCFS.deployedContractsLength()).toString();
    const addressPremintRoundFCFS = await contractU2UDeployerPremintRoundFCFS.deployedContracts(deployedContractsLengthRoundFCFS - 1);

    await projectManager.setRoundContracts(projectCount, [
      addressPremintRoundZero,
      addressPremintRoundWhitelist,
      addressPremintRoundFCFS
    ]);

    const instanceU2UPremintRoundZero = await ethers.getContractFactory('U2UPremintRoundZero');
    const contractU2UPremintRoundZero = await instanceU2UPremintRoundZero.attach(addressPremintRoundZero);
    await contractU2UPremintRoundZero.addWhitelistOwner([acc7.address]);

    const instanceU2UPremintRoundWhitelist = await ethers.getContractFactory('U2UPremintRoundZero');
    const contractU2UPremintRoundWhitelist = await instanceU2UPremintRoundWhitelist.attach(addressPremintRoundWhitelist);
    await contractU2UPremintRoundWhitelist.addWhitelistOwner([acc3.address, acc4.address, acc5.address]);

    const instanceU2UPremintRoundFCFS = await ethers.getContractFactory('U2UPremintRoundZero');
    const contractU2UPremintRoundFCFS = await instanceU2UPremintRoundFCFS.attach(addressPremintRoundFCFS);
    
    await contractNFTRequired.mintNFT(acc3.address);
    // await contractNFT1155.mintBatchMultipleIdNFT(acc2.address, 3, 3);
    // await contractNFT1155.connect(acc2).setApprovalForAll(contractU2UPremintRoundZero.target, true);
    // await contractNFT1155.connect(acc2).setApprovalForAll(contractU2UPremintRoundWhitelist.target, true);
    // await contractNFT1155.connect(acc2).setApprovalForAll(contractU2UPremintRoundFCFS.target, true);

    await contractNFT.mintBatchNFT(acc2, 9);
    await contractNFT.connect(acc2).setApprovalForAll(contractU2UPremintRoundZero.target, true);
    await contractNFT.connect(acc2).setApprovalForAll(contractU2UPremintRoundWhitelist.target, true);
    await contractNFT.connect(acc2).setApprovalForAll(contractU2UPremintRoundFCFS.target, true);
    
    const tokens1 = [
      // {
      //   id: 1,
      //   amount: 3,
      // }
      {
        id: 1,
        amount: 1,
      },
      {
        id: 2,
        amount: 1,
      },
      {
        id: 3,
        amount: 1,
      },
    ]
    await contractU2UPremintRoundZero.addTokens(tokens1);

    const tokens2 = [
      // {
      //   id: 2,
      //   amount: 3,
      // }
      {
        id: 4,
        amount: 1,
      },
      {
        id: 5,
        amount: 1,
      },
      {
        id: 6,
        amount: 1,
      },
    ]
    await contractU2UPremintRoundWhitelist.addTokens(tokens2);

    const tokens3 = [
      // {
      //   id: 3,
      //   amount: 3,
      // }
      {
        id: 7,
        amount: 1,
      },
      {
        id: 8,
        amount: 1,
      },
      {
        id: 9,
        amount: 1,
      },
    ]
    await contractU2UPremintRoundFCFS.addTokens(tokens3);

    return {
      contractNFT,
      contractNFT1155,
      contractU2UPremintRoundZero,
      contractU2UPremintRoundWhitelist,
      contractU2UPremintRoundFCFS,
      dataCollection721,
      dataCollection1155,
      dataRoundZero,
      dataRoundWhitelist,
      dataRoundFCFS,
      acc1,
      acc2,
      acc3,
      acc4,
      acc5,
      acc6,
      acc7
    };
  }

  it('Should allow eligible users to buy and claim ERC721', async function () {
    const {
      contractNFT,
      contractNFT1155,
      contractU2UPremintRoundZero,
      contractU2UPremintRoundWhitelist,
      contractU2UPremintRoundFCFS,
      dataCollection721,
      dataCollection1155,
      dataRoundZero,
      dataRoundWhitelist,
      dataRoundFCFS,
      acc1,
      acc2,
      acc3,
      acc4,
      acc5,
      acc6,
      acc7
    } = await loadFixture(deployFixture);
    // Round Zero
    await expect(contractU2UPremintRoundZero.connect(acc3).buyERC721({ value: 100 })).to.be.revertedWith('U2U: not started');
    await time.increaseTo(dataRoundZero.start + 1);
    await expect(contractU2UPremintRoundZero.connect(acc3).buyERC721({ value: 100 })).to.be.revertedWith('U2U: not in timeframe');
    await time.increaseTo(dataRoundZero.start + 7200);
    await expect(contractU2UPremintRoundZero.connect(acc3).buyERC721({ value: 100 })).to.changeEtherBalances([acc3, acc4], [-100, 5]);
    await expect(contractU2UPremintRoundZero.connect(acc7).buyERC721({ value: 100 })).to.changeEtherBalances([acc7, acc4], [-100, 5]);
    expect(await contractNFT.balanceOf(contractU2UPremintRoundZero.target)).to.equal(2);
    await expect(contractU2UPremintRoundZero.connect(acc4).buyERC721({ value: 100})).to.be.revertedWith('U2U: only NFT holders');
    await time.increaseTo(dataRoundZero.end + 1);
    await contractU2UPremintRoundZero.transferNFTsToNextRound(contractU2UPremintRoundWhitelist.target, 2);
    await expect(contractU2UPremintRoundZero.connect(acc3).claimERC721()).to.changeTokenBalance(contractNFT, acc3, 1);
    await expect(contractU2UPremintRoundZero.connect(acc7).claimERC721()).to.changeTokenBalance(contractNFT, acc7, 1);
    
    // Round Whitelist
    await time.increaseTo(dataRoundWhitelist.start - 1);
    await expect(contractU2UPremintRoundWhitelist.connect(acc3).buyERC721()).to.be.revertedWith('U2U: not started');
    await time.increaseTo(dataRoundWhitelist.start + 1);
    await expect(contractU2UPremintRoundWhitelist.connect(acc3).buyERC721()).to.be.revertedWith('U2U: not in timeframe');
    await time.increaseTo(dataRoundWhitelist.start + 10800);
    await expect(contractU2UPremintRoundWhitelist.connect(acc3).buyERC721({ value: 110 })).to.changeEtherBalance(acc3, -110);
    await time.increaseTo(dataRoundWhitelist.start + 93600);
    await expect(contractU2UPremintRoundWhitelist.connect(acc3).buyERC721()).to.be.revertedWith('U2U: not in timeframe');
    await time.increaseTo(dataRoundWhitelist.start + 97200);
    await expect(contractU2UPremintRoundWhitelist.connect(acc3).buyERC721({ value: 110 })).to.changeEtherBalance(acc3, -110);
    await expect(contractU2UPremintRoundWhitelist.connect(acc3).buyERC721({ value: 110 })).to.be.revertedWith('U2U: your amount reached');
    expect(await contractNFT.balanceOf(contractU2UPremintRoundWhitelist.target)).to.equal(2);
    await expect(contractU2UPremintRoundWhitelist.connect(acc4).buyERC721({ value: 110 })).to.changeEtherBalance(acc4, -110);
    await expect(contractU2UPremintRoundWhitelist.connect(acc4).buyERC721({ value: 110 })).to.changeEtherBalance(acc4, -110);
    await expect(contractU2UPremintRoundWhitelist.connect(acc4).buyERC721({ value: 110 })).to.be.revertedWith('U2U: no supply');
    await time.increaseTo(dataRoundWhitelist.startClaim);
    await expect(contractU2UPremintRoundWhitelist.connect(acc3).claimERC721()).to.changeTokenBalance(contractNFT, acc3, 2);
    expect(await contractNFT.balanceOf(contractU2UPremintRoundWhitelist.target)).to.equal(2);
    await expect(contractU2UPremintRoundWhitelist.connect(acc4).claimERC721()).to.changeTokenBalance(contractNFT, acc4, 2);
    expect(await contractNFT.balanceOf(contractU2UPremintRoundWhitelist.target)).to.equal(0);

    // // Round FCFS
    await time.increaseTo(dataRoundFCFS.start - 1);
    await expect(contractU2UPremintRoundFCFS.connect(acc5).buyERC721()).to.be.revertedWith('U2U: not started');
    await time.increaseTo(dataRoundFCFS.start + 1);
    await expect(contractU2UPremintRoundFCFS.connect(acc5).buyERC721()).to.be.revertedWith('U2U: not in timeframe');
    await time.increaseTo(dataRoundFCFS.start + 18000);
    await expect(contractU2UPremintRoundFCFS.connect(acc5).buyERC721({ value: 120 })).to.changeEtherBalance(acc5, -120);
    await time.increaseTo(dataRoundFCFS.start + 86400);
    await expect(contractU2UPremintRoundFCFS.connect(acc6).buyERC721({ value: 120 })).to.be.revertedWith('U2U: not in timeframe');
    await time.increaseTo(dataRoundFCFS.start + 104400);
    await expect(contractU2UPremintRoundFCFS.connect(acc6).buyERC721({ value: 120 })).to.changeEtherBalance(acc6, -120);
    await expect(contractU2UPremintRoundFCFS.connect(acc6).buyERC721({ value: 120 })).to.be.revertedWith('U2U: your amount reached');
    await expect(contractU2UPremintRoundFCFS.connect(acc7).buyERC721({ value: 120 })).to.changeEtherBalance(acc7, -120);
    expect(await contractNFT.balanceOf(contractU2UPremintRoundFCFS.target)).to.equal(3);
    await time.increaseTo(dataRoundFCFS.startClaim + 1);
    await expect(contractU2UPremintRoundFCFS.connect(acc5).claimERC721()).to.changeTokenBalance(contractNFT, acc5, 1);
    await expect(contractU2UPremintRoundFCFS.connect(acc6).claimERC721()).to.changeTokenBalance(contractNFT, acc6, 1);
    await expect(contractU2UPremintRoundFCFS.connect(acc7).claimERC721()).to.changeTokenBalance(contractNFT, acc7, 1);
    expect(await contractNFT.balanceOf(contractU2UPremintRoundFCFS.target)).to.equal(0);
  });

  // it('Should allow eligible users to buy and claim ERC1155', async function () {
  //   const {
  //     contractNFT,
  //     contractNFT1155,
  //     contractU2UPremintRoundZero,
  //     contractU2UPremintRoundWhitelist,
  //     contractU2UPremintRoundFCFS,
  //     dataCollection721,
  //     dataCollection1155,
  //     dataRoundZero,
  //     dataRoundWhitelist,
  //     dataRoundFCFS,
  //     acc1,
  //     acc2,
  //     acc3,
  //     acc4,
  //     acc5,
  //     acc6,
  //     acc7
  //   } = await loadFixture(deployFixture);
  //   // Round Zero
  //   await expect(contractU2UPremintRoundZero.connect(acc3).buyERC1155(1, { value: 100 })).to.be.revertedWith('U2U: not started');
  //   await time.increaseTo(dataRoundZero.start + 1);
  //   await expect(contractU2UPremintRoundZero.connect(acc3).buyERC1155(1, { value: 100 })).to.be.revertedWith('U2U: not in timeframe');
  //   await time.increaseTo(dataRoundZero.start + 7200);
  //   await expect(contractU2UPremintRoundZero.connect(acc3).buyERC1155(1, { value: 100 })).to.changeEtherBalances([acc3, acc4], [-100, 5]);;
  //   await expect(contractU2UPremintRoundZero.connect(acc7).buyERC1155(1, { value: 100 })).to.changeEtherBalances([acc7, acc4], [-100, 5]);;
  //   expect(await contractNFT1155.balanceOf(contractU2UPremintRoundZero.target, 1)).to.equal(2);
  //   await expect(contractU2UPremintRoundZero.connect(acc4).buyERC1155(1, { value: 100})).to.be.revertedWith('U2U: only NFT holders');
  //   await time.increaseTo(dataRoundZero.end + 1);
  //   await contractU2UPremintRoundZero.transferNFTsToNextRound(contractU2UPremintRoundWhitelist.target, 2);
  //   await contractU2UPremintRoundZero.connect(acc3).claimERC1155();
  //   await contractU2UPremintRoundZero.connect(acc7).claimERC1155();
  //   expect(await contractNFT1155.balanceOf(acc3.address, 1)).to.equal(1);
  //   expect(await contractNFT1155.balanceOf(acc7.address, 1)).to.equal(1);
  //   expect(await contractNFT1155.balanceOf(contractU2UPremintRoundZero.target, 1)).to.equal(0);
    
  //   // Round Whitelist
  //   await time.increaseTo(dataRoundWhitelist.start - 1);
  //   await expect(contractU2UPremintRoundWhitelist.connect(acc3).buyERC1155(1, { value: 110 })).to.be.revertedWith('U2U: not started');
  //   await time.increaseTo(dataRoundWhitelist.start + 1);
  //   await expect(contractU2UPremintRoundWhitelist.connect(acc3).buyERC1155(1, { value: 110 })).to.be.revertedWith('U2U: not in timeframe');
  //   await time.increaseTo(dataRoundWhitelist.start + 10800);
  //   await expect(contractU2UPremintRoundWhitelist.connect(acc3).buyERC1155(2, { value: 220 })).to.changeEtherBalance(acc3, -220);
  //   await time.increaseTo(dataRoundWhitelist.start + 93600);
  //   await expect(contractU2UPremintRoundWhitelist.connect(acc4).buyERC1155(2, { value: 220 })).to.be.revertedWith('U2U: not in timeframe');
  //   await time.increaseTo(dataRoundWhitelist.start + 97200);
  //   await expect(contractU2UPremintRoundWhitelist.connect(acc4).buyERC1155(1, { value: 110 })).to.changeEtherBalance(acc4, -110);
  //   await expect(contractU2UPremintRoundWhitelist.connect(acc4).buyERC1155(1, { value: 110 })).to.changeEtherBalance(acc4, -110);
  //   await expect(contractU2UPremintRoundWhitelist.connect(acc3).buyERC1155(1, { value: 110 })).to.be.revertedWith('U2U: no supply');
  //   await expect(contractU2UPremintRoundWhitelist.connect(acc4).buyERC1155(2, { value: 220 })).to.be.revertedWith('U2U: no supply');
  //   expect(await contractNFT1155.balanceOf(contractU2UPremintRoundWhitelist.target, 2)).to.equal(3);
  //   expect(await contractNFT1155.balanceOf(contractU2UPremintRoundWhitelist.target, 1)).to.equal(1);
  //   const ownerOfAmount3 = await contractU2UPremintRoundWhitelist.getOwnerOfAmount(acc3.address);
  //   const tokenIdsAcc3 = ownerOfAmount3.map(element => {
  //     return element[0].toString();
  //   });
  //   const tokenIdsAmountAcc3 = ownerOfAmount3.map(element => {
  //     return element[1].toString();
  //   });
  //   const ownerOfAmount4 = await contractU2UPremintRoundWhitelist.getOwnerOfAmount(acc4.address);
  //   const tokenIdsAcc4 = ownerOfAmount4.map(element => {
  //     return element[0].toString();
  //   });
  //   const tokenIdsAmountAcc4 = ownerOfAmount4.map(element => {
  //     return element[1].toString();
  //   });
  //   await time.increaseTo(dataRoundWhitelist.startClaim);
  //   await contractU2UPremintRoundWhitelist.connect(acc3).claimERC1155();
  //   await contractU2UPremintRoundWhitelist.connect(acc4).claimERC1155();
  //   for (let i = 0; i < ownerOfAmount3.length; i++) {
  //     expect(await contractNFT1155.balanceOf(acc3.address, tokenIdsAcc3[i])).to.equal(tokenIdsAmountAcc3[i]);
  //   }
  //   for (let i = 0; i < ownerOfAmount4.length; i++) {
  //     expect(await contractNFT1155.balanceOf(acc4.address, tokenIdsAcc4[i])).to.equal(tokenIdsAmountAcc4[i]);
  //   }
  //   expect(await contractNFT1155.balanceOf(contractU2UPremintRoundWhitelist.target, 1)).to.equal(0);
  //   expect(await contractNFT1155.balanceOf(contractU2UPremintRoundWhitelist.target, 2)).to.equal(0);

  //   // Round FCFS
  //   await time.increaseTo(dataRoundFCFS.start - 1);
  //   await expect(contractU2UPremintRoundFCFS.connect(acc5).buyERC1155(1, { value: 120 })).to.be.revertedWith('U2U: not started');
  //   await time.increaseTo(dataRoundFCFS.start + 1);
  //   await expect(contractU2UPremintRoundFCFS.connect(acc5).buyERC1155(1, { value: 120 })).to.be.revertedWith('U2U: not in timeframe');
  //   await time.increaseTo(dataRoundFCFS.start + 18000);
  //   await expect(contractU2UPremintRoundFCFS.connect(acc5).buyERC1155(1, { value: 120 })).to.changeEtherBalance(acc5, -120);
  //   await time.increaseTo(dataRoundFCFS.start + 86400);
  //   await expect(contractU2UPremintRoundFCFS.connect(acc6).buyERC1155(1, { value: 120 })).to.be.revertedWith('U2U: not in timeframe');
  //   await time.increaseTo(dataRoundFCFS.start + 104400);
  //   await expect(contractU2UPremintRoundFCFS.connect(acc6).buyERC1155(2, { value: 240 })).to.be.revertedWith('U2U: your amount reached');
  //   await expect(contractU2UPremintRoundFCFS.connect(acc6).buyERC1155(1, { value: 120 })).to.changeEtherBalance(acc6, -120);
  //   await expect(contractU2UPremintRoundFCFS.connect(acc7).buyERC1155(1, { value: 120 })).to.changeEtherBalance(acc7, -120);
  //   expect(await contractNFT1155.balanceOf(contractU2UPremintRoundFCFS.target, 3)).to.equal(3);
  //   await time.increaseTo(dataRoundFCFS.startClaim + 1);
  //   await contractU2UPremintRoundFCFS.connect(acc5).claimERC1155();
  //   await contractU2UPremintRoundFCFS.connect(acc6).claimERC1155();
  //   await contractU2UPremintRoundFCFS.connect(acc7).claimERC1155();
  //   expect(await contractNFT1155.balanceOf(acc5.address, 3)).to.equal(1);
  //   expect(await contractNFT1155.balanceOf(acc6.address, 3)).to.equal(1);
  //   expect(await contractNFT1155.balanceOf(acc7.address, 3)).to.equal(1);
  //   expect(await contractNFT1155.balanceOf(contractU2UPremintRoundFCFS.target, 5)).to.equal(0);
  //   expect(await contractNFT1155.balanceOf(contractU2UPremintRoundFCFS.target, 6)).to.equal(0);
  //   expect(await contractNFT1155.balanceOf(contractU2UPremintRoundFCFS.target, 7)).to.equal(0);
  // });
});
