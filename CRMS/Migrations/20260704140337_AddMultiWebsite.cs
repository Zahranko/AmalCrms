using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CRMS.Migrations
{
    /// <inheritdoc />
    public partial class AddMultiWebsite : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "WebsiteId",
                table: "ReferralSources",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "WebsiteId",
                table: "Procedures",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "WebsiteId",
                table: "Notifications",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "WebsiteId",
                table: "Doctors",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "WebsiteId",
                table: "Departments",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "WebsiteId",
                table: "Customers",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "Websites",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Key = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    NameEn = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    NameAr = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Websites", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "UserWebsites",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "int", nullable: false),
                    WebsiteId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserWebsites", x => new { x.UserId, x.WebsiteId });
                    table.ForeignKey(
                        name: "FK_UserWebsites_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserWebsites_Websites_WebsiteId",
                        column: x => x.WebsiteId,
                        principalTable: "Websites",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "WebsiteSettings",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    WebsiteId = table.Column<int>(type: "int", nullable: false),
                    Key = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Value = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WebsiteSettings", x => x.Id);
                    table.ForeignKey(
                        name: "FK_WebsiteSettings_Websites_WebsiteId",
                        column: x => x.WebsiteId,
                        principalTable: "Websites",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ReferralSources_WebsiteId",
                table: "ReferralSources",
                column: "WebsiteId");

            migrationBuilder.CreateIndex(
                name: "IX_Procedures_WebsiteId",
                table: "Procedures",
                column: "WebsiteId");

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_WebsiteId",
                table: "Notifications",
                column: "WebsiteId");

            migrationBuilder.CreateIndex(
                name: "IX_Doctors_WebsiteId",
                table: "Doctors",
                column: "WebsiteId");

            migrationBuilder.CreateIndex(
                name: "IX_Departments_WebsiteId",
                table: "Departments",
                column: "WebsiteId");

            migrationBuilder.CreateIndex(
                name: "IX_Customers_WebsiteId",
                table: "Customers",
                column: "WebsiteId");

            migrationBuilder.CreateIndex(
                name: "IX_UserWebsites_WebsiteId",
                table: "UserWebsites",
                column: "WebsiteId");

            migrationBuilder.CreateIndex(
                name: "IX_Websites_Key",
                table: "Websites",
                column: "Key",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_WebsiteSettings_WebsiteId",
                table: "WebsiteSettings",
                column: "WebsiteId");

            migrationBuilder.CreateIndex(
                name: "IX_WebsiteSettings_WebsiteId_Key",
                table: "WebsiteSettings",
                columns: new[] { "WebsiteId", "Key" },
                unique: true);

            // Seed the two websites and back-fill every existing tenant row to the
            // "crms" website (all pre-existing data belongs to the original CRM).
            // Must run before the WebsiteId foreign keys below, or the default-0
            // values would violate them.
            migrationBuilder.Sql(@"
IF NOT EXISTS (SELECT 1 FROM [Websites] WHERE [Key] = 'crms')
    INSERT INTO [Websites] ([Key], [NameEn], [NameAr], [IsActive], [CreatedAt])
    VALUES ('crms', 'CRMS', N'نظام إدارة العملاء', 1, SYSUTCDATETIME());

IF NOT EXISTS (SELECT 1 FROM [Websites] WHERE [Key] = 'contact')
    INSERT INTO [Websites] ([Key], [NameEn], [NameAr], [IsActive], [CreatedAt])
    VALUES ('contact', 'Contact', N'تواصل', 1, SYSUTCDATETIME());

DECLARE @crmsId INT = (SELECT [Id] FROM [Websites] WHERE [Key] = 'crms');
UPDATE [Customers]       SET [WebsiteId] = @crmsId WHERE [WebsiteId] = 0;
UPDATE [Departments]     SET [WebsiteId] = @crmsId WHERE [WebsiteId] = 0;
UPDATE [Doctors]         SET [WebsiteId] = @crmsId WHERE [WebsiteId] = 0;
UPDATE [Procedures]      SET [WebsiteId] = @crmsId WHERE [WebsiteId] = 0;
UPDATE [ReferralSources] SET [WebsiteId] = @crmsId WHERE [WebsiteId] = 0;
UPDATE [Notifications]   SET [WebsiteId] = @crmsId WHERE [WebsiteId] = 0;
");

            migrationBuilder.AddForeignKey(
                name: "FK_Customers_Websites_WebsiteId",
                table: "Customers",
                column: "WebsiteId",
                principalTable: "Websites",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Departments_Websites_WebsiteId",
                table: "Departments",
                column: "WebsiteId",
                principalTable: "Websites",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Doctors_Websites_WebsiteId",
                table: "Doctors",
                column: "WebsiteId",
                principalTable: "Websites",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Notifications_Websites_WebsiteId",
                table: "Notifications",
                column: "WebsiteId",
                principalTable: "Websites",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Procedures_Websites_WebsiteId",
                table: "Procedures",
                column: "WebsiteId",
                principalTable: "Websites",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_ReferralSources_Websites_WebsiteId",
                table: "ReferralSources",
                column: "WebsiteId",
                principalTable: "Websites",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Customers_Websites_WebsiteId",
                table: "Customers");

            migrationBuilder.DropForeignKey(
                name: "FK_Departments_Websites_WebsiteId",
                table: "Departments");

            migrationBuilder.DropForeignKey(
                name: "FK_Doctors_Websites_WebsiteId",
                table: "Doctors");

            migrationBuilder.DropForeignKey(
                name: "FK_Notifications_Websites_WebsiteId",
                table: "Notifications");

            migrationBuilder.DropForeignKey(
                name: "FK_Procedures_Websites_WebsiteId",
                table: "Procedures");

            migrationBuilder.DropForeignKey(
                name: "FK_ReferralSources_Websites_WebsiteId",
                table: "ReferralSources");

            migrationBuilder.DropTable(
                name: "UserWebsites");

            migrationBuilder.DropTable(
                name: "WebsiteSettings");

            migrationBuilder.DropTable(
                name: "Websites");

            migrationBuilder.DropIndex(
                name: "IX_ReferralSources_WebsiteId",
                table: "ReferralSources");

            migrationBuilder.DropIndex(
                name: "IX_Procedures_WebsiteId",
                table: "Procedures");

            migrationBuilder.DropIndex(
                name: "IX_Notifications_WebsiteId",
                table: "Notifications");

            migrationBuilder.DropIndex(
                name: "IX_Doctors_WebsiteId",
                table: "Doctors");

            migrationBuilder.DropIndex(
                name: "IX_Departments_WebsiteId",
                table: "Departments");

            migrationBuilder.DropIndex(
                name: "IX_Customers_WebsiteId",
                table: "Customers");

            migrationBuilder.DropColumn(
                name: "WebsiteId",
                table: "ReferralSources");

            migrationBuilder.DropColumn(
                name: "WebsiteId",
                table: "Procedures");

            migrationBuilder.DropColumn(
                name: "WebsiteId",
                table: "Notifications");

            migrationBuilder.DropColumn(
                name: "WebsiteId",
                table: "Doctors");

            migrationBuilder.DropColumn(
                name: "WebsiteId",
                table: "Departments");

            migrationBuilder.DropColumn(
                name: "WebsiteId",
                table: "Customers");
        }
    }
}
