import json
import os
import sqlite3
from time import sleep, time

from google import genai

print("Running db_bot.py!")

fdir = os.path.dirname(__file__)
def getPath(fname):
    return os.path.join(fdir, fname)

# SQLITE
sqliteDbPath = getPath("aidb.sqlite")
setupSqlPath = getPath("setup.sql")
setupSqlDataPath = getPath("setupData.sql")

# Erase previous db
if os.path.exists(sqliteDbPath):
    os.remove(sqliteDbPath)

# create new db
sqliteCon = sqlite3.connect(sqliteDbPath) 
sqliteCursor = sqliteCon.cursor()

# read in setup files
with (
        open(setupSqlPath) as setupSqlFile,
        open(setupSqlDataPath) as setupSqlDataFile
    ):

    setupSqlScript = setupSqlFile.read()
    setupSQlDataScript = setupSqlDataFile.read()

# execute setup files
sqliteCursor.executescript(setupSqlScript) # setup tables and keys
sqliteCursor.executescript(setupSQlDataScript) # setup tables and keys

def runSql(query):
    resultCursor = sqliteCursor.execute(query)
    columns = [column[0] for column in resultCursor.description or []]
    return columns, resultCursor.fetchall()

# OPENAI
configPath = getPath("config.json")
print(configPath)
with open(configPath) as configFile:
    config = json.load(configFile)

geminiClient = genai.Client(api_key=config["openaiKey"])
geminiClient.models.list() # check if the key is valid (update in config.json)
chosen_model = "gemini-3.5-flash-lite"

databaseDescription = (
    "This is a small chess tournament database. It stores players, their birth "
    "dates, Elo ratings, phone numbers, and addresses; chess venues and their "
    "addresses; tournaments held at venues, including dates and prize amounts; "
    "players registered for tournaments with their seed and final rank; games "
    "with the tournament, board, players playing white and black, result, and "
    "date and time; and each game's moves, including the player, move number, "
    "start and end squares, piece type, captured piece, and promotion piece. "
    "The tables are address, player, location, tournament, tournament_player, "
    "game, and move."
)
print("\nDatabase overview:")
print(databaseDescription)
question = input("\nWhat would you like to know about the database? ").strip()

def getChatGptResponse(content):
    stream = geminiClient.models.generate_content_stream(
        model=chosen_model,
        contents=content,
    )

    responseList = []
    for chunk in stream:
        text = getattr(chunk, "text", None)
        if text:
            responseList.append(text)

    result = "".join(responseList)
    return result


baseSqlPromptPrefix = (
    setupSqlScript
    + "\nDatabase description: " + databaseDescription
    + "\nWrite one SQLite SELECT query that answers the user's question. "
      "Use the schema and joins as needed. Return only SQL, with no explanation."
)

exampleQuestion = "How many games did each tournament contain?"
exampleQuery = (
    "SELECT t.name AS tournament_name, COUNT(g.game_id) AS game_count "
    "FROM tournament AS t "
    "LEFT JOIN game AS g ON t.tournament_id = g.tournament_id "
    "GROUP BY t.tournament_id, t.name;"
)

strategies = {
    "schema_only": baseSqlPromptPrefix,
    "single_domain_double_shot": (
        baseSqlPromptPrefix
        + "\n\nExample question: " + exampleQuestion
        + "\nExample SQLite query: " + exampleQuery
        + "\nUse this example as a pattern where relevant, adapting the tables, "
          "joins, and aggregation to the user's question."
    ),
}


# use the markdown for the sql syntax to find the SQL query
def sanitizeForJustSql(value):
    gptStartSqlMarker = "```"
    gptEndSqlMarker = "```"
    if gptStartSqlMarker in value:
        # Split at the first ``` and take everything after it
        value = value.split(gptStartSqlMarker, 1)[1]
        # Find the newline after the language identifier (sql, sqlite, etc.)
        newline_index = value.find("\n")
        if newline_index != -1:
            value = value[newline_index + 1:]
    if gptEndSqlMarker in value:
        # Split at the closing ``` and take everything before it
        value = value.split(gptEndSqlMarker, 1)[0]

    return value.strip()

print("\nQuestion:")
print(question)
for strategy, sqlPromptPrefix in strategies.items():
    print(f"\n--- Strategy: {strategy} ---")
    error = "None"
    sqlSyntaxResponse = None
    queryRawResponse = None
    friendlyResponse = None

    try:
        if not question:
            raise ValueError("Please enter a question before running the bot.")

        sqlPrompt = sqlPromptPrefix + "\nUser question: " + question
        sqlSyntaxResponse = sanitizeForJustSql(getChatGptResponse(sqlPrompt))
        print("\nSQL query:")
        print(sqlSyntaxResponse)

        columns, queryRows = runSql(sqlSyntaxResponse)
        resultRecords = [dict(zip(columns, row)) for row in queryRows]
        queryRawResponse = json.dumps(resultRecords, ensure_ascii=False)
        print("\nQuery results:")
        print(queryRawResponse)

        # Keep each strategy's SQL and response requests at least 5 seconds apart.
        sleep(5)
        friendlyResultsPrompt = (
            "Answer the user's database question in a concise, friendly, conversational way. "
            "Use only the SQL result data below; do not invent facts or claim more than it shows. "
            "If the result data is empty, say that no matching records were found.\n\n"
            f"User question: {question}\n"
            f"SQL query: {sqlSyntaxResponse}\n"
            f"Result columns: {columns}\n"
            f"SQL result data (JSON): {queryRawResponse}"
        )
        friendlyResponse = getChatGptResponse(friendlyResultsPrompt).strip()
        print("\nResponse:")
        print(friendlyResponse)
    except Exception as err:
        error = str(err)
        print("\nError:")
        print(err)

    responses = {
        "strategy": strategy,
        "prompt_prefix": sqlPromptPrefix,
        "questionResults": [{
            "question": question,
            "sql": sqlSyntaxResponse,
            "queryRawResponse": queryRawResponse,
            "friendlyResponse": friendlyResponse,
            "error": error
        }]
    }

    with open(getPath(f"response_{strategy}_{time()}.json"), "w") as outFile:
        json.dump(responses, outFile, indent=2)


sqliteCursor.close()
sqliteCon.close()
print("Done!")
