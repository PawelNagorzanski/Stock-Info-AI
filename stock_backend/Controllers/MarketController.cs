using Microsoft.AspNetCore.Mvc;

namespace stock_backend.Controllers;

[ApiController]
[Route("api/stock")]
public class MarketController : ControllerBase
{
    private readonly IFinnhubService _finnhubService;

    public MarketController(IFinnhubService finnhubService)
    {
        _finnhubService = finnhubService;
    }

    [HttpGet("chart")]
    public async Task<IActionResult> GetChart(
        [FromQuery] string symbol = "AAPL",
        [FromQuery] string interval = "1d",
        [FromQuery] string range = "10y")
    {
        try
        {
            var resolution = interval switch
            {
                "1d" => "D",
                "1w" => "W",
                "1m" => "M",
                _ => "D"
            };

            var to = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            var from = to;

            if (range.EndsWith("y") && int.TryParse(range.TrimEnd('y'), out var years))
            {
                from = DateTimeOffset.UtcNow.AddYears(-years).ToUnixTimeSeconds();
            }
            else if (range.EndsWith("m") && int.TryParse(range.TrimEnd('m'), out var months))
            {
                from = DateTimeOffset.UtcNow.AddMonths(-months).ToUnixTimeSeconds();
            }
            else if (range.EndsWith("d") && int.TryParse(range.TrimEnd('d'), out var days))
            {
                from = DateTimeOffset.UtcNow.AddDays(-days).ToUnixTimeSeconds();
            }

            var candles = await _finnhubService.GetCandlesAsync(symbol, resolution, from, to);
            return Ok(candles);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Błąd backendu: {ex.Message}");
        }
    }

    [HttpGet("news")]
    public async Task<IActionResult> GetNews([FromQuery] string symbol = "AAPL")
    {
        try
        {
            var newsJson = await _finnhubService.GetNewsAsync(symbol);
            return Content(newsJson, "application/json");
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Błąd backendu: {ex.Message}");
        }
    }
}

