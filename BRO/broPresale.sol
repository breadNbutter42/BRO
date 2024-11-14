/* $BRO Links:
Medium: https://medium.com/@BROFireAvax
Twitter: @BROFireAvax
Discord: https://discord.gg/uczFJdMaf4
Telegram: BROFireAvax
Website: www.BROFireAvax.com
Email: contact@BROFireAvax.com
*/

// This is a presale contract for the $BRO token on Avalanche.
// Users can transfer AVAX directly to this contract address during the presale time window.
// There is a minimum presale buy in amount of 1 AVAX per transfer.
// LP to be trustlessly created after the presale ends, using half of the $BRO supply and all of the presale AVAX.
// Presale buyers' $BRO tokens to be trustlessly "airdropped" out after presale ends, aka sent directly to them.
// Note: There are no whale limits or allowlists for this presale.

// V1 and V2 LP is burned since fees are automatically converted to more LP
// V3 and V2.2 LP NFTs are locked in collection contract so fees can be collected and converted to more LP


//$BRO is an ERC20 token that collects fees on transfers, and creates LP with other top community tokens.
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



interface IUniswapV2Factory { 

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);


    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

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



interface ILFJV1Router02 is ILFJV1Router01 {

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
import '@uniswap/v3-core/contracts/libraries/TickMath.sol'; //Uniswap V3 tick math library
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; //Reentrancy guard from OpenZeppelin
import "@openzeppelin/contracts/access/Ownable.sol"; //Owner contract from OpenZeppelin
import "https://github.com/traderjoe-xyz/joe-v2/blob/main/src/libraries/PriceHelper.sol"; //LFJ V2.2 LP helper library
import "@uniswap/v3-core/contracts/libraries/FixedPoint96.sol"; //Uniswap V3 fixed-point math library Q64.96
import "@uniswap/v3-core/contracts/libraries/FullMath.sol"; //Uniswap V3 full math library
import "https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/SqrtPriceMath.sol"; //Uniswap V3 sqrt price math library
import "https://github.com/Uniswap/solidity-lib/blob/master/contracts/libraries/Babylonian.sol"; //Uniswap Babylonian square root math library


contract BroPresale is Ownable, ReentrancyGuard {
    IBroToken public broInterface; //ERC20 Bro token interface
    ILFJV1Router02 public lfjV1Router; //DEX router for LFJ V1 LP creation
    ILBRouter public lfjLbRouterV2ii; //V2.2 of LFJ router which is analagous to v4 uniswap lp
    IUniswapV2Router02 public uniswapV2Router; //DEX router for Uniswap V2 LP creation
    INonfungiblePositionManager public uniswapV3; //Uniswap V3 NFT manager for LP creation
    IUniswapV2Router02 public pharoahV2Router; //DEX router for Pharoah V2 LP creation
    INonfungiblePositionManager public pharoahV3; //Pharoah V3 NFT manager for LP creation
    IUniswapV2Router02 public pangolinV2Router; //DEX router for Pangolin V2 LP creation

        //V2.2 LP variables
    uint256 public constant PRECISION = 1e18;  // Fixed-point precision constant of BRO token
    uint256 public constant binStep = PRECISION/100; //Bin step in fixed-point (e.g., 1% as 1e16) for LFJ V2.2 LP
    uint256 public constant NumBins = 700; //Bins for LFJ V2.2 LP, if 70 @ 1% bin step is ~ 2^1 = 2x then 700 bins is ~ 2^10 = 1024x range
    uint256 public constant ratioOfTokensPerBin_ = ((1*10**18) / 70); //Ratio inputs for tokens per bin for V2.2 divided evenly over 70 bins

        //Uniswap V3 LP variables
    int24 public constant V3_TICK_SPACING = 200; //Set from chart here ++https://support.uniswap.org/hc/en-us/articles/21069524840589-What-is-a-tick-when-providing-liquidity
    uint256 public constant V3FEE = 10000; //Uniswap V3 fee in hundreths of a bips, 10000 = 1% fee
    uint256 public constant V3_SCALE = 1054; //Scale to find max price for LP range, here I picked 1% price increase * 700 : 1.01**700 = ~1054
    //Max price to seed LP = (floorPrice*V3_SCALE)

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
    uint256 public constant V1_LFJ_DEX_PERCENT = 5; //Percentage of auto LP for LFJ TraderJoe dex V1
    uint256 public constant V2ii_LFJ_DEX_PERCENT = 80; //Percentage of auto LP for LFJ TraderJoe dex V2.2 LBRouter
    uint256 public constant V2_UNISWAP_DEX_PERCENT = 3; //Percentage of auto LP for Uniswap dex V2
    uint256 public constant V3_UNISWAP_DEX_PERCENT = 3; //Percentage of auto LP for Uniswap dex V3
    uint256 public constant V2_PHAROAH_DEX_PERCENT = 3; //Percentage of auto LP for Pharoah dex V2
    uint256 public constant V3_PHAROAH_DEX_PERCENT = 3; //Percentage of auto LP for Pharoah dex V3
    uint256 public constant V2_PANGOLIN_DEX_PERCENT = 3; //Percentage of auto LP for Pangolin dex V2

    uint256 public constant BroForLFJWeiV1 = V1_LFJ_DEX_PERCENT * LP_BRO_SUPPLY_WEI / 100; // BRO  for LFJ TraderJoe dex V1 LP creation
    uint256 public constant BroForLFJWeiV2ii = V2ii_LFJ_DEX_PERCENT * LP_BRO_SUPPLY_WEI / 100; // BRO  for LFJ TraderJoe dex V2.2 LP creation
    uint256 public constant BroForUniswapWeiV2 = V2_UNISWAP_DEX_PERCENT * LP_BRO_SUPPLY_WEI / 100; // BRO  for Uniswap dex V2 LP creation
    uint256 public constant BroForUniswapWeiV3 = V3_UNISWAP_DEX_PERCENT * LP_BRO_SUPPLY_WEI / 100; // BRO  for Uniswap dex V3 LP creation
    uint256 public constant BroForPharoahWeiV2 = V2_PHAROAH_DEX_PERCENT * LP_BRO_SUPPLY_WEI / 100; // BRO  for Pharoah dex V2 LP creation
    uint256 public constant BroForPharoahWeiV3 = V3_PHAROAH_DEX_PERCENT * LP_BRO_SUPPLY_WEI / 100; // BRO  for Pharoah dex V3 LP creation
    uint256 public constant BroForPangolinWeiV2 = V2_PANGOLIN_DEX_PERCENT * LP_BRO_SUPPLY_WEI / 100; //BRO for Pangolin dex V2 LP creation
    uint256 public constant BroPer70Bins = BroForLFJWeiV2ii/(NumBins/70); // BRO per 70 bins for LFJ V2.2 LP

    address public constant WAVAX_ADDRESS = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7; //WAVAX Mainnet: 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7 ; Fuji: 0xd00ae08403B9bbb9124bB305C09058E32C39A48c
    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD; //Burn address for LP tokens
    address public constant LFJ_V1_ROUTER_ADDRESS = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4; //Mainnet: 0x60aE616a2155Ee3d9A68541Ba4544862310933d4 ; Fuji: 0xd7f655E3376cE2D7A2b08fF01Eb3B1023191A901
    address public constant LFJ_V2ii_LB_ROUTER_ADDRESS = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88; //Mainnet: 0xC36442b4a4522E871399CD717aBDD847Ab11FE88 ; Fuji: 0x18556DA13313f3532c54711497A8FedAC273220E
    address public constant UNISWAP_V2_ROUTER_ADDRESS = 0x4752ba5dbc23f44d87826276bf6fd6b1c372ad24; //Mainnet: 0x4752ba5dbc23f44d87826276bf6fd6b1c372ad24 ; Sepolia: 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3
    address public constant UNISWAP_V3_NONFUNGIBLE_POSITION_MANAGER_ADDRESS = 0x655C406EBFa14EE2006250925e54ec43AD184f8B; //Mainnet: 0x655C406EBFa14EE2006250925e54ec43AD184f8B
    address public constant PHAROAH_V2_ROUTER_ADDRESS = 0xAAA9f93572B99919750FA59c33c0946bc5fC0e90; //Mainnet: 0xAAA9f93572B99919750FA59c33c0946bc5fC0e90
    address public constant PHAROAH_V3_NONFUNGIBLE_POSITION_MANAGER_ADDRESS = 0xAAA78E8C4241990B4ce159E105dA08129345946A; //Mainnet: 0xAAA78E8C4241990B4ce159E105dA08129345946A
    address public constant PANGOLIN_V2_ROUTER_ADDRESS = 0xE54Ca86531e17Ef3616d22Ca28b0D458b6C89106; //Mainnet: 0xE54Ca86531e17Ef3616d22Ca28b0D458b6C89106 ;  FUJI: 0x2D99ABD9008Dc933ff5c0CD271B88309593aB921
    address public constant TEAM_WALLET = 0xE395C115657b636760AbDe037185C6C8E6948A72; //Address to receive AVAX for team funds once presale is completed


    address public broAddress = address(0); //Set after deploying BRO token contract
    address public lfjV1PairAddress = address(0); //Set when LFJ V1 Pair contract has been initialized
    address public lfjV2iiPairAddress = address(0); //Set when LFJ V2.2 Pair contract has been initialized
    address public uniswapV2PairAddress = address(0); //Set when Uniswap V2 Pair contract has been initialized
    address public uniswapV3PairAddress = address(0); //Set when Uniswap V3 Pair contract has been initialized
    address public pharoahV2PairAddress = address(0); //Set when Pharoah V2 Pair contract has been initialized
    address public pharoahV3PairAddress = address(0); //Set when Pharoah V3 Pair contract has been initialized
    address public pangolinV2PairAddress = address(0); //Set when Pangolin V2 Pair contract has been initialized

    address[] public presaleBuyers = new address[](0); //Array to store presale buyers addresses to send BRO tokens to later and for WL phase checks

    mapping (address => uint256) public totalAvaxUserSent; //Mapping to store total AVAX sent by each presale buyer

    uint256 public airdropIndex = 0; //Count through the airdrop array when sending out tokens
    uint256 public totalAvaxPresaleWei = 0; //Count total AVAX received during presale
    uint256 public avaxForLPWei = 0; //Amount of collected AVAX  for LP creation
    uint256 public avaxForTeamWei = 0; //Get remaining AVAX balance after LP creation
    uint256 public avaxForLFJWeiV1 = 0; // AVAX  for LFJ TraderJoe dex V1 LP creation
    uint256 public avaxForLFJWeiV2ii = 0; // % of LP for LFJ TraderJoe dex v2.2
    uint256 public avaxForUniswapWeiV2 = 0; // AVAX  for Uniswap dex V2 LP creation
    uint256 public avaxForUniswapWeiV3 = 0; // AVAX  for Uniswap dex V3 LP creation
    uint256 public avaxForPharoahWeiV2 = 0; // AVAX  for Pharoah dex V2 LP creation
    uint256 public avaxForPharoahWeiV3 = 0; // AVAX  for Pharoah dex V3 LP creation
    uint256 public avaxForPangolinWeiV2 = 0; // AVAX  for Pangolin dex V2 LP creation

    uint256 public priceIn128_ = 0; // Price in fixed-point 128x128 format for LFJ V2.2 LP
    uint256 public startingBinId_ = 0; // Initial bin ID based on price (which is based on avax / bro) for LFJ V2.2 LP
    uint256 public previousBin = 0; //Tracks the most recent bin updated by the function call to make LFJ V2.2 LP
    uint256 public sqrtPriceQ96 = 0; //Holds final price variable for Uniswap V3 LP creation floor price
    uint256 public sqrtPriceQ96Max = 0; //Holds final price variable for Uniswap V3 LP creation maximum range price
    uint256 public teamTokensWithdrawn = 0; //Count BRO tokens withdrawn to team wallet after auto LP creation
    uint256 public teamAvaxWithdrawn = 0; //Count Avax withdrawn to team wallet after auto LP creation

    bool public lfjV1LpCreated = false; //Flag to indicate when LFJ V1 LP has been created
    bool public lfjV2iiLpCreated = false; //Flag to indicate when LFJ V2.2 LP has been created
    bool public uniswapV2LpCreated = false; //Flag to indicate when Uniswap V2 LP has been created
    bool public uniswapV3LpCreated = false; //Flag to indicate when Uniswap V3 LP has been created
    bool public uniswapV3LpFloorCreated = false; //Flag to indicate when Uniswap V3 LP AVAX floor has been created
    bool public pharoahV2LpCreated = false; //Flag to indicate when Pharoah V2 LP has been created
    bool public pharoahV3LpFloorCreated = false; //Flag to indicate when Pharoah V3 LP AVAX floor has been created
    bool public pharoahV3LpCreated = false; //Flag to indicate when Pharoah V3 LP has been created
    bool public pangolinV2LpCreated = false; //Flag to indicate when Pangolin V2 LP has been created
    bool public lpCreated = false; //Flag to indicate when all LP has been created


    bool public broInitialized = false; //Flag to indicate when BRO tokens have been seeded into contract to open presale to buyers
    bool public pairsInitialized = false; //Flag to indicate when all LP pool pair contracts have been initialized
    bool public amountsCalculated = false; //Flag to indicate when post presale amounts have been calculated
    bool public airdropCompleted = false; //Flag to indicate when airdrop is completed
    
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
        require(block.timestamp >= AIRDROP_TIME + 7 days, "Cannot withdraw tokens until 7 days after airdrop starts"); 
        //Wait 7 days to give time for presale to complete first
        _;
    }

