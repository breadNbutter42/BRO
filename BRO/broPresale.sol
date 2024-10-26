// This is a presale contract for the $BRO token on Avalanche.
// Users can transfer AVAX directly to this contract address during the presale time window.
// There is a minimum presale buy in amount of 1 AVAX per transfer.
// LP to be trustlessly created after the presale ends, using half of the $BRO supply and all of the presale AVAX.
// Presale buyers' $BRO tokens to be trustlessly "airdropped" out after presale ends, aka sent directly to them, after the IDO launch.
// Note: There are no whale limits or allowlists for this presale.



interface IUniswapV2Router01 {
    
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

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BroPresale is Ownable, ReentrancyGuard {
    IUniswapV2Router02 public uniswapV2Router; //DEX router for LP creation
    IBroToken public broInterface;

    uint256 public constant Minimum_Buy_Wei = 1000000000000000000; //1 AVAX in wei
    uint256 public constant Presale_End_Time = 1791775312; //Date presale ends, a day before IDO launch so time to make LP and send out tokens
    uint256 public constant Airdrop_Time = 1811775312; //Date airdrop starts, immediately after IDO phased launch so can transfer tokens without whale limits
    uint256 public constant Total_Bro_Received = 88888888000000000000000000; //Total $BRO minted into the contract which in this case is 100% of total $BRO supply
    uint256 public constant LP_Bro_Supply_Wei = 44444444000000000000000000; //Total supply of $BRO is 88888888, split 50% for LP and 50% presale buyers
    uint256 public constant Presalers_Bro_Supply_Wei = 44444444000000000000000000; //Total supply of $BRO is 88888888, split 50% for LP and 50% presale buyers
    uint256 public constant Total_Ct_Tokens = 8; //Total number of Communty Tokens addresses, aka CT, to create LP for
    uint256 public constant Total_Ct_Lp_Percentage = 16;
    uint256 public constant Ct_Lp_Percentage = (Total_Ct_Lp_Percentage / Total_Ct_Tokens); //Percentage of AVAX to be used for each CT LP creation, 8 CT * 2% of AVAX received to be used per CT LP, 16% total.
    uint256 public constant Main_Lp_Bro_Wei = ((LP_Bro_Supply_Wei * Bro_Lp_Percentage) / 100); //Amount of $BRO to be used for LP creation, 44444444 * 84% = 37,333,332.96 tokens
    uint256 public constant Ct_Lp_Bro_Wei = ((LP_Bro_Supply_Wei - Main_Lp_Bro_Wei) / Total_Ct_Tokens); //Amount of $BRO to be used for each CT LP creation, 
    //44444444 half tokens - 37,333,332.96 main LP = 7,111,111.04 CT LP total / 8 CTs = 888,888.88 $BRO per CT LP aka 1% of total supply or 2% of half supply per LP

    address public constant WAVAX = 0xd00ae08403B9bbb9124bB305C09058E32C39A48c; 
        //WAVAX Mainnet: 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7 ; Fuji: 0xd00ae08403B9bbb9124bB305C09058E32C39A48c

    address[] public Community_Tokens = 
            //FUJI Testnet Chainlink: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846
/*        [0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846];  
*/
                        //Mainnet: 
            [0xab592d197ACc575D16C3346f4EB70C703F308D1E,
            0x420FcA0121DC28039145009570975747295f2329,
            0x184ff13B3EBCB25Be44e860163A5D8391Dd568c1,
            0xb5Cc2CE99B3f98a969DBe458b96a117680AE0fA1,
            0xc06E17bDC3F008F4Ce08D27d364416079289e729,
            0xc8E7fB72B53D08C4f95b93b390ed3f132d03f2D5,
            0x69260B9483F9871ca57f81A90D91E2F96c2Cd11d,
            0x96E1056a8814De39c8c3Cd0176042d6ceCD807d7];    
            //FEED//COQ//KIMBO//LUCKY//DWC//SQRCAT//GGP//OSAK//
    
    address[] public CT_Routers = 
        //Fuji Testnet TJ Router: 0xd7f655E3376cE2D7A2b08fF01Eb3B1023191A901
/*        [0x3b014c0307Ad9dc4262F1696BC463Fd3c6dC4679]; 
*/
                        //Mainnet: 
            [0x60aE616a2155Ee3d9A68541Ba4544862310933d4,
            0x60aE616a2155Ee3d9A68541Ba4544862310933d4,
            0x60aE616a2155Ee3d9A68541Ba4544862310933d4,
            0x60aE616a2155Ee3d9A68541Ba4544862310933d4,
            0x60aE616a2155Ee3d9A68541Ba4544862310933d4,
            0x60aE616a2155Ee3d9A68541Ba4544862310933d4,
            0x60aE616a2155Ee3d9A68541Ba4544862310933d4,
            0x60aE616a2155Ee3d9A68541Ba4544862310933d4];    //(TraderJoe has best liquidity for each CT LP currently)
    
    address[] public presaleBuyers = new address[](0); //Array to store presale buyers addresses to send tokens to later
    address public broAddress; //Address of the Bro token contract to be created in the future

    uint256 public ctLpIndex; //Amount of CT we have already created LP for
    uint256 public airdropIndex; //Count through the airdrop array when sending out tokens
    uint256 public totalAvaxPresale; //Total AVAX received during presale

    bool public lpCreated; //Flag to indicate when LP has been created
    bool public airdropCompleted; //Flag to indicate when airdrop is completed
    bool public broInitialized; //Flag to indicate when Bro token contract has been set
    bool public alreadySeeded; //Flag to indicate when LP has been seeded

    mapping (address => bool) public previousBuyer; //Mapping to check if presale buyer is already in the presaleBuyers array
    mapping (address => uint256) public totalSent; //Mapping to store total AVAX sent by each presale buyer


    event AvaxWithdraw(address indexed to, uint256 amount);
    event TokenWithdraw(address indexed to, uint256 amount, address indexed token);
    event TokenApproved(address indexed spender, uint256 amount, address indexed token);
    event NFTWithdraw(address indexed to, uint256 tokenId, address indexed token);
    event AirdropSent(address indexed caller, uint256 airdropIndex);
    event LPSeeded(address indexed caller);
    event BroInterfaceSet(address indexed caller);
    event BuyerAdded(address indexed buyer);

    modifier afterPresale() {
        require(block.timestamp >= Airdrop_Time + 1 days, "Cannot emergency withdraw tokens until 1 day after airdrop starts"); //Wait 1 day to give time for presale to complete first
        _;
    }



    constructor()
            Ownable(msg.sender)
    { //Constructor to check initial values and set owner
        uint256 totalBroAllocated = Main_Lp_Bro_Wei + (Ct_Lp_Bro_Wei * Total_Ct_Tokens); //Calculate total Bro allocated for LP creation
        require(totalBroAllocated == LP_Bro_Supply_Wei, "Total Bro allocated for LP must equal to half of the total supply");
        require(Presale_End_Time >= (block.timestamp + 1 hours), "Presale must end at least one hour in the future from now");
        require(Airdrop_Time >= (Presale_End_Time + 2 hours), "Airdrop time must be at least 2 hours after presale end time, to give time for LP creation and IDO phases to complete first");
        require(Community_Tokens.length == Total_Ct_Tokens, "communityTokens array length must be equal to Total_Ct_Tokens");
        require(CT_Routers.length == Total_Ct_Tokens, "CT_Routers array length must be equal to Total_Ct_Tokens");

    }



    //Public functions


    function seedLP() public nonReentrant { //This function must be called once, after the presale ends;
        require(!lpCreated, "LP has already been seeded");
        require(block.timestamp > Presale_End_Time, "Presale has not ended yet");
        uint256 lpAvax_ = ((totalAvaxPresale * Bro_Lp_Percentage) / 100); //Use 84% of total AVAX received for main BRO/AVAX LP creation
            seedAndBurnBroLP{value: lpAvax_}(Main_Lp_Bro_Wei, lpAvax_);
            lpCreated = true;
        } else {
            uint256 avaxAmount_ = ((totalAvaxPresale * Ct_Lp_Percentage) / 100); //Use 2% of total AVAX received per CT LP creation, for 8 tokens this will total 16%
            uint256 ctBalanceBefore = IERC20Token(Community_Tokens[ctLpIndex]).balanceOf(address(this));
            swapAvaxForCT(avaxAmount_, ctLpIndex);
            uint256 ctBalanceAfter = IERC20Token(Community_Tokens[ctLpIndex]).balanceOf(address(this));
            uint256 ctLpTokens_ = ctBalanceAfter - ctBalanceBefore; //Calculate CT tokens received in swap
            require(IERC20Token(Community_Tokens[ctLpIndex]).approve(broAddress, ctLpTokens_), "Approval failed");
            broInterface.seedAndBurnCtLP(ctLpIndex, Community_Tokens[ctLpIndex], Ct_Lp_Bro_Wei, ctLpTokens_);
            ctLpIndex++; //Increment counter so that a new CT token will be seeded LP the next time this function is called
        }
        emit LPSeeded(msg.sender);
    }


