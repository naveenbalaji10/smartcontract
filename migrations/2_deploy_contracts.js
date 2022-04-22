const NFT = artifacts.require("./NFT");

module.exports = async function (deployer) {
    const accounts = await web3.eth.getAccounts()

    const IPFS_IMAGE_METADATA_URI = `ipfs://QmX5vyan4VuUCRHjSKpHrGddNxU7sJc7pLr42QjAnyBDjz/`

    await deployer.deploy(
        NFT,
        "BINARYGIRL",
        "BGL",
        IPFS_IMAGE_METADATA_URI,
        25, // 25%
        accounts[1] // Artist
    )
};