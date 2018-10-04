pragma solidity ^0.4.24;

import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/os/contracts/lib/math/SafeMath.sol";
import "@aragon/os/contracts/kernel/Kernel.sol";
import "@aragon/os/contracts/apm/Repo.sol";
import "@aragon/os/contracts/lib/ens/ENS.sol";
import "@aragon/os/contracts/lib/ens/PublicResolver.sol";
import "@recoblix/minime-token/contracts/MiniMeToken.sol";
import "@aragon/os/contracts/apm/APMNamehash.sol";
import "@aragon/os/contracts/acl/ACL.sol";


contract MiniMeTokenFactory is AragonApp, APMNamehash {



    bytes32 constant public CREATE_CLONE_ROLE = keccak256("CREATE_CLONE_ROLE");


    // State
    mapping (address => bool) tokens;
    address public defaultManager;
    ENS public ens;

    Kernel dao;
    ACL acl;
    bytes32 tokenAppId;

  	function initialize(address _defaultManager, ENS _ens) onlyInit
  	{
      defaultManager = _defaultManager;
      ens = _ens;
      dao = Kernel(kernel());
      acl = ACL(dao.acl());
      tokenAppId = apmNamehash("minime-app");
  		initialized();
  	}

    /**
    * @notice Update the DApp by creating a new token with new functionalities
    *  the msg.sender becomes the controller of this clone token
    * @param _parentToken Address of the token being cloned
    * @param _snapshotBlock Block of the parent token that will
    *  determine the initial distribution of the clone token
    * @param _tokenName Name of the new token
    * @param _decimalUnits Number of decimals of the new token
    * @param _tokenSymbol Token Symbol for the new token
    * @param _transfersEnabled If true, tokens will be able to be transferred
    * @param _sender The sender, if this comes from a token
    * @return The address of the new token contract
    */
    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled,
        address _sender
    ) public returns (MiniMeToken) {
        if(tokens[msg.sender]){
          require(canPerform(_sender, CREATE_CLONE_ROLE, arr()));
        }else{
          require(canPerform(msg.sender, CREATE_CLONE_ROLE, arr()));
          _sender = msg.sender;
        }

        MiniMeToken newToken;

        if(dao.getApp(dao.APP_BASES_NAMESPACE(),tokenAppId) != address(0)){
          newToken = MiniMeToken(dao.newAppInstance(tokenAppId, dao.getApp(dao.APP_BASES_NAMESPACE(),tokenAppId)));
        }else{
          Repo repo = Repo(PublicResolver(ens.resolver(tokenAppId)).addr(tokenAppId));
          address base;
          (,base,) = repo.getLatest();
          newToken = MiniMeToken(dao.newAppInstance(tokenAppId, base));
        }

        newToken.initialize(
            this,
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
            );

        acl.createPermission(_sender, newToken, newToken.NO_ROLE(), defaultManager);

        tokens[newToken] = true;

        newToken.changeController(_sender);
        return newToken;
    }

    function changeDefaultManager(address _defaultManager){
      require(msg.sender == defaultManager);
      defaultManager = _defaultManager;
    }


}
