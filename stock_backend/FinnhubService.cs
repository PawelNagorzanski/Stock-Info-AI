using System.Text.Json;

namespace stock_backend;

public interface IFinnhubService
{
    Task<IEnumerable<CandleData>> GetCandlesAsync(string symbol, string resolution, long from, long to);
    Task<string> GetNewsAsync(string symbol);
}

public class FinnhubService : IFinnhubService
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _configuration;
    private readonly JsonSerializerOptions _jsonOptions = new() { PropertyNameCaseInsensitive = true };


    public FinnhubService(IHttpClientFactory httpClientFactory, IConfiguration configuration)
    {
        _httpClientFactory = httpClientFactory;
        _configuration = configuration;
    }

    public async Task<IEnumerable<CandleData>> GetCandlesAsync(string symbol, string resolution, long from, long to)
    {
        var client = _httpClientFactory.CreateClient();
        var apiKey = _configuration["FinnhubApiKey"];
        var baseUrl = _configuration["FinnhubApiUrl"];
        var url = $"{baseUrl}/stock/candle?symbol={symbol}&resolution={resolution}&from={from}&to={to}&token={apiKey}";

        var response = await client.GetAsync(url);
        response.EnsureSuccessStatusCode();

        var content = await response.Content.ReadAsStringAsync();
        var finnhubResponse = JsonSerializer.Deserialize<FinnhubCandleResponse>(content, _jsonOptions);

        if (finnhubResponse?.s != "ok" || finnhubResponse.c == null || finnhubResponse.t == null || finnhubResponse.o == null || finnhubResponse.h == null || finnhubResponse.l == null || finnhubResponse.v == null)
        {
            return new List<CandleData>();
        }

        var candles = new List<CandleData>();
        for (int i = 0; i < finnhubResponse.c.Count; i++)
        {
            candles.Add(new CandleData
            {
                Timestamp = finnhubResponse.t[i],
                Open = finnhubResponse.o[i],
                High = finnhubResponse.h[i],
                Low = finnhubResponse.l[i],
                Close = finnhubResponse.c[i],
                Volume = finnhubResponse.v[i]
            });
        }

        return candles;
    }

    public async Task<string> GetNewsAsync(string symbol)
    {
        var client = _httpClientFactory.CreateClient();
        var apiKey = _configuration["FinnhubApiKey"];
        var baseUrl = _configuration["FinnhubApiUrl"];
        // Get news for the last 7 days
        var to = DateTime.UtcNow.ToString("yyyy-MM-dd");
        var from = DateTime.UtcNow.AddDays(-7).ToString("yyyy-MM-dd");
        var url = $"{baseUrl}/company-news?symbol={symbol}&from={from}&to={to}&token={apiKey}";

        var response = await client.GetAsync(url);
        response.EnsureSuccessStatusCode();

        var content = await response.Content.ReadAsStringAsync();
        
        return content;
    }
}
