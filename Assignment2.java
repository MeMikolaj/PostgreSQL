import java.sql.*;

public class Assignment2 {


	public Connection connection;


	public Assignment2() throws  ClassNotFoundException {
		Class.forName("org.postgresql.Driver");
	}


	public boolean connectDB(String URL, String username, String password) {
		try{
			Properties props = new Properties();
			props.setProperty("user",username);
			props.setProperty("password",password);
			props.setProperty("ssl","true");
			connection = DriverManager.getConnection(URL, props);
			return true;
		}
		catch(Exception e){
			return false;
			//throw new RuntimeException("Function Not Implemented");
		}
	}


	public boolean disconnectDB() {
		try{
			connection.close();
			return true;
		} catch(Exception e){
			return false;
		}
	}


	public boolean insertPlayer(int id, String playerName, String email, String countryCode) {
		try{
			int i = 0; //counter if everything is unique
			Statement stmt = connection.createStatement();
			ResultSet rs   = stmt.executeQuery(“SELECT id FROM Player”);
			while (rs.next()){
				if (rs == id)
					i++;
			}
			rs.close();

			Statement stmt = connection.createStatement();
			ResultSet rs   = stmt.executeQuery(“SELECT playername FROM Player”);
			while (rs.next()){
				if (rs == playerName)
					i++;
			}
			rs.close();

			Statement stmt = connection.createStatement();
			ResultSet rs   = stmt.executeQuery(“SELECT email FROM Player”);
			while (rs.next()){
				if (rs == email)
					i++;
			}
			rs.close();

			if(countryCode.length != 3)
				i++;

			for(int j=0; j<3; j++){
				char john = countryCode.charAt(j);

				if(!isUpperCase(john))
					i++;
			}

			if(i == 0){

				PreparedStatement pStmt = connection.prepareStatement("INSERT INTO Player values(?,?,?,?,?,?,?,?,?,?)");
				pStmt.setInt(1, id);
				pStmt.setString(2, playerName);
				pStmt.setString(3, email);
				pStmt.setString(4, countryCode);
				pStmt.executeUpdate();

				stmt.close();
				return true;
			} 
			else {
				stmt.close();
				return false;
			}

			stmt.close();
			return true;
		} catch(Exception e){
			return false;
		}
	}


	public int getMembersCount(int gid) {
		try{
			Statement stmt = connection.createStatement();
			ResultSet rs   = stmt.executeQuery(“SELECT COUNT(id) AS number, guild FROM Player WHERE Player.guild = gid GROUP BY guild”);
			while (rs.next()){
				int num = rs.getInt("number");
			}
			rs.close();
			stmt.close();
			return num;
		} catch(Exception e){
			return(-1);
		}
	}


	public String getPlayerInfo(int id) {
		try{
			String answer     = "Have a good day";
			int differentName = id;
			Statement stmt    = connection.createStatement();
			ResultSet rs      = stmt.executeQuery(“SELECT * FROM Player WHERE Player.id = differentName”);
			if(rs.next() != NULL){
				int idd             = rs.getInt("id");
				String playername   = rs.getString("playername");
       			String email        = rs.getString("email");
        		String country_code = rs.getString("country_code");
       			int coins           = rs.getInt("coins");
       			int rolls           = rs.getInt("rolls");
       			int wins            = rs.getInt("wins");
       			int losses          = rs.getInt("losses");
       			int total_battles   = rs.getInt("total_battles");
       			int guild           = rs.getInt("guild");
       			answer = idd +":"+playername+":"+email+":"+country_code+":"+coins+":"+rolls+":"+wins+":"+losses+":"+total_battles+":"+guild;
			} else{
				answer = "";
			}
			rs.close();
			stmt.close();
			return answer;
		} catch(Exception e){
			return(-1);
		}
	}


	public boolean changeGuild(String oldName, String newName) {
		try{
			if(oldName == "" || newName == ""){
				return false;
			} else {
				Statement stmt = connection.createStatement();
				stmt.executeUpdate("UPDATE Guild SET guildname = newName WHERE guildname = oldName");
				stmt.close();
			}
			return true;
		}catch(Exception e){
			return false;
		}
	}


	public boolean deleteGuild(String guildName) {
		try{
			String hold    = guildName;
			Statement stmt = connection.createStatement();
			stmt.executeUpdate("DELETE FROM Guild WHERE guildname = hold");
			stmt.close();
			return true;
		}catch(Exception e){
			return false;
		}
	}


