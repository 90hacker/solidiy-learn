// artifacts.require 部署的合约名词(非文件名)
const Migrations = artifacts.require("Migrations");
// 智能合约的导出操作
module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
