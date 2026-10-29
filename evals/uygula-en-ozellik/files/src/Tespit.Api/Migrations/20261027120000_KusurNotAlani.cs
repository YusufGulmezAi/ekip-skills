using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Tespit.Api.Migrations
{
    /// <inheritdoc />
    public partial class KusurNotAlani : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Aciklama",
                table: "Kusurlar");

            migrationBuilder.AddColumn<string>(
                name: "Not",
                table: "Kusurlar",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Not",
                table: "Kusurlar");

            migrationBuilder.AddColumn<string>(
                name: "Aciklama",
                table: "Kusurlar",
                type: "text",
                nullable: true);
        }
    }
}
