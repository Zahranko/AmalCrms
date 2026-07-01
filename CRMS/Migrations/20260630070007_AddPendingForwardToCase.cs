using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CRMS.Migrations
{
    /// <inheritdoc />
    public partial class AddPendingForwardToCase : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "PendingForwardToUserId",
                table: "Customers",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Customers_PendingForwardToUserId",
                table: "Customers",
                column: "PendingForwardToUserId");

            migrationBuilder.AddForeignKey(
                name: "FK_Customers_Users_PendingForwardToUserId",
                table: "Customers",
                column: "PendingForwardToUserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Customers_Users_PendingForwardToUserId",
                table: "Customers");

            migrationBuilder.DropIndex(
                name: "IX_Customers_PendingForwardToUserId",
                table: "Customers");

            migrationBuilder.DropColumn(
                name: "PendingForwardToUserId",
                table: "Customers");
        }
    }
}
