CREATE TABLE [dbo].[Images](
	[ImagePath] [varchar](1000) NULL
) ON [PRIMARY]

INSERT INTO Images(ImagePath) VALUES ('https://${storage_account_name}.blob.core.windows.net/${app_container_name}/Html.jpg')

INSERT INTO Images(ImagePath) VALUES ('https://${storage_account_name}.blob.core.windows.net/${app_container_name}/Css.jpg')

INSERT INTO Images(ImagePath) VALUES ('https://${storage_account_name}.blob.core.windows.net/${app_container_name}/Js.jpg')

     	