	public String listAllTimePlayerRatings() {
		try{
			String answer  = "";
			Statement stmt = connection.createStatement();
			ResultSet rs   = stmt.executeQuery(“SELECT Player.playername, Frank.all_time_rating FROM Player, (SELECT id, all_time_rating FROM PlayerRatings WHERE PlayerRatings.year = (SELECT George.last_year FROM (SELECT DISTINCT PlayerRatings.year AS last_year, MAX(PlayerRatings.month) AS last_month FROM PlayerRatings GROUP BY PlayerRatings.year HAVING PlayerRatings.year = MAX(PlayerRatings.year))George) AND PlayerRatings.month = (SELECT George.last_month FROM (SELECT DISTINCT PlayerRatings.year AS last_year, MAX(PlayerRatings.month) AS last_month FROM PlayerRatings GROUP BY PlayerRatings.year HAVING PlayerRatings.year = MAX(PlayerRatings.year))George))Frank ORDER BY all_time_rating DESC”);
			while (rs.next()){
				String pname   = rs.getString("playername");
        		String prating = rs.getString("all_time_rating");
        		answer+= (pname + ":" + prating + ":"); 
			}
			rs.close();
			stmt.close();
			return answer;

		}catch(Exception e){
			return("Didn't work out");
		}
	}


	public boolean updateMonthlyRatings() {
		try{
			int serial_id  = 0;
			Statement stmt = connection.createStatement();
			ResultSet rs   = stmt.executeQuery(“SELECT MAX(id) AS num FROM PlayerRatings”);
			while(rs.next()){
				serial_id = 1 + rs.getInt("num");
			}
			rs.close();

			ResultSet rs = stmt.executeQuery(“SELECT * FROM PlayerRatings WHERE PlayerRatings.month = (SELECT last_month FROM (SELECT DISTINCT PlayerRatings.year AS last_year, MAX(PlayerRatings.month) AS last_month FROM PlayerRatings GROUP BY PlayerRatings.year HAVING PlayerRatings.year = MAX(PlayerRatings.year)) Joe) AND PlayerRatings.year = (SELECT last_year FROM (SELECT DISTINCT PlayerRatings.year AS last_year, MAX(PlayerRatings.month) AS last_month FROM PlayerRatings GROUP BY PlayerRatings.year HAVING PlayerRatings.year = MAX(PlayerRatings.year)) Ben)”);
			while(rs.next()){
				int p_id            = rs.getInt("p_id");
				int monthly_rating  = rs.getInt("monthly_rating");
				int all_time_rating = rs.getInt("all_time_rating");

				int new_monthly = int(monthly_rating* 0.1);
				int new_alltime = int(all_time_rating* 0.1);

       			PreparedStatement pStmt = connection.prepareStatement("INSERT INTO PlayerRatings values(?,?,?,?,?,?)");
				pStmt.setInt(1, serial_id);
				pStmt.setInt(2, p_id);
				pStmt.setInt(3, 10);
				pStmt.setInt(4, 2021);
				pStmt.setInt(5, new_monthly);
				pStmt.setInt(6, new_alltime);
				pStmt.executeUpdate();
				serial_id++;
			} 
			rs.close();

			ResultSet rs = stmt.executeQuery(“SELECT p_id FROM PlayerRatings WHERE p_id NOT IN (SELECT p_id FROM PlayerRatings WHERE PlayerRatings.month = (SELECT last_month FROM (SELECT DISTINCT PlayerRatings.year AS last_year, MAX(PlayerRatings.month) AS last_month FROM PlayerRatings GROUP BY PlayerRatings.year HAVING PlayerRatings.year = MAX(PlayerRatings.year)) Joe) AND PlayerRatings.year = (SELECT last_year FROM (SELECT DISTINCT PlayerRatings.year AS last_year, MAX(PlayerRatings.month) AS last_month FROM PlayerRatings GROUP BY PlayerRatings.year HAVING PlayerRatings.year = MAX(PlayerRatings.year)) Ben))”);
			while(rs.next()){
				int p_id = rs.getInt("p_id");

       			PreparedStatement pStmt = connection.prepareStatement("INSERT INTO PlayerRatings values(?,?,?,?,?,?)");
				pStmt.setInt(1, serial_id);
				pStmt.setInt(2, p_id);
				pStmt.setInt(3, 10);
				pStmt.setInt(4, 2021);
				pStmt.setInt(5, 1000);
				pStmt.setInt(6, 1000);
				pStmt.executeUpdate();
				serial_id++;
			} 
			rs.close();

			int serial_guild_id = 0;
			ResultSet rs        = stmt.executeQuery(“SELECT MAX(id) AS numb FROM GuildRatings”);
			while(rs.next()){
				serial_guild_id = 1 + rs.getInt("numb");
			}
			rs.close();

			ResultSet rs = stmt.executeQuery(“SELECT * FROM GuildRatings WHERE GuildRatings.month = (SELECT last_month FROM (SELECT DISTINCT GuildRatings.year AS last_year, MAX(GuildRatings.month) AS last_month FROM GuildRatings GROUP BY GuildRatings.year HAVING GuildRatings.year = MAX(GuildRatings.year)) Joe) AND GuildRatings.year = (SELECT last_year FROM (SELECT DISTINCT GuildRatings.year AS last_year, MAX(GuildRatings.month) AS last_month FROM GuildRatings GROUP BY GuildRatings.year HAVING GuildRatings.year = MAX(GuildRatings.year)) Ben)”);
			while(rs.next()){
				int g_id            = rs.getInt("g_id");
				int monthly_rating  = rs.getInt("monthly_rating");
				int all_time_rating = rs.getInt("all_time_rating");

				int new_monthly = (int)(monthly_rating* 0.1);
				int new_alltime = (int)(all_time_rating* 0.1);

       			PreparedStatement pStmt = connection.prepareStatement("INSERT INTO GuildRatings values(?,?,?,?,?,?)");
				pStmt.setInt(1, serial_guild_id);
				pStmt.setInt(2, g_id);
				pStmt.setInt(3, 10);
				pStmt.setInt(4, 2021);
				pStmt.setInt(5, new_monthly);
				pStmt.setInt(6, new_alltime);
				pStmt.executeUpdate();
				serial_guild_id++;
			} 
			rs.close();

			ResultSet rs = stmt.executeQuery(“SELECT g_id FROM GuildRatings WHERE g_id NOT IN (SELECT g_id FROM GuildRatings WHERE GuildRatings.month = (SELECT last_month FROM (SELECT DISTINCT GuildRatings.year AS last_year, MAX(GuildRatings.month) AS last_month FROM GuildRatings GROUP BY GuildRatings.year HAVING GuildRatings.year = MAX(GuildRatings.year)) Joe) AND GuildRatings.year = (SELECT last_year FROM (SELECT DISTINCT GuildRatings.year AS last_year, MAX(GuildRatings.month) AS last_month FROM GuildRatings GROUP BY GuildRatings.year HAVING GuildRatings.year = MAX(GuildRatings.year)) Ben))”);
			while(rs.next()){
				int g_id = rs.getInt("g_id");

       			PreparedStatement pStmt = connection.prepareStatement("INSERT INTO GuildRatings values(?,?,?,?,?,?)");
				pStmt.setInt(1, serial_guild_id);
				pStmt.setInt(2, g_id);
				pStmt.setInt(3, 10);
				pStmt.setInt(4, 2021);
				pStmt.setInt(5, 1000);
				pStmt.setInt(6, 1000);
				pStmt.executeUpdate();
				serial_guild_id++;
			} 
			rs.close();

			stmt.close();
			return true;
		} catch(Exception e){
			return(false);
		}
	}


