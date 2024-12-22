using School.Web;
using School.Web.AppStart;

var builder = WebApplication.CreateBuilder(args);

builder.Logging.ClearProviders();
builder.Logging.AddLog4Net();

//IConfigurationRoot config = new ConfigurationBuilder()
//   .AddJsonFile("appsettings.json")
//   .AddEnvironmentVariables()
//   .Build();

// Add services to the container.
builder.Services.AddControllersWithViews();
builder.Services.AddConfiguration(builder.Configuration);
builder.Services.AddAuthentication(builder.Configuration);
builder.Services.RegisterDependency(builder.Configuration);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseCors();
app.UseRouting();
var cookiePolicyOptions = new CookiePolicyOptions
{
    MinimumSameSitePolicy = SameSiteMode.Strict,
    HttpOnly = Microsoft.AspNetCore.CookiePolicy.HttpOnlyPolicy.Always,
    Secure = CookieSecurePolicy.None,
    ConsentCookie = new CookieBuilder()
    {
        Name = ".School.cooki1.Session"
	}
};
app.UseCookiePolicy(cookiePolicyOptions);
app.UseAuthentication();
app.UseAuthorization();
app.UseSession(new SessionOptions()
{
	Cookie = new CookieBuilder()
	{
		Name = ".School.app1.Session"
	}
});

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Auth}/{action=Index}/{id?}");

app.Run();