    modifier calculated() {
        require(amountsCalculated, "Must call calculatePostPresaleAmounts() first"); 
        _;
    }           

    modifier broInit() {
        require(broInitialized, "Must call initializeBro() first"); 
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
        require(TOTAL_BRO_RECEIVE_WEI <= 1*10**30, "Total BRO tokens must be less or equal to 1 Trillion tokens in WEI value to prevent sqrtPriceQ96 calc overflow");
        require(AVAX_FOR_LP_PERCENT + AVAX_FOR_TEAM_PERCENT == 100, "AVAX percentages must add up to 100");
        require(
            V1_LFJ_DEX_PERCENT + 
            V2_UNISWAP_DEX_PERCENT + 
            V2ii_LFJ_DEX_PERCENT + 
            V3_UNISWAP_DEX_PERCENT + 
            V2_PHAROAH_DEX_PERCENT + 
            V3_PHAROAH_DEX_PERCENT + 
            V2_PANGOLIN_DEX_PERCENT == 100, "DEX auto LP allocation percentages must add up to 100");

        require(MINIMUM_BUY_WEI >= 1000000000000000000, "Minimum buy must be at least 1 AVAX to prevent airdrop gas attacks");
        require(NumBins % 70 == 0, "Number of bins must be divisible by 70 for our LFJ V2.2 LP calculations");
        require(NumBins > 0, "Number of bins must be greater than 0 for our LFJ V2.2 LP calculations");
        require(NumBins < 7001, "Number of bins must be less than 7001 for feasability to make all LP transactions"); //7000 bins at 70 bins a tx is 100 txs which is already too many, and gives more than enough range for LP
        
        require(V3_SCALE <= 10**6, "V3_SCALE must be less than 10^6 to prevent overflow in LP seeding"); 

        //Define DEX router interfaces
        lfjV1Router = ILFJV1Router02(LFJ_V1_ROUTER_ADDRESS);
        lfjLbRouterV2ii = ILBRouter(LFJ_V2ii_LB_ROUTER_ADDRESS);
        uniswapV2Router = IUniswapV2Router02(UNISWAP_V2_ROUTER_ADDRESS);
        uniswapV3 = INonfungiblePositionManager(UNISWAP_V3_NONFUNGIBLE_POSITION_MANAGER_ADDRESS);
        pharoahV2Router = IUniswapV2Router02(PHAROAH_V2_ROUTER_ADDRESS);
        pharoahV3 = INonfungiblePositionManager(PHAROAH_V3_NONFUNGIBLE_POSITION_MANAGER_ADDRESS);
        pangolinV2Router = IUniswapV2Router02(PANGOLIN_V2_ROUTER_ADDRESS);
    }



