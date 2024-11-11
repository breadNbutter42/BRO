

/* $DRAGON Links:
Medium: https://medium.com/@DragonFireAvax
Twitter: @DragonFireAvax
Discord: https://discord.gg/uczFJdMaf4
Telegram: DragonFireAvax
Website: www.DragonFireAvax.com
Email: contact@DragonFireAvax.com
*/

// This is a presale contract for the $BRO token on Avalanche.
// Users can transfer AVAX directly to this contract address during the presale time window.
// There is a minimum presale buy in amount of 1 AVAX per transfer.
// LP to be trustlessly created after the presale ends, using half of the $BRO supply and all of the presale AVAX.
// Presale buyers' $BRO tokens to be trustlessly "airdropped" out after presale ends, aka sent directly to them.
// Note: There are no whale limits or allowlists for this presale.

// V1 and V2 LP is burned since fees are automatically converted to more LP
// V3 and V2.2 LP NFTs are locked in collection contract so fees can be collected and converted to more LP


//$DRAGON is an ERC20 token that collects fees on transfers, and creates LP with other top community tokens.
//Base contract imports created with https://wizard.openzeppelin.com/ using their ERC20 with Permit and Ownable.

interface ILBRouter {

    /**
     * @dev This enum represents the version of the pair requested
     * - V1: Joe V1 pair
     * - V2: LB pair V2. Also called legacyPair
     * - V2_1: LB pair V2.1 (current version)
     */
    enum Version {
        V1,
        V2,
        V2_1
    }

    /**
     * @dev The liquidity parameters, such as:
     * - tokenX: The address of token X
     * - tokenY: The address of token Y
     * - binStep: The bin step of the pair
     * - amountX: The amount to send of token X
     * - amountY: The amount to send of token Y
     * - amountXMin: The min amount of token X added to liquidity
     * - amountYMin: The min amount of token Y added to liquidity
     * - activeIdDesired: The active id that user wants to add liquidity from
     * - idSlippage: The number of id that are allowed to slip
     * - deltaIds: The list of delta ids to add liquidity (`deltaId = activeId - desiredId`)
     * - distributionX: The distribution of tokenX with sum(distributionX) = 100e18 (100%) or 0 (0%)
     * - distributionY: The distribution of tokenY with sum(distributionY) = 100e18 (100%) or 0 (0%)
     * - to: The address of the recipient
     * - refundTo: The address of the recipient of the refunded tokens if too much tokens are sent
     * - deadline: The deadline of the transaction
     */
    struct LiquidityParameters {
        IERC20 tokenX;
        IERC20 tokenY;
        uint256 binStep;
        uint256 amountX;
        uint256 amountY;
        uint256 amountXMin;
        uint256 amountYMin;
        uint256 activeIdDesired;
        uint256 idSlippage;
        int256[] deltaIds;
        uint256[] distributionX;
        uint256[] distributionY;
        address to;
        address refundTo;
        uint256 deadline;
    }

    /**
     * @dev The path parameters, such as:
     * - pairBinSteps: The list of bin steps of the pairs to go through
     * - versions: The list of versions of the pairs to go through
     * - tokenPath: The list of tokens in the path to go through
     */
    struct Path {
        uint256[] pairBinSteps;
        Version[] versions;
        IERC20[] tokenPath;
    }

    function getWNATIVE() external view returns (IWNATIVE);

    function getIdFromPrice(ILBPair LBPair, uint256 price) external view returns (uint24);

    function getPriceFromId(ILBPair LBPair, uint24 id) external view returns (uint256);

    function createLBPair(IERC20 tokenX, IERC20 tokenY, uint24 activeId, uint16 binStep)
        external
        returns (ILBPair pair);

    function addLiquidityNATIVE(LiquidityParameters calldata liquidityParameters)
        external
        payable
        returns (
            uint256 amountXAdded,
            uint256 amountYAdded,
            uint256 amountXLeft,
            uint256 amountYLeft,
            uint256[] memory depositIds,
            uint256[] memory liquidityMinted
        );
}


interface IUniswapV2Router01 {

    function factory() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountAVAX,
            uint256 liquidity
        );
}



interface IUniswapV2Router02 is IUniswapV2Router01 {

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}




interface ILFJV1Router01 {

    function factory() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityAVAX(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountAVAX,
            uint256 liquidity
        );
}



interface ILFJV1Router03 is ILFJV1Router01 {

    function swapExactAVAXForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


    function swapExactTokensForAVAXSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}



interface IERC20Token { //Generic ability to transfer out funds accidentally sent into the contract
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address) external returns (uint256);
}


interface IERC721Token { //Generic ability to transfer out NFTs accidentally sent into the contract
    function transferFrom(address from, address to, uint256 tokenId) external; 
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransfer(address from, address to, uint256 tokenId) external;
    function transfer(address from, address to, uint256 tokenId) external;
}


interface IBroToken { //To make BRO/AVAX LP and send out airdropped BRO tokens
    function transfer(address, uint256) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address) external returns (uint256);
    function totalSupply() external returns (uint256);
}



/*
⠀⠀⠀⠀⠀⠀⠀⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣼⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣧⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢸⣿⣿⣷⡀⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⢀⣾⣿⣿⡇⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⣷⠀⣠⣾⣿⣿⣷⣄⠀⣾⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠛⠿⠁⣼⣿⣿⣿⣿⣿⣿⣧⠈⠿⠛⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠘⠛⠛⠛⠛⠛⠛⠛⠛⠃⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣼⠏⠀⠿⣿⣶⣶⣶⣶⣿⠿⠀⠹⣷⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢰⡟⠀⣴⡄⠀⣈⣹⣏⣁⡀⢠⣦⠀⢻⣇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠀⠐⢿⣿⠿⠿⠿⠿⠿⠿⣿⡿⠂⠀⠙⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⣴⣿⣷⣄⠉⢠⣶⠒⠒⣶⡄⠉⣠⣾⣿⣦⡀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣾⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠚⠛⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠛⠛⠓⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣿⣿⡿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀


    /$$    /$$$$$$$  /$$$$$$$   /$$$$$$        /$$$$$$$  /$$$$$$$  /$$$$$$$$  /$$$$$$   /$$$$$$  /$$       /$$$$$$$$
  /$$$$$$ | $$__  $$| $$__  $$ /$$__  $$      | $$__  $$| $$__  $$| $$_____/ /$$__  $$ /$$__  $$| $$      | $$_____/
 /$$__  $$| $$  \ $$| $$  \ $$| $$  \ $$      | $$  \ $$| $$  \ $$| $$      | $$  \__/| $$  \ $$| $$      | $$      
| $$  \__/| $$$$$$$ | $$$$$$$/| $$  | $$      | $$$$$$$/| $$$$$$$/| $$$$$   |  $$$$$$ | $$$$$$$$| $$      | $$$$$   
|  $$$$$$ | $$__  $$| $$__  $$| $$  | $$      | $$____/ | $$__  $$| $$__/    \____  $$| $$__  $$| $$      | $$__/   
 \____  $$| $$  \ $$| $$  \ $$| $$  | $$      | $$      | $$  \ $$| $$       /$$  \ $$| $$  | $$| $$      | $$      
 /$$  \ $$| $$$$$$$/| $$  | $$|  $$$$$$/      | $$      | $$  | $$| $$$$$$$$|  $$$$$$/| $$  | $$| $$$$$$$$| $$$$$$$$
|  $$$$$$/|_______/ |__/  |__/ \______/       |__/      |__/  |__/|________/ \______/ |__/  |__/|________/|________/
 \_  $$_/                                                                                                           
   \__/                                                                                                             


*/



