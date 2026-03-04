public class ChartPoint
{
    public DateTime Date { get; set; }
    public double Price { get; set; }
}

public class NewsEvent
{
    public DateTime Date { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Impact { get; set; } = "Neutral"; // np. Positive/Negative
}