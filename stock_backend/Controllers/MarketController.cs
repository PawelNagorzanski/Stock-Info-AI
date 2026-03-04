using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace stock_backend.Controllers;

[ApiController]
[Route("api/stock")]
public class MarketController : ControllerBase
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _config;

    public MarketController(HttpClient httpClient, IConfiguration config)
    {
        _httpClient = httpClient;
        _config = config;
    }

    [HttpGet("chart")]
    public async Task<IActionResult> GetChart([FromQuery] string symbol = "AAPL", [FromQuery] string resolution = "D")
    {
        var apiKey = _config["FinnhubApiKey"];
        
        // Dane z ostatnich 30 dni
        var to = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        var from = DateTimeOffset.UtcNow.AddDays(-30).ToUnixTimeSeconds();

        var url = $"https://finnhub.io/api/v1/stock/candle?symbol={symbol}&resolution={resolution}&from={from}&to={to}&token={apiKey}";
        
        var response = await _httpClient.GetAsync(url);
        if (!response.IsSuccessStatusCode) return StatusCode(500, "Błąd API Finnhub");

        var content = await response.Content.ReadAsStringAsync();
        var finnhubData = JsonSerializer.Deserialize<FinnhubCandleResponse>(content);

        // Mapowanie na format frontendu
        var result = new List<CandleData>();
        if (finnhubData?.s == "ok" && finnhubData.t != null)
        {
            for (int i = 0; i < finnhubData.t.Count; i++)
            {
                result.Add(new CandleData
                {
                    Date = DateTimeOffset.FromUnixTimeSeconds(finnhubData.t[i]).DateTime,
                    Open = finnhubData.o![i],
                    High = finnhubData.h![i],
                    Low = finnhubData.l![i],
                    Close = finnhubData.c![i],
                    Volume = finnhubData.v![i]
                });
            }
        }

        return Ok(result);
    }
}