pragma solidity 0.8.28;
// SPDX-License-Identifier: MIT

import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol"; //Uniswap V3 NFT manager
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol"; //TransferHelper from Uniswap V3
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; //Reentrancy guard from OpenZeppelin
import "@openzeppelin/contracts/access/Ownable.sol"; //Owner contract from OpenZeppelin
import "@traderjoe-xyz/joe-v2/blob/main/src/libraries/PriceHelper.sol"; //LFJ V2.2 LP helper library

contract BroPresale is Ownable, ReentrancyGuard {
    //IUniswapV2Router01 public uniswapV2Router; //DEX router for V2 LP creation, can be used if just one dex
    IBroToken public broInterface; //ERC20 Bro token interface
    ILFJV1Router02 public lfjV1Router; //DEX router for LFJ V1 LP creation
    ILBRouter public lfjLbRouterV2ii; //V2.2 of LFJ router which is analagous to v4 uniswap lp
    IUniswapV2Router02 public uniswapV2Router; //DEX router for Uniswap V2 LP creation
    INonfungiblePositionManager public uniswapV3; //Uniswap V3 NFT manager for LP creation
    IUniswapV2Router02 public pharoahV2Router; //DEX router for Pharoah V2 LP creation
    INonfungiblePositionManager public pharoahV3; //Pharoah V3 NFT manager for LP creation
    IUniswapV2Router02 public pangolinV2Router; //DEX router for Pangolin V2 LP creation

    uint256 public constant PRECISION = 1e18;  // Fixed-point precision constant of BRO token
    uint256 public constant binStep = PRECISION/100; //Bin step in fixed-point (e.g., 1% as 1e16) for LFJ V2.2 LP
    uint256 public constant numBins = 700; //Bins for LFJ V2.2 LP, if 70 @ 1% bin step is ~ 2^1 = 2x then 700 bins is ~ 2^10 = 1024x range
    uint256 public constant ratioOfTokensPerBin_ = ((1*10**18) / 70); //Ratio of tokens per bin for LFJ V2.2 LP

    uint256 public constant MINIMUM_BUY_WEI = 1000000000000000000; //1 AVAX in wei
    uint256 public constant PRESALE_END_TIME = 1791775312; //Date presale ends, before IDO launch so time to make LP before launch
    uint256 public constant AIRDROP_TIME = 1791775313; //Date airdrop starts, if restrictions on transfers then send out after IDO phased launch so can transfer tokens without whale limits
    uint256 public constant TOTAL_BRO_RECEIVE_WEI = 420690000000000000000000000000; //Total $BRO to be sent into the contract which in this case is 100% of total $BRO supply
    uint256 public constant PRESALERS_BRO_SUPPLY_WEI = 210345000000000000000000000000; // 50% of initial BRO for presale buyers
    uint256 public constant LP_BRO_SUPPLY_WEI = 201931200000000000000000000000; //48% of initial $BRO is for automated LP
    uint256 public constant TEAM_BRO_SUPPLY_WEI = 8413800000000000000000000000; // 2% of initial BRO to be sent to team wallet after presale ends to manually create APEX304 aBRO LP
    //Right now 2% of intital BRO is same as 4% of all BRO for LP creation, since half of BRO is allocated to all LP, so we use 4% of AVAX to match it for manual LP creation
    uint256 public constant AVAX_FOR_TEAM_PERCENT = 4; //Percentage of AVAX collected in presale to use for team funds to manually create APEX304 aBRO LP
    uint256 public constant AVAX_FOR_LP_PERCENT = 96; //Percentage of AVAX collected in presale to use for auto BRO/AVAX LP creation
    uint256 public constant V1_LFJ_DEX_PERCENT = 5; //Percentage of auto LP to be used for LFJ TraderJoe dex V1
    uint256 public constant V2ii_LFJ_DEX_PERCENT = 80; //Percentage of auto LP to be used for LFJ TraderJoe dex V2.2 LBRouter
    uint256 public constant V2_UNISWAP_DEX_PERCENT = 3; //Percentage of auto LP to be used for Uniswap dex V2
    uint256 public constant V3_UNISWAP_DEX_PERCENT = 3; //Percentage of auto LP to be used for Uniswap dex V3
    uint256 public constant V2_PHAROAH_DEX_PERCENT = 3; //Percentage of auto LP to be used for Pharoah dex V2
    uint256 public constant V3_PHAROAH_DEX_PERCENT = 3; //Percentage of auto LP to be used for Pharoah dex V3
    uint256 public constant V2_PANGOLIN_DEX_PERCENT = 3; //Percentage of auto LP to be used for Pangolin dex V2

    address public constant WAVAX_ADDRESS = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7; //WAVAX Mainnet: 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7 ; Fuji: 0xd00ae08403B9bbb9124bB305C09058E32C39A48c
    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD; //Burn address for LP tokens
    address public constant LFJ_V1_ROUTER_ADDRESS = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4; //Mainnet: 0x60aE616a2155Ee3d9A68541Ba4544862310933d4 ; Fuji: 0xd7f655E3376cE2D7A2b08fF01Eb3B1023191A901
    address public constant LFJ_V2ii_LB_ROUTER_ADDRESS = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88; //Mainnet: 0xC36442b4a4522E871399CD717aBDD847Ab11FE88 ; Fuji: 0x18556DA13313f3532c54711497A8FedAC273220E
    address public constant UNISWAP_V2_ROUTER_ADDRESS = 0x4752ba5dbc23f44d87826276bf6fd6b1c372ad24; //Mainnet: 0x4752ba5dbc23f44d87826276bf6fd6b1c372ad24 ; Sepolia: 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3
    address public constant UNISWAP_V3_NONFUNGIBLE_POSITION_MANAGER_ADDRESS = 0xe89B7C295d73FCCe88eF263F86e7310925DaEBAF; //Mainnet: 0xe89B7C295d73FCCe88eF263F86e7310925DaEBAF
    address public constant PHAROAH_V2_ROUTER_ADDRESS = 0xAAA9f93572B99919750FA59c33c0946bc5fC0e90; //Mainnet: 0xAAA9f93572B99919750FA59c33c0946bc5fC0e90
    address public constant PHAROAH_V3_NONFUNGIBLE_POSITION_MANAGER_ADDRESS = 0xAAA78E8C4241990B4ce159E105dA08129345946A; //Mainnet: 0xAAA78E8C4241990B4ce159E105dA08129345946A
    address public constant PANGOLIN_V2_ROUTER_ADDRESS = 0xE54Ca86531e17Ef3616d22Ca28b0D458b6C89106; //Mainnet: 0xE54Ca86531e17Ef3616d22Ca28b0D458b6C89106 ;  FUJI: 0x2D99ABD9008Dc933ff5c0CD271B88309593aB921
    address public constant TEAM_WALLET = 0xE395C115657b636760AbDe037185C6C8E6948A72; //Address to receive AVAX for team funds once presale is completed
    address public constant BRO_ADDRESS = 0x; //This can be set as not a constant if BRO token address is not known before deployment
    address[] public presaleBuyers = new address[](0); //Array to store presale buyers addresses to send BRO tokens to later and for WL phase checks

    mapping (address => uint256) public totalAvaxUserSent; //Mapping to store total AVAX sent by each presale buyer

    uint256 public airdropIndex = 0; //Count through the airdrop array when sending out tokens
    uint256 public totalAvaxPresaleWei = 0; //Count total AVAX received during presale

    uint256 public avaxForLPWei = 0; //Amount of collected AVAX to be used for LP creation
    uint256 public avaxForTeamWei = 0; //Get remaining AVAX balance after LP creation
    uint256 public avaxForLFJWeiV1 = 0; //Calculate AVAX to be used for LFJ TraderJoe dex V1 LP creation
    uint256 public avaxForLFJWeiV2ii = 0; //Calculate % of LP to be used for LFJ TraderJoe dex v2.2
    uint256 public avaxForUniswapWeiV2 = 0; //Calculate AVAX to be used for Uniswap dex V2 LP creation
    uint256 public avaxForUniswapWeiV3 = 0; //Calculate AVAX to be used for Uniswap dex V3 LP creation
    uint256 public avaxForPharoahWeiV2 = 0; //Calculate AVAX to be used for Pharoah dex V2 LP creation
    uint256 public avaxForPharoahWeiV3 = 0; //Calculate AVAX to be used for Pharoah dex V3 LP creation
    uint256 public avaxForPangolinWeiV2 = 0; //Calculate AVAX to be used for Pangolin dex V2 LP creation

    uint256 public broForLFJWeiV1 = 0; //Calculate BRO to be used for LFJ TraderJoe dex V1 LP creation
    uint256 public broForLFJWeiV2ii = 0; //Calculate BRO to be used for LFJ TraderJoe dex V2.2 LP creation
    uint256 public broForUniswapWeiV2 = 0; //Calculate BRO to be used for Uniswap dex V2 LP creation
    uint256 public broForUniswapWeiV3 = 0; //Calculate BRO to be used for Uniswap dex V3 LP creation
    uint256 public broForPharoahWeiV2 = 0; //Calculate BRO to be used for Pharoah dex V2 LP creation
    uint256 public broForPharoahWeiV3 = 0; //Calculate BRO to be used for Pharoah dex V3 LP creation
    uint256 public broForPangolinWeiV2 = 0; //Calculate BRO to be used for Pangolin dex V2 LP creation
    
    uint256 public broPer70Bins; //Calculate BRO per 70 bins for LFJ V2.2 LP
    uint256 public priceIn128_ = 0; // Price in fixed-point 128x128 format for LFJ V2.2 LP
    uint256 public startingBinId_ = 0; // Initial bin ID based on price (which is based on avax / bro) for LFJ V2.2 LP
    uint256 public lastBin = 0; //Tracks the last bin updated in the series for LFJ V2.2 LP


    bool public lfjV1LpCreated = false; //Flag to indicate when LFJ V1 LP has been created
    bool public lfjV2iiLpCreated = false; //Flag to indicate when LFJ V2.2 LP has been created
    bool public uniswapV2LpCreated = false; //Flag to indicate when Uniswap V2 LP has been created
    bool public uniswapV3LpCreated = false; //Flag to indicate when Uniswap V3 LP has been created
    bool public pharoahV2LpCreated = false; //Flag to indicate when Pharoah V2 LP has been created
    bool public pharoahV3LpCreated = false; //Flag to indicate when Pharoah V3 LP has been created
    bool public pangolinV2LpCreated = false; //Flag to indicate when Pangolin V2 LP has been created
    bool public lpCreated = false; //Flag to indicate when all LP has been created

    bool public initialized = false; //Flag to indicate when BRO tokens have been seeded into contract to open presale to buyers
    bool public amountsCalculated = false; //Flag to indicate when post presale amounts have been calculated
    bool public airdropCompleted = false; //Flag to indicate when airdrop is completed
    bool public teamTokensWithdrawn = false; //Flag to indicate team allocated AVAX and BRO tokens have been withdrawn after auto LP creation

    event AirdropSent(address indexed caller, uint256 airdropIndex);
    event LPSeeded(address indexed caller);
    event BroInterfaceSet(address indexed caller);
    event BuyerAdded(address indexed buyer);
    event PresaleBought(uint256 amount, address indexed buyer);
    event AvaxWithdraw(address indexed to, uint256 amount);
    event TokenWithdraw(address indexed to, uint256 amount, address indexed token);
    event TokenApproved(address indexed spender, uint256 amount, address indexed token);
    event NFTWithdraw(address indexed to, uint256 tokenId, address indexed token);
    event PostPresaleProcessing(address indexed caller);
    event V3FeesCollected(uint256 amountToken0, uint256 amountToken1, address indexed caller);

    modifier afterAirdrop() {
        require(block.timestamp >= AIRDROP_TIME + 7 days, "Cannot withdraw tokens until 7 days after airdrop starts"); //Wait 7 days to give time for presale to complete first
        _;
    }

    modifier calculated() {
        require(amountsCalculated, "Amounts have not been calculated yet"); // Must call calculatePostPresaleAmounts() first
        _;
    }           



    constructor()
            Ownable(msg.sender)
    { //Constructor to check initial values and set owner
        require(PRESALE_END_TIME >= (block.timestamp + 1 hours), "Presale must end at least 1 hour in the future from now or more");
        require(PRESALE_END_TIME <= (block.timestamp + 15 days), "Presale must end within 15 days from now or less");
        require(AIRDROP_TIME > (PRESALE_END_TIME), "Airdrop time must be after presale end time");
        require(AIRDROP_TIME <= (PRESALE_END_TIME + 1 days), "Airdrop time must be within 1 day after presale end time or less");

        require(LP_BRO_SUPPLY_WEI > 0, "Main LP Bro token allocation must be greater than 0");
        require(PRESALERS_BRO_SUPPLY_WEI > 0, "Presalers Bro token allocation must be greater than 0");
        require(TOTAL_BRO_RECEIVE_WEI == LP_BRO_SUPPLY_WEI + PRESALERS_BRO_SUPPLY_WEI + TEAM_BRO_SUPPLY_WEI, "Total BRO tokens must be allocated correctly");
        
        require(V1_LFJ_DEX_PERCENT + V2_UNISWAP_DEX_PERCENT + V2ii_LFJ_DEX_PERCENT + V3_UNISWAP_DEX_PERCENT == 100, "DEX percentages must add up to 100");
        require(V1_LFJ_DEX_PERCENT + V2_UNISWAP_DEX_PERCENT + V2ii_LFJ_DEX_PERCENT + V3_UNISWAP_DEX_PERCENT + V2_PHAROAH_DEX_PERCENT + V3_PHAROAH_DEX_PERCENT + V2_PANGOLIN_DEX_PERCENT == 100, "DEX auto LP allocation percentages must add up to 100");
        require(AVAX_FOR_LP_PERCENT + AVAX_FOR_TEAM_PERCENT == 100, "AVAX percentages must add up to 100");

        require(MINIMUM_BUY_WEI >= 1000000000000000000, "Minimum buy must be at least 1 AVAX to prevent airdrop gas attacks");
        require(numBins % 70 == 0, "Number of bins must be divisible by 70 for our LFJ V2.2 LP calculations");
        require(numBins > 0, "Number of bins must be greater than 0 for our LFJ V2.2 LP calculations");
        require(numBins < 7001, "Number of bins must be less than 7001 for feasability to make all LP transactions"); //7000 bins at 70 bins a tx is 100 txs which is already too many, and gives more than enough range for LP
        
        //Define DEX routers
        lfjV1Router = ILFJV1Router01(LFJ_V1_ROUTER_ADDRESS);
        lfjLbRouterV2ii = ILBRouter(LFJ_V2ii_LB_ROUTER_ADDRESS);
        uniswapV2Router = IUniswapV2Router01(UNISWAP_V2_ROUTER_ADDRESS);
        uniswapV3 = INonfungiblePositionManager(UNISWAP_V3_NONFUNGIBLE_POSITION_MANAGER_ADDRESS);
        pharoahV2Router = IUniswapV2Router01(PHAROAH_V2_ROUTER_ADDRESS);
        pharoahV3 = INonfungiblePositionManager(PHAROAH_V3_NONFUNGIBLE_POSITION_MANAGER_ADDRESS);
        pangolinV2Router = IUniswapV2Router01(PANGOLIN_V2_ROUTER_ADDRESS);
    }



    //Public functions


    function buyPresale(uint256 amount_, address buyer_) public {
        require(initialized == true, "Presale has not been initialized yet");
        require(block.timestamp < PRESALE_END_TIME, "Presale has already ended");
        require(amount_ >= MINIMUM_BUY_WEI, "Minimum buy of 1 AVAX per transaction; Not enough AVAX sent");
        
        if (totalAvaxUserSent[buyer_] == 0) { //Add buyer to the presaleBuyers array if they are a first time buyer
            presaleBuyers.push(buyer_);
            emit BuyerAdded(buyer_);
        }

        totalAvaxUserSent[buyer_]+= amount_;
        totalAvaxPresaleWei+= amount_;
        emit PresaleBought(amount_, buyer_);
    }


    function calculatePostPresaleAmounts() public nonReentrant { //1. This function must be called once, first thing after the presale ends
        require(!amountsCalculated, "Amounts have already been calculated");
        require(block.timestamp > PRESALE_END_TIME, "Presale has not ended yet");

        avaxForLPWei = AVAX_FOR_LP_PERCENT * totalAvaxPresaleWei / 100; //Calculate % of total AVAX for auto LP creation
        avaxForTeamWei = totalAvaxPresaleWei - avaxForLPWei; //Get remaining AVAX balance after auto LP creation
        avaxForLFJWeiV1 = V1_LFJ_DEX_PERCENT * avaxForLPWei / 100; //Calculate % of LP to be used for LFJ TraderJoe dex V1
        avaxForLFJWeiV2ii = V2ii_LFJ_DEX_PERCENT * avaxForLPWei; //Calculate AVAX to be used for LFJ TraderJoe dex V3 LP creation
        avaxForUniswapWeiV2 = V2_UNISWAP_DEX_PERCENT * avaxForLPWei / 100; //Calculate AVAX to be used for Uniswap dex V2 LP creation
        avaxForUniswapWeiV3 = V3_UNISWAP_DEX_PERCENT * avaxForLPWei / 100; //Calculate AVAX to be used for Uniswap dex V2 LP creation
        avaxForPharoahWeiV2 = V2_PHAROAH_DEX_PERCENT * avaxForLPWei / 100; //Calculate AVAX to be used for Pharoah dex V2 LP creation
        avaxForPharoahWeiV3 = V3_PHAROAH_DEX_PERCENT * avaxForLPWei / 100; //Calculate AVAX to be used for Pharoah dex V3 LP creation
        avaxForPangolinWeiV2 = V2_PANGOLIN_DEX_PERCENT * avaxForLPWei / 100; //Calculate AVAX to be used for Pangolin dex V2 LP creation

        broForLFJWeiV1 = V1_LFJ_DEX_PERCENT * LP_BRO_SUPPLY_WEI / 100; //Calculate BRO to be used for LFJ TraderJoe dex V1 LP creation
        broForLFJWeiV2ii = V2ii_LFJ_DEX_PERCENT * LP_BRO_SUPPLY_WEI / 100; //Calculate BRO to be used for LFJ TraderJoe dex V2.2 LP creation
        broForUniswapWeiV2 = V2_UNISWAP_DEX_PERCENT * LP_BRO_SUPPLY_WEI / 100; //Calculate BRO to be used for Uniswap dex V2 LP creation
        broForUniswapWeiV3 = V3_UNISWAP_DEX_PERCENT * LP_BRO_SUPPLY_WEI / 100; //Calculate BRO to be used for Uniswap dex V3 LP creation
        broForPharoahWeiV2 = V2_PHAROAH_DEX_PERCENT * LP_BRO_SUPPLY_WEI / 100; //Calculate BRO to be used for Pharoah dex V2 LP creation
        broForPharoahWeiV3 = V3_PHAROAH_DEX_PERCENT * LP_BRO_SUPPLY_WEI / 100; //Calculate BRO to be used for Pharoah dex V3 LP creation
        broForPangolinWeiV2 = V2_PANGOLIN_DEX_PERCENT * LP_BRO_SUPPLY_WEI / 100; //Calculate BRO to be used for Pangolin dex V2 LP creation

        broPer70Bins = broForLFJWeiV2ii/(numBins/70); //Calculate BRO per 70 bins for LFJ V2.2 LP
        priceIn128_ = PriceHelper.convertDecimalPriceTo128x128(avaxForLFJWeiV2ii / broForLFJWeiV2ii); // Price in fixed-point 128x128 format
        startingBinId_ = lfjV2iiGetBinIdFromPrice(priceIn128_); // Initial bin ID based on current price

        amountsCalculated = true;
        emit PostPresaleProcessing(msg.sender);
    }


    function seedLpV1LFJ() public nonReentrant calculated { //2. This function must be called once, after the presale ends
        require(!lfjV1LpCreated, "LFJ V1 LP has already been seeded");

        try
        lfjV1Router.addLiquidityAVAX{value: avaxForLFJWeiV1}( //Seed LFJ V1 LP
            BRO_ADDRESS, 
            broForLFJWeiV1,
            100, //Infinite slippage basically since it's in wei
            100, //Infinite slippage basically since it's in wei
            DEAD_ADDRESS,
            block.timestamp); 
        {}
        catch {
            revert(string("addLiquidityBRO failed"));
        }

        lfjV1LpCreated = true;
        emit LPSeeded(msg.sender);
    }


    function seedLpV2iiLFJ() public nonReentrant calculated { //3. This function must be called once, after the presale ends
        require(!lfjV2iiLpCreated, "LFJ V2.2 LP has already been seeded");
        
        // If `lastBin` is zero, we need to initialize LFJ V2.2 LP setup
        if (lastBin == 0) {
            lfjV2iiInitializeLP();
        } else {
            lfjV2iiContinueAddingLiquidity();
        }

        if (lastBin >= numBins) { //If seeded desired bins, set flag to indicate LP has been created
            lfjV2iiLpCreated = true;
        }
        emit LPSeeded(msg.sender);
    }


    function finalizeLP() public { //This function must be called once, after the auto LP creation functions have been called
        if (V1_LFJ_DEX_PERCENT > 0) {
            require(lfjV1LpCreated, "LFJ V1 LP has not been seeded yet");
        }
        if (V2ii_LFJ_DEX_PERCENT > 0) {
            require(lfjV2iiLpCreated, "LFJ V2.2 LP has not been seeded yet");
        }
        if (V2_UNISWAP_DEX_PERCENT > 0) {
            require(uniswapV2LpCreated, "Uniswap V2 LP has not been seeded yet");
        }
        if (V3_UNISWAP_DEX_PERCENT > 0) {
            require(uniswapV3LpCreated, "Uniswap V3 LP has not been seeded yet");
        }
        if (V2_PHAROAH_DEX_PERCENT > 0) {
            require(pharoahV2LpCreated, "Pharoah V2 LP has not been seeded yet");
        }
        if (V3_PHAROAH_DEX_PERCENT > 0) {
            require(pharoahV3LpCreated, "Pharoah V3 LP has not been seeded yet");
        }
        if (V2_PANGOLIN_DEX_PERCENT > 0) {
            require(pangolinV2LpCreated, "Pangolin V2 LP has not been seeded yet");
        }

        lpCreated = true; //Set flag to indicate all 7 auto LPs have been created
        emit LPSeeded(msg.sender);
    }


    function withdrawTeamTokens() public { //This function can be called after the LP has been created
        require(!teamTokensWithdrawn, "Team tokens have already been withdrawn");
        require(lpCreated, "LP has not been seeded yet");
        uint256 avaxBalance_ = address(this).balance; //Get AVAX balance of contract, any remaining balance after making LP is for team funds
        if (avaxBalance_ > 0 && AVAX_FOR_TEAM_PERCENT > 0) {
            TEAM_WALLET.transfer(avaxBalance_); //Send team AVAX from contract to team wallet
            emit AvaxWithdraw(TEAM_WALLET, avaxBalance_);

        uint256 broInContract_ = broInterface.balanceOf(address.this); //Get remaining BRO balance in contract
        if (broInContract_ > 0 && TEAM_BRO_SUPPLY_WEI > 0) {
            broInterface.transfer(TEAM_WALLET, broInterface.balanceOf(address.this)); //Send remaining BRO to team wallet
            emit TokenWithdraw(LFJ_V1_ROUTER_ADDRESS, broForLFJWeiV1, address(broInterface));
        }
    }


    function numberOfPresalers() external view returns(uint256){
        return (presaleBuyers.length);
    }


    function airdropBuyers() external nonReentrant {
        require(!airdropCompleted, "Airdrop has already been completed");
        require(block.timestamp >= AIRDROP_TIME, "It is not yet time to airdrop the presale buyer's tokens");
        _airdrop();
    }


    function collectUniswapV3Fees(uint256 tokenID_) public afterAirdrop { //Collect fees from a Uniswap V3 LP NFT locked in this contract
        require(uniswapV3LpCreated, "Uniswap V3 LP has not been seeded yet");
        (uint256 fees0_, uint256 fees1_) = uniswapV3.collect(
            tokenID_, 
            address(this),
            type(uint128).max
        );
        addLiquidityV2(UNISWAP_V2_ROUTER_ADDRESS); //Add fees to Uniswap V2 LP
        emit V3FeesCollected(fees0_, fees1_, msg.sender);
    }


    function collectPharoahV3Fees(uint256 tokenID_) public afterAirdrop { //Collect fees from a Pharoah V3 LP NFT locked in this contract
        require(pharoahV3LpCreated, "Pharoah V3 LP has not been seeded yet");
        (uint256 fees0_, uint256 fees1_) = pharoahV3.collect(
            tokenID_, 
            address(this),
            type(uint128).max
        );
        addLiquidityV2(PHAROAH_V2_ROUTER_ADDRESS); //Add fees to Pharoah V2 LP
        emit V3FeesCollected(fees0_, fees1_, msg.sender);
    }



    //Internal functions


    function _airdrop() private {
        uint256 limitCount_ = airdropIndex + 100; //Max amount of addresses to airdrop to per call is 100 addresses
        address buyer_;
        uint256 amount_;

        while(airdropIndex < presaleBuyers.length && airdropIndex < limitCount_) {
            buyer_ = presaleBuyers[airdropIndex];
            amount_ = (totalAvaxUserSent[buyer_] * PRESALERS_BRO_SUPPLY_WEI) / totalAvaxPresaleWei; //Calculate amount of Bro tokens to send to buyer as ratio of AVAX sent
            require(broInterface.transfer(buyer_, amount_), "Transfer failed");
            airdropIndex++;
        }

        if (airdropIndex == presaleBuyers.length) {
            airdropCompleted = true;
        }

        emit AirdropSent(msg.sender, airdropIndex);
    }


    /**
     * @notice Initializes LFJ V2.2 LP by setting up the first allocation and bin ID
     */
    function lfjV2iiInitializeLP() private {
        // Initialize arrays for liquidity parameters (71 bins: bin 0 to bin 70)
                // Arrays for liquidity parameters
        int256[71] memory deltaIds; // Relative bin IDs
        uint256[71] memory distributionX; // BRO allocations
        uint256[71] memory distributionY; // AVAX allocations

        // Set deltaIds and distributions for AVAX in bin 0
        deltaIds[0] = 0; // Bin 0 relative to activeIdDesired
        distributionX[0] = 0;     // No BRO tokens in bin 0
        distributionY[0] = 1e18; // 100% AVAX in bin 0 (fixed-point representation)

        // Loop through bins 1 to 70 to seed BRO tokens in LFJ V2.2 LP
        for (uint256 i = 1; i <= 70; i++) {
            deltaIds[i] = int256(i); // Relative bin ID
            distributionX[i] = ratioOfTokensPerBin_; // Ratio of BRO tokens allocated to this bin
            distributionY[i] = 0; // No AVAX in these bins
        }

        // Build liquidity parameters for initial AVAX liquidity in bin 0 and BRO tokens in bins 1-70
        ILBRouter.LiquidityParameters memory params = lfjV2iiBuildLiquidityParameters(
            broPer70Bins,       // Total BRO tokens for this batch
            totalAVAX,          // AVAX amount
            startingBinId_,     // Starting bin ID
            0,                  // idSlippage
            deltaIds,
            distributionX,
            distributionY
        );

        // Approve BRO tokens for transfer
        broToken.approve(LFJ_V2ii_LB_ROUTER_ADDRESS, broForLFJWeiV2ii);

        // Add initial LFJ V2.2 liquidity including AVAX floor
        try 
            lfjLbRouterV2ii.addLiquidityNATIVE{value: avaxForLFJWeiV2ii}(params) //Seed LFJ V2.2 LP
        {} catch {
            revert("lfjV2iiInitializeLP() failed");
        }

        lastBin = 70; // Make note of the last relative bin seeded
    }



    /**
     * @notice Continues LFJ V2.2 LP using equal tokens per bin
     */
    function lfjV2iiContinueAddingLiquidity() internal {

        // Arrays for liquidity parameters (70 bins per batch)
        int256[70] memory deltaIds; // Relative bin IDs
        uint256[70] memory distributionX; // BRO allocations
        uint256[70] memory distributionY; // AVAX allocations
    }

        for (uint256 i = 0; i < 70; i++) { //Loop through 70 more bins to seed BRO tokens in LFJ V2.2 LP
            deltaIds[i] = lastBin + i + 1; // Relative bin ID
            distributionX[i] = ratioOfTokensPerBin_; //Ratio of BRO tokens allocated to this bin
            distributionY[i] = 0; // No AVAX in these bins
        }

        // Build liquidity parameters for BRO tokens in bins
        ILBRouter.LiquidityParameters memory params = lfjV2iiBuildLiquidityParameters(
            broPer70Bins, // Total BRO tokens this round
            0, // No AVAX in these bins
            startingBinId_, // Starting bin ID
            0, // idSlippage
            deltaIds,
            distributionX,
            distributionY
        );

        // Add more LFJ V2.2 liquidity 
        try
        lfjLbRouterV2ii.addLiquidityNATIVE(params); //Seed LFJ V2.2 LP
        {}
        catch {
            revert(string("lfjV2iiContinueAddingLiquidity() failed"));
        }

        lastBin += 70; // Make note of last relative bin seeded
    }


    /**
     * @notice Helper to build and populate the LiquidityParameters struct
     */
    function lfjV2iiBuildLiquidityParameters(
        uint256 broAmount,
        uint256 avaxAmount,
        uint256 activeId,
        uint256 idSlippage,
        int256[] memory deltaIds,
        uint256[] memory distributionX,
        uint256[] memory distributionY
    ) internal view returns (ILBRouter.LiquidityParameters memory params) {
        params = ILBRouter.LiquidityParameters({
            tokenX: BRO_ADDRESS,
            tokenY: WAVAX_ADDRESS,
            binStep: uint16(binStep / 1e14), // Convert binStep to uint16
            amountX: broAmount,
            amountY: avaxAmount,
            amountXMin: broAmount,  // No slippage needed to seed LP
            amountYMin: avaxAmount, // No slippage needed to seed LP
            activeIdDesired: uint24(activeId),
            idSlippage: uint24(idSlippage),
            deltaIds: deltaIds,
            distributionX: distributionX,
            distributionY: distributionY,
            to: address(this),
            refundTo: address(this),
            deadline: block.timestamp
        });
    }


    //Get bin ID from price for LFJ V2.2 LP creation. Use PriceHelper library to get bin ID
    function lfjV2iiGetBinIdFromPrice(uint256 priceIn128_) internal view returns (uint24 binId) { 
        binId = PriceHelper.getIdFromPrice(priceIn128_, uint16(binStep / 1e14)); // Convert binStep to uint16 
    }


    function addLiquidityV2(address v2RouterAddress_) private { //Add fees collected from Uniswap V3 LP to Uniswap V2 LP
        //First we sell all BRO for AVAX, then sell half AVAX for BRO, to balance fees collected to current price
        uint256 tokenAmount_ = broInterface.balanceOf(address(this)); //Get BRO balance of contract
        swapBroToAvaxV2(tokenAmount_, v2RouterAddress_); //Swap all BRO to AVAX
        uint256 avaxAmount_ = address(this).balance; //Get AVAX balance of contract
        swapAvaxToBroV2(avaxAmount_, v2RouterAddress_); //Swap half of AVAX to BRO
        avaxAmount_ = address(this).balance;
        tokenAmount_ = broInterface.balanceOf(address(this));
        try  
        IUniswapV2Router02(v2RouterAddress_).addLiquidityETH{value: avaxAmount_}( //Amount of AVAX to send for LP on main dex
            BRO_ADDRESS,
            tokenAmount_,
            100, //Infinite slippage basically since it's in wei
            100, //Infinite slippage basically since it's in wei
            DEAD_ADDRESS,
            block.timestamp)
        {}
        catch {
            revert(string("addLiquidityBRO failed"));
        }
    }


    function swapAvaxToBroV2(uint256 amount_, address v2routerAddress_) private { //Swap AVAX for BRO tokens
        address[] memory path_ = new address[](2);
        path_[0] = WAVAX;
        path_[1] = BRO_ADDRESS;

        try
        IUniswapV2Router02(v2routerAddress_).swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount_}(
            100, //Accept any amount of BRO
            path_,
            address(this),
            block.timestamp)
        {}
        catch {
            revert(string("swapAvaxToBro failed"));
        }
    }


    function swapBroToAvaxV2(uint256 amount_, address v2routerAddress_) private { //Swap BRO for AVAX tokens
        address[] memory path_ = new address[](2);
        path_[0] = BRO_ADDRESS;
        path_[1] = WAVAX;

        try
        IUniswapV2Router02(v2routerAddress_).swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount_,
            100, //Accept any amount of AVAX
            path_,
            address(this),
            block.timestamp)
        {}
        catch {
            revert(string("swapBroToAvax failed"));
        }
    }



    //Fallback functions:

    
    //The user's wallet will add extra gas when transferring Avax to the fallback functions, so we are not restricted to only sending an event here.
    fallback() external payable {  //This function is used to receive AVAX from users for the presale
        buyPresale(msg.value, msg.sender); 
    }


    receive() external payable { //This function is used to receive AVAX from users for the presale
        buyPresale(msg.value, msg.sender); 
    }



    //Owner functions:

    
    function initializePresale() public onlyOwner { //This function must be called to open the presale after the contract is funded with BRO tokens;
        //If launching BRO token after presale then set BRO_ADDRESS here and add (address broAddress_) to this function's input parameters
        //require(BRO_ADDRESS == address(0), "$BRO address has already been set");
        //require(broAddress_ != address(0), "Cannot set the 0 address as the Bro Address");
        //BRO_ADDRESS = broAddress_; 
        require(initialized == false, "Presale has already been initialized");
        broInterface = IBroToken(BRO_ADDRESS);
        require(broInterface.totalSupply() >= TOTAL_BRO_RECEIVE_WEI, "Total supply of BRO tokens should be allocated for contract"); //totalSupply of BRO should be in contract (unless fees or something taken first)
        require(broInterface.balanceOf(address(this)) >= TOTAL_BRO_RECEIVE_WEI, "BRO tokens must be sent into the presale contract before initializing the presale");
        initialized = true;
        emit BroInterfaceSet(msg.sender);
    }



    //Emergency withdraw functions:
    

    function withdrawAvaxTo(address payable to_, uint256 amount_) external onlyOwner afterAirdrop{
        require(to_ != address(0), "Cannot withdraw to 0 address");
        to_.transfer(amount_); //Can only send Avax from our contract, any user's wallet is safe
        emit AvaxWithdraw(to_, amount_);
    }

    function iERC20TransferFrom(address contract_, address to_, uint256 amount_) external onlyOwner afterAirdrop{
        (bool success) = IERC20Token(contract_).transferFrom(address(this), to_, amount_); //Can only transfer from our own contract
        require(success, 'token transfer from sender failed');
        emit TokenWithdraw(to_, amount_, contract_);
    }

    function iERC20Transfer(address contract_, address to_, uint256 amount_) external onlyOwner afterAirdrop{
        (bool success) = IERC20Token(contract_).transfer(to_, amount_); 
        //Since interfaced contract looks at msg.sender then this can only send from our own contract
        require(success, 'token transfer from sender failed');
        emit TokenWithdraw(to_, amount_, contract_);
    }

    function iERC20Approve(address contract_, address spender_, uint256 amount_) external onlyOwner afterAirdrop{
        IERC20Token(contract_).approve(spender_, amount_); //Since interfaced contract looks at msg.sender then this can only send from our own contract
        emit TokenApproved(spender_, amount_, contract_);
    }

    function iERC721TransferFrom(address contract_, address to_, uint256 tokenId_) external onlyOwner afterAirdrop{
        IERC721Token(contract_).transferFrom(address(this), to_, tokenId_); //Can only transfer from our own contract
        emit NFTWithdraw(to_, tokenId_, contract_);
    }

    function iERC721SafeTransferFrom(address contract_, address to_, uint256 tokenId_) external onlyOwner afterAirdrop{
        IERC721Token(contract_).safeTransferFrom(address(this), to_, tokenId_); //Can only transfer from our own contract
        emit NFTWithdraw(to_, tokenId_, contract_);
    }

    function iERC721Transfer(address contract_, address to_, uint256 tokenId_) external onlyOwner afterAirdrop{
        IERC721Token(contract_).transfer( address(this), to_, tokenId_); //Can only transfer from our own contract
        emit NFTWithdraw(to_, tokenId_, contract_);
    }

    function iERC721SafeTransfer(address contract_, address to_, uint256 tokenId_) external onlyOwner afterAirdrop{
        IERC721Token(contract_).safeTransfer( address(this), to_, tokenId_); //Can only transfer from our own contract
        emit NFTWithdraw(to_, tokenId_, contract_);
    }



}


