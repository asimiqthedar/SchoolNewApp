using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Http.Features;
using OfficeOpenXml;
using School.Models.WebModels;
using School.Services.WebServices.Implementation;
using School.Services.WebServices.Services;
using School.Web.Models;

namespace School.Web.AppStart
{
    public static class ServiceConfiguration
    {
        public static IServiceCollection AddConfiguration(this IServiceCollection services, IConfiguration configuration)
        {
            services.AddSession(options =>
            {
                // Set session timeout to 60 minutes
                options.IdleTimeout = TimeSpan.FromMinutes(60);
            });
            services.AddOptions();
            services.AddRouting(options => options.LowercaseUrls = true);
            services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();
            services.AddCors(options =>
            {
                options.AddDefaultPolicy(builder =>
                {
                    builder.AllowAnyOrigin()
                           .AllowAnyHeader()
                           .AllowAnyMethod();
                });
            });
            //Service Inject
            services.Configure<AppSettingConfig>(configuration.GetSection("ApplicationSettings"));
            services.Configure<EmailConfiguration>(configuration.GetSection("EmailConfiguration"));
            services.Configure<ZatcaAppSettingConfig>(configuration.GetSection("Zatca"));

            services.AddScoped<IDropdownService, DropdownService>();
            services.AddScoped<IAuthService, AuthService>();
            services.AddScoped<IHomeService, HomeService>();
            services.AddScoped<IUserService, UserService>();
            services.AddScoped<IParentService, ParentService>();
            services.AddScoped<ISetupService, SetupService>();
            services.AddScoped<IAttachements, AttachementService>();
            services.AddScoped<IStudentService, StudentService>();
            services.AddScoped<ISchoolService, SchoolService>();
            services.AddScoped<ICommonService, CommonService>();
            services.AddScoped<IReportService, ReportService>();
            services.AddScoped<IFeeService, FeeService>();
            services.AddScoped<IInvoiceService, InvoiceService>();

            services.AddScoped<IAcademicTermService, AcademicTermService>();
            services.AddScoped<IAcademicYearService, AcademicYearService>();
			
            services.AddScoped<IEmailService, EmailService>();
			services.AddScoped<IEmailHelper, EmailHelper>();
			services.AddScoped<IGPIntegrationService, GPIntegrationService>();
            services.Configure<FormOptions>(options =>
            {
                options.MultipartBodyLengthLimit = 104857600; // 100 MB limit
            });
			ExcelPackage.LicenseContext = LicenseContext.NonCommercial; // or LicenseContext.Commercial

			return services;
        }
        public static IServiceCollection AddAuthentication(this IServiceCollection services, IConfiguration configuration)
        {
            services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
                .AddCookie(options =>
                {
                    options.Cookie.Name = "SchoolCookie";
                    options.LoginPath = "/Auth/Index";
                    options.SlidingExpiration = true;
                    // Set expiration time for authentication cookie
                    options.ExpireTimeSpan = TimeSpan.FromMinutes(60); // 60 minutes
                });

            return services;
        }
    }
}
