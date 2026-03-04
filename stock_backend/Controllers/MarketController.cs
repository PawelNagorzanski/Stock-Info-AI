using Microsoft.AspNetCore.Mvc;

namespace StockApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class StockController : ControllerBase
{
    [HttpGet("chart")]
    public IEnumerable<ChartPoint> GetChartData()
    {
        return new List<ChartPoint>
        {
            new() { Date = DateTime.Now.AddDays(-3), Price = 105.20 },
            new() { Date = DateTime.Now.AddDays(-2), Price = 103.50 },
            new() { Date = DateTime.Now.AddDays(-1), Price = 108.80 },
            new() { Date = DateTime.Now, Price = 110.00 }
        };
    }

    [HttpGet("news")]
    public IEnumerable<NewsEvent> GetNews()
    {
        return new List<NewsEvent>
        {
            new() { Date = DateTime.Now.AddDays(-2), Title = "Decyzja Fed o stopach", Impact = "Negative" },
            new() { Date = DateTime.Now.AddDays(-1), Title = "Dobre wyniki spółki X", Impact = "Positive" }
        };
    }
}