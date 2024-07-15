async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const Token = await ethers.getContractFactory("MockERC20");
    const token = await Token.deploy("Governance Token", "GT", 1000000);
    await token.deployed();

    const KehindeDAO = await ethers.getContractFactory("KehindeDAO");
    const dao = await KehindeDAO.deploy(token.address, [deployer.address]);
    await dao.deployed();

    console.log("Governance Token deployed to:", token.address);
    console.log("KehindeDAO deployed to:", dao.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });