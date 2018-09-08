var MarketPlace = artifacts.require("./MarketPlace");

var MarketLib = artifacts.require("./MarketLib");

module.exports = function (deployer) {
	deployer.deploy(MarketLib);
	deployer.link(MarketLib, MarketPlace);
	deployer.deploy(MarketPlace);
};