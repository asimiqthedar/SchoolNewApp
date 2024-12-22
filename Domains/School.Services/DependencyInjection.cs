using Microsoft.Extensions.DependencyInjection;
using School.Services.ALSManager;
using School.Services.ZatcaManager;

namespace School.Services
{
	public static class DependencyInjection
    {
        public static IServiceCollection RegisterManager(this IServiceCollection services)
        {
            services.AddScoped<IGradeMaster, GradeMaster>();
            services.AddScoped<IParentManager, ParentManager>();
            services.AddScoped<IParentAccountManager, ParentAccountManager>();
            services.AddScoped<IStudentManager, StudentManager>();

            services.AddScoped<IInvInvoiceDetailManager, InvInvoiceDetailManager>();
            services.AddScoped<IInvInvoicePaymentManager, InvInvoicePaymentManager>();
            services.AddScoped<IInvSummaryManager, InvSummaryManager>();

            services.AddScoped<IZatcaInvoiceDetailManager, ZatcaInvoiceDetailManager>();
            services.AddScoped<IZatcaInvoicePaymentManager, ZatcaInvoicePaymentManager>();
            services.AddScoped<IZatcaInvoiceSummaryManager, ZatcaInvoiceSummaryManager>();

			services.AddScoped<IZatcaInvoiceUniformManager, ZatcaInvoiceUniformManager>();

            services.AddScoped<ICountryManager, CountryManager>();
            services.AddScoped<ISchoolAcademicManager, SchoolAcademicManager>();

            services.AddScoped<IVATManager, VATManager>();
            services.AddScoped<IPaymentMethodManager, PaymentMethodManager>();
            services.AddScoped<IUserManager, UserManager>();
            return services;
        }
    }
}