    //Public functions


    function buyPresale() public payable { //Public function alternative to fallback function to buy presale tokens
        _buyPresale(msg.value, msg.sender); //Simpler interface no need to specify buyer address since it's the msg.sender
    }


    function buyPresaleBuyer(address buyer_) public payable { //Public function alternative to fallback function to buy presale tokens
        _buyPresale(msg.value, buyer_); //Can specify buyer address in case it's useful such as a middleman rewards contract
    }


//Is this function too big and will fail from out of gas, especially with sqrtPriceQ96 calculations calling Babylonian sqrt search?
    function calculatePostPresaleAmounts() public { //1. This function must be called once, after the presale ends
        require(pairsInitialized, "Pair contracts have not been initialized yet"); //Should have been initialized by devs already
        require(!amountsCalculated, "Amounts have already been calculated");
        require(block.timestamp > PRESALE_END_TIME, "Presale has not ended yet");

        avaxForLPWei = AVAX_FOR_LP_PERCENT * totalAvaxPresaleWei / 100; //Calculate % of total AVAX for auto LP creation
        avaxForTeamWei = totalAvaxPresaleWei - avaxForLPWei; //Get remaining AVAX balance after auto LP creation
        avaxForLFJWeiV1 = V1_LFJ_DEX_PERCENT * avaxForLPWei / 100; //Calculate % of LP for LFJ TraderJoe dex V1
        avaxForLFJWeiV2ii = V2ii_LFJ_DEX_PERCENT * avaxForLPWei / 100; //Calculate AVAX  for LFJ TraderJoe dex V3 LP creation
        avaxForUniswapWeiV2 = V2_UNISWAP_DEX_PERCENT * avaxForLPWei / 100; //Calculate AVAX  for Uniswap dex V2 LP creation
        avaxForUniswapWeiV3 = V3_UNISWAP_DEX_PERCENT * avaxForLPWei / 100; //Calculate AVAX  for Uniswap dex V2 LP creation
        avaxForPharoahWeiV2 = V2_PHAROAH_DEX_PERCENT * avaxForLPWei / 100; //Calculate AVAX  for Pharoah dex V2 LP creation
        avaxForPharoahWeiV3 = V3_PHAROAH_DEX_PERCENT * avaxForLPWei / 100; //Calculate AVAX  for Pharoah dex V3 LP creation
        avaxForPangolinWeiV2 = V2_PANGOLIN_DEX_PERCENT * avaxForLPWei / 100; //Calculate AVAX  for Pangolin dex V2 LP creation

        //Converts a uint256 price with 18 decimals to a 128.128-binary fixed-point number
        priceIn128_ = PriceHelper.convertDecimalPriceTo128x128((avaxForLPWei * 1e18) / LP_BRO_SUPPLY_WEI); 
        // Price in fixed-point 128x128 format. scale up by 1e18 to match 18 decimals
        
        startingBinId_ = PriceHelper.getIdFromPrice(priceIn128_, uint16(binStep / 1e14)); // Convert binStep to uint16(priceIn128_); // Initial bin ID based on current price

        (sqrtPriceQ96Floor, sqrtPriceQ96Max) = getSqrtPricesX96(LP_BRO_SUPPLY_WEI, avaxForLPWei); //Used for Uniswap V3 LP creation 
        // sqrtPriceQ96Floor is derived from Floor Price = AVAX/BRO 
        // sqrtPriceQ96Max is LP ceiling price derived from (floor * V3_SCALE)

        amountsCalculated = true;
        emit PostPresaleProcessing(msg.sender);
    }


