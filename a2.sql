SET search_path TO A2;

-- If you define any views for a question (you are encouraged to), you must drop them
-- after you have populated the answer table for that question.
-- Good Luck!

-- Query 1 --------------------------------------------------

/* 
Players who are a whale

subquery - Players and number of months they were active
*/
CREATE VIEW Whales AS
SELECT Player.id
FROM Player, 
	(SELECT p_id, COUNT(month) AS months_active
	FROM PlayerRatings
	GROUP BY p_id) Active
WHERE Player.id = Active.p_id AND Active.months_active > 0 AND Player.rolls/Active.months_active >= 100;


/* Players who are a lucky */
CREATE VIEW Luckies AS
SELECT Player.id
FROM Player,
	(SELECT p_id, count(rarity) AS rarity5
	FROM LilmonInventory, Lilmon
	WHERE LilmonInventory.l_id = Lilmon.id AND Lilmon.rarity = 5
	GROUP BY p_id) Rarer
WHERE Player.id = Rarer.p_id AND Player.rolls >= 0 AND Rarer.rarity5/Player.rolls >= 0.05;


/* Players who are hoarder */
CREATE VIEW Hoarders AS
SELECT Player.id
FROM Player, 
	(SELECT p_id, COUNT(month) AS months_active
	FROM PlayerRatings
	GROUP BY p_id) Active
WHERE Player.id = Active.p_id AND Active.months_active > 0 AND Player.coins/Active.months_active >= 10000;

/* All classes together */
INSERT INTO Query1
(SELECT Player.id AS p_id, Player.playername, Player.email, CONCAT(Species.class1, Species.class2, Species.class3) AS classification
FROM Player,
	(SELECT Player.id,
	CASE 
		WHEN Player.id IN (SELECT Whales.id FROM Whales) THEN 'whale-'
		ELSE '-'
	END AS class1,
	CASE 
		WHEN Player.id IN (SELECT Luckies.id FROM Luckies) THEN 'lucky-'
		ELSE '-'
	END AS class2,
	CASE 
		WHEN Player.id IN (SELECT Hoarders.id FROM Hoarders) THEN 'hoarder'
		ELSE NULL
	END AS class3
	FROM Player, Whales, Luckies, Hoarders) Species
WHERE Player.id = Species.id
GROUP BY p_id, Player.playername, Player.email, Species.class1, Species.class2, Species.class3
ORDER BY p_id ASC);


DROP VIEW Whales;
DROP VIEW Luckies;
DROP VIEW Hoarders;

-- Query 2 --------------------------------------------------
CREATE VIEW DistinctElements AS
SELECT DISTINCT LilmonInventory.p_id, element
FROM LilmonInventory, 
(SELECT id, element1 as element
FROM Lilmon

UNION

SELECT id, element2 AS element
FROM Lilmon
WHERE element2 IS NOT NULL) ElementsTable
WHERE LilmonInventory.l_id = ElementsTable.id;

INSERT INTO Query2
(SELECT element, COUNT(p_id) AS popularity_count
FROM DistinctElements
GROUP BY element
ORDER BY popularity_count DESC);

DROP VIEW DistinctElements;



-- Query 3 --------------------------------------------------

CREATE VIEW Answer3 AS
SELECT Player.id, ((Player.total_battles - Player.wins - Player.losses)/MonthsActive.months_active) AS avg_games
FROM Player,
	(SELECT p_id, 
	CASE 
		WHEN COUNT(month) = 0 THEN 1
		ELSE COUNT(month) 
	END AS months_active
	FROM PlayerRatings
	GROUP BY p_id) MonthsActive
WHERE Player.id = MonthsActive.p_id;


INSERT INTO Query3
(SELECT AVG(CAST(Answer3.avg_games AS REAL)) AS avg_ig_per_month_per_player
FROM Answer3);

DROP VIEW Answer3;

-- Query 4 --------------------------------------------------


CREATE VIEW Populares AS
SELECT l_id, COUNT(p_id) AS popularity_count
FROM (SELECT DISTINCT l_id, p_id
	  FROM LilmonInventory
	  WHERE in_team = TRUE OR fav = TRUE) LilPlayer
GROUP BY l_id;


