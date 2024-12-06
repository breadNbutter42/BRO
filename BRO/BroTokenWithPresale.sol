//Make sure theres no bug where someone can send just AVAX to an empty LP pair and mess up the LP seeding later by making token infinitely expensive

/* $BRO Links:
Medium: https://medium.com/@BROFireAvax
Twitter: @BROFireAvax
Discord: https://discord.gg/uczFJdMaf4
Telegram: BROFireAvax
Website: www.BROFireAvax.com
Email: contact@BROFireAvax.com
*/

// This includes presale logic for the $BRO token launch on LFG.gg on Avalanche.
// Users can transfer AVAX directly to this contract address during the presale time window.
// There is a minimum presale buy in amount of 1 AVAX per transfer.
// LP to be trustlessly created after the presale ends, using half of the $BRO supply and all of the presale AVAX.
// Presale buyers' $BRO tokens to be trustlessly "airdropped" out after presale ends, aka sent directly to them.
// Note: There are no whale limits or allowlists for the presale, to allow for open and dynamic presale AVAX collection size.

// LP is burned since fees are automatically converted to more LP

//Base contract imports created with https://wizard.openzeppelin.com/ using their ERC20 with Permit and Ownable.


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



interface IERC20Token { //Generic ability to transfer out funds accidentally sent into the contract
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}