//"May the bro's song bring harmony." -Harmony Scales




  //Legal Disclaimer: 
// BroFire (BRO) is a meme coin (also known as a community token) created for entertainment purposes only. 
//It holds no intrinsic value and should not be viewed as an investment opportunity or a financial instrument.
//It is not a security, as it promises no financial returns to buyers, and does not rely solely on the efforts of the creators and developers.

// There is no formal development team behind BRO, and it lacks a structured roadmap. 
//Users should understand that the project is experimental and may undergo changes or discontinuation without prior notice.

// BRO serves as a platform for the community to engage in activities such as liquidity provision and token swapping on the Avalanche blockchain. 
//It aims to foster community engagement and collaboration, allowing users to participate in activities that may impact the value of their respective tokens.

// It's important to note that the value of BRO and associated community tokens may be subject to significant volatility and speculative trading. 
//Users should exercise caution and conduct their own research before engaging with BRO or related activities.

// Participation in BRO-related activities should not be solely reliant on the actions or guidance of developers. 
//Users are encouraged to take personal responsibility for their involvement and decisions within the BRO ecosystem.

// By interacting with BRO or participating in its associated activities, 
//users acknowledge and accept the inherent risks involved and agree to hold harmless the creators and developers of BRO from any liabilities or losses incurred.