INSERT INTO Query4
(SELECT id, name, rarity, popularity_count
FROM Lilmon, Populares
WHERE Lilmon.id = Populares.l_id
ORDER BY popularity_count DESC, rarity DESC, id DESC);

DROP VIEW Populares;

-- Query 5 --------------------------------------------------

/* Last month and year */
CREATE VIEW LastDate AS
SELECT DISTINCT PlayerRatings.year AS last_year, MAX(PlayerRatings.month) AS last_month
FROM PlayerRatings
GROUP BY PlayerRatings.year
HAVING PlayerRatings.year = MAX(PlayerRatings.year);

CREATE VIEW RankInfo AS
SELECT p_id, MIN(monthly_rating) AS low_rat, MAX(monthly_rating) AS high_rat, COUNT(monthly_rating) AS is_six, MAX(all_time_rating) AS all_time
FROM PlayerRatings
WHERE PlayerRatings.year = 
			 CASE
		 		WHEN (SELECT LastDate.last_month FROM LastDate) > 6  THEN (SELECT LastDate.last_year FROM LastDate)
		 		ELSE (SELECT LastDate.last_year FROM LastDate) - 1
		 	 END
		 	 AND (PlayerRatings.month = 
		 	 CASE
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) > 6  THEN ((SELECT LastDate.last_month FROM LastDate)-6)
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 6  THEN 1
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 5  THEN 1
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 4  THEN 1
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 3  THEN 1
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 2  THEN 1
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 1  THEN 7
		 		ELSE 0
		 	 END OR PlayerRatings.month = 
		 	 CASE
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) > 6  THEN ((SELECT LastDate.last_month FROM LastDate)-5)
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 6  THEN 2
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 5  THEN 2
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 4  THEN 2
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 3  THEN 2
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 2  THEN 8
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 1  THEN 8
		 		ELSE 0
		 	 END OR PlayerRatings.month = 
		 	 CASE
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) > 6  THEN ((SELECT LastDate.last_month FROM LastDate)-4)
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 6  THEN 3
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 5  THEN 3
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 4  THEN 3
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 3  THEN 9
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 2  THEN 9
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 1  THEN 9
		 		ELSE 0
		 	 END OR PlayerRatings.month = 
		 	 CASE
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) > 6  THEN ((SELECT LastDate.last_month FROM LastDate)-3)
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 6  THEN 4
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 5  THEN 4
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 4  THEN 10
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 3  THEN 10
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 2  THEN 10
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 1  THEN 10
		 		ELSE 0
		 	 END OR PlayerRatings.month = 
		 	 CASE
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) > 6  THEN ((SELECT LastDate.last_month FROM LastDate)-2)
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 6  THEN 5
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 5  THEN 11
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 4  THEN 11
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 3  THEN 11
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 2  THEN 11
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 1  THEN 11
		 		ELSE 0
		 	 END OR PlayerRatings.month = 
		 	 CASE
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) > 6  THEN ((SELECT LastDate.last_month FROM LastDate)-1)
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 6  THEN 12
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 5  THEN 12
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 4  THEN 12
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 3  THEN 12
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 2  THEN 12
		 	 	WHEN (SELECT LastDate.last_month FROM LastDate) = 1  THEN 12
		 		ELSE 0
		 	 END)
GROUP BY p_id;


INSERT INTO Query5
(SELECT RankInfo.p_id, Player.playername, Player.email, RankInfo.low_rat AS min_mr, RankInfo.high_rat AS max_mr
FROM Player, RankInfo
WHERE Player.id = RankInfo.p_id
GROUP BY RankInfo.p_id, Player.playername, Player.email, RankInfo.low_rat, RankInfo.high_rat, RankInfo.is_six, RankInfo.all_time, Player.country_code
HAVING RankInfo.is_six = 6 AND RankInfo.all_time >= 2000 AND RankInfo.high_rat - RankInfo.low_rat <=50 AND Player.country_code IN ('USA', 'CAN', 'MEX')
ORDER BY max_mr DESC, min_mr DESC, p_id ASC);


DROP VIEW LastDate CASCADE;

-- Query 6 --------------------------------------------------

