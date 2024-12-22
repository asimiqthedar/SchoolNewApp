using Microsoft.EntityFrameworkCore;
using School.Models.WebModels;
using School.Services;
using School.Services.Entities;
using School.Services.ZatcaEntities;
using System.Configuration;

namespace School.Web
{
    public static class DependencyInjection
    {
        public static void RegisterDependency(this IServiceCollection services, IConfiguration config)
        {
            services.RegisterManager();
            services.RegisterProductDBContext(config);

            services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

            //// Add our Config object so it can be injected
            //services.Configure<AppSettingConfig>(config.GetSection("Zatca"));
        }

        public static void RegisterProductDBContext(this IServiceCollection services, IConfiguration config)
        {
            var connectionstring = config.GetSection("ApplicationSettings:DBConnectionString").Value;

            services.AddDbContext<ALSContext>(options => options.UseSqlServer(connectionstring));

            //var connectionstringZatca = config.GetSection("ApplicationSettings:ZatcaDBConnectionString").Value;

            //services.AddDbContext<ZatcaContext>(options => options.UseSqlServer(connectionstringZatca));
        }
    }
}
