const hre = require('hardhat');
require('dotenv').config();
const swapRouter = '0x10ED43C718714eb63d5aA57B78B54704E256024E';
const usdAddr = '0x55d398326f99059fF775485246999027B3197955';

async function main() {
  // npx hardhat run scripts/deploy.js --network bsc
  const GWEI = await hre.ethers.getContractFactory('KO');

  const deployFeeReceiver = '0x81B37073Fe8445c1A73d1D4608edc5C24A5a2b90';
  const tokenPas = [
    'CZ', // name
    'CZ',     // symbol
    deployFeeReceiver, // fundReceiver
    450, // fundTaxBuy 买营销
    449, // fundTaxSell 卖营销
    0,  // lpTaxBuy 买回流
    1,  // lpTaxSell 卖回流
    hre.ethers.parseUnits('1000000', 18), // totalSupply
    swapRouter // swapRouter placeholder
  ];

  

  const gwei = await GWEI.deploy(tokenPas, deployFeeReceiver, usdAddr);
  await gwei.waitForDeployment();

  console.log('gwei deployed to:', gwei.target);

  const constructorArguments = [
    tokenPas,deployFeeReceiver,usdAddr
  ];
  
  // 开源操作
  try {
    await hre.run('verify:verify', {
      address: gwei.target,
      constructorArguments
    });
    console.log('Verification finished');
  } catch (e) {
    console.error('Verification failed:', e.message || e);
    process.exitCode = 1;
  }
  // 权限转移到 ownerAddress
  try {
    const tx = await gwei.transferOwnership(deployFeeReceiver);
    await tx.wait();
    console.log('Ownership transferred to:', deployFeeReceiver);
  } catch (e) {
    console.error('transferOwnership failed:', e.message || e);
  }

  // 代币转移到 ownerAddress 地址

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
