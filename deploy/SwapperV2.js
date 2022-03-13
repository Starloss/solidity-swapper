const CONTRACT_NAME = "SwapperV2";

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  // Upgradeable Proxy
  await deploy("Swapper", {
    from: deployer,
    contract: "SwapperV2",
    proxy: {
      owner: deployer
    },
    log: true,
  });
};

module.exports.tags = [CONTRACT_NAME];