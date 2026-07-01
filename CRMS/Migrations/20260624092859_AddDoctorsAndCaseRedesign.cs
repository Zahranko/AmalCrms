using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CRMS.Migrations
{
    /// <inheritdoc />
    public partial class AddDoctorsAndCaseRedesign : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "FailureReason",
                table: "Customers");

            migrationBuilder.DropColumn(
                name: "FollowUpDescription",
                table: "Customers");

            migrationBuilder.RenameColumn(
                name: "FollowUpDate",
                table: "Customers",
                newName: "AppointmentDate");

            migrationBuilder.RenameColumn(
                name: "FollowUpDate",
                table: "CaseActions",
                newName: "ActionDate");

            migrationBuilder.AlterColumn<int>(
                name: "DepartmentId",
                table: "Customers",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AddColumn<int>(
                name: "CreatedByUserId",
                table: "Customers",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "DoctorId",
                table: "Customers",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "DepartmentId",
                table: "CaseActions",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "DoctorId",
                table: "CaseActions",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ResultingStatus",
                table: "CaseActions",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Doctors",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    DepartmentId = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Doctors", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Doctors_Departments_DepartmentId",
                        column: x => x.DepartmentId,
                        principalTable: "Departments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Customers_CreatedByUserId",
                table: "Customers",
                column: "CreatedByUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Customers_DoctorId",
                table: "Customers",
                column: "DoctorId");

            migrationBuilder.CreateIndex(
                name: "IX_CaseActions_DepartmentId",
                table: "CaseActions",
                column: "DepartmentId");

            migrationBuilder.CreateIndex(
                name: "IX_CaseActions_DoctorId",
                table: "CaseActions",
                column: "DoctorId");

            migrationBuilder.CreateIndex(
                name: "IX_Doctors_DepartmentId",
                table: "Doctors",
                column: "DepartmentId");

            migrationBuilder.AddForeignKey(
                name: "FK_CaseActions_Departments_DepartmentId",
                table: "CaseActions",
                column: "DepartmentId",
                principalTable: "Departments",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_CaseActions_Doctors_DoctorId",
                table: "CaseActions",
                column: "DoctorId",
                principalTable: "Doctors",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Customers_Doctors_DoctorId",
                table: "Customers",
                column: "DoctorId",
                principalTable: "Doctors",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Customers_Users_CreatedByUserId",
                table: "Customers",
                column: "CreatedByUserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            // Remap legacy v1 enum strings so pre-existing rows deserialize under the
            // new CustomerStatus / CaseActionType enums. Backfill ResultingStatus from
            // the old follow-up Type values BEFORE collapsing Type.
            migrationBuilder.Sql(@"
                UPDATE [Customers] SET [Status] = 'Pending' WHERE [Status] IN ('Assigned','Forwarded','FollowUp');
                UPDATE [Customers] SET [Status] = 'Success' WHERE [Status] = 'Resolved';
                UPDATE [CaseActions] SET [ResultingStatus] = CASE [Type]
                        WHEN 'FollowUpSucceeded' THEN 'Success'
                        WHEN 'FollowUpFailed' THEN 'Failed'
                        WHEN 'FollowUpScheduled' THEN 'Waiting'
                        ELSE [ResultingStatus] END
                    WHERE [Type] IN ('FollowUpSucceeded','FollowUpFailed','FollowUpScheduled');
                UPDATE [CaseActions] SET [Type] = 'Created' WHERE [Type] = 'Assigned';
                UPDATE [CaseActions] SET [Type] = 'FollowUp' WHERE [Type] IN ('Failed','FollowUpScheduled','FollowUpSucceeded','FollowUpFailed');
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_CaseActions_Departments_DepartmentId",
                table: "CaseActions");

            migrationBuilder.DropForeignKey(
                name: "FK_CaseActions_Doctors_DoctorId",
                table: "CaseActions");

            migrationBuilder.DropForeignKey(
                name: "FK_Customers_Doctors_DoctorId",
                table: "Customers");

            migrationBuilder.DropForeignKey(
                name: "FK_Customers_Users_CreatedByUserId",
                table: "Customers");

            migrationBuilder.DropTable(
                name: "Doctors");

            migrationBuilder.DropIndex(
                name: "IX_Customers_CreatedByUserId",
                table: "Customers");

            migrationBuilder.DropIndex(
                name: "IX_Customers_DoctorId",
                table: "Customers");

            migrationBuilder.DropIndex(
                name: "IX_CaseActions_DepartmentId",
                table: "CaseActions");

            migrationBuilder.DropIndex(
                name: "IX_CaseActions_DoctorId",
                table: "CaseActions");

            migrationBuilder.DropColumn(
                name: "CreatedByUserId",
                table: "Customers");

            migrationBuilder.DropColumn(
                name: "DoctorId",
                table: "Customers");

            migrationBuilder.DropColumn(
                name: "DepartmentId",
                table: "CaseActions");

            migrationBuilder.DropColumn(
                name: "DoctorId",
                table: "CaseActions");

            migrationBuilder.DropColumn(
                name: "ResultingStatus",
                table: "CaseActions");

            migrationBuilder.RenameColumn(
                name: "AppointmentDate",
                table: "Customers",
                newName: "FollowUpDate");

            migrationBuilder.RenameColumn(
                name: "ActionDate",
                table: "CaseActions",
                newName: "FollowUpDate");

            migrationBuilder.AlterColumn<int>(
                name: "DepartmentId",
                table: "Customers",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "FailureReason",
                table: "Customers",
                type: "nvarchar(2000)",
                maxLength: 2000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "FollowUpDescription",
                table: "Customers",
                type: "nvarchar(2000)",
                maxLength: 2000,
                nullable: true);
        }
    }
}