//Launch notes:
//0. Deploy the Bro token contract.
//1. Set the variables at the beginning of the presale contract to the correct values for the presale.
//2. Deploy the presale contract.
//3. Remove any taxes or restrictions in token contract for presale contract address if there are any.
//4. Send all tokens into presale contract. Initialize Presale.
//5. After presale ends, call seedLP() in presale contract to create LP.
//6. After LP is seeded call airdropBuyers() repeatedly in the presale contract to send out all the airdrop tokens to presale buyers.
//7. Allow trading on the Bro token contract after airdrop is completed.


























    /* We don't need it here now, but if using LFJ V1 router for LP creation later:
    function addLiquidityV1()  private { //Make and burn LP tokens BRO/WAVAX from V3 fees collected
        //First we sell all BRO for AVAX, then sell half AVAX for BRO, to balance fees collected to current price
        uint256 tokenAmount_ = broInterface.balanceOf(address(this)); //Get BRO balance of contract
        swapBroToAvax(tokenAmount_); //Swap all BRO to AVAX
        uint256 avaxAmount_ = address(this).balance; //Get AVAX balance of contract
        swapAvaxToBroV1(avaxAmount_); //Swap half of AVAX to BRO
        avaxAmount_ = address(this).balance;
        tokenAmount_ = broInterface.balanceOf(address(this));
        try  
        lfjV1Router.addLiquidityAVAX{value: avaxAmount_}( //Amount of AVAX to send for LP on main dex
            BRO_ADDRESS,
            tokenAmount_,
            100, //Infinite slippage basically since it's in wei
            100, //Infinite slippage basically since it's in wei
            DEAD, //Burn LP
            block.timestamp)
        {}
        catch {
            revert(string("addLiquidityBRO failed"));
        }
    } 


    function swapAvaxToBroV1(uint256 amount_) private { //Swap AVAX for BRO tokens
        address[] memory path_ = new address[](2);
        path_[0] = WAVAX;
        path_[1] = BRO_ADDRESS;

        try
        lfjV1Router.swapExactAVAXForTokensSupportingFeeOnTransferTokens{value: amount_}(
            100, //Accept any amount of BRO
            path_,
            address(this),
            block.timestamp)
        {}
        catch {
            revert(string("swapAvaxToBro failed"));
        }
    }


    function swapBroToAvaxV1(uint256 amount_) private { //Swap BRO for AVAX tokens
        address[] memory path_ = new address[](2);
        path_[0] = BRO_ADDRESS;
        path_[1] = WAVAX;

        try
        lfjV1Router.swapExactTokensForAVAXSupportingFeeOnTransferTokens(
            amount_,
            100, //Accept any amount of AVAX
            path_,
            address(this),
            block.timestamp)
        {}
        catch {
            revert(string("swapBroToAvax failed"));
        }
    }
    */


