    function numberOfPresalers() external view returns(uint256){
        return (presaleBuyers.length);
    }


    function airdropBuyers() external nonReentrant {
        require(!airdropCompleted, "Airdrop has already been completed");
        require(block.timestamp >= Airdrop_Time, "It is not yet time to send out presale tokens");
        _airdrop();
    }



    //Internal functions


    function _airdrop() private {
        uint256 limitCount_ = airdropIndex + 100; //Max amount of addresses to airdrop to per call is 100 addresses
        address buyer_;
        uint256 amount_;

        while(airdropIndex < presaleBuyers.length && airdropIndex < limitCount_) {
            buyer_ = presaleBuyers[airdropIndex];
            amount_ = (totalSent[buyer_] * Presalers_Bro_Supply_Wei) / totalAvaxPresale; //Calculate amount of Bro tokens to send to buyer as ratio of AVAX sent
            require(broInterface.transfer(buyer_, amount_), "Transfer failed");
            airdropIndex++;
        }

        if (airdropIndex == presaleBuyers.length) {
            airdropCompleted = true;
        }

        emit AirdropSent(msg.sender, airdropIndex);
    }


    function swapAvaxForCT(uint256 avaxAmount_, uint256 index_) private {
        address[] memory path = new address[](2); //Our swap path WAVAX/CT
        path[0] = WAVAX; //WAVAX
        path[1] = Community_Tokens[index_]; //CT

        try  
        IUniswapV2Router02(CT_Routers[index_]).swapExactAVAXForTokensSupportingFeeOnTransferTokens //AVAX to CT, swap on dex router with most LP
        {value: avaxAmount_}(
            100, //Infinite slippage basically since it's in Wei
            path,
            address(this), //Send CT tokens received to this contract
            block.timestamp)
        {}
        catch {
            revert(string("swapAvaxForCT failed"));
        }
    }
    

