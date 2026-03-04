var builder = WebApplication.CreateBuilder(args);

// Dodajemy politykę CORS (pozwalamy na połączenia z dowolnego źródła)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
        builder.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});

builder.Services.AddControllers();
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
    });
}); 
// Dodaj to:
builder.Services.AddHttpClient();

var app = builder.Build();

// Uruchamiamy CORS przed kontrolerami! To bardzo ważne.
app.UseCors("AllowAll");

app.MapControllers(); 
app.Run();