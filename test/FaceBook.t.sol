// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.21;
import {Test, console2} from "forge-std/Test.sol";

import {FaceBook} from "../src/FaceBook.sol";

contract TestFaceBook is Test {
    FaceBook public fb;

    function setUp() public {
        fb = new FaceBook();
    }

    function testFacebookNameSymbol() public {
        assertEq(fb.name(), "FaceBook");
        assertEq(fb.symbol(), "FB");
    }

    function testOwner() public {
        assertEq(fb.owner(), address(this));
    }

    function testFailOwnerShip() public {
        vm.prank(address(1));
        fb.transferOwnership(address(1));
    }

    function test_createUser() public {
        vm.prank(address(1));
        fb.createUser("test", "test", "test");
        FaceBook.UserInfo memory user = fb.viewUserInfo(address(1));
        assertEq(user.Id, 0);
        assertEq(user.userName, "test");
        assertEq(user.userPhoto, "test");
        assertEq(user.userBio, "test");
        assertTrue(user.isRegistered);
    }

    function test_createUser_CheckUser() public {
        vm.startPrank(address(1));
        fb.createUser("test", "test", "test");
        vm.expectRevert();

        fb.createUser("test", "test", "test");

        vm.stopPrank();
    }

    function test_createUser_CheckUserName() public {
        vm.prank(address(1));
        vm.expectRevert();
        fb.createUser("", "test", "test");
    }

    function test_editUserName() public {
        vm.startPrank(address(1));
        fb.createUser("test", "test", "test");
        fb.editUserNamee("test2");
        FaceBook.UserInfo memory user = fb.viewUserInfo(address(1));
        assertEq(user.userName, "test2");
        vm.expectRevert();
        fb.editUserNamee("");
        vm.stopPrank();
        vm.expectRevert();
        fb.editUserNamee("test2");
    }

    function test_edituserPhoto() public {
        vm.startPrank(address(1));
        fb.createUser("test", "test", "test");
        fb.editUserPhoto("test2");
        FaceBook.UserInfo memory user = fb.viewUserInfo(address(1));
        assertEq(user.userPhoto, "test2");
        vm.expectRevert();
        fb.editUserPhoto("");
        vm.stopPrank();
        vm.prank(address(2));
        vm.expectRevert();
        fb.editUserPhoto("test2");
    }

    function test_edituserBio() public {
        vm.startPrank(address(1));
        fb.createUser("test", "test", "test");
        fb.editUserBio("test2");
        FaceBook.UserInfo memory user = fb.viewUserInfo(address(1));
        assertEq(user.userBio, "test2");
        vm.expectRevert();
        fb.editUserBio("");
        vm.stopPrank();
        vm.prank(address(2));
        vm.expectRevert();
        fb.editUserBio("test2");
    }

    function test_createPost() public {
        vm.startPrank(address(1));
        fb.createUser("test", "test", "test");
        fb.createPost("TestPost", "TestPost");
        vm.stopPrank();
        FaceBook.PostInfo memory temp = fb.viewPostById(0);
        assertEq(temp.postPhoto, "TestPost");
        assertEq(temp.postBio, "TestPost");
    }

    function test_createPostCheck() public {
        vm.prank(address(1));
        vm.expectRevert();
        fb.createPost("TestPost", "TestPost");
    }

    function test_deletePost() public {
        vm.startPrank(address(1));
        fb.createUser("test", "test", "test");
        fb.createPost("TestPost", "TestPost");
        fb.createPost("TestPost2", "TestPost2");
        fb.deletePost(0);
        vm.expectRevert();
        fb.viewPostById(0);
        FaceBook.PostInfo memory temp2 = fb.viewPostById(1);
        assertEq(temp2.postPhoto, "TestPost2");
        assertEq(temp2.postBio, "TestPost2");
        console2.log(temp2.useraddress);
    }

    function test_EditPost() public {
        vm.startPrank(address(1));
        fb.createUser("test", "test", "test");
        fb.createPost("TestPost", "TestPost");

        FaceBook.PostInfo memory temp = fb.viewPostById(0);
        assertEq(temp.postPhoto, "TestPost");
        assertEq(temp.postBio, "TestPost");
        fb.editPost(0, "Test2", "Test2");
        FaceBook.PostInfo memory temp2 = fb.viewPostById(0);
        vm.stopPrank();
        assertEq(temp2.postPhoto, "Test2");
        assertEq(temp2.postBio, "Test2");
    }

    function test_EditPostCheck() public {
        vm.startPrank(address(1));
        fb.createUser("test", "test", "test");
        fb.createPost("TestPost", "TestPost");
        vm.stopPrank();
        vm.startPrank(address(2));
        fb.createUser("test", "test", "test");
        fb.createPost("TestPost", "TestPost");
        vm.stopPrank();
        vm.prank(address(2));
        vm.expectRevert();
        fb.editPost(0, "asd", "asd");
        vm.prank(address(2));
        vm.expectRevert();
        fb.editPost(3, "asd", "asd");
    }
}