/* Last month and year */
CREATE VIEW LastDate AS
SELECT GuildRatings.year AS last_year, MAX(GuildRatings.month) AS last_month
FROM GuildRatings
GROUP BY GuildRatings.year
HAVING GuildRatings.year = MAX(GuildRatings.year);

/* Classified */
CREATE VIEW GuildClass AS
SELECT Guild.id, 
	CASE
		WHEN COUNT(Player.id) >= 500 THEN 'large'
		WHEN COUNT(Player.id) >= 100 AND COUNT(Player.id) <= 499 THEN 'medium'
		ELSE 'small'
	END AS classification
FROM Guild, Player
WHERE Guild.id = Player.guild
GROUP BY Guild.id;

/* True if played last month and False otherwise */
CREATE VIEW PlayedMissed AS
(SELECT GuildRatings.g_id, TRUE AS played 
FROM LastDate, GuildRatings
WHERE LastDate.last_month = GuildRatings.month AND LastDate.last_year = GuildRatings.year

UNION

SELECT GuildRatings.g_id, FALSE as played
FROM GuildRatings
WHERE GuildRatings.g_id NOT IN 
	(SELECT GuildRatings.g_id 
	FROM LastDate, GuildRatings
	WHERE LastDate.last_month = GuildRatings.month AND LastDate.last_year = GuildRatings.year));


CREATE VIEW WithSize AS
SELECT GuildRatings.g_id, GuildClass.classification,
	CASE
		WHEN GuildClass.classification = 'large' AND GuildRatings.monthly_rating >=2000 THEN 'elite'
		WHEN GuildClass.classification = 'large' AND GuildRatings.monthly_rating >=1500 AND GuildRatings.monthly_rating<2000 THEN 'average'
		WHEN GuildClass.classification = 'large' AND GuildRatings.monthly_rating <1500 THEN 'casual'
		WHEN GuildClass.classification = 'medium' AND GuildRatings.monthly_rating >=1750 THEN 'elite'
		WHEN GuildClass.classification = 'medium' AND GuildRatings.monthly_rating >=1250 AND GuildRatings.monthly_rating<1750 THEN 'average'
		WHEN GuildClass.classification = 'medium' AND GuildRatings.monthly_rating <1250 THEN 'casual'
		WHEN GuildClass.classification = 'small' AND GuildRatings.monthly_rating >=1500 THEN 'elite'
		WHEN GuildClass.classification = 'small' AND GuildRatings.monthly_rating >=1000 AND GuildRatings.monthly_rating<1500 THEN 'average'
		WHEN GuildClass.classification = 'small' AND GuildRatings.monthly_rating <1000 THEN 'casual'
		Else 'error'
	END AS size
FROM GuildRatings, GuildClass, LastDate
WHERE GuildRatings.g_id = GuildClass.id AND GuildRatings.month = LastDate.last_month AND GuildRatings.year = LastDate.last_year;

CREATE VIEW NewSize AS
SELECT GuildRatings.g_id, GuildClass.classification, 'new' AS size
FROM GuildRatings, GuildClass
WHERE GuildRatings.g_id = GuildClass.id AND GuildRatings.g_id NOT IN (SELECT WithSize.g_id FROM WithSize);

CREATE VIEW Sizes AS
(SELECT * FROM WithSize
UNION
SELECT * FROM NewSize);

INSERT INTO Query6
(SELECT Sizes.g_id, Guild.guildname, Guild.tag, Player.id AS leader_id, Player.playername AS leader_name, Player.country_code AS leader_country, Sizes.size, Sizes.classification
FROM Guild, Player, Sizes
WHERE Guild.leader = Player.id AND Sizes.g_id = Guild.id AND Sizes.g_id = Player.guild
ORDER BY Sizes.g_id ASC);




DROP VIEW Sizes CASCADE;
DROP VIEW WithSize CASCADE;
DROP VIEW PlayedMissed CASCADE;
DROP VIEW GuildClass CASCADE;
DROP VIEW LastDate CASCADE;

-- Query 7 --------------------------------------------------

