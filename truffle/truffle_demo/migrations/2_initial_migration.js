// artifacts.require 部署的合约名词(非文件名)
const MathContract = artifacts.require("MathContract");
// 智能合约的导出操作
module.exports = function (deployer) {
  deployer.deploy(MathContract);
};
