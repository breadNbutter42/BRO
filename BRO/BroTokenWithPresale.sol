// This includes presale logic for the $BRO token launch on LFG.gg on Avalanche.
// Users can transfer AVAX directly to this contract address during the presale time window.
// There is a minimum presale buy in amount of 1 AVAX per transfer.
// LP to be trustlessly created after the presale ends, using half of the $BRO supply and all of the presale AVAX.
// Presale buyers' $BRO tokens to be trustlessly "airdropped" out after presale ends, aka sent directly to them.
// Note: There are no whale limits or allowlists for the presale, to allow for open and dynamic presale AVAX collection size.

// LP is burned since fees are automatically converted to more LP

// Base token contract imports created with https://wizard.openzeppelin.com/ using their ERC20 with Permit.


interface IUniswapV2Factory { 

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);


    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

}



interface ITJUniswapV2Router01 {  //TraderJoe version of Uniswap code which has AVAX instead of ETH in the function names

    function factory() external pure returns (address);

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


    /$$    /$$$$$$$  /$$$$$$$   /$$$$$$ 
  /$$$$$$ | $$__  $$| $$__  $$ /$$__  $$
 /$$__  $$| $$  \ $$| $$  \ $$| $$  \ $$  
| $$  \__/| $$$$$$$ | $$$$$$$/| $$  | $$  
|  $$$$$$ | $$__  $$| $$__  $$| $$  | $$   
 \____  $$| $$  \ $$| $$  \ $$| $$  | $$     
 /$$  \ $$| $$$$$$$/| $$  | $$|  $$$$$$/
|  $$$$$$/|_______/ |__/  |__/ \______/  
 \_  $$_/                                                                                                           
   \__/                                                                                                             

*/

// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract BroTokenWithPresale is ERC20, ERC20Permit, ReentrancyGuard {

    uint256 public constant SECONDS_FOR_WL = 5 minutes; //Seconds per each phase, for example 5 minutes is 300 seconds
    uint256 public constant TOTAL_SUPPLY_WEI = 100000000000000000000000000; //BRO supply in wei
    uint256 public constant PRESALERS_BRO_SUPPLY_WEI = (TOTAL_SUPPLY_WEI * 50) / 100; // 50% of BRO supply is for the presale buyers
    uint256 public constant LP_BRO_SUPPLY_WEI = TOTAL_SUPPLY_WEI - PRESALERS_BRO_SUPPLY_WEI; //Remaining BRO is for automated LP
    uint256 public constant IDO_START_TIME = 1738666068; //Whitelist phase start time in unix timestamp
    uint256 public constant PRESALE_END_TIME = IDO_START_TIME - 120 minutes; //LP seeding start time in unix timestamp, must be before IDO_START_TIME
    uint256 public constant AIRDROP_TIME = IDO_START_TIME - 119 minutes; //Date presale tokens dispersal starts, leave a buffer since miners can vary timestamp slightly
    uint256 public constant MINIMUM_BUY_WEI = 1000000000000000000; //1 AVAX in wei minimum buy, to prevent micro buy spam attack hurting the airdrop phase
    uint256 public constant TOTAL_PHASES = 4; 
    //Total phases for IDO, phase 0 is the presale, phase 1 is LP seeding, phase 2 is presale token dispersal, phase 3 is the whitelist IDO launch, phase 4 is public trading

    address public constant FEE_WALLET = 0x7e2bb91e5785545A74d4797120702526A06b6355; //Multisig Gnosis wallet to receive fees from any emergency withdrawals
    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD; //Burn LP by sending it to this address 
    address public constant WAVAX_ADDRESS = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7; 
    //WAVAX Mainnet: 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7 ; Fuji: 0xd00ae08403B9bbb9124bB305C09058E32C39A48c
    address public constant ROUTER_ADDRESS = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4; //Main BRO/AVAX LP dex router
    //TraderJoe router = C-Chain Mainnet: 0x60aE616a2155Ee3d9A68541Ba4544862310933d4 ; Fuji Testnet: 0xd7f655E3376cE2D7A2b08fF01Eb3B1023191A901


