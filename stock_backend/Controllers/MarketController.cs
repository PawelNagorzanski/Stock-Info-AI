using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace stock_backend.Controllers;

[ApiController]
[Route("api/stock")]
public class MarketController : ControllerBase
{
    private readonly HttpClient _httpClient;

    public MarketController(HttpClient httpClient)
    {
        _httpClient = httpClient;
        // Yahoo API wymaga nagłówka User-Agent, inaczej odrzuci połączenie
        _httpClient.DefaultRequestHeaders.Add("User-Agent", "Mozilla/5.0");
    }

[HttpGet("chart")]
    public async Task<IActionResult> GetChart([FromQuery] string symbol = "AAPL", [FromQuery] string range = "1mo", [FromQuery] string interval = "1d")
    {
        // Dynamiczne wstawianie parametrów do URL
        var url = $"https://query2.finance.yahoo.com/v8/finance/chart/{symbol}?interval={interval}&range={range}";
        
        var response = await _httpClient.GetAsync(url);
        if (!response.IsSuccessStatusCode) return StatusCode(500, $"Błąd Yahoo: {response.StatusCode}");

        var content = await response.Content.ReadAsStringAsync();
        using var doc = JsonDocument.Parse(content);
        
        var result = new List<CandleData>();
        var resultNode = doc.RootElement.GetProperty("chart").GetProperty("result")[0];
        
        if (!resultNode.TryGetProperty("timestamp", out var timestampsNode)) return Ok(result);

        var timestamps = timestampsNode.EnumerateArray().ToList();
        var quote = resultNode.GetProperty("indicators").GetProperty("quote")[0];
        
        var opens = quote.GetProperty("open").EnumerateArray().ToList();
        var highs = quote.GetProperty("high").EnumerateArray().ToList();
        var lows = quote.GetProperty("low").EnumerateArray().ToList();
        var closes = quote.GetProperty("close").EnumerateArray().ToList();
        var volumes = quote.GetProperty("volume").EnumerateArray().ToList();

        for (int i = 0; i < timestamps.Count; i++)
        {
            // Omijanie pustych dni giełdowych (święta itp.)
            if (opens[i].ValueKind == JsonValueKind.Null) continue;

            result.Add(new CandleData
            {
                Date = DateTimeOffset.FromUnixTimeSeconds(timestamps[i].GetInt64()).DateTime,
                Open = opens[i].GetDecimal(),
                High = highs[i].GetDecimal(),
                Low = lows[i].GetDecimal(),
                Close = closes[i].GetDecimal(),
                Volume = volumes[i].GetDecimal()
            });
        }

        return Ok(result);
    }

    [HttpGet("news")]
    public IActionResult GetNews()
    {
        var news = new List<object>
        {
            new { date = DateTime.UtcNow.AddDays(-2).ToString("yyyy-MM-dd"), title = "Oczekiwana korekta na S&P500", impact = "Negative" },
            new { date = DateTime.UtcNow.AddDays(-1).ToString("yyyy-MM-dd"), title = "Świetne wyniki gigantów tech", impact = "Positive" }
        };
        return Ok(news);
    }
}