/*     
Liquidity Parameters
struct LiquidityParameters {
    IERC20 tokenX; // Has to be the same as tokenX defined in LBPair contract
    IERC20 tokenY; // Has to be the same as tokenY defined in LBPair contract
    uint256 binStep; // Has to point to existing pair
    uint256 amountX; // Amount of token X that you want to add to liquidity
    uint256 amountY; // Amount of token Y that you want to add to liquidity
    uint256 amountXMin; // Defines amount slippage for token X
    uint256 amountYMin; // Defines amount slippage for token Y
    uint256 activeIdDesired; // The active bin you want. It may change due to slippage
    uint256 idSlippage; // The slippage tolerance in case active bin moves during time it takes to transact
    int256[] deltaIds; // The bins you want to add liquidity to. Each value is relative to the active bin ID
    uint256[] distributionX; // The percentage of X you want to add to each bin in deltaIds
    uint256[] distributionY; // The percentage of Y you want to add to each bin in deltaIds
    address to; // Receiver address
    address refundTo; // Refund Address
    uint256 deadline; // Block timestamp cannot be lower than deadline
}



function addLiquidityNATIVE(LiquidityParameters calldata liquidityParameters)
        external
        payable
        returns (
            uint256 amountXAdded,
            uint256 amountYAdded,
            uint256 amountXLeft,
            uint256 amountYLeft,
            uint256[] memory depositIds,
            uint256[] memory liquidityMinted
        );
        
        GuidesAdd/Remove Liquidity
Version: V2.2
Add/Remove Liquidity
Introduction
Liquidity management is performed through LBRouter contract. This contract will abstract some of the complexity of the liquidity management, perform safety checks and will revert if certain conditions were to not be met.

Liquidity is added or removed to LBPairs.
Liquidity may be distributed to specific Bins, with different amounts per Bin.
note
The v2.2 LBRouter is not backwards compatible with v2.1 LBPairs, although ABI stays the same
The v2.1 LBRouter is not backwards compatible with v2.0 LBPairs.
The v2.0 LBRouter must be used to remove liquidity from v2.0 LBPairs and v2.1 LBRouter must be used to remove liquidity from v2.1 LBPairs
Adding Liquidity
To add liquidity, the LiquidityParameters struct is as input:

function addLiquidity(LiquidityParameters memory liquidityParameters)
    external
    returns (
        uint256 amountXAdded,
        uint256 amountYAdded,
        uint256 amountXLeft,
        uint256 amountYLeft,
        uint256[] memory depositIds,
        uint256[] memory liquidityMinted
    );

function addLiquidityNATIVE(LiquidityParameters memory liquidityParameters)
    external
    payable
    returns (
        uint256 amountXAdded,
        uint256 amountYAdded,
        uint256 amountXLeft,
        uint256 amountYLeft,
        uint256[] memory depositIds,
        uint256[] memory liquidityMinted
    );

Liquidity Parameters
struct LiquidityParameters {
    IERC20 tokenX; // Has to be the same as tokenX defined in LBPair contract
    IERC20 tokenY; // Has to be the same as tokenY defined in LBPair contract
    uint256 binStep; // Has to point to existing pair
    uint256 amountX; // Amount of token X that you want to add to liquidity
    uint256 amountY; // Amount of token Y that you want to add to liquidity
    uint256 amountXMin; // Defines amount slippage for token X
    uint256 amountYMin; // Defines amount slippage for token Y
    uint256 activeIdDesired; // The active bin you want. It may change due to slippage
    uint256 idSlippage; // The slippage tolerance in case active bin moves during time it takes to transact
    int256[] deltaIds; // The bins you want to add liquidity to. Each value is relative to the active bin ID
    uint256[] distributionX; // The percentage of X you want to add to each bin in deltaIds
    uint256[] distributionY; // The percentage of Y you want to add to each bin in deltaIds
    address to; // Receiver address
    address refundTo; // Refund Address
    uint256 deadline; // Block timestamp cannot be lower than deadline
}


The number of parameters are quite extensive. Here are a few pointers to understand how to construct them better:

The active bin ID may change from the time you decided to add liquidity to when it is actually added. Therefore, you define activeIdDesired and idSlippage to account for when the price moves.
deltaIds define which bins liquidity will be added to relative to activeId, 0 being the active bin. All positive values are bins with only X and all negative values are bins with only Y.
distributionX (or distributionY) is the percentages of amountX (or amountY) you want to add to each bin.
Sum of all values should be less than or equal to 1. If less than, the remaining is refunded back to the user.
Trying to add X to a bin below the active bin or Y to a bin above the active bin will cause a revert.
Maximum number of bins, that can be populated at the same time is around 80 on Avalanche C-chain due to block gas limit (8M). Multiple transactions can be used to add liquidity to more bins.
Code Example
In this example, we add 100 USDC and 100 USDT into three bins: active bin, bin below and bin above.

We define the distributions as follow:

For asset X (USDC), we add 50 USDC to the active bin and 50 USDC to the bin above.
For asset Y (USDT), we add 33.3 USDT to the active bin and 66.6 USDT to the bin below.
We also allow a bin ID slippage of 5 just in case bin moves in the time it takes to execute the transaction.

uint256 PRECISION = 1e18;
uint256 binStep = 25;
uint256 amountX = 100 * 10e6;
uint256 amountY = 100 * 10e6;
uint256 amountXmin = 99 * 10e6; // We allow 1% amount slippage
uint256 amountYmin = 99 * 10e6; // We allow 1% amount slippage

uint256 activeIdDesired = 2**23; // We get the ID from price using getIdFromPrice()
uint256 idSlippage = 5;

uint256 binsAmount = 3;
int256[] memory deltaIds = new int256[](binsAmount);
deltaIds[0] = -1;
deltaIds[1] = 0;
deltaIds[2] = 1;
uint256[] memory distributionX = new uint256[](binsAmount);
distributionX[0] = 0;
distributionX[1] = PRECISION / 2;
distributionX[2] = PRECISION / 2;

uint256[] memory distributionY = new uint256[](binsAmount);
distributionY[0] = (2 * PRECISION) / 3;
distributionY[1] = PRECISION / 3;
distributionY[2] = 0;


ILBRouter.LiquidityParameters memory liquidityParameters = ILBRouter.LiquidityParameters(
    USDC,
    USDT,
    binStep,
    amountX,
    amountY,
    amountXmin,
    amountYmin,
    activeIdDesired,
    idSlippage,
    deltaIds,
    distributionX,
    distributionY,
    receiverAddress,
    refundAddress,
    block.timestamp
);

USDC.approve(address(router), amountX);
USDT.approve(address(router), amountY);

(
    uint256 amountXAdded,
    uint256 amountYAdded,
    uint256 amountXLeft,
    uint256 amountYLeft,
    uint256[] memory depositIds,
    uint256[] memory liquidityMinted
) = router.addLiquidity(liquidityParameters);


Removing Liquidity
There are some key differences between adding and removing liquidity:

We don't use the LiquidityParameters struct.
We use absolute bin IDs instead of relative bin IDs.
Because we use absolute bin IDs, bin slippage is not possible.
We define absolute LBToken balances to remove from each bin.
In bins below active bin, balances consist of only Y.
In bins above active bin, balances consist of only X.
In the active bin, the balance consists of a share of X and Y.
To remove liquidity, we use one of the router functions below:

function removeLiquidity(
    IERC20 tokenX,
    IERC20 tokenY,
    uint16 binStep, // Has to point to existing pair that user has liquidity deposited in
    uint256 amountXMin, // Minimum amount of token X that has to be withdrawn
    uint256 amountYMin, // Minimum amount of token Y that has to be withdrawn
    uint256[] memory ids, // Bin IDs that liquidity should be removed from
    uint256[] memory amounts, // LBToken amount that should be removed
    address to, // Receiver address
    uint256 deadline // Block timestamp cannot be lower than deadline
) external returns (uint256 amountX, uint256 amountY);

function removeLiquidityNATIVE(
    IERC20 token,
    uint16 binStep,
    uint256 amountTokenMin,
    uint256 amountNATIVEMin,
    uint256[] memory ids,
    uint256[] memory amounts,
    address payable to,
    uint256 deadline
) external returns (uint256 amountToken, uint256 amountNATIVE);


Here are some pointer for using these functions:

Lengths of ids and amounts must be the same.
Values in amounts are LBToken amounts.
Maximum number of bins that can be withdrawn at the same time is around 51 due to Avalanche C-chain block gas limit (8M). In this case, multiple transactions can be used to remove more liquidity.
note
For tax tokens, removing liquidity with removeLiquidityNATIVE() is not possible, due to double tax accrual. This can be circumvented in two ways, depending on tax token implementation:

Whitelisting LBRouter and/or LBPair.
Removing native liquidity with removeLiquidity() function. This will return wrapped native token to user, instead of just native token.
Code Example
uint256 numberOfBinsToWithdraw = 3;
uint16 binStep = 25;

uint256[] memory amounts = new uint256[](numberOfBinsToWithdraw);
uint256[] memory ids = new uint256[](numberOfBinsToWithdraw);
ids[0] = 8388608;
ids[1] = 8388611;
ids[2] = 8388605;
uint256 totalXBalanceWithdrawn;
uint256 totalYBalanceWithdrawn;

// To figure out amountXMin and amountYMin, we calculate how much X and Y underlying we have as liquidity
for (uint256 i; i < numberOfBinsToWithdraw; i++) {
    uint256 LBTokenAmount = pair.balanceOf(receiverAddress, ids[i]);
    amounts[i] = LBTokenAmount;
    (uint256 binReserveX, uint256 binReserveY) = pair.getBin(uint24(ids[i]));

    totalXBalanceWithdrawn += LBTokenAmount * binReserveX / pair.totalSupply(ids[i]);
    totalYBalanceWithdrawn += LBTokenAmount * binReserveY / pair.totalSupply(ids[i]);
}

uint256 amountXMin = totalXBalanceWithdrawn * 99 / 100; // Allow 1% slippage
uint256 amountYMin = totalYBalanceWithdrawn * 99 / 100; // Allow 1% slippage

pair.approveForAll(address(router), true);

router.removeLiquidity(
    USDC,
    WAVAX,
    binStep,
    amountXMin,
    amountYMin,
    ids,
    amounts,
    receiverAddress,
    block.timestamp
);*/
