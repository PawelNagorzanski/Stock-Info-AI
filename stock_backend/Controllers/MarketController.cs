using MatthiWare.FinancialModelingPrep;
using MatthiWare.FinancialModelingPrep.Model.StockTimeSeries;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Globalization;

namespace stock_backend.Controllers;

[ApiController]
[Route("api/stock")]
public class MarketController : ControllerBase
{
    private readonly IFinancialModelingPrepApiClient _apiClient;

    public MarketController(IFinancialModelingPrepApiClient apiClient)
    {
        _apiClient = apiClient;
    }

    [HttpGet("chart")]
    public async Task<IActionResult> GetChart(
        [FromQuery] string symbol = "AAPL",
        [FromQuery] string interval = "1d",
        [FromQuery] string range = "10y")
    {
        try
        {
            var years = 10;
            if (range.EndsWith("y") && int.TryParse(range.TrimEnd('y'), out var y))
            {
                years = y;
            }
            
            var startDate = DateTime.Now.AddYears(-years);
            var endDate = DateTime.Now;

            // TODO: The library doesn't seem to support weekly/monthly intervals directly.
            // Using daily for all and the frontend will have to deal with it, or we need to implement resampling.
            var apiResponse = await _apiClient.StockTimeSeries.GetHistoricalDailyPricesAsync(symbol, startDate.ToString("yyyy-MM-dd"), endDate.ToString("yyyy-MM-dd"));

            if (apiResponse.HasError)
            {
                return StatusCode(500, $"Błąd API: {apiResponse.Error}");
            }

            if (apiResponse.Data == null || !apiResponse.Data.Historical.Any())
            {
                return Ok(new List<CandleData>());
            }
            
            var result = apiResponse.Data.Historical.Select(c => new CandleData
            {
                Timestamp = ((DateTimeOffset)DateTime.Parse(c.Date, CultureInfo.InvariantCulture)).ToUnixTimeMilliseconds(),
                Open = (decimal)c.Open,
                High = (decimal)c.High,
                Low = (decimal)c.Low,
                Close = (decimal)c.Close,
                Volume = (decimal)c.Volume
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
