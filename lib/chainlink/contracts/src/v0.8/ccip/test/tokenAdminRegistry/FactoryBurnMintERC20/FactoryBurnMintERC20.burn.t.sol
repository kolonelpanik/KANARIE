// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {FactoryBurnMintERC20} from "../../../tokenAdminRegistry/TokenPoolFactory/FactoryBurnMintERC20.sol";
import {BurnMintERC20Setup} from "./BurnMintERC20Setup.t.sol";

contract FactoryBurnMintERC20_burn is BurnMintERC20Setup {
  function test_BasicBurn_Success() public {
    s_burnMintERC20.grantBurnRole(OWNER);
    deal(address(s_burnMintERC20), OWNER, s_amount);

    vm.expectEmit();
    emit IERC20.Transfer(OWNER, address(0), s_amount);

    s_burnMintERC20.burn(s_amount);

    assertEq(0, s_burnMintERC20.balanceOf(OWNER));
  }

  // Revert

  function test_SenderNotBurner_Reverts() public {
    vm.expectRevert(abi.encodeWithSelector(FactoryBurnMintERC20.SenderNotBurner.selector, OWNER));

    s_burnMintERC20.burnFrom(STRANGER, s_amount);
  }

  function test_ExceedsBalance_Reverts() public {
    changePrank(s_mockPool);

    vm.expectRevert("ERC20: burn amount exceeds balance");

    s_burnMintERC20.burn(s_amount * 2);
  }

  function test_BurnFromZeroAddress_Reverts() public {
    s_burnMintERC20.grantBurnRole(address(0));
    changePrank(address(0));

    vm.expectRevert("ERC20: burn from the zero address");

    s_burnMintERC20.burn(0);
  }
}