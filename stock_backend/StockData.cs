using System.Text.Json.Serialization;

namespace stock_backend;

// Format dla frontendu
public class CandleData
{
    public DateTime Date { get; set; }
    public decimal Open { get; set; }
    public decimal High { get; set; }
    public decimal Low { get; set; }
    public decimal Close { get; set; }
    public decimal Volume { get; set; }
}

// Format odpowiedzi Finnhub
public class FinnhubCandleResponse
{
    public List<decimal>? c { get; set; } // Close
    public List<decimal>? h { get; set; } // High
    public List<decimal>? l { get; set; } // Low
    public List<decimal>? o { get; set; } // Open
    public List<long>? t { get; set; }    // Timestamps
    public List<decimal>? v { get; set; } // Volume
    public string? s { get; set; }        // Status ("ok" lub "no_data")
}