    function seedLpV1LFJ() public nonReentrant calculated { //2. This function must be called once, after the presale ends
        require(!lfjV1LpCreated, "LFJ V1 LP has already been seeded");
        
        // Approve BRO tokens for transfer
        broToken.approve(LFJ_V1_ROUTER_ADDRESS, BroForLFJWeiV1);

        try
        lfjV1Router.addLiquidityAVAX{value: avaxForLFJWeiV1}( //Seed LFJ V1 LP
            broAddress, 
            BroForLFJWeiV1,
            100, //Infinite slippage basically since it's in wei
            100, //Infinite slippage basically since it's in wei
            DEAD_ADDRESS,
            block.timestamp)
        {}
        catch {
            revert(string("seedLpV1LFJ() failed"));
        }

        lfjV1LpCreated = true;
        emit LPSeeded(msg.sender);
    }


    function seedLpV2iiLFJ() public nonReentrant calculated { //3. This function must be called 1-100 times as needed, after the presale ends
        require(!lfjV2iiLpCreated, "LFJ V2.2 LP has already been fully seeded");
        
        // If `previousBin` is zero, we need to initialize LFJ V2.2 LP setup
        if (previousBin == 0) {
            lfjV2iiInitializeLP();
        } else {
            lfjV2iiContinueAddingLiquidity();
        }

        if (previousBin >= NumBins) { //If seeded desired bins, set flag to indicate LP has been created
            lfjV2iiLpCreated = true;
        }
        emit LPSeeded(msg.sender);
    }

    
    function seedLpUniswapV2() public nonReentrant calculated { //4. This function must be called once, after the presale ends
        require(!uniswapV2LpCreated, "Uniswap V2 LP has already been seeded");
                // Approve BRO tokens for transfer
        broToken.approve(UNISWAP_V2_ROUTER_ADDRESS, BroForUniswapWeiV2);

        try
        uniswapV2Router.addLiquidityETH{value: avaxForUniswapWeiV2}( //Seed Uniswap V2 LP
            broAddress, 
            BroForUniswapWeiV2,
            0, //Infinite slippage basically since it's in wei
            0, //Infinite slippage basically since it's in wei
            DEAD_ADDRESS, //Burn V2 LP tokens
            block.timestamp)
        {}
        catch {
            revert(string("seedLpUniswapV2() failed"));
        }

        uniswapV2LpCreated = true;
        emit LPSeeded(msg.sender);
    }


    function seedLpUniswapV3Floor() public nonReentrant calculated { //5a. This function must be called once, after the presale ends
        require(!uniswapV3LpFloorCreated, "Uniswap V3 LP has already been seeded");
        (int24 floorTick, ) = calculateV3Ticks();

        // Approve BRO tokens for transfer
        broToken.approve(UNISWAP_V3_NONFUNGIBLE_POSITION_MANAGER_ADDRESS, BroForUniswapWeiV3);

        try
        uniswapV3.mint{value: avaxForUniswapWeiV3}( //Seed Uniswap V3 LP
            broAddress, //Token0
            WAVAX_ADDRESS, //Token1
            V3FEE, //Fee uint24
            floorTick - V3_TICK_SPACING, //Lower tick int24, minimally spaced tick for adding our Avax floor
            floorTick, //Upper tick int24, max tick for adding our Avax floor
            0, //Amount0 desired
            avaxForUniswapWeiV3, //Amount1 desired
            0, //Amount0 min with infinite slippage
            1, //Amount1 min with infinite slippage
            address(this), //Keep this contract as recipient to collect V3 fees while keeping LP locked forever in this contract
            block.timestamp) //Deadline
        {}
        catch {
            revert(string("seedLpUniswapV3Floor() failed"));
        }

        uniswapV3LpFloorCreated = true;
        emit LPSeeded(msg.sender);
    }
    /*     struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    } */


    function seedLpUniswapV3Range() public nonReentrant calculated { //5b. This function must be called once, after the presale ends
        //We already approved BRO tokens for transfer in seedLpUniswapV3Floor()
        require(uniswapV3LpFloorCreated, "Uniswap V3 LP floor AVAX must be seeded first");
        (int24 tickLower, int24 tickUpper) = calculateV3Ticks();
        
        try uniswapV3.mint(//Seed Uniswap V3 LP
            broAddress, //Token0
            WAVAX_ADDRESS, //Token1
            V3FEE, //Fee uint24
            tickLower, //Lower tick int24
            tickUpper + V3_TICK_SPACING, //Upper tick int24, with tick spacing for range padding in case lower and upper are the same
            BroForUniswapWeiV3, //Amount0 desired
            0, //Amount1 desired
            1, //Amount0 min with infinite slippage
            0, //Amount1 min with infinite slippage
            address(this), //Keep this contract as recipient to collect V3 fees while keeping LP locked forever in this contract
            block.timestamp) //Deadline
        {}
        catch {
            revert("seedLpUniswapV3Range() failed");
        }
        
        uniswapV3LpCreated = true;
        emit LPSeeded(msg.sender);
    }



    
    function seedLpPharoahV2() public nonReentrant calculated { //6. This function must be called once, after the presale ends
        require(!pharoahV2LpCreated, "Pharoah V2 LP has already been seeded");
                // Approve BRO tokens for transfer
        broToken.approve(PHAROAH_V2_ROUTER_ADDRESS, BroForPharoahWeiV2);

        try
        pharoahV2Router.addLiquidityETH{value: avaxForPharoahWeiV2}( //Seed Pharoah V2 LP
            broAddress, 
            BroForPharoahWeiV2,
            0, //Infinite slippage basically since it's in wei
            0, //Infinite slippage basically since it's in wei
            DEAD_ADDRESS, //Burn V2 LP tokens
            block.timestamp) 
        {}
        catch {
            revert(string("seedLpPharoahV2() failed"));
        }

        pharoahV2LpCreated = true;
        emit LPSeeded(msg.sender);
    }


