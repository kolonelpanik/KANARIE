// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Router} from "../../../Router.sol";

import {MaybeRevertMessageReceiver} from "../../helpers/receivers/MaybeRevertMessageReceiver.sol";
import {OnRampSetup} from "../../onRamp/OnRamp/OnRampSetup.t.sol";

contract Router_recoverTokens is OnRampSetup {
  function test_RecoverTokens_Success() public {
    // Assert we can recover sourceToken
    IERC20 token = IERC20(s_sourceTokens[0]);
    uint256 balanceBefore = token.balanceOf(OWNER);
    token.transfer(address(s_sourceRouter), 1);
    assertEq(token.balanceOf(address(s_sourceRouter)), 1);
    s_sourceRouter.recoverTokens(address(token), OWNER, 1);
    assertEq(token.balanceOf(address(s_sourceRouter)), 0);
    assertEq(token.balanceOf(OWNER), balanceBefore);

    // Assert we can recover native
    balanceBefore = OWNER.balance;
    deal(address(s_sourceRouter), 10);
    assertEq(address(s_sourceRouter).balance, 10);
    s_sourceRouter.recoverTokens(address(0), OWNER, 10);
    assertEq(OWNER.balance, balanceBefore + 10);
    assertEq(address(s_sourceRouter).balance, 0);
  }

  function test_RecoverTokensNonOwner_Revert() public {
    // Reverts if not owner
    vm.startPrank(STRANGER);
    vm.expectRevert("Only callable by owner");
    s_sourceRouter.recoverTokens(address(0), STRANGER, 1);
  }

  function test_RecoverTokensInvalidRecipient_Revert() public {
    vm.expectRevert(abi.encodeWithSelector(Router.InvalidRecipientAddress.selector, address(0)));
    s_sourceRouter.recoverTokens(address(0), address(0), 1);
  }

  function test_RecoverTokensNoFunds_Revert() public {
    // Reverts if no funds present
    vm.expectRevert();
    s_sourceRouter.recoverTokens(address(0), OWNER, 10);
  }

  function test_RecoverTokensValueReceiver_Revert() public {
    MaybeRevertMessageReceiver revertingValueReceiver = new MaybeRevertMessageReceiver(true);
    deal(address(s_sourceRouter), 10);

    // Value receiver reverts
    vm.expectRevert(Router.FailedToSendValue.selector);
    s_sourceRouter.recoverTokens(address(0), address(revertingValueReceiver), 10);
  }
}
