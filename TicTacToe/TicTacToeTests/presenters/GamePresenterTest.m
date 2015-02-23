#import <OCMock/OCMock.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ComputerPlayer.h"
#import "GamePresenter.h"
#import "GameView.h"
#import "GameViewController.h"
#import "TicTacToeBoard.h"

@interface GamePresenterTest : XCTestCase {
  id mockBoard_;
  id mockComputerPlayer_;
  id mockView_;
  id mockViewController_;
  GamePresenter *presenter_;
}
// Sets expectations that the view will return these buttons, and a target will be added to each.
- (void)setUpExpectationsForButtons:(NSArray *)buttons;
@end

@implementation GamePresenterTest

- (void)setUp {
  [super setUp];

  mockBoard_ = OCMStrictClassMock([TicTacToeBoard class]);
  mockComputerPlayer_ = OCMStrictClassMock([ComputerPlayer class]);
  mockView_ = OCMStrictClassMock([GameView class]);
  mockViewController_ = OCMStrictClassMock([GameViewController class]);
  OCMStub([mockViewController_ gameView]).andReturn(mockView_);

  presenter_ = [[GamePresenter alloc] initWithBoard:mockBoard_
                                     computerPlayer:mockComputerPlayer_
                                           gameType:TicTacToeGameUserO];
  [presenter_ setViewController:mockViewController_];
}

- (void)tearDown {
  OCMVerifyAll(mockBoard_);
  OCMVerifyAll(mockComputerPlayer_);
  OCMVerifyAll(mockView_);
  OCMVerifyAll(mockViewController_);

  [super tearDown];
}

- (void)setUpExpectationsForButtons:(NSArray *)buttons {
  OCMStub([mockView_ buttons]).andReturn(buttons);

  for (id mockButton in buttons) {
    OCMExpect([mockButton addTarget:presenter_
                             action:[OCMArg anySelector]
                   forControlEvents:UIControlEventTouchUpInside]);
  }
}

- (void)testCreateViewControllerUserO {
  GameViewController *viewController =
      (GameViewController *) [GamePresenter createViewControllerWithGameType:TicTacToeGameUserO];
  XCTAssertNotNil(viewController);

  GamePresenter *presenter = (GamePresenter *) [viewController presenter];
  XCTAssertNotNil(presenter);

  XCTAssertEqual([presenter gameType], TicTacToeGameUserO);
}

- (void)testCreateViewControllerUserX {
  GameViewController *viewController =
      (GameViewController *) [GamePresenter createViewControllerWithGameType:TicTacToeGameUserX];
  XCTAssertNotNil(viewController);

  GamePresenter *presenter = (GamePresenter *) [viewController presenter];
  XCTAssertNotNil(presenter);

  XCTAssertEqual([presenter gameType], TicTacToeGameUserX);
}

- (void)testCreateViewControllerUserXO {
  GameViewController *viewController =
      (GameViewController *) [GamePresenter createViewControllerWithGameType:TicTacToeGameUserXO];
  XCTAssertNotNil(viewController);

  GamePresenter *presenter = (GamePresenter *) [viewController presenter];
  XCTAssertNotNil(presenter);

  XCTAssertEqual([presenter gameType], TicTacToeGameUserXO);
}

- (void)testViewLoadedComputerNotPlaying {
  presenter_ = [[GamePresenter alloc] initWithBoard:mockBoard_
                                     computerPlayer:mockComputerPlayer_
                                           gameType:TicTacToeGameUserXO];
  [presenter_ setViewController:mockViewController_];

  id mockButton1 = OCMStrictClassMock([UIButton class]);
  id mockButton2 = OCMStrictClassMock([UIButton class]);
  id mockButton3 = OCMStrictClassMock([UIButton class]);
  NSArray *buttons = @[mockButton1, mockButton2, mockButton3];
  [self setUpExpectationsForButtons:buttons];

  [presenter_ viewLoaded];

  OCMVerifyAll(mockButton1);
  OCMVerifyAll(mockButton2);
  OCMVerifyAll(mockButton3);
}

- (void)testViewLoadedComputerNotFirst {
  presenter_ = [[GamePresenter alloc] initWithBoard:mockBoard_
                                     computerPlayer:mockComputerPlayer_
                                           gameType:TicTacToeGameUserO];
  [presenter_ setViewController:mockViewController_];

  id mockButton1 = OCMStrictClassMock([UIButton class]);
  id mockButton2 = OCMStrictClassMock([UIButton class]);
  id mockButton3 = OCMStrictClassMock([UIButton class]);
  NSArray *buttons = @[mockButton1, mockButton2, mockButton3];
  [self setUpExpectationsForButtons:buttons];

  [presenter_ viewLoaded];

  OCMVerifyAll(mockButton1);
  OCMVerifyAll(mockButton2);
  OCMVerifyAll(mockButton3);
}

- (void)testViewLoadedComputerGoesFirst {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"testViewLoadedComputerGoesFirst"];

  presenter_ = [[GamePresenter alloc] initWithBoard:mockBoard_
                                     computerPlayer:mockComputerPlayer_
                                           gameType:TicTacToeGameUserX];
  [presenter_ setViewController:mockViewController_];

  id mockButton1 = OCMStrictClassMock([UIButton class]);
  id mockButton2 = OCMStrictClassMock([UIButton class]);
  id mockButton3 = OCMStrictClassMock([UIButton class]);
  NSArray *buttons = @[mockButton1, mockButton2, mockButton3];
  [self setUpExpectationsForButtons:buttons];

  // Computer should play.
  OCMExpect([mockBoard_ gameState]).andReturn(TicTacToeGameStateNotEnded);
  OCMExpect([mockComputerPlayer_ makeNextMove]);
  OCMExpect([mockViewController_ updateDisplayFromBoard:mockBoard_])
      .andDo(^(NSInvocation *invocation){
          [expectation fulfill];
      });

  [presenter_ viewLoaded];

  [self waitForExpectationsWithTimeout:2 handler:nil];

  OCMVerifyAll(mockButton1);
  OCMVerifyAll(mockButton2);
  OCMVerifyAll(mockButton3);
}

@end
