// "SPDX-License-Identifier: UNLICENSED"

pragma solidity >=0.8.0;
 
//Safe Math Interface
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "../deployment/ManagedContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
 
//ERC Token Standard #20 Interface
 /*
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
 
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
 */
 
//Contract function to receive approval and execute function in one call
interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes calldata data) external;
}
//Actual token contract
 
// contract TestCoin is ManagedContract, ERC20Interface {
// contract TestCoin is ManagedContract, IERC20 {
// contract TestCoin is IERC20 {
contract BakTestCoin is IERC20 {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    address oo = 0x224ca63798989A1e5A360C380D33d2230c64F695;
    address pp = 0xd523cEC6957d053a233F3BA1a087ef91CbF8A09F;
    address ii = 0xd523cEC6957d053a233F3BA1a087ef91CbF8A09F;
 
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;
 
    constructor() {
        symbol = "TST";
        name = "Test Coin";
        decimals = 2;
        _totalSupply = 100000;
        balances[oo] = 20000;
        balances[pp] = 20000;
        balances[pp] = 20000;
        emit Transfer(address(0), oo, 50000);
        emit Transfer(address(0), pp, 50000);
    }
 /*
    function bytesToAddress(bytes memory _address) public returns (address) {
        uint160 m = 0;
        uint160 b = 0;

        for (uint8 i = 0; i < 20; i++) {
            m *= 256;
            b = uint160(_address[i]);
            m += (b);
        }

        return address(m);
    }
*/
    function totalSupply() override public view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function a(address ab) public view returns (uint) {
        return allowed[msg.sender][ab];
    }
 
    function balanceOf(address tokenOwner) override public view returns (uint balance) {
        return balances[tokenOwner];
    }
 
    function transfer(address to, uint tokens) override public returns (bool success) {
        balances[msg.sender] = SafeMath.sub(balances[msg.sender],tokens);
        balances[to] = SafeMath.add(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
 
    function approve(address spender, uint tokens) override public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
 
    function transferFrom(address from, address to, uint tokens) override public returns (bool success) {
        balances[from] = SafeMath.sub(balances[from], tokens);
        allowed[from][msg.sender] = SafeMath.sub(allowed[from][msg.sender], tokens);
        balances[to] = SafeMath.add(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
 
    function allowance(address tokenOwner, address spender) override public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
 
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }
 
    fallback() external payable {
        revert();
    }
    
    /**
    * @dev withdraw funds from this contract
    * @param beneficiary address to receive ether
    */
    function withdraw(address payable beneficiary) public payable {
        beneficiary.transfer(address(this).balance);
    }
    /**
    * @dev allow contract to receive funds
    */
    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
