// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract FaceBook is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private postId;
    Counters.Counter private userId;

    constructor() ERC721("FaceBook", "FB") {}

    struct UserInfo {
        uint256 Id;
        address userAddress;
        string userName;
        string userPhoto;
        string userBio;
        bool isRegistered;
    }
    struct PostInfo {
        uint256 Id;
        address useraddress;
        string postPhoto;
        string postBio;
    }

    address[] private userList;
    mapping(uint256 => PostInfo) private posts;
    mapping(uint256 => bool) public isPostExist;
    mapping(address => uint256[]) private myPosts;
    mapping(address => UserInfo) private users;
    mapping(address => address[]) private friendList;

    function createUser(
        string memory _userName,
        string memory _userPhoto,
        string memory _userBio
    ) public {
        uint256 _userId = userId.current();
        require(!users[msg.sender].isRegistered, "User already registered");
        require(bytes(_userName).length > 0, "User name cannot be empty");
        userId.increment();
        users[msg.sender] = UserInfo(
            _userId,
            msg.sender,
            _userName,
            _userPhoto,
            _userBio,
            true
        );

        userList.push(msg.sender);
    }

    function editUserNamee(string memory _userName) public {
        require(users[msg.sender].isRegistered, "You are not registered");
        require(bytes(_userName).length > 0, "User name cannot be empty");
        users[msg.sender].userName = _userName;
    }

    function editUserPhoto(string memory _userPhoto) public {
        require(users[msg.sender].isRegistered, "You are not registered");
        require(bytes(_userPhoto).length > 0, "User photo cannot be empty");
        users[msg.sender].userPhoto = _userPhoto;
    }

    function editUserBio(string memory _userBio) public {
        require(users[msg.sender].isRegistered, "You are not registered");
        require(bytes(_userBio).length > 0, "User bio cannot be empty");
        users[msg.sender].userBio = _userBio;
    }

    function viewUserInfo(
        address UserAddress
    ) public view returns (UserInfo memory) {
        return users[UserAddress];
    }

    function createPost(
        string memory _postPhoto,
        string memory _postBio
    ) external {
        require(users[msg.sender].isRegistered, "You are not registered");

        uint256 id = postId.current();
        postId.increment();
        isPostExist[id] = true;
        posts[id] = PostInfo(id, msg.sender, _postPhoto, _postBio);
        myPosts[msg.sender].push(id);
        _safeMint(msg.sender, id);
    }

    function deletePost(uint256 _id) external {
        require(isPostExist[_id], "Post id Does not Exist");
        require(users[msg.sender].isRegistered, "You are not registered");
        require(
            posts[_id].useraddress == msg.sender,
            "You are not owner of the post"
        );

        _burn(_id);
        uint[] storage tempArray = myPosts[msg.sender];
        for (uint256 i = 0; i < tempArray.length; i++) {
            if (tempArray[i] == _id) {
                tempArray[i] = tempArray[tempArray.length - 1];
                tempArray.pop();
                break;
            }
        }
        isPostExist[_id] = false;
    }

    function viewMyPostId(
        address _address
    ) public view returns (uint256[] memory) {
        return myPosts[_address];
    }

    function viewPost(
        address _address
    ) public view returns (PostInfo[] memory) {
        uint256[] memory tempPostArray = myPosts[_address];
        PostInfo[] memory temp = new PostInfo[](tempPostArray.length);
        for (uint256 i = 0; i < tempPostArray.length; i++) {
            temp[i] = posts[tempPostArray[i]];
        }
        return temp;
    }

    function userLists() public view returns (address[] memory) {
        return userList;
    }

    function viewPostById(uint256 _id) public view returns (PostInfo memory) {
        require(isPostExist[_id], "Post id Does not Exist");

        return posts[_id];
    }

    function editPost(
        uint256 _id,
        string memory _postPhoto,
        string memory _postBio
    ) public {
        require(isPostExist[_id], "Post id Does not Exist");
        require(users[msg.sender].isRegistered, "You are not registered");
        require(posts[_id].useraddress == msg.sender, "This is not Your Post");
        PostInfo storage temp = posts[_id];
        temp.postPhoto = _postPhoto;
        temp.postBio = _postBio;
    }
}
