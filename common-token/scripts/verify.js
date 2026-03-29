/**
 * Run with: npx hardhat run scripts/verify.js --network bsc
 * Edit `address` and `constructorArguments` below to match your deployed contract.
 */
const hre = require('hardhat');

async function verifyCode() {
  const address = '0xed482652184A5c7287f02E30d746E0b304Ab2A4a';
  const usdAddr = '0x55d398326f99059fF775485246999027B3197955';
  const swapRouter = '0x10ED43C718714eb63d5aA57B78B54704E256024E';

  const deployFeeReceiver = '0x8B78c7D1F4872b2FABA9f162b61469D4c860A9B8';
  const tokenPas = [
    'CZ', // name
    'CZ',     // symbol
    deployFeeReceiver, // fundReceiver
    449, // fundTaxBuy 买营销
    450, // fundTaxSell 卖营销
    1,  // lpTaxBuy 买回流
    0,  // lpTaxSell 卖回流
    hre.ethers.parseUnits('680000', 18), // totalSupply
    swapRouter // swapRouter placeholder
  ];



  const constructorArguments = [
    tokenPas,deployFeeReceiver,usdAddr
  ];

  try {
    await hre.run('verify:verify', {
      address,
      constructorArguments
    });
    console.log('Verification finished');
  } catch (e) {
    console.error('Verification failed:', e.message || e);
    process.exitCode = 1;
  }
}

// 转账 ERC20 代币：从指定私钥的钱包查询该 token 全部余额并转到目标地址
// 使用方法示例（在运行时传 env）：
// TRANSFER=true TOKEN_ADDRESS=0x... FROM_PRIVATE_KEY=0x... TO_ADDRESS=0x... npx hardhat run scripts/verify.js --network bsc
async function transferAllERC20(tokenAddress, fromPrivateKey, toAddress) {
  if (!tokenAddress || !fromPrivateKey || !toAddress) {
    throw new Error('tokenAddress, fromPrivateKey and toAddress are required');
  }

  // create signer from private key connected to the selected network provider
  const signer = new hre.ethers.Wallet(fromPrivateKey, hre.ethers.provider);

  // Use project's ERC20 contract artifact if available, otherwise assume standard ERC20 interface
  let tokenContract;
  try {
    tokenContract = await hre.ethers.getContractAt('ERC20', tokenAddress, signer);
  } catch (e) {
    // fallback: minimal ABI
    const abi = [
      'function balanceOf(address) view returns (uint256)',
      'function transfer(address to, uint256 amount) returns (bool)',
      'function decimals() view returns (uint8)'
    ];
    tokenContract = new hre.ethers.Contract(tokenAddress, abi, signer);
  }

  const fromAddress = await signer.getAddress();
  const balance = await tokenContract.balanceOf(fromAddress);
  if (!balance || balance == 0n) {
    console.log(`No token balance for ${fromAddress} on token ${tokenAddress}`);
    return;
  }

  const decimals = (await tokenContract.decimals?.()) || 18;
  console.log(`Transferring full balance from ${fromAddress} to ${toAddress}:`, hre.ethers.formatUnits(balance, decimals), 'tokens');

  const tx = await tokenContract.transfer(toAddress, balance);
  console.log('Transfer tx hash:', tx.hash);
  await tx.wait();
  console.log('Transfer confirmed');
}

// Entrypoint: if TRANSFER=true in env, run transfer, otherwise run verify
async function main() {
  if (process.env.TRANSFER === 'true') {
    const tokenAddress = process.env.TOKEN_ADDRESS;
    const fromPk = process.env.PRIVATE_KEY;
    const to = process.env.TO_ADDRESS;
    try {
      await transferAllERC20(tokenAddress, fromPk, to);
    } catch (e) {
      console.error('transferAllERC20 failed:', e.message || e);
      process.exitCode = 1;
    }
  }

}

main();