interface IERC721Token { //Generic ability to transfer out NFTs accidentally sent into the contract
    function transferFrom(address from, address to, uint256 tokenId) external; 
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransfer(address from, address to, uint256 tokenId) external;
    function transfer(address from, address to, uint256 tokenId) external;
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
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract BroTokenWithPresale is ERC20, ERC20Permit, Ownable, ReentrancyGuard {

    uint256 public constant SECONDS_FOR_WL = 5 minutes; //Seconds per each phase, for example 5 minutes is 300 seconds
    uint256 public constant TOTAL_SUPPLY_WEI = 88888888000000000000000000; //88,888,888 BRO in wei
    uint256 public constant PRESALERS_BRO_SUPPLY_WEI = (TOTAL_SUPPLY_WEI * 50) / 100; // 50% of BRO supply is for the presale buyers
    uint256 public constant LP_BRO_SUPPLY_WEI = TOTAL_SUPPLY_WEI - PRESALERS_BRO_SUPPLY_WEI; //Remaining BRO is for automated LP
    uint256 public constant IDO_Start_Time = 1738666068; //Whitelist phase start time in unix timestamp
    uint256 public constant PRESALE_END_TIME = IDO_Start_Time - 120 minutes; //LP seeding start time in unix timestamp, must be before IDO_Start_Time
    uint256 public constant AIRDROP_TIME = IDO_Start_Time - 120 minutes; //Date presale tokens dispersal starts, can set to before or after IDO_Start_Time
    uint256 public constant MINIMUM_BUY_WEI = 1000000000000000000; //1 AVAX in wei minimum buy, to prevent micro buy spam attack hurting the airdrop phase
    uint256 public constant TOTAL_PHASES = 4; 
    //Total phases for IDO, phase 0 is the presale, phase 1 is LP seeding, phase 2 is presale token dispersal, phase 3 is the whitelist IDO launch, phase 4 is public trading

    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD; //Burn LP by sending it to this address 
    address public constant WAVAX_ADDRESS = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7; 
    //WAVAX Mainnet: 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7 ; Fuji: 0xd00ae08403B9bbb9124bB305C09058E32C39A48c
    address public constant Router_Address = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4; //Main BRO/AVAX LP dex router
    //TraderJoe router = C-Chain Mainnet: 0x60aE616a2155Ee3d9A68541Ba4544862310933d4 ; Fuji Testnet: 0xd7f655E3376cE2D7A2b08fF01Eb3B1023191A901


    ITJUniswapV2Router01 public lfjV1Router; //DEX router interface for swapping BRO and making all LP pairs on our own new dex

    address[] public presaleBuyers = new address[](0); //Array to store presale buyers addresses to send BRO tokens to later and for WL phase checks
    address public lfjV1PairAddress  = address(0); //Swap with this pair BRO/WAVAX

    bool public lpSeeded = false; //Block trading until LP is seeded
    bool public airdropCompleted = false; //Flag to indicate when airdrop is completed

    uint256 public airdropIndex = 0; //Count through the airdrop array when sending out tokens
    uint256 public totalAvaxPresaleWei = 0; //Count total AVAX received during presale

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

    event TokenWithdraw(
        address indexed to, 
        uint256 amount,
        address indexed token
    );

    event TokenApproved(
        address indexed spender, 
        uint256 amount,
        address indexed token
    );

    event NFTWithdraw(
        address indexed to, 
        uint256 ID,
        address indexed token
    );

    
    modifier afterAirdrop() {
        require(block.timestamp >= AIRDROP_TIME + 24 hours, "Cannot emergency withdraw tokens until 24 hours after airdrop starts"); 
        //Wait to give time for presale token dispersal to complete first
        _;
    }


    //Change name and symbol to Bro, BRO for actual deployment
    constructor()
    ERC20("Test", "TST")
    ERC20Permit("Test")
    Ownable(msg.sender)
    { //This ERC20 constructor creates our BRO token name and symbol. 

        require(IDO_Start_Time > block.timestamp + 3 hours, "IDO start time must be at least 3 hours in the future");
        require(IDO_Start_Time < block.timestamp + 91 days, "IDO start time cannot be more than 91 days from now");
        require(PRESALE_END_TIME < IDO_Start_Time, "Presale end time must be before IDO start time");
        require(AIRDROP_TIME > PRESALE_END_TIME, "Airdrop time must be after presale end time");
        require(AIRDROP_TIME <= (PRESALE_END_TIME + 1 days), "Airdrop time must be within 1 day after presale end time");


        ITJUniswapV2Router01 lfjV1Router_;
        address lfjV1PairAddress_;
        
        lfjV1Router_ = ITJUniswapV2Router01(Router_Address);
          //Initialize Uniswap V2 BRO/WAVAX LP pair, with 0 LP tokens in it to start with
        try lfjV1PairAddress_ = IUniswapV2Factory(lfjV1Router_.factory()).createPair(address(this), WAVAX_ADDRESS);
        {} 
        catch {
            revert(string("initPairLFJV1() failed"));
        }

        lfjV1Router = lfjV1Router_; //Uses the interface created above
        lfjV1PairAddress = lfjV1PairAddress_; //Uses the pair address created above

        super._update(address(0), address(this), TOTAL_SUPPLY_WEI); //Mint total supply to this contract to make LP and presale
        emit SettingsChanged(msg.sender, "constructor");
    }





    //Public functions:

    function tradingActive() public view returns (bool) { //Check if IDO_Start_Time happened yet to open trading in general
        if (lpSeeded) {
            return block.timestamp >= IDO_Start_Time; //Return true if IDO has started
        } else {
            return false;
        }
    }


    function tradingRestricted() public view returns (bool) { //Check if we are in restricted whitelist phase
        return tradingActive() && block.timestamp <= (IDO_Start_Time + SECONDS_FOR_WL); //True if tradingActive and whitelisted phase is not yet over
    }


    function tradingPhase() public view returns (uint256 phase) { //Check the phase
        uint256 timeNow_ = block.timestamp;

        if (!tradingActive) {
            if (timeNow_ < PRESALE_END_TIME) {
                return 0; //0 == Presale
            } 
            else if (timeNow_ < IDO_Start_Time) {
                if (!lpSeeded) {
                    return 1; //1 == LP seeding
                } 
                else {
                    return 2; //2 == Presale token dispersal
                } 
            }
        } 
        else if (tradingRestricted) { //If trading is active and restricted then it's the whitelist phase
            return 3; //3 == Whitelist IDO launch
        } 
        else { //If trading is active and not restricted then it's the public phase
            return 4; //4 == Public trading
        }

        return phase_;
    }


    function buyPresale() public payable { //Public function alternative to fallback function to buy presale tokens
        _buyPresale(msg.value, msg.sender); //Simple interface, no need to specify buyer address since it's the msg.sender
    }


    function buyPresale(address buyer_) public payable { //Public function alternative to fallback function to buy presale tokens
        _buyPresale(msg.value, buyer_); //Can specify buyer address in case it's useful, such as a middleman rewards contract
    }


    function seedLpV1LFJ() public nonReentrant { //1. This function must be called once, after the presale ends
        require(!lpSeeded, "LFJ V1 LP has already been seeded");
        
        // Approve BRO tokens for transfer by the router
        approve(Router_Address, BroForLFJWeiV1);

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
            revert(string("seedLpV1LFJ() failed"));
        }

        lpSeeded = true;
        emit LPSeeded(msg.sender);
    }


    function airdropBuyers() external nonReentrant { //2. Call as many times as needed to airdrop all presale buyers
        require(lpSeeded, "LP must be seeded before airdrop can start");
        require(!airdropCompleted, "Airdrop has already been completed");
        require(block.timestamp >= AIRDROP_TIME, "It is not yet time to airdrop the presale buyer's tokens");
        _airdrop();
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
        
        beforeTokenTransfer(to_, amount_, tradingPhase_); //Check if user is allowed to receive tokens in whitelist phase 3
        super._update(from_, to_, amount_); //Send the token transfer requested by user
    }