    function seedLpPharoahV3Floor() public nonReentrant calculated { //7a. This function must be called once, after the presale ends
        require(!pharoahV3LpFloorCreated, "Pharoah V3 LP has already been seeded");
        (int24 floorTick, ) = calculateV3Ticks();

        // Approve BRO tokens for transfer
        broToken.approve(PHAROAH_V3_NONFUNGIBLE_POSITION_MANAGER_ADDRESS, BroForPharoahWeiV3);

        try
        pharoahV3.mint{value: avaxForPharoahWeiV3}( //Seed Pharoah V3 LP
            broAddress, //Token0
            WAVAX_ADDRESS, //Token1
            V3FEE, //Fee uint24
            floorTick - V3_TICK_SPACING, //Lower tick int24, minimally spaced tick for adding our Avax floor
            floorTick, //Upper tick int24, max tick for adding our Avax floor
            0, //Amount0 desired
            avaxForPharoahWeiV3, //Amount1 desired
            0, //Amount0 min with infinite slippage
            1, //Amount1 min with infinite slippage
            address(this), //Keep this contract as recipient to collect V3 fees while keeping LP locked forever in this contract
            block.timestamp) //Deadline
        {}
        catch {
            revert(string("seedLpPharoahV3Floor() failed"));
        }

        pharoahV3LpFloorCreated = true;
        emit LPSeeded(msg.sender);
    }


    function seedLpPharoahV3Range() public nonReentrant calculated { //7b. This function must be called once, after the presale ends
        //We already approved BRO tokens for transfer in seedLpPharoahV3Floor()
        require(pharoahV3LpFloorCreated, "Pharoah V3 LP floor AVAX must be seeded first");
        (int24 tickLower, int24 tickUpper) = calculateV3Ticks();
        
        try pharoahV3.mint(//Seed Pharoah V3 LP
            broAddress, //Token0
            WAVAX_ADDRESS, //Token1
            V3FEE, //Fee uint24
            tickLower, //Lower tick int24
            tickUpper + V3_TICK_SPACING, //Upper tick int24, with tick spacing for range padding in case lower and upper are the same
            BroForPharoahWeiV3, //Amount0 desired
            0, //Amount1 desired
            1, //Amount0 min with infinite slippage
            0, //Amount1 min with infinite slippage
            address(this), //Keep this contract as recipient to collect V3 fees while keeping LP locked forever in this contract
            block.timestamp) //Deadline
        {}
        catch {
            revert("seedLpPharoahV3Range() failed");
        }
        
        pharoahV3LpCreated = true;
        emit LPSeeded(msg.sender);
    }

    
    function seedLpPangolinV2() public nonReentrant calculated { //8. This function must be called once, after the presale ends
        require(!pangolinV2LpCreated, "Pangolin V2 LP has already been seeded");
                // Approve BRO tokens for transfer
        broToken.approve(PANGOLIN_V2_ROUTER_ADDRESS, BroForPangolinWeiV2);

        try
        pangolinV2Router.addLiquidityETH{value: avaxForPangolinWeiV2}( //Seed Pangolin V2 LP
            broAddress, 
            BroForPangolinWeiV2,
            0, //Infinite slippage basically since it's in wei
            0, //Infinite slippage basically since it's in wei
            DEAD_ADDRESS, //Burn V2 LP tokens
            block.timestamp)
        {}
        catch {
            revert(string("seedLpPangolinV2() failed"));
        }

        pangolinV2LpCreated = true;
        emit LPSeeded(msg.sender);
    }


