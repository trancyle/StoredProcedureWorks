--Stored Procedure to display all the bustops within 1Km from given Suburb.
CREATE PROCEDURE GeoDistance
(@Suburb nvarchar (255),
 @Distance nvarchar(255))
 AS
	BEGIN
		SET NOCOUNT ON;
		DECLARE @SubGeo GEOGRAPHY, @SubLat DECIMAL (9,6), @subLon DECIMAL (9,6);
		SELECT @subLat = [Lat],
				@subLon = [Lon]
		FROM [DimGeography] (NOLOCK)
		WHERE Suburb = @Suburb;

		SET @SubGeo = GEOGRAPHY :: Point (@SubLat, @SubLon, 4326);

		SELECT [StopName],
				[TransportationMode],
				[StopID],
				CASE WHEN [Latitude] IS NOT NULL AND [Longitude] IS NOT NULL THEN ROUND ((@SubGeo.STDistance(Geography::Point([Latitude],[Longitude], 4326))/1000),2) ELSE NULL 
				END AS [Distance (Km)]
				FROM DimTransportation (NOLOCK)
				WHERE (@subGeo.STDistance(geography::Point([Latitude],[Longitude], 4326))/1000) <=@distance
				ORDER BY [Distance (km)];
	END
GO

--Stored Procediure to display Crime rate within 1Km from given Suburb in a selected year
CREATE PROCEDURE GeoCrime
(@Suburb nvarchar (255),
 @Distance nvarchar(255),
 @Year nvarchar(255))
 AS
	BEGIN
		SET NOCOUNT ON;
		DECLARE @SubGeo GEOGRAPHY, @SubLat DECIMAL (9,6), @subLon DECIMAL (9,6);
		SELECT @subLat = [Lat],
				@subLon = [Lon]
		FROM [DimGeography] (NOLOCK)
		WHERE Suburb = @Suburb;

		SET @SubGeo = GEOGRAPHY :: Point (@SubLat, @SubLon, 4326);
		
				
		SELECT [CrimeType],
				COUNT([NumberOfOffence]) AS NumberOfOffence,
				[City],
				[Suburb],
				Cast(Datepart(YEAR,year) AS nvarchar(255)) AS ReportedYear,
				Cast(Datepart(MONTH,year) AS nvarchar(255)) AS ReportedMonth,
				CASE WHEN [Latitude] IS NOT NULL AND [Longitude] IS NOT NULL THEN ROUND ((@SubGeo.STDistance(Geography::Point([Latitude],[Longitude], 4326))/1000),2) ELSE NULL 
				END AS [Distance]
				FROM Fact_CrimeByYear (NOLOCK)
				INNER JOIN DimGeography ON Fact_CrimeByYear.GeographyID = DimGeography.GeographyKey
				WHERE ((@subGeo.STDistance(geography::Point([Latitude],[Longitude], 4326))/1000) <= @distance) AND Cast(Datepart(YEAR,year) AS nvarchar(255)) = @Year
				GROUP BY Fact_CrimeByYear.CrimeType, DimGeography.Suburb, DimGeography.City,Fact_CrimeByYear.NumberOfOffence, Latitude, Longitude, Cast(Datepart(YEAR,Year) AS nvarchar(255)), Cast(Datepart(MONTH,year) AS nvarchar(255))
				ORDER BY [Distance], Cast(Datepart(MONTH,year) AS nvarchar(255)), CrimeType
	END
GO