    ITJUniswapV2Router01 public lfjV1Router; //DEX router interface for swapping BRO and making LP on lfj.gg TraderJoe V1 router

    address[] public presaleBuyers = new address[](0); //Array to store presale buyers addresses to send BRO tokens to later and for WL phase checks
    address public lfjV1PairAddress  = address(0); //Swap with this pair BRO/WAVAX

    bool public lpSeeded = false; //Block trading until LP is seeded
    bool public airdropCompleted = false; //Flag to indicate when airdrop is completed

    uint256 public airdropIndex = 0; //Count through the airdrop array when sending out tokens
    uint256 public totalAvaxPresaleWei = 0; //Count total AVAX received during presale

    mapping (address => bool) public previousBuyer; //Mapping to store if user is a new presale buyer
    mapping (address => uint256) public totalAvaxUserSent; //Mapping to store total AVAX sent by each presale buyer
    mapping (address => uint256) public totalPurchasedWithWhitelist; //Track total purchased by user during gated phases

    
    event AirdropSent(
        address indexed caller, 
        uint256 airdropIndex
    );

    event LPSeeded(
        address indexed caller
    );

    event BuyerAdded(
        address indexed buyer
    );

    event PresaleBought(
        uint256 amount, 
        address indexed buyer
    );

    event AvaxWithdraw(
        address indexed to, 
        uint256 amount
    );
   


    //Change name and symbol to Bro, BRO for actual deployment
    constructor()
    ERC20("Test", "TST")
    ERC20Permit("Test")
    { //This ERC20 constructor creates our BRO token name and symbol. 

        require(IDO_START_TIME > block.timestamp + 3 hours, "IDO start time must be at least 3 hours in the future");
        require(IDO_START_TIME < block.timestamp + 91 days, "IDO start time cannot be more than 91 days from now");
        require(PRESALE_END_TIME < IDO_START_TIME, "Presale end time must be before IDO start time");
        require(AIRDROP_TIME > PRESALE_END_TIME, "Airdrop time must be after presale end time");
        require(AIRDROP_TIME <= (PRESALE_END_TIME + 1 days), "Airdrop time must be within 1 day after presale end time");


        ITJUniswapV2Router01 lfjV1Router_;
        address lfjV1PairAddress_;
        
        lfjV1Router_ = ITJUniswapV2Router01(ROUTER_ADDRESS);

        //Initialize Uniswap V2 BRO/WAVAX LP pair, with 0 LP tokens in it to start with
        lfjV1PairAddress_ = IUniswapV2Factory(lfjV1Router_.factory()).createPair(address(this), WAVAX_ADDRESS);

        lfjV1Router = lfjV1Router_; //Uses the interface created above
        lfjV1PairAddress = lfjV1PairAddress_; //Uses the pair address created above

        super._update(address(0), address(this), TOTAL_SUPPLY_WEI); //Mint total supply to this contract, to later make LP and presale airdrop
    }



    //Public functions:

    function tradingActive() public view returns (bool) { //Check if IDO_START_TIME happened yet to open trading in general
        if (lpSeeded) {
            return block.timestamp >= IDO_START_TIME; //Return true if IDO has started
        } else {
            return false;
        }
    }


    function tradingRestricted() public view returns (bool) { //Check if we are in restricted whitelist phase
        return tradingActive() && block.timestamp <= (IDO_START_TIME + SECONDS_FOR_WL); //True if tradingActive and whitelisted phase is not yet over
    }


    function tradingPhase() public view returns (uint256) { //Check the phase
        uint256 timeNow_ = block.timestamp;

        if (!tradingActive()) {
            if (timeNow_ < PRESALE_END_TIME + 1 minutes) { //Add a one minute buffer in case of miner timestamp variance
                return 0; //0 == Presale
            } 
            else if (!lpSeeded) {
                return 1; //1 == LP seeding
            } 
            else {
                return 2; //2 == Presale airdrop token dispersal is allowed
            } 
        } 
        else if (tradingRestricted()) { //If trading is active and restricted then it's the whitelist phase
            return 3; //3 == Whitelist IDO launch
        } 
        else { //If trading is active and not restricted then it's the public phase
            return 4; //4 == Public trading
        }
    }