    function finalizeLP() public { //9. This function must be called once, after the auto LP creation functions have been called
        require(!lpCreated, "All automated LP has already been created");
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


    function withdrawTeamBro(uint256 teamBroWei_) public nonReentrant { //10a. This function can be called after auto LP is seeded
        require(TEAM_BRO_SUPPLY_WEI > 0, "Team has 0 BRO tokens allocated");
        require(lpCreated, "All automated LP has not been seeded yet"); //Make sure all auto LP has been created first before doing manual LP creation
        require(teamTokensWithdrawn < TEAM_BRO_SUPPLY_WEI, "Team BRO tokens have already been withdrawn");
        require(teamTokensWithdrawn + teamBroWei_  <= TEAM_BRO_SUPPLY_WEI, "Team BRO tokens requested is greater than allocated amount");

        broInterface.transfer(TEAM_WALLET, teamBroWei_); //Send allocated BRO to team wallet
        teamTokensWithdrawn += teamBroWei_;
        emit TokenWithdraw(TEAM_WALLET, teamBroWei_, broAddress);
    }


    function withdrawTeamAvax(uint256 teamAvaxWei_) public nonReentrant { //10b. This function can be called after auto LP is seeded
        require(avaxForTeamWei > 0, "Team has 0 AVAX allocated");
        require(lpCreated, "All automated LP has not been seeded yet"); //Make sure all auto LP has been created first before doing manual LP creation
        require(teamAvaxWithdrawn < avaxForTeamWei, "Team AVAX coins have already been withdrawn");
        require(teamAvaxWithdrawn + teamAvaxWei_  <= avaxForTeamWei, "Team AVAX requested is greater than allocated amount");

        TEAM_WALLET.transfer(teamAvaxWei_); //Send team AVAX from contract to team wallet
        teamAvaxWithdrawn += teamAvaxWei_;
        emit AvaxWithdraw(TEAM_WALLET, teamAvaxWei_);
    }


    function numberOfPresalers() external view returns(uint256){
        return (presaleBuyers.length);
    }


    function airdropBuyers() external nonReentrant { //11. Call as many times as needed to airdrop presale buyers
        require(!airdropCompleted, "Airdrop has already been completed");
        require(block.timestamp >= AIRDROP_TIME, "It is not yet time to airdrop the presale buyer's tokens");
        _airdrop();
    }


//Should we also collect V2ii fees since maybe they are stuck out of price range and would be better allocated to LFJ V1 LP?
    function collectUniswapV3Fees(uint256 tokenID_) public afterAirdrop nonReentrant{ //Collect fees from a Uniswap V3 LP NFT locked in this contract
        require(uniswapV3LpCreated, "Uniswap V3 LP has not been seeded yet");
        (uint256 fees0_, uint256 fees1_) = uniswapV3.collect(
            tokenID_, 
            address(this),
            type(uint128).max
        );
        addLiquidityV2(UNISWAP_V2_ROUTER_ADDRESS); //Add fees to Uniswap V2 LP
        emit V3FeesCollected(fees0_, fees1_, msg.sender);
    }


    function collectPharoahV3Fees(uint256 tokenID_) public afterAirdrop nonReentrant{ //Collect fees from a Pharoah V3 LP NFT locked in this contract
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


    function _buyPresale(uint256 amount_, address buyer_) private {
        require(pairsInitialized, "Presale has not been fully initialized yet by devs");
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


    function _airdrop() private {
        uint256 limitCount_ = airdropIndex + 100; //Max amount of addresses to airdrop to per call is 100 addresses
        address buyer_;
        uint256 amount_;

        while (airdropIndex < presaleBuyers.length && airdropIndex < limitCount_) {
            buyer_ = presaleBuyers[airdropIndex];
            amount_ = (totalAvaxUserSent[buyer_] * PRESALERS_BRO_SUPPLY_WEI) / totalAvaxPresaleWei; //Calculate amount of Bro tokens to send to buyer as ratio of AVAX sent
            require(broInterface.transfer(buyer_, amount_), "_airdrop() failed");
            airdropIndex++;
        }

        if (airdropIndex == presaleBuyers.length) {
            airdropCompleted = true;
        }

        emit AirdropSent(msg.sender, airdropIndex);
    }


    /**
     * @notice Initializes LFJ V2.2 LP by setting up the first allocation of floor AVAX and BRO tokens
     */
    function lfjV2iiInitializeLP() private {
        // Initialize arrays for liquidity parameters (71 bins: bin 0 to bin 70)
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
            BroPer70Bins,       // Total BRO tokens for this batch
            totalAVAX,          // AVAX amount
            startingBinId_,     // Starting bin ID
            0,                  // idSlippage
            deltaIds,
            distributionX,
            distributionY
        );

        // Approve BRO tokens for transfer
        broToken.approve(LFJ_V2ii_LB_ROUTER_ADDRESS, BroForLFJWeiV2ii);

        // Add initial LFJ V2.2 liquidity including AVAX floor
        try 
            lfjLbRouterV2ii.addLiquidityNATIVE{value: avaxForLFJWeiV2ii}(params) //Seed LFJ V2.2 LP
        {} catch {
            revert("lfjV2iiInitializeLP() failed");
        }

        previousBin = 70; // Make note of the last relative bin seeded
    }



    /**
     * @notice Continues LFJ V2.2 LP using equal tokens per bin
     */
    function lfjV2iiContinueAddingLiquidity() internal {
        //We already approved BRO tokens for transfer in lfjV2iiInitializeLP()

        // Arrays for liquidity parameters (70 bins per batch)
        int256[70] memory deltaIds; // Relative bin IDs
        uint256[70] memory distributionX; // BRO allocations
        uint256[70] memory distributionY; // AVAX allocations

        for (uint256 i = 0; i < 70; i++) { //Loop through 70 more bins to seed BRO tokens in LFJ V2.2 LP
            deltaIds[i] = previousBin + i + 1; // Relative bin ID
            distributionX[i] = ratioOfTokensPerBin_; //Ratio of BRO tokens allocated to this bin
            distributionY[i] = 0; // No AVAX in these bins
        }

        // Build liquidity parameters for BRO tokens in bins
        ILBRouter.LiquidityParameters memory params = lfjV2iiBuildLiquidityParameters(
            BroPer70Bins, // Total BRO tokens this round
            0, // No AVAX in these bins
            startingBinId_, // Starting bin ID
            0, // idSlippage
            deltaIds,
            distributionX,
            distributionY
        );

        // Add more LFJ V2.2 liquidity 
        try
        lfjLbRouterV2ii.addLiquidityNATIVE(params) //Seed LFJ V2.2 LP
        {}
        catch {
            revert(string("lfjV2iiContinueAddingLiquidity() failed"));
        }

        previousBin += 70; // Make note of last relative bin seeded
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
            tokenX: IERC20(broAddress),
            tokenY: IERC20(WAVAX_ADDRESS),
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
            to: DEAD_ADDRESS, // Burn V2.2 LP tokens since the fees accrue as deeper LP automatically, unlike Uniswap V3
            refundTo: address(this),
            deadline: block.timestamp
        });
    }


    //Calculate ticks for Uniswap V3 LP creation, where we find teh floor avax price as low tick based on price and fit to 1% ticks, 
    //and high price is 1.01**NumBins for 1% fee
//apparently ticks jump by 200 if doing 1% fee?
    function calculateV3Ticks() internal view returns (int24 tickLower, int24 tickUpper) {
        tickLower = TickMath.getTickAtSqrtRatio(sqrtPriceQ96Floor); // Tick for floor price at launch
        tickUpper = TickMath.getTickAtSqrtRatio(sqrtPriceQ96Max);  // Tick for ceiling price of LP made at launch
        
        // Adjust ticks to align with tick spacing
        tickLower = (tickLower / V3_TICK_SPACING) * V3_TICK_SPACING;
        tickUpper = (tickUpper / V3_TICK_SPACING) * V3_TICK_SPACING;
    }
    //    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {


    function addLiquidityV2(address v2RouterAddress_) private { //Add fees collected from Uniswap V3 LP to Uniswap V2 LP
                // Approve all possible BRO tokens for transfer
        broToken.approve(v2RouterAddress_, type(uint256).max);
        //First we sell all BRO for AVAX, then sell half AVAX for BRO, to balance fees collected to current price
        uint256 tokenAmount_ = broInterface.balanceOf(address(this)); //Get BRO balance of contract
        swapBroToAvaxV2(tokenAmount_, v2RouterAddress_); //Swap all BRO to AVAX
        uint256 avaxAmount_ = address(this).balance; //Get AVAX balance of contract
        swapAvaxToBroV2(avaxAmount_, v2RouterAddress_); //Swap half of AVAX to BRO
        avaxAmount_ = address(this).balance;
        tokenAmount_ = broInterface.balanceOf(address(this));


        try  
        IUniswapV2Router02(v2RouterAddress_).addLiquidityETH{value: avaxAmount_}( //Amount of AVAX to send for LP on main dex
            broAddress,
            tokenAmount_,
            100, //Infinite slippage basically since it's in wei
            100, //Infinite slippage basically since it's in wei
            DEAD_ADDRESS,
            block.timestamp)
        {}
        catch {
            revert(string("addLiquidityV2() failed"));
        }
    }


