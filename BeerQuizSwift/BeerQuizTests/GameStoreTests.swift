import XCTest
@testable import BeerQuiz

final class GameStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "GameStoreTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    private func makeQuestion(_ text: String) -> QuizQuestion {
        QuizQuestion(
            question: text,
            choices: ["A", "B", "C", "D"],
            correctAnswerIndex: 0,
            trivia: "trivia",
            difficulty: .easy
        )
    }

    func testWrongAnswerIsStoredAndClearedWhenAnsweredCorrectly() {
        let store = GameStore(defaults: defaults)
        let question = makeQuestion("Q1")

        store.recordAnswer(AnswerRecord(question: question, selectedIndex: 1))
        XCTAssertEqual(store.wrongQuestionIDs, [question.id])
        XCTAssertEqual(store.reviewQuestions(from: [question]).count, 1)

        store.recordAnswer(AnswerRecord(question: question, selectedIndex: 0))
        XCTAssertTrue(store.wrongQuestionIDs.isEmpty)
        XCTAssertEqual(store.totalAnswered, 2)
        XCTAssertEqual(store.totalCorrect, 1)
        XCTAssertEqual(store.accuracyPercent, 50)
    }

    func testHighScoreOnlyUpdatesWhenBeaten() {
        let store = GameStore(defaults: defaults)

        XCTAssertTrue(store.recordGameFinished(score: 6))
        XCTAssertFalse(store.recordGameFinished(score: 6))
        XCTAssertFalse(store.recordGameFinished(score: 4))
        XCTAssertTrue(store.recordGameFinished(score: 9))
        XCTAssertEqual(store.highScore, 9)
        XCTAssertEqual(store.gamesPlayed, 4)
    }

    func testStatsPersistAcrossInstances() {
        let first = GameStore(defaults: defaults)
        first.recordGameFinished(score: 7)
        first.recordAnswer(AnswerRecord(question: makeQuestion("Q1"), selectedIndex: 2))

        let second = GameStore(defaults: defaults)
        XCTAssertEqual(second.highScore, 7)
        XCTAssertEqual(second.wrongQuestionIDs, ["Q1"])
    }

    func testDailyQuestionIsStableWithinADayAndCompletionResetsNextDay() {
        let store = GameStore(defaults: defaults)
        let questions = (0..<5).map { makeQuestion("Q\($0)") }
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        XCTAssertEqual(store.dailyQuestion(from: questions, on: today), store.dailyQuestion(from: questions, on: today))
        XCTAssertNotEqual(store.dailyQuestion(from: questions, on: today), store.dailyQuestion(from: questions, on: tomorrow))

        XCTAssertFalse(store.isDailyCompleted(on: today))
        store.recordDailyCompleted(on: today)
        XCTAssertTrue(store.isDailyCompleted(on: today))
        XCTAssertFalse(store.isDailyCompleted(on: tomorrow))
    }

    func testResetStatsClearsEverything() {
        let store = GameStore(defaults: defaults)
        store.recordGameFinished(score: 5)
        store.recordAnswer(AnswerRecord(question: makeQuestion("Q1"), selectedIndex: 3))
        store.recordDailyCompleted()

        store.resetStats()

        XCTAssertEqual(store.highScore, 0)
        XCTAssertEqual(store.totalAnswered, 0)
        XCTAssertTrue(store.wrongQuestionIDs.isEmpty)
        XCTAssertFalse(store.isDailyCompleted())
        XCTAssertNil(store.accuracyPercent)
    }
}