    function beforeTokenTransfer(
        address to_,
        uint256 amountTokensToTransfer_,
        uint256 tradingPhase_
    ) private {
        if (to_ != lfjV1PairAddress) { //Don't limit selling or LP creation during IDO
            require(tradingPhase_ == 3, "Whitelist IDO phase is not yet active");
            totalPurchasedWithWhitelist[to_] += amountTokensToTransfer_; //Track total amount of tokens user receives during the whitelist phase
            amountPresaleTokensPurchased_ = presaleTokensPurchased(to_);
            require(totalPurchasedWithWhitelist[to_] <= amountPresaleTokensPurchased_, "During whitelist phase, you cannot receive more tokens than purchased in the presale");
        }
    }


    function presaleTokensPurchased(address buyer_) public view returns (uint256) { //Calculate amount of Bro tokens to send to buyer as ratio of AVAX sent
        return (totalAvaxUserSent[buyer_] * PRESALERS_BRO_SUPPLY_WEI) / totalAvaxPresaleWei;
    }


    function _buyPresale(uint256 amount_, address buyer_) private {
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
            amount_ = presaleTokensPurchased(buyer_);
            require(transfer(buyer_, amount_), "_airdrop() failed");
            airdropIndex++;
        }

        if (airdropIndex == presaleBuyers.length) {
            airdropCompleted = true;
        }

        emit AirdropSent(msg.sender, airdropIndex);
    }


    //Fallback functions:
    //The user's wallet will add extra gas when transferring AVAX to the fallback functions, so we are not restricted to only sending an event here.

    fallback() external payable {  //This function is used to receive AVAX from users for the presale
        _buyPresale(msg.value, msg.sender); 
    }


    receive() external payable { //This function is used to receive AVAX from users for the presale
        _buyPresale(msg.value, msg.sender); 
    }



    //Owner emergency withdraw functions:

    function withdrawAvaxTo(address payable to_, uint256 amount_) external onlyOwner afterAirdrop {
        require(to_ != address(0), "Cannot withdraw to 0 address");
        to_.transfer(amount_); //Can only send Avax from our contract, any user's wallet is safe
        emit AvaxWithdraw(to_, amount_);
    }

    function iERC20TransferFrom(address contract_, address to_, uint256 amount_) external onlyOwner afterAirdrop {
        (bool success) = IERC20Token(contract_).transferFrom(address(this), to_, amount_); //Can only transfer from our own contract
        require(success, 'token transfer from sender failed');
        emit TokenWithdraw(to_, amount_, contract_);
    }

    function iERC20Transfer(address contract_, address to_, uint256 amount_) external onlyOwner afterAirdrop {
        (bool success) = IERC20Token(contract_).transfer(to_, amount_); 
        //Since interfaced contract looks at msg.sender then this can only send from our own contract
        require(success, 'token transfer from sender failed');
        emit TokenWithdraw(to_, amount_, contract_);
    }

    function iERC20Approve(address contract_, address spender_, uint256 amount_) external onlyOwner afterAirdrop {
        IERC20Token(contract_).approve(spender_, amount_); //Since interfaced contract looks at msg.sender then this can only send from our own contract
        emit TokenApproved(spender_, amount_, contract_);
    }

    function iERC721TransferFrom(address contract_, address to_, uint256 tokenId_) external onlyOwner afterAirdrop {
        IERC721Token(contract_).transferFrom(address(this), to_, tokenId_); //Can only transfer from our own contract
        emit NFTWithdraw(to_, tokenId_, contract_);
    }

    function iERC721SafeTransferFrom(address contract_, address to_, uint256 tokenId_) external onlyOwner afterAirdrop {
        IERC721Token(contract_).safeTransferFrom(address(this), to_, tokenId_); //Can only transfer from our own contract
        emit NFTWithdraw(to_, tokenId_, contract_);
    }

    function iERC721Transfer(address contract_, address to_, uint256 tokenId_) external onlyOwner afterAirdrop {
        IERC721Token(contract_).transfer( address(this), to_, tokenId_); //Can only transfer from our own contract
        emit NFTWithdraw(to_, tokenId_, contract_);
    }

    function iERC721SafeTransfer(address contract_, address to_, uint256 tokenId_) external onlyOwner afterAirdrop {
        IERC721Token(contract_).safeTransfer( address(this), to_, tokenId_); //Can only transfer from our own contract
        emit NFTWithdraw(to_, tokenId_, contract_);
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
2. Deploy contract with solidity version: 0.8.24, EVM version: Paris, and runs optimized: 200.
3. Verify contract and set socials on block explorer and dexscreener.
4. Bug bounty could be good to set up on https://www.sherlock.xyz/ or https://code4rena.com/ or similar.
5. After presale ends, call seedLP() in presale contract to create LP.
6. After LP is seeded call airdropBuyers() repeatedly in the presale contract to send out all the airdrop tokens to presale buyers.
7. Can renounce ownership after IDO is complete in case of emergency, or keep ownership for emergency withdraws or transfer to a DAO, but owner has no real powers to worry about.
*/