    function swapAvaxToBroV2(uint256 amount_, address v2routerAddress_) private { //Swap AVAX for BRO tokens
        address[] memory path_ = new address[](2);
        path_[0] = WAVAX;
        path_[1] = broAddress;

        try
        IUniswapV2Router02(v2routerAddress_).swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount_}(
            100, //Accept any amount of BRO
            path_,
            address(this),
            block.timestamp)
        {}
        catch {
            revert(string("swapAvaxToBroV2() failed"));
        }
    }


    function swapBroToAvaxV2(uint256 amount_, address v2routerAddress_) private { //Swap BRO for AVAX tokens
        // *We already approved all possible BRO tokens for transfer before calling this function
        address[] memory path_ = new address[](2);
        path_[0] = broAddress;
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
            revert(string("swapBroToAvaxV2() failed"));
        }
    }


    /**
     * @notice Calculates the sqrt floor and max price for Uniswap V3 LP from reserves AVAX/BRO
     * @param reserve0BroWei_ The amount of BRO token in reserve, in wei
     * @param reserve1AvaxWei_ The amount of AVAX in reserve, in wei
     * @return sqrtPriceX96Floor The Q64.96 square root floor price for the pair
     * @return sqrtPriceX96Max The Q64.96 square root max price for the pair
     */
    function getSqrtPricesX96(uint256 reserve0BroWei_, uint256 reserve1AvaxWei_) internal pure 
    returns (uint160 sqrtPriceX96Floor, uint160 sqrtPriceX96Max) { 
        require(reserve0BroWei_ > 0 && reserve1AvaxWei_ > 0, "Reserves must be greater than zero");

        // Calculate ratio with token allocation constraints
        uint256 ratio = FullMath.mulDiv(reserve1AvaxWei_, 1e18, reserve0BroWei_); // Calculate ratio of AVAX/BRO in wei, * 1e18 for precision
        uint256 ratioMax = (ratio * V3_SCALE); // Scale ratio to max LP price range

        // Compute the square root of the ratio
        uint256 sqrtRatio = Babylonian.sqrt(ratio); // Calculate square root of ratio using Uniswap Babylonian library
        uint256 sqrtRatioMax = Babylonian.sqrt(ratioMax);

        // Convert to Q64.96 by scaling with 2^96
        uint256 sqrtPriceX96Full = FullMath.mulDiv(sqrtRatio, 2**96, 1e18); // Multiply by 2^96 for Q96, divide by 1e18 convert Wei to Eth values
        uint256 sqrtPriceX96FullMax = FullMath.mulDiv(sqrtRatioMax, 2**96, 1e18);

        sqrtPriceX96Floor = uint160(sqrtPriceX96Full); //Implicitly return sqrtPriceX96 as uint160
        sqrtPriceX96Max = uint160(sqrtPriceX96FullMax); //Implicitly return sqrtPriceX96Max as uint160
        
        // Result always fits within uint160, largest price could be is about a billion avax divided by 1 wei bro which would be 1e27,
        // then sqrt of that is ~3e13, then * 2^96 is less than 3e42, which is within uint160 since 2**160 is over 1e48
        // Result always has enough precision as well because we capped tokens allocated to 1 Trillion in Wei value so smallest price is 1e-12 
        // leaving 6 decimal places of precision since there's 18 decimal places of precision in the input as Wei, and a 6 digit precision will
        // be close enough to fit within 0.01% tick ranges to calculate ticks from the sqrtPriceQ96 derived here.
    }



    //Fallback functions:

    
    //The user's wallet will add extra gas when transferring Avax to the fallback functions, so we are not restricted to only sending an event here.
    fallback() external payable {  //This function is used to receive AVAX from users for the presale
        _buyPresale(msg.value, msg.sender); 
    }


    receive() external payable { //This function is used to receive AVAX from users for the presale
        _buyPresale(msg.value, msg.sender); 
    }



    //Owner functions:

    //Call this function before initializing LP pair contracts before opening presale up to to buyers
    function initializeBro(address broAddress_) public onlyOwner { //This function must be called to set Bro details after the contract is funded with BRO tokens;
        require(!broInitialized, "Bro has already been initialized");
        require(broAddress_ != address(0), "Cannot set the 0 address as the Bro Address");
        broAddress = broAddress_; 
        broInterface = IBroToken(broAddress);
        require(broInterface.totalSupply() >= TOTAL_BRO_RECEIVE_WEI, "Total supply of BRO tokens should be allocated for contract"); //totalSupply of BRO should be in contract (unless fees or something taken first)
        require(broInterface.balanceOf(address(this)) >= TOTAL_BRO_RECEIVE_WEI, "BRO tokens must be sent into the presale contract before initializing the presale");
        broInitialized = true;
        emit BroInterfaceSet(msg.sender);
    }


    function initPairLFJV1() public onlyOwner broInit { //Create LFJ V1 LP pair contract with no tokens yet as precaution before presale starts
        require(V1_LFJ_DEX_PERCENT > 0, "No allocation for LFJ V1"); //Check allocation needed
        require(lfjV1PairAddress != address(0), "LFJ V1 LP Pair contract has already been created");
        try lfjV1PairAddress = IUniswapV2Factory(lfjV1Router.factory()).createPair(broAddress, WAVAX_ADDRESS)
        {} 
        catch {
            revert(string("initPairLFJV1() failed"));
        }
        emit LPSeeded(msg.sender);
    }


    function initPairLFJV2ii() public onlyOwner broInit { //Create LFJ V2.2 LP pair contract with no tokens yet
        require(V2ii_LFJ_DEX_PERCENT > 0, "No allocation for LFJ V2.2"); //Check allocation needed
        require(lfjV2iiPairAddress != address(0), "LFJ V2.2 LP Pair contract has already been created");
        try lfjV2iiPairAddress = lfjLbRouterV2ii.createLBPair(broAddress, WAVAX_ADDRESS, 8387914, 100) //1% bin step
        //Create LFJ V2.2 LP pair contract with no tokens yet, using random bin ID since we don't know the price yet
        {} 
        catch {
            revert(string("initPairLFJV2ii() failed"));
        }
        emit LPSeeded(msg.sender);
    }


    function initPairUniswapV2() public onlyOwner broInit { //Create Uniswap V2 LP pair contract with no tokens yet
        require(V2_UNISWAP_DEX_PERCENT > 0, "No allocation for Uniswap V2"); //Check allocation needed
        require(uniswapV2PairAddress != address(0), "Uniswap V2 LP Pair contract has already been created");
        try uniswapV2PairAddress = IUniswapV2Factory(uniswapV2Router.factory()).createPair(broAddress, WAVAX_ADDRESS)
        {} 
        catch {
            revert(string("initPairUniswapV2() failed"));
        }
        emit LPSeeded(msg.sender);
    }


    function initPairUniswapV3() public onlyOwner broInit { //Create Uniswap V3 LP pair contract with no tokens yet
        require(V3_UNISWAP_DEX_PERCENT > 0, "No allocation for Uniswap V3"); //Check allocation needed
        require(uniswapV3PairAddress != address(0), "Uniswap V3 LP Pair contract has already been created");
        try uniswapV3PairAddress = uniswapV3.createAndInitializePoolIfNecessary(
            broAddress,
            WAVAX_ADDRESS,
            V3FEE, //1% fee as a uint24
            (2**96) //sqrtPriceX96 (uint160) random value to start it for now
            //The initial square root price of the pool as a Q64.96 value 1 as a Q64.96 value is 1 * 2^96
            //The price must be between TickMath.MIN_SQRT_RATIO and TickMath.MAX_SQRT_RATIO
        )
        //Create Uniswap V3 LP pair contract with no tokens yet, using random price since we don't know price yet
        {} 
        catch {
            revert(string("initPairUniswapV3() failed"));
        }
        emit LPSeeded(msg.sender);
    }


    function initPairPharoahV2() public onlyOwner broInit { //Create Pharoah V2 LP pair contract with no tokens yet
        require(V2_PHAROAH_DEX_PERCENT > 0, "No allocation for Pharoah V2"); //Check allocation needed
        require(pharoahV2PairAddress != address(0), "Pharoah V2 LP Pair contract has already been created");
        try pharoahV2PairAddress = IUniswapV2Factory(pharoahV2Router.factory()).createPair(broAddress, WAVAX_ADDRESS)
        {} 
        catch {
            revert(string("initPairPharoahV2() failed"));
        }
        emit LPSeeded(msg.sender);
    }


    function initPairPharoahV3() public onlyOwner broInit { //Create Pharoah V3 LP pair contract with no tokens yet
        require(V3_PHAROAH_DEX_PERCENT > 0, "No allocation for Pharoah V3"); //Check allocation needed
        require(pharoahV3PairAddress != address(0), "Pharoah V3 LP Pair contract has already been created");
        try pharoahV3PairAddress = pharoahV3.createAndInitializePoolIfNecessary(
            broAddress,
            WAVAX_ADDRESS,
            V3FEE, //1% fee as a uint24
            (2**96) //sqrtPriceX96 (uint160) random value to start it for now
            //The initial square root price of the pool as a Q64.96 value 1 as a Q64.96 value is 1* 2^96
            //The price must be between TickMath.MIN_SQRT_RATIO and TickMath.MAX_SQRT_RATIO
        )
        //Create Pharoah V3 LP pair contract with no tokens yet, using random price since we don't know price yet
        {} 
        catch {
            revert(string("initPairPharoahV3() failed"));
        }
        emit LPSeeded(msg.sender);
    }


    function initPairPangolinV2() public onlyOwner broInit { //Create Pangolin V2 LP pair contract with no tokens yet
        require(V2_PANGOLIN_DEX_PERCENT > 0, "No allocation for Pangolin V2"); //Check allocation needed
        require(pangolinV2PairAddress != address(0), "Pangolin V2 LP Pair contract has already been created");
        try pangolinV2PairAddress = IUniswapV2Factory(pangolinV2Router.factory()).createPair(broAddress, WAVAX_ADDRESS)
        {} 
        catch {
            revert(string("initPairPangolinV2() failed"));
        }
        emit LPSeeded(msg.sender);
    }


    //Checks we can create all pair contracts as needed, as a precaution before presale starts
    //Call this after initializeBro() and all initPair functions have been called to allow presale buys
    function initializePairs() public onlyOwner {
        if (V1_LFJ_DEX_PERCENT > 0) { //Checks LFJ V1 LP pair contract exists already
            require(lfjV1PairAddress != address(0), "LFJ V1 LP Pair contract must first be created");
        }
        if (V2ii_LFJ_DEX_PERCENT > 0) { //Checks LFJ V2.2 LP pair contract exists already
            require(lfjV2iiPairAddress != address(0), "LFJ V2.2 LP Pair contract must first be created");
        }
        if (V2_UNISWAP_DEX_PERCENT > 0) { //Checks Uniswap V2 LP pair contract exists already
            require(uniswapV2PairAddress != address(0), "Uniswap V2 LP Pair contract must first be created");
        }
        if (V3_UNISWAP_DEX_PERCENT > 0) { //Checks Uniswap V3 LP pair contract exists already
            require(uniswapV3PairAddress != address(0), "Uniswap V3 LP Pair contract must first be created");
        }
        if (V2_PHAROAH_DEX_PERCENT > 0) { //Checks Pharoah V2 LP pair contract exists already
            require(pharoahV2PairAddress != address(0), "Pharoah V2 LP Pair contract must first be created");
        }
        if (V3_PHAROAH_DEX_PERCENT > 0) { //Checks Pharoah V3 LP pair contract exists already
            require(pharoahV3PairAddress != address(0), "Pharoah V3 LP Pair contract must first be created");
        }
        if (V2_PANGOLIN_DEX_PERCENT > 0) { //Checks Pangolin V2 LP pair contract exists already
            require(pangolinV2PairAddress != address(0), "Pangolin V2 LP Pair contract must first be created");
        }
        pairsInitialized = true; //If all pairs needed exist, then we can allow presale buys
        emit LPSeeded(msg.sender);
    }

    


    //Emergency withdraw functions:
    

    function withdrawAvaxTo(address payable to_, uint256 amount_) external onlyOwner afterAirdrop{
        require(to_ != address(0), "Cannot withdraw to 0 address");
        to_.transfer(amount_); //Can only send Avax from our contract, any user's wallet is safe
        emit AvaxWithdraw(to_, amount_);
    }

    function iERC20TransferFrom(address contract_, address to_, uint256 amount_) external onlyOwner afterAirdrop{
        (bool success) = IERC20Token(contract_).transferFrom(address(this), to_, amount_); //Can only transfer from our own contract
        require(success, 'iERC20TransferFrom() failed');
        emit TokenWithdraw(to_, amount_, contract_);
    }

    function iERC20Transfer(address contract_, address to_, uint256 amount_) external onlyOwner afterAirdrop{
        (bool success) = IERC20Token(contract_).transfer(to_, amount_); 
        //Since interfaced contract looks at msg.sender then this can only send from our own contract
        require(success, 'iERC20Transfer() failed');
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

