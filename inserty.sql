-- inserty
insert into dbo.RentalCarsTypes(typeID,name) values(1,'Ciężarowy');
insert into dbo.RentalCarsTypes(typeID,name) values(2,'Sedan');
insert into dbo.RentalCarsTypes(typeID,name) values(3,'Harchback');
insert into dbo.RentalCarsTypes(typeID,name) values(4,'Kobi');

insert into dbo.RentalCarsMake(makeID,name) values(1,'audi');
insert into dbo.RentalCarsMake(makeID,name) values(2,'bmw');
insert into dbo.RentalCarsMake(makeID,name) values(3,'fiat');
insert into dbo.RentalCarsMake(makeID,name) values(4,'seat');

insert into dbo.RentalCarsMakeModel(modelID,name,makeID) values(1,'A1',1);
insert into dbo.RentalCarsMakeModel(modelID,name,makeID) values(2,'A3',1);
insert into dbo.RentalCarsMakeModel(modelID,name,makeID) values(3,'A4',1);
insert into dbo.RentalCarsMakeModel(modelID,name,makeID) values(4,'A5',1);

insert into dbo.RentalCars(register,modelID,engine,autotransmission,ac,typeID) values('BIA70B8',2,1.9,1,0,3);
insert into dbo.RentalCars(register,modelID,engine,autotransmission,ac,typeID) values('BI001',3,3.0,0,1,4);

select c.carID, c.register, c.engine, c.price, c.autotransmission, t.name, m.name, mm.name from RentalCars c
join RentalCarsTypes t on t.typeID = c.typeID
join RentalCarsMakeModel mm on mm.modelID = c.modelID
join RentalCarsMake m on m.makeID = mm.makeID;

DBCC CHECKIDENT ('nazwa_tabeli', RESEED, 0)



CREATE TABLE [dbo].[RentalCars](
	[carID] [int] IDENTITY(1,1) NOT NULL,
	[register] [nchar](10) NULL,
	[modelID] [int] NULL,
	[engine] [float] NULL,
	[price] [nchar](10) NULL,
	[autotransmission] [bit] NULL,
	[ac] [bit] NULL,
	[typeID] [int] NULL,
	[available] [bit] NULL,
 CONSTRAINT [PK_RentalCars] PRIMARY KEY CLUSTERED 
(
	[carID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RentalCars]  WITH CHECK ADD  CONSTRAINT [FK_RentalCars_RentalCarsMakeModel] FOREIGN KEY([modelID])
REFERENCES [dbo].[RentalCarsMakeModel] ([modelID])
GO

ALTER TABLE [dbo].[RentalCars] CHECK CONSTRAINT [FK_RentalCars_RentalCarsMakeModel]
GO

ALTER TABLE [dbo].[RentalCars]  WITH CHECK ADD  CONSTRAINT [FK_RentalCars_RentalCarsTypes] FOREIGN KEY([typeID])
REFERENCES [dbo].[RentalCarsTypes] ([typeID])
GO

ALTER TABLE [dbo].[RentalCars] CHECK CONSTRAINT [FK_RentalCars_RentalCarsTypes]
GO

-- 
CREATE TABLE [dbo].[RentalCarsMake](
	[makeID] [int] NOT NULL,
	[name] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_RentalCarsMake] PRIMARY KEY CLUSTERED 
(
	[makeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

--
CREATE TABLE [dbo].[RentalCarsMakeModel](
	[modelID] [int] NOT NULL,
	[name] [nvarchar](70) NULL,
	[makeID] [int] NOT NULL,
 CONSTRAINT [PK_RentalCarsMakeModel] PRIMARY KEY CLUSTERED 
(
	[modelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RentalCarsMakeModel]  WITH CHECK ADD  CONSTRAINT [FK_RentalCarsMakeModel_RentalCarsMake] FOREIGN KEY([makeID])
REFERENCES [dbo].[RentalCarsMake] ([makeID])
GO

ALTER TABLE [dbo].[RentalCarsMakeModel] CHECK CONSTRAINT [FK_RentalCarsMakeModel_RentalCarsMake]
GO


--

USE [RentalDB]
GO

/****** Object:  Table [dbo].[RentalCarsTypes]    Script Date: 2016-06-25 18:07:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RentalCarsTypes](
	[typeID] [int] NOT NULL,
	[name] [nchar](10) NULL,
 CONSTRAINT [PK_RentalCarsTypes] PRIMARY KEY CLUSTERED 
(
	[typeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

--
CREATE TABLE [dbo].[RentalUsers](
	[userID] [int] NOT NULL,
	[login] [nvarchar](50) NULL,
	[password] [nvarchar](50) NULL,
	[isAdmin] [bit] NULL,
	[isActive] [bit] NULL
) ON [PRIMARY]

GO
--

USE [RentalDB]
GO
/****** Object:  StoredProcedure [dbo].[procRentalAddReservation]    Script Date: 2016-06-25 18:09:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Author:		Kamil Zerrouki
-- Create date: 24.06.2016
-- Description:	Tworzenie rezerwacji

ALTER PROCEDURE [dbo].[procRentalAddReservation] @begin_date date = null, @end_date date, @total_price float,
					@client_name nvarchar(50), @client_surname nvarchar(50),
					@client_pesel nvarchar(11), @client_adress nvarchar(100),
					@client_phone nvarchar(11),
					 @carid int	
AS
BEGIN
SET NOCOUNT ON
	declare
	@N_ID int,
	@N_register nvarchar(11),
	@N_engine float,
	@N_price float,
	@N_autotransmission bit,
	@N_ac bit,
	@N_makeName nvarchar(50),
	@N_modelName nvarchar(50),
	@N_typeName nvarchar(50)
	declare 
		kursor SCROLL CURSOR  FOR 
		select c.carID, c.register, c.engine, c.price, c.ac, c.autotransmission, t.name, m.name, mm.name from RentalCars c with(nolock)
		join RentalCarsTypes t with(nolock) on t.typeID = c.typeID 
		join RentalCarsMakeModel mm with(nolock) on mm.modelID = c.modelID
		join RentalCarsMake m with(nolock) on m.makeID = mm.makeID
		where c.carID = @carid;
	OPEN kursor FETCH NEXT FROM kursor INTO @N_ID, @N_register,@N_engine, @N_price, @N_ac,@N_autotransmission,@N_typeName, @N_modelName,@N_makeName	
	BEGIN
		insert into dbo.RentalReservation(begin_date,end_date,total_price,client_name,client_surname,client_pesel,client_adress,client_phone,register,engine,autotransmission,model_name,make_name,type_name,ac,carID)
		 values(@begin_date,@end_date,@total_price,@client_name,@client_surname,@client_pesel,@client_adress,@client_phone,@N_register,@N_engine,@N_autotransmission,@N_modelName,@N_makeName,@N_typeName,@N_ac,@carid);
		BEGIN TRY
			update RentalCars set available = 0 
				where carID = @carid;
		END TRY
		BEGIN CATCH
			 SELECT 
			  ERROR_NUMBER() AS ErrorNumber,
			  ERROR_MESSAGE() AS ErrorMessage;
		 END CATCH
	END
CLOSE kursor
DEALLOCATE kursor	
END