INSERT INTO Query7
(SELECT country_code, AVG(months_active) AS player_retention
FROM Player,
	(SELECT p_id, COUNT(month) AS months_active
	FROM PlayerRatings
	GROUP BY p_id) Active
WHERE Player.id = Active.p_id AND Active.months_active > 0
GROUP BY country_code
ORDER BY player_retention DESC);


-- Query 8 --------------------------------------------------

CREATE VIEW PlayerWr AS
SELECT Player.id, (Player.wins/(Player.wins + Player.losses)) AS player_wr, Player.guild
FROM Player;

CREATE VIEW GuildWr AS
SELECT PlayerWR.guild, (SUM(PlayerWR.player_wr)/COUNT(PlayerWR.id)) AS guild_aggregate_wr
FROM PlayerWR
GROUP BY PlayerWR.guild;


INSERT INTO Query8
(SELECT Player.id AS p_id, Player.playername, PlayerWr.player_wr, Guild.id AS g_id, Guild.guildname, Guild.tag, GuildWr.guild_aggregate_wr
FROM PlayerWr, GuildWr, Player, Guild
WHERE PlayerWr.id = Player.id AND PlayerWr.guild = GuildWr.guild AND GuildWr.guild = Guild.id
ORDER BY PlayerWr.player_wr DESC, GuildWr.guild_aggregate_wr DESC);

DROP VIEW PlayerWr CASCADE;

-- Query 9 --------------------------------------------------


/* Last month and year */
CREATE VIEW LastDate AS
SELECT GuildRatings.year AS last_year, MAX(GuildRatings.month) AS last_month
FROM GuildRatings
GROUP BY GuildRatings.year
HAVING GuildRatings.year = MAX(GuildRatings.year);

/* Top 10 guilds */
CREATE VIEW TopGuilds AS
SELECT DISTINCT GuildRatings.g_id, GuildRatings.monthly_rating, GuildRatings.all_time_rating
FROM GuildRatings
WHERE GuildRatings.month IN (SELECT LastDate.last_month FROM LastDate) AND GuildRatings.year IN (SELECT LastDate.last_year FROM LastDate)
ORDER BY GuildRatings.all_time_rating DESC, GuildRatings.monthly_rating DESC, GuildRatings.g_id
LIMIT 10;


INSERT INTO Query9
(SELECT MembersNum.g_id, Guild.guildname, TopGuilds.monthly_rating, TopGuilds.all_time_rating, MaxCountry.country_pcount, MembersNum.total_pcount, MaxCountry.country_code
FROM Guild, TopGuilds, (SELECT TopGuilds.g_id, COUNT(Player.id) AS total_pcount 
						FROM Player, TopGuilds
						WHERE Player.guild = TopGuilds.g_id
						GROUP BY TopGuilds.g_id) MembersNum, (SELECT DISTINCT TopGuilds.g_id, MAX(Johnny.country_count_almost) AS country_pcount, Player.country_code
																FROM Player, TopGuilds, (SELECT DISTINCT TopGuilds.g_id, COUNT(Player.country_code) AS country_count_almost, Player.country_code
																						FROM Player, TopGuilds
																						WHERE Player.guild = TopGuilds.g_id
																						GROUP BY TopGuilds.g_id, Player.country_code) Johnny
																WHERE Player.guild = TopGuilds.g_id AND Johnny.g_id = TopGuilds.g_id
																GROUP BY TopGuilds.g_id, Player.country_code) MaxCountry
WHERE Guild.id = MembersNum.g_id AND Guild.id = MaxCountry.g_id AND Guild.id = TopGuilds.g_id
ORDER BY TopGuilds.all_time_rating DESC, TopGuilds.monthly_rating DESC, MembersNum.g_id);


DROP VIEW TopGuilds;
DROP VIEW LastDate;

-- Query 10 --------------------------------------------------

INSERT INTO Query10
(SELECT Guild.id AS g_id, Guild.guildname, AVG(Active.months_active) AS avg_veteranness
FROM Player, Guild,
(SELECT PlayerRatings.p_id, COUNT(PlayerRatings.month) AS months_active
	FROM PlayerRatings
	GROUP BY p_id) Active
WHERE Player.id = Active.p_id AND Player.guild = Guild.id
GROUP BY g_id, Guild.guildname
ORDER BY avg_veteranness DESC, g_id ASC);