    function seedLP() public nonReentrant { //1. This function must be called once, after the presale ends
        require (block.timestamp >= PRESALE_END_TIME + 1 minutes, "Presale time plus buffer has not yet ended"); //Add a one minute buffer in case of miner timestamp variance
        require(!lpSeeded, "LFJ V1 LP has already been seeded");
        
        // Approve BRO tokens for transfer by the router
        _approve(address(this), ROUTER_ADDRESS, LP_BRO_SUPPLY_WEI); //Approve main router to use our DRAGON tokens and make LP


        try
        lfjV1Router.addLiquidityAVAX{value: totalAvaxPresaleWei}( //Seed LFJ V1 LP with all avax collected during presale
            address(this), 
            LP_BRO_SUPPLY_WEI, //Seed with remaining BRO supply not airdropped to presale buyers
            0, //Infinite slippage
            0, //Infinite slippage
            DEAD_ADDRESS,
            block.timestamp)
        {}
        catch {
            revert(string("seedLP() failed"));
        }

        lpSeeded = true;
        emit LPSeeded(msg.sender);
    }


    function airdropBuyers(uint256 maxTransfers_) external nonReentrant { //Airdrop function where users can set max transfers per tx
        require(lpSeeded, "LP must be seeded before airdrop can start");
        require(!airdropCompleted, "Airdrop has already been completed");
        require(block.timestamp >= AIRDROP_TIME, "It is not yet time to airdrop the presale buyer's tokens");
        _airdrop(maxTransfers_);
    }

    //*Note: NONREENTRANT is called in the internal _buyPresale
    function buyPresale() public payable { //Public function alternative to fallback function to buy presale tokens
        _buyPresale(msg.value, msg.sender); //Simple interface, no need to specify buyer address since it's the msg.sender
    }


    //This is so users can exit the presale before presale is over. We will still have them in the array of addresses to airdrop but we will reset their totalPurchasedWithWhitelist to 0
    //To prevent abuse of this function we will charge a 10% withdrawal fee of the avax deposited to the contract, so that during the airdrop we don't have to process a bunch of empty slots
    function emergencyWithdrawWithFee() external nonReentrant { 
        if (block.timestamp > PRESALE_END_TIME) { //If presale is over, make sure to give time to make LP, before allowing emergency withdrawal
            require(!lpSeeded, "LP has already been seeded with users funds; Cannot emergency withdraw AVAX after LP is seeded");
            require(block.timestamp >= PRESALE_END_TIME + 24 hours, "Cannot emergency withdraw AVAX after presale ends, until 24 hours afterwards, to give time to seed LP first"); 
        }
        uint256 amount_ = totalAvaxUserSent[msg.sender];
        require(amount_ > 0, "No AVAX to withdraw");
        totalAvaxUserSent[msg.sender] = 0; //Reset user's total AVAX sent to 0
        totalAvaxPresaleWei-= amount_; //Subtract the user's AVAX from the total AVAX sent during presale
        uint256 fee_ = (amount_ * 10) / 100; //10% fee on withdrawls to prevent spamming the contract with empty airdrop slots
        payable(FEE_WALLET).transfer(fee_); //Send the fee to the fee collector wallet
        payable(msg.sender).transfer(amount_ - fee_); //Send back the user's AVAX deposited minus the fee
        emit AvaxWithdraw(msg.sender, amount_ - fee_);
    }


    function presaleTokensPurchased(address buyer_) public view returns (uint256) { //Calculate amount of Bro tokens to send to buyer as ratio of AVAX sent
        require(block.timestamp > PRESALE_END_TIME, "Presale has not yet ended"); //Cannot calculate ratios until all AVAX is collected in presale
        return (totalAvaxUserSent[buyer_] * PRESALERS_BRO_SUPPLY_WEI) / totalAvaxPresaleWei;
    }



    //Internal functions:

