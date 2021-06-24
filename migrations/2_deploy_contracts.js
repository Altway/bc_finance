var test = false;

// const Deployer = artifacts.require("Deployer");
// const BlockTimeProvider = artifacts.require("BlockTimeProvider");
const Marex = artifacts.require("Marex");
const MarexCoin = artifacts.require("MarexCoin");
const DecentralizedNote = artifacts.require("DecentralizedNote");
// const TimeProviderMock = artifacts.require("TimeProviderMock");
// const EthFeedMock = artifacts.require("EthFeedMock");
/*const ProtocolSettings = artifacts.require("ProtocolSettings");
const GovToken = artifacts.require("GovToken");
const CreditToken = artifacts.require("CreditToken");
const CreditProvider = artifacts.require("CreditProvider");
const OptionTokenFactory = artifacts.require("OptionTokenFactory");
const OptionsExchange = artifacts.require("OptionsExchange");
const LinearLiquidityPool = artifacts.require("LinearLiquidityPool");
const LinearInterpolator = artifacts.require("LinearInterpolator");
const YieldTracker = artifacts.require("YieldTracker");
*/
module.exports = async function(deployer) {
/*
  if (test) {
   // await deployer.deploy(Deployer, "0x0000000000000000000000000000000000000000");
   // await deployer.deploy(TimeProviderMock);
   // await deployer.deploy(EthFeedMock);
  } else {
    await deployer.deploy(Deployer, "0x224ca63798989A1e5A360C380D33d2230c64F695");
    //await deployer.deploy(BlockTimeProvider);
  }*/
  await deployer.deploy(MarexCoin);
  const marexCoin = await MarexCoin.deployed();

  await deployer.deploy(DecentralizedNote);
  const decentralizedNote = await DecentralizedNote.deployed();
  await deployer.deploy(Marex, decentralizedNote.address, marexCoin.address);
  /*await deployer.deploy(ProtocolSettings);
  await deployer.deploy(CreditToken);
  await deployer.deploy(GovToken);
  await deployer.deploy(CreditProvider);
  await deployer.deploy(OptionTokenFactory);
  await deployer.deploy(OptionsExchange);
  await deployer.deploy(LinearLiquidityPool);
  await deployer.deploy(LinearInterpolator);
  await deployer.deploy(YieldTracker);
*/
  //var d = await Deployer.deployed();
  /*
  if (test) {
   // d.setContractAddress("TimeProvider", TimeProviderMock.address);
    //d.setContractAddress("UnderlyingFeed", EthFeedMock.address);
  } else {
    d.setContractAddress("TimeProvider", BlockTimeProvider.address);
  }
  */
  //d.setContractAddress("CreditProvider", CreditProvider.address);
  //d.addAlias("CreditIssuer", "CreditProvider");
  /*d.setContractAddress("CreditToken", CreditToken.address);
  d.setContractAddress("OptionsExchange", OptionsExchange.address);
  d.setContractAddress("OptionTokenFactory", OptionTokenFactory.address);
  d.setContractAddress("GovToken", GovToken.address);
  d.setContractAddress("ProtocolSettings", ProtocolSettings.address);
  d.setContractAddress("LinearLiquidityPool", LinearLiquidityPool.address);
  d.setContractAddress("LinearInterpolator", LinearInterpolator.address);
  d.setContractAddress("YieldTracker", YieldTracker.address);*/
//  d.setContractAddress("TestCoin", TestCoin.address);
};
