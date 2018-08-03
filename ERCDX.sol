pragma solidity ^0.4.24;

library SafeMath 
{

  function mul(  uint256 _a, 
                 uint256 _b  ) internal pure returns (uint256 c) 
  {
      
        if (_a == 0) {
            return 0;
            }
        c = _a * _b;
        assert(c / _a == _b);
        return c;
        
  }

  function div(  uint256 _a, 
                 uint256 _b  ) internal pure returns (uint256) 
  {
        return _a / _b;
  }

  function sub(  uint256 _a, 
                 uint256 _b  ) internal pure returns (uint256) 
  {
      
        assert(_b <= _a);
        return _a - _b;
        
  }

  function add(  uint256 _a, 
                 uint256 _b  ) internal pure returns (uint256 c) 
   {
       
        c = _a + _b;
        assert(c >= _a);
        return c;
    
  }
  
}


contract ERC20Basic 
{
    
  function totalSupply( 
                           ) public view returns (uint256);
                           
  function balanceOf(  address _who
                                     ) public view returns (uint256);
                                     
  function transfer(  address _to,
                      uint256 _value  ) public returns (bool);
                      
  event Transfer(  address indexed from,
                   address indexed to, 
                   uint256 value  );
  
}

contract ERC20 is ERC20Basic 
{
    
  function allowance(  address _owner, 
                       address _spender  ) public view returns (uint256);

  function transferFrom(  address _from, 
                          address _to, 
                          uint256 _value  ) public returns (bool);

  function approve(  address _spender,
                     uint256 _value  ) public returns (bool);
  
  event Approval(  address indexed owner,
                   address indexed spender,
                   uint256 value  );
}

contract BasicToken is ERC20Basic 
{
    
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  function totalSupply(
                           ) public view returns (uint256) 
  {
        return totalSupply_;
  }

  function transfer(  address _to, 
                      uint256 _value  ) public returns (bool) 
  {
                          
        require(_value <= balances[msg.sender]);
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    
  }

  function balanceOf(  
                       address _owner  ) public view returns (uint256) 
  {
        return balances[_owner];
  }

}

contract ERCDX is ERC20, BasicToken 
{
    
    bytes32 constant POS = 0x506f736974697665000000000000000000000000000000000000000000000000;
    bytes32 constant NEG = 0x4e65676174697665000000000000000000000000000000000000000000000000;
    bytes32 constant NA = 0x0000000000000000000000000000000000000000000000000000000000000000;
    address public founder = msg.sender;
    address public admin;

    modifier only_founder(){ if(msg.sender != founder){revert();} _; }
    modifier only_admin(){ if(msg.sender != admin){revert();} _; }

    mapping(address => mapping (address => uint256)) internal allowed;
    mapping(address => bytes32[25]) public previous;
    mapping(address => bytes32[6]) public delegate;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    constructor( 
                    ) public 
    {

        symbol = "DX";
        name = "Ðivision X";
        decimals = 18;
        totalSupply = uint(50600000000).mul(10**uint(decimals));
        balances[founder] = totalSupply;
        emit Transfer(this, founder, totalSupply);

    }

    function transferFrom(  address _from,
                            address _to,
                            uint256 _value  ) public returns (bool)
    {

        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;

    }

    function approve(  address _spender,
                       uint256 _value    ) public returns (bool)
    {

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;

    }

    function allowance(  address _owner,
                         address _spender  ) public view returns (uint256)
    {

        return allowed[_owner][_spender];

    }

    function increaseApproval(  address _spender,
                                uint _addedValue  ) public returns (bool)
    {

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;

    }

    function decreaseApproval(  address _spender,
                                uint _subtractedValue  ) public returns (bool)
    {

        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;

    }

    function registerVoter( 
                             bytes32 user  ) public
    {

        bytes32[6] storage x = delegate[msg.sender];
        require(x[0] == NA);
        x[0] = user;

    }

    function viewStats(
                         address target  ) public constant returns (  bytes32,
                                                                      bytes32[25],
                                                                      uint256,
                                                                      uint256,
                                                                      uint256,
                                                                      uint256,
                                                                      bytes32  )
    {

        bytes32[6] storage x = delegate[target];
        bytes32[25] storage y = previous[target];

        return (  x[0],
                  y,
                  uint256(x[1]),
                  uint256(x[2]),
                  uint256(x[3]),
                  uint256(x[4]),
                  x[5]  );

    }

    function adminControl(
                            address entity  ) public only_founder returns (address)
    {

        admin = entity;
        return admin;

    }

    function delegationEvent(  address voter,
                               uint256 weight,
                               bytes32 choice,
                               bytes32 project  ) public only_admin
    {

        uint256 c = 0;
        bytes32[25] memory prv;
        bytes32[6] storage x = delegate[voter];
        bytes32[25] storage y = previous[voter];

	    for(uint v = 0; v < y.length ; v++)
	    {

            prv[v] = y[v];
            if(project == y[v]){revert();}
		    else if(prv[v] == NA){c++;
                                  prv[v] = project;
                                  if(v == y.length-1){c++;} break;}

	    }

        require(c > 0);
        previous[voter] = prv;
        x[1] = bytes32(uint256(x[1]).add(1));

        if(choice == POS){ x[3] = bytes32(uint256(x[3]).add(weight)); }
        else if(choice == NEG){ x[2] = bytes32(uint256(x[2]).add(weight)); }

        x[4] = bytes32(uint256(x[4]).add(weight));

        if(c == 1){ x[5] = bytes32("false"); }
        else if(c == 2){ x[5] = bytes32("true"); }

    }

    function delegationBonus(
                               address voter  ) public only_admin
    {

        bytes32[6] storage x = delegate[voter];
        x[5] = bytes32("false");
        delete previous[voter];

    }

}