    function _update( //Phases check
        address from_,
        address to_,
        uint256 amount_
    ) internal override(ERC20) {

        if (amount_ == 0) {
            super._update(from_, to_, 0);
            return;
        }

        uint256 tradingPhase_ = tradingPhase();

        if (tradingPhase_ == TOTAL_PHASES){ //Don't limit public phase 4
            super._update(from_, to_, amount_);
            return;
        }

        if (from_ == address(this) && tradingPhase_ > 0) { //Don't limit initial LP seeding, or the presale tokens dispersal, for phases 1 and 2
            super._update(from_, to_, amount_);
            return;
        }
        
        _beforeTokenTransfer(to_, amount_, tradingPhase_); //Check if user is allowed to receive tokens in whitelist phase 3
        super._update(from_, to_, amount_); //Send the token transfer requested by user
    }


    function _beforeTokenTransfer(
        address to_,
        uint256 amountTokensToTransfer_,
        uint256 tradingPhase_
    ) private {
        require(tradingPhase_ == 3, "Whitelist IDO phase is not yet active");
        if (to_ != lfjV1PairAddress) { //Don't limit selling or LP creation during IDO
            totalPurchasedWithWhitelist[to_] += amountTokensToTransfer_; //Track total amount of tokens user receives during the whitelist phase
            uint256 amountPresaleTokensPurchased_ = presaleTokensPurchased(to_);
            require(totalPurchasedWithWhitelist[to_] <= amountPresaleTokensPurchased_, "During whitelist phase, you cannot receive more tokens than purchased in the presale");
        }
    }


    function _buyPresale(uint256 amount_, address buyer_) private nonReentrant{
        require(block.timestamp < PRESALE_END_TIME, "Presale has already ended");
        require(amount_ >= MINIMUM_BUY_WEI, "Minimum buy of 1 AVAX per transaction; Not enough AVAX sent");
        
        if (!previousBuyer[buyer_]) { //Add buyer to the presaleBuyers array if they are a first time buyer
            previousBuyer[buyer_] = true;
            presaleBuyers.push(buyer_);
            emit BuyerAdded(buyer_);
        }

        totalAvaxUserSent[buyer_] += amount_;
        totalAvaxPresaleWei += amount_;
        emit PresaleBought(amount_, buyer_);
    }


    function _airdrop(uint256 maxTransfers_) private {
        uint256 limitCount_ = airdropIndex + maxTransfers_; //Max amount of addresses to airdrop
        address buyer_;
        uint256 amount_;
        uint256 localIndex_; 

        while (airdropIndex < presaleBuyers.length && airdropIndex < limitCount_) {
            localIndex_ = airdropIndex;
            airdropIndex++; // In case of any reentrancy type issues, we increment the global index before sending out tokens
            buyer_ = presaleBuyers[localIndex_];
            amount_ = (totalAvaxUserSent[buyer_] * PRESALERS_BRO_SUPPLY_WEI) / totalAvaxPresaleWei; //Calculate amount_ here, instead of with the time checked presaleTokensPurchased(), to save gas
            if (amount_ > 0) { //If someone exited the presale early, then they will have 0 tokens to receive in airdrop
                _transfer(address(this), buyer_, amount_); //Send tokens from the contract itself to the presale buyers
            }
        }

        if (airdropIndex == presaleBuyers.length) {
            airdropCompleted = true;
        }

        emit AirdropSent(msg.sender, airdropIndex);
    }
    


    //Fallback functions:
    //The user's wallet will add extra gas when transferring AVAX to the fallback functions, so we are not restricted to only sending an event here.

    receive() external payable { //This function is used to receive AVAX from users for the presale
        _buyPresale(msg.value, msg.sender); 
    }


}



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



/*
   Launch instructions:
1. Set the constant values at the start of the contract and the token name and symbol.
2. Deploy contract with solidity version: 0.8.28 and runs optimized: 200.
3. Verify contract and set socials on block explorer and Dexscreener.
4. Bug bounty could be good to set up on https://www.sherlock.xyz/ or https://code4rena.com/ or similar.
5. After presale ends, call seedLP() in presale contract to create LP.
6. After LP is seeded call airdropBuyers() repeatedly in the presale contract to send out all the airdrop tokens to presale buyers.
*/
