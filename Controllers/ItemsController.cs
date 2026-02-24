using Microsoft.AspNetCore.Mvc;
using System.Data.SqlClient;
using System.Data;

namespace SimpleSearch.Controllers
{
    public class ItemsController : ControllerBase
    {
        private readonly IConfiguration _config;

        public ItemsController(IConfiguration config)
        {
            _config = config;
        }

        [HttpGet("search")]
        public async Task<IActionResult> Search([FromQuery] ItemSearchQuery query)
        {
            var conn = new SqlConnection(_config.GetConnectionString("Default"));
            try
            {
                using var cmd = new SqlCommand("dbo.Udsp_SearchItems", conn);

                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@Search", (object?)query.Search ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Category", (object?)query.Category ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@From", (object?)query.From ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@To", (object?)query.To ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Page", query.Page);
                cmd.Parameters.AddWithValue("@PageSize", query.PageSize);
                cmd.Parameters.AddWithValue("@SortBy", query.SortBy);
                cmd.Parameters.AddWithValue("@Desc", query.Desc);

                await conn.OpenAsync();

                using var reader = await cmd.ExecuteReaderAsync();

                var results = new List<ItemDto>();

                while (await reader.ReadAsync())
                {
                    results.Add(new ItemDto
                    {
                        Id = reader.GetInt32("Id"),
                        Name = reader.GetString("Name"),
                        Description = reader["Description"]?.ToString(),
                        Category = reader.GetString("Category"),
                        CreatedAt = reader.GetDateTime("CreatedAt")
                    });
                }

                return Ok(results);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
            finally
            {
                await conn.CloseAsync();
            }
        }
    }
}
