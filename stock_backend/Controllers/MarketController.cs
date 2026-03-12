using Microsoft.AspNetCore.Mvc;
using YahooFinanceApi;

namespace stock_backend.Controllers;

[ApiController]
[Route("api/stock")]
public class MarketController : ControllerBase
{
    public MarketController()
    {
    }

    [HttpGet("chart")]
    public async Task<IActionResult> GetChart(
        [FromQuery] string symbol = "AAPL",
        [FromQuery] string interval = "1d",
        [FromQuery] string range = "10y")
    {
        try
        {
            var period = interval switch
            {
                "1d" => Period.Daily,
                "1wk" => Period.Weekly,
                "1mo" => Period.Monthly,
                _ => Period.Daily
            };

            var years = 10; // Domyślnie dla '10y'
            if (range.EndsWith("y") && int.TryParse(range.TrimEnd('y'), out var y))
            {
                years = y;
            }
            
            var startDate = DateTime.Now.AddYears(-years);
            var endDate = DateTime.Now;

            var history = await Yahoo.GetHistoricalAsync(symbol, startDate, endDate, period);

            var result = history.Select(c => new CandleData
            {
                Date = c.DateTime,
                Open = c.Open,
                High = c.High,
                Low = c.Low,
                Close = c.Close,
                Volume = c.Volume
            }).ToList();

            return Ok(result);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Błąd backendu: {ex.Message}");
        }
    }

    [HttpGet("news")]
    public IActionResult GetNews()
    {
        var news = new List<object>
        {
            new { date = DateTime.UtcNow.AddDays(-2).ToString("yyyy-MM-dd"), title = "Expected S&P500 correction", impact = "Negative" },
            new { date = DateTime.UtcNow.AddDays(-1).ToString("yyyy-MM-dd"), title = "Great tech giant earnings", impact = "Positive" }
        };
        return Ok(news);
    }
}