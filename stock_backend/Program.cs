using MatthiWare.FinancialModelingPrep;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddHttpClient();

var fmpOptions = new FinancialModelingPrepOptions
{
    ApiKey = builder.Configuration.GetValue<string>("FmpApiKey")
};
builder.Services.AddFinancialModelingPrepApiClient(fmpOptions);


builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
        builder.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});

builder.Services.AddControllers();

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseCors("AllowAll");

app.MapControllers();

app.Run();