    function buyPresale(uint256 amount_, address buyer_) private {
        require(block.timestamp < Presale_End_Time, "Presale has already ended");
        require(broAddress != address(0), "Bro token address has not yet been set");
        require(amount_ >= Minimum_Buy_Wei, "Minimum buy of 1 AVAX per transaction; Not enough AVAX sent");
        totalSent[buyer_]+= amount_;
        totalAvaxPresale+= amount_;

        if (!previousBuyer[buyer_]) { //Add buyer to the presaleBuyers array if they are not already in it
            previousBuyer[buyer_] = true;
            presaleBuyers.push(buyer_);
            emit BuyerAdded(buyer_);
        }
    }


    function seedAndBurnBroLP(uint256 amountBro_, uint256 amountAvax_) external payable {
        require(alreadySeeded != true, "LP has already been seeded"); //This function is just to seed LP for IDO launch
        require(msg.value == amountAvax_, "Different amount of Avax sent than indicated in call values"); //Verify intended amount sent
        require(amountBro_ >= 100000000000000000, "Must send at least 0.1 Bro tokens");
        require(amountAvax_ >= 100000000000000000, "Must send at least 0.1 AVAX");
        require(!swapping, "Already making Bro LP, you have created a reentrancy issue");
        swapping = true; //Reentrancy block
        transfer(address(this), amountBro_);
        _approve(address(this), address(uniswapV2Router), amountBro_); //Approve main router to use our BRO tokens and make LP
        addLiquidityBRO(amountBro_, amountAvax_);
        swapping = false;
        emit SwapAndLiquify(amountBro_, amountAvax_, WAVAX);
    }


        
    function addLiquidityBRO(uint256 tokenAmount_, uint256 avaxAmount_)  private { //Make and burn LP tokens BRO/WAVAX
        try  
        uniswapV2Router.addLiquidityAVAX{value: avaxAmount_}( //Amount of AVAX to send for LP on main dex
            address(this),
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



    //Fallback functions:

    
    //The user's wallet will add extra gas when transferring Avax to the fallback functions, so we are not restricted to only sending an event here.
    fallback() external payable {  //This function is used to receive AVAX from users for the presale
        buyPresale(msg.value, msg.sender); 
    }


    receive() external payable { //This function is used to receive AVAX from users for the presale
        buyPresale(msg.value, msg.sender); 
    }



    //Owner functions:


    function setBroInterface(address _broAddress) public onlyOwner { //Starts the presale by setting the Bro token contract address
        require(_broAddress != address(0), "Cannot set the 0 address as the Bro Address");
        require(broAddress == address(0), "$BRO address has already been set");
        broInterface = IBroToken(_broAddress);
        broAddress = _broAddress;
        broInitialized = true;
        emit BroInterfaceSet(msg.sender);
    }


    //Emergency withdraw functions:
    

    function withdrawAvaxTo(address payable to_, uint256 amount_) external onlyOwner afterPresale{
        require(to_ != address(0), "Cannot withdraw to 0 address");
        to_.transfer(amount_); //Can only send Avax from our contract, any user's wallet is safe
        emit AvaxWithdraw(to_, amount_);
    }

    function iERC20TransferFrom(address contract_, address to_, uint256 amount_) external onlyOwner afterPresale{
        (bool success) = IERC20Token(contract_).transferFrom(address(this), to_, amount_); //Can only transfer from our own contract
        require(success, 'token transfer from sender failed');
        emit TokenWithdraw(to_, amount_, contract_);
    }

    function iERC20Transfer(address contract_, address to_, uint256 amount_) external onlyOwner afterPresale{
        (bool success) = IERC20Token(contract_).transfer(to_, amount_); 
        //Since interfaced contract looks at msg.sender then this can only send from our own contract
        require(success, 'token transfer from sender failed');
        emit TokenWithdraw(to_, amount_, contract_);
    }

    function iERC20Approve(address contract_, address spender_, uint256 amount_) external onlyOwner afterPresale{
        IERC20Token(contract_).approve(spender_, amount_); //Since interfaced contract looks at msg.sender then this can only send from our own contract
        emit TokenApproved(spender_, amount_, contract_);
    }

    function iERC721TransferFrom(address contract_, address to_, uint256 tokenId_) external onlyOwner afterPresale{
        IERC721Token(contract_).transferFrom(address(this), to_, tokenId_); //Can only transfer from our own contract
        emit NFTWithdraw(to_, tokenId_, contract_);
    }

    function iERC721SafeTransferFrom(address contract_, address to_, uint256 tokenId_) external onlyOwner afterPresale{
        IERC721Token(contract_).safeTransferFrom(address(this), to_, tokenId_); //Can only transfer from our own contract
        emit NFTWithdraw(to_, tokenId_, contract_);
    }

    function iERC721Transfer(address contract_, address to_, uint256 tokenId_) external onlyOwner afterPresale{
        IERC721Token(contract_).transfer( address(this), to_, tokenId_); //Can only transfer from our own contract
        emit NFTWithdraw(to_, tokenId_, contract_);
    }

    function iERC721SafeTransfer(address contract_, address to_, uint256 tokenId_) external onlyOwner afterPresale{
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

//1. Set the variables at the beginning of the presale contract to the correct values for the presale.
//2. Deploy the presale contract.
//3. Deploy the Bro token contract, minting tokens directly to the presale contract address, with no taxes or restrictions for presale contract.
//4. Call setBroInterface with the Bro token contract address in the presale contract. This starts the presale.
//5. After presale ends, call seedLP() in presale contract to create LP.
//6. After LP is seeded call airdropBuyers() repeatedly in the presale contract to send out all the airdrop tokens to presale buyers.
//7. Allow trading on the Bro token contract after airdrop is completed.