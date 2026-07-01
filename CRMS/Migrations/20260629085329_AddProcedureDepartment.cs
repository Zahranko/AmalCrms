using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CRMS.Migrations
{
    /// <inheritdoc />
    public partial class AddProcedureDepartment : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "DepartmentId",
                table: "Procedures",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_Procedures_DepartmentId",
                table: "Procedures",
                column: "DepartmentId");

            migrationBuilder.AddForeignKey(
                name: "FK_Procedures_Departments_DepartmentId",
                table: "Procedures",
                column: "DepartmentId",
                principalTable: "Departments",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Procedures_Departments_DepartmentId",
                table: "Procedures");

            migrationBuilder.DropIndex(
                name: "IX_Procedures_DepartmentId",
                table: "Procedures");

            migrationBuilder.DropColumn(
                name: "DepartmentId",
                table: "Procedures");
        }
    }
}
