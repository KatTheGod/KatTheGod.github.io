    <%@ page import="java.util.Vector" %>
    <%@ page import="java.sql.SQLException" %>
    <%@ page import="java.sql.*" %>
    <%@ page import="java.time.format.DateTimeFormatter" %>
    <%@ page import="java.time.LocalDate" %>
    <%@ page import="java.io.FileWriter" %>
    <%@ page import="java.io.IOException" %>
    <%@ page import="javax.swing.*" %>
    <%@ page import="javax.print.attribute.standard.RequestingUserName" %>
    <%@ page import="javax.sound.midi.Soundbank" %>
    <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <!DOCTYPE html>
    <html>
    <head>
        <title>JSP - Hello World</title>
        <link rel="stylesheet" href="IndexCSS.css">
    </head>
    <body>
    <%!
        int prevGameID = -1;
        int nextGameId = -1;
        int currentGameID = -1;
        Vector<String> allGameIDs = new Vector<>();
        String gameID = "";
        String division = "";
        String datePlayed = "";
        String timePlayed = "";
        String redName = "";
        String greenName = "";
        String blueName = "";
        String yellowName = "";
        String gameString = "";
        String strAllGameIDs = "";
        String gamesDatabase = "";
        String playersDatabase = "";

        void getNextGame() throws ClassNotFoundException, SQLException, IOException {
            String strBreak = "<br>";
            String strEnd = "<end>";
            allGameIDs.clear();
            String url = "jdbc:mysql://localhost:3306/stringtest";
            String password = "M1lkt@rt$rg00d";
            //String password = "milktartsrgood";
            String username = "root";
            String query = "select * from Games order by datePlayed desc, timePlayed desc;";
            //String query = "show tables";
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, username, password);
            Statement st = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
            ResultSet resultSet = st.executeQuery(query);

            System.out.println("Current GameID: " + currentGameID);
            boolean alreadySet = false;
            prevGameID = -1;
            nextGameId = -1;
            gamesDatabase = "";
            while (resultSet.next()){
                String strGameID = resultSet.getString("gameID");
                int iRound = resultSet.getInt("round");
                int iDivision = resultSet.getInt("division");
                String strDatePlayed = resultSet.getString("datePlayed");
                String strTimePlayed = resultSet.getString("timePlayed");
                String strRedSnake = resultSet.getString("redSnake");
                String strGreenSnake = resultSet.getString("greenSnake");
                String strBlueSnake = resultSet.getString("blueSnake");
                String strYellowSnake = resultSet.getString("yellowSnake");
                gamesDatabase += (strGameID + strBreak + iRound + strBreak + iDivision + strBreak + strDatePlayed + strBreak +
                        strTimePlayed + strBreak + strRedSnake + strBreak + strGreenSnake + strBreak + strBlueSnake + strBreak +
                        strYellowSnake + strEnd);
                allGameIDs.add(strGameID);
                if (Integer.parseInt(strGameID) == currentGameID){
                    setGameVariables(resultSet);
                    alreadySet = true;
                    System.out.println("Set Game Variables: " + gameID);
                }
                if (resultSet.isLast() && !alreadySet){
                    resultSet.beforeFirst();
                    resultSet.next();
                    setGameVariables(resultSet);
                    System.out.println("Set Game Variables: " + gameID);
                    resultSet.afterLast();
                }
            }

            makeArrayContainer();
            System.out.println("gameID: " + gameID);

            query = "select username as \"Username\", ELO, weightedRank / gamesPlayed as \"Weighted Rank\" " +
                    "from Players " +
                    "where username not like \"%development%\" and " +
                    "gamesPlayed > 0 order by ELO desc;";
            resultSet = st.executeQuery(query);
            playersDatabase = "";
            while (resultSet.next()){
                String strPlayerUsername = resultSet.getString("Username");
                String strPlayerELO = Double.toString(Math.floor(resultSet.getFloat("ELO")));
                String strPlayerWeightedRank = String.format("%.2f", resultSet.getFloat("Weighted Rank"));

                playersDatabase += strPlayerUsername + strBreak + strPlayerELO + strBreak + strPlayerWeightedRank + strBreak + strEnd;
            }

                /*String[] tmpPlayerCount = playersDatabase.split(strEnd);
                System.out.println("Players gathered: " + tmpPlayerCount.length);*/

        }

        void setGameVariables(ResultSet resultSet) throws SQLException {
            gameID = resultSet.getString("gameID");
            division = Integer.toString(resultSet.getInt("division"));
            datePlayed = resultSet.getString("datePlayed");
            timePlayed = resultSet.getString("timePlayed");
            redName = resultSet.getString("redSnake");
            greenName = resultSet.getString("greenSnake");
            blueName = resultSet.getString("blueSnake");
            yellowName = resultSet.getString("yellowSnake");
            gameString = resultSet.getString("gameString");
        }

        String getNormalDate(){
            System.out.println("get normal data called");
            DateTimeFormatter inFormat = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate date = LocalDate.parse(datePlayed, inFormat);

            DateTimeFormatter outFormat = DateTimeFormatter.ofPattern("dd MMMM yyyy");
            return date.format(outFormat);
        }

        void makeArrayContainer(){
            System.out.println("Entered make array container, gameid: " + gameID);
            if (allGameIDs.size() != 0){
                String result = "";
                for (int i = 0; i < allGameIDs.size(); i++){
                    String ID = allGameIDs.get(i);
                    result += ID + ",";

                    if (ID.equals(gameID)){
                        prevGameID = (i != 0) ? Integer.parseInt(allGameIDs.get(i - 1)) : Integer.parseInt(ID);
                        nextGameId = (i != allGameIDs.size() - 1) ? Integer.parseInt(allGameIDs.get(i + 1)) : Integer.parseInt(ID);
                    }
                }
                strAllGameIDs = result;
            }
            else
            {
                strAllGameIDs = "";
                prevGameID = -1;
                nextGameId = -1;
            }
        }
    %>

    <div class="gameBox">
        <canvas id="board" width="500" height="500"></canvas><!--
                --><label id = "Timestamp" class = "heading1 odd">Timestamp: </label><!--
                --><label id = "lblDatePlayed" class = "heading2 odd">Date Played: </label><!--
                --><label id = "lblTimePlayed" class = "heading2 odd">Time Played: </label><br>

        <label id = "lblGameID" class = "name even">GameID: </label><!--
                --><label id = "lblBestLengthHeading" class = "data even">Max: </label><!--
                --><label id = "lblKillsHeading" class = "data even" >Kills: </label><!--
                --><label id = "lblDeathsHeading" class = "data even">Deaths: </label><!--
                --><label id = "lblLengthHeading" class = "data even">Length: </label><br>

        <label id = "firstPlace" class = "name">Red: </label><!--
                --><label id = "lblFirstPlaceBestLength" class = "data">:</label><!--
                --><label id = "lblFirstPlaceKills" class = "data">:</label><!--
                --><label id = "lblFirstPlaceDeaths" class = "data">:</label><!--
                --><label id = "lblFirstPlaceLength" class = "data">:</label><br>

        <label id = "secondPlace" class = "name">Second: </label><!--
                --><label id = "lblSecondPlaceBestLength" class = "data">:</label><!--
                --><label id = "lblSecondPlaceKills" class = "data">:</label><!--
                --><label id = "lblSecondPlaceDeaths" class = "data">:</label><!--
                --><label id = "lblSecondPlaceLength" class = "data">:</label><br>

        <label id = "thirdPlace" class = "name">Third: </label><!--
                --><label id = "lblThirdPlaceBestLength" class = "data">:</label><!--
                --><label id = "lblThirdPlaceKills" class = "data">:</label><!--
                --><label id = "lblThirdPlaceDeaths" class = "data">:</label><!--
                --><label id = "lblThirdPlaceLength" class = "data">:</label><br>

        <label id = "lastPlace" class = "name">Last: </label><!--
                --><label id = "lblLastPlaceBestLength" class = "data">:</label><!--
                --><label id = "lblLastPlaceKills" class = "data">:</label><!--
                --><label id = "lblLastPlaceDeaths" class = "data">:</label><!--
                --><label id = "lblLastPlaceLength" class = "data">:</label><br>
    </div>

    <div class="informationBox">
        <label id = "lblPlayBackHeading" class="wideHeading">Playback Controls</label>
        <br>
        <button id = "btnSkipRewind" class="btnPlayback">Skip Back</button><!--
             --><button id = "btnRewind" class="btnPlayback">Rewind</button><!--
             --><button id = "btnPausePlay" class="btnPlayback">Pause / Play</button><!--
             --><button id = "btnFastForward" class="btnPlayback">Fast forward</button><!--
             --><button id = "btnSkipForward" class="btnPlayback">Skip Forward</button>


        <div class="break"></div>

        <!---section for navigate games--->
        <label id = "lblGameControlHeading" class="wideHeading">Game Controls</label>
        <br>
        <label id = "lblNavigationHeading" class="halfHeading">Navigation</label><!--
             --><label id = "lblSelectGameHeading" class="halfHeading">Select Game</label>
        <br>
        <form action="PreviousGame.jsp" method="get">
            <button type="submit" class="btnNavigation">Prev Game</button>
        </form><!--
                    --><button id = "btnStopGames" class="btn btnNavigation" onclick="stopGame()">Stop Game</button><!--
            --><form action="NextGame.jsp" method="get">
        <button type="submit" class="btn btnNavigation">Next Game</button>
    </form>

        <!---section for select game--->
        <form action="SelectGame.jsp" method="get">
            <select name="cbbGames" id="cbbGames" class="comboBox"></select>
            <button type="submit" class="btn btnComboBox">Submit</button>
        </form>


        <div class="break"></div>


        <!---Section for games Table--->
        <label id = "lblGamesDatabaseHeading" class="wideHeading">All Games</label>
        <br>
        <div class="tableContainer">
            <table class="games" id="tblGames">
                <tr class="games">
                    <th class="normal">gameID</th>
                    <th class="normal">Round</th>
                    <th class="normal">division</th>
                    <th class="normal">datePlayed</th>
                    <th class="normal">timePlayed</th>
                    <th class="normal">redSnake</th>
                    <th class="normal">greenSnake</th>
                    <th class="normal">blueSnake</th>
                    <th class="normal">yellowSnake</th>
                </tr>
            </table>
        </div>

        <div class="break"></div>


        <!-- Section for Players and their ratings--->
        <label id = "lblPlayersDatabaseHeading" class="wideHeading">All Players (active)</label>
        <br>
        <div class="tableContainer">
            <table class="KTable" id="tblPlayers">
                <tr class="KTable">
                    <th class="normal">Username</th>
                    <th class="normal">ELO</th>
                    <th class="normal">Weighted Rank</th>
                </tr>
            </table>
        </div>


        <div class="break"></div>


        <form action="LayoutForm.jsp" method="get">
            <button type="submit" class="btn odd">Test</button>
        </form>

        <form action="ResultsPage.jsp" method="get">
            <button type="submit" class="btn odd">Results Page</button>
        </form>

    </div>

    <%
        Object object = session.getAttribute("gameID");
        if (object == null){
            currentGameID = -1;
            System.out.println("\nINDEX Null: " + -1);
        }
        else
        {
            System.out.println("Object: " + object);
            System.out.println("ObjectLength: " + object.toString());
            try{
                currentGameID = (Integer) object;
            }
            catch (Exception e){
                System.out.println("Flopped make current -1");
                currentGameID = -1;
            }
            System.out.println("\nINDEX NEW: " + currentGameID);
        }
        session.setAttribute("gameID", currentGameID);

        try {
            getNextGame();
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        session.setAttribute("gameID", gameID);
        session.setAttribute("previousGame", prevGameID);
        session.setAttribute("nextGame", nextGameId);

        System.out.println("Set gameID: " + gameID);
        System.out.println("Set prevGame: " + prevGameID);
        System.out.println("Set next: " + nextGameId);
    %>

    <script type="text/javascript" src="formController.js"></script>
    <script type="text/javascript" src="loadOptions.js"></script>
    <script type="text/javascript" src="loadGames.js"></script>
    <script type="text/javascript" src="loadPlayers.js"></script>

    <script>
        function outerCall(stats){
            alert("Outer call worked for stats: " + stats.length);
            for (let j in stats){
                alert(stats[j]);
            }
        }
        fillOptions("<%=strAllGameIDs%>");
        fillGames("<%=gamesDatabase%>");
        fillPlayers("<%=playersDatabase%>");
        console.log("Done getting game");
        console.log(<%=gameID%>);
        document.getElementById("lblGameID").textContent = "Game ID: " + "<%=gameID%>" + ", Division: " + "<%=division%>";
        document.getElementById("lblDatePlayed").textContent = /*"Date Played: " + */"<%=getNormalDate()%>";
        document.getElementById("lblTimePlayed").textContent = /*"Time Played: " + */"<%=timePlayed%>";
        setGame("<%=gameID%>", "<%=datePlayed%>", "<%=timePlayed%>", "<%=redName%>", "<%=greenName%>", "<%=blueName%>", "<%=yellowName%>", "<%=gameString%>");
    </script>

    </body>
    </html>