	public boolean createSquidTable() {
		try{
			Statement stmt = connection.createStatement();
			String sql = "CREATE squidNation " +
                   "(id INTEGER not NULL, " +
                   " playername VARCHAR, " + 
                   " email VARCHAR, " + 
                   " coins INTEGER, " + 
                   " rolls INTEGER, " +
                   " wins INTEGER, " +
                   " losses INTEGER, " +
                   " total_battles INTEGER, " +
                   " PRIMARY KEY (id))";
         	stmt.executeUpdate(sql);

			ResultSet rs = stmt.executeQuery(“SELECT Player.id, Player.playername, Player.email, Player.coins, Player.rolls, Player.wins, Player.losses, Player.total_battles FROM Player, Guild WHERE Player.guild = Guild.id AND Guild.guildname = 'Squid Game' AND Player.country_code = 'KOR' ORDER BY Player.id ASC”);
			while(rs.next()){
				int id            = rs.getInt("id");
				String playername = rs.getString("playername");
				String email      = rs.getString("email");
				int coins         = rs.getInt("coins");
				int rolls         = rs.getInt("rolls");
				int wins          = rs.getInt("wins");
				int losses        = rs.getInt("losses");
				int total_battles = rs.getInt("total_battles");

       			PreparedStatement pStmt = connection.prepareStatement("INSERT INTO squidNation values(?,?,?,?,?,?,?,?)");
				pStmt.setInt(1, id);
				pStmt.setString(2, playername);
				pStmt.setString(3, email);
				pStmt.setInt(4, coins);
				pStmt.setInt(5, rolls);
				pStmt.setInt(6, wins);
				pStmt.setInt(7, losses);
				pStmt.setInt(8, total_battles);
				pStmt.executeUpdate();
			} 
			rs.close();
			stmt.close();
			return true;
		} catch(Exception e){
			return false;
		}

	}
	
	
	public boolean deleteSquidTable() {
		try{
			Statement stmt = connection.createStatement();
			String sql = "DROP TABLE squidNation";
			stmt.executeUpdate(sql);
			stmt.close();
			return true;
		}catch(Exception e){
			return false;
		}
	}
}
