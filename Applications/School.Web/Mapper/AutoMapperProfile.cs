using AutoMapper;
using School.Models.WebModels.InvoiceSetupModels;
using School.Services.Entities;
using School.Services.ZatcaEntities;

namespace Zuuk.ProductService.API.Mapper
{
	public class AutoMapperProfile : Profile
    {
        public AutoMapperProfile()
        {
            CreateMap<InvInvoiceSummaryModel, InvInvoiceSummary>().ReverseMap();
            CreateMap<InvInvoiceDetailModel, InvInvoiceDetail>().ReverseMap();
            CreateMap<InvInvoicePaymentModel, InvInvoicePayment>().ReverseMap();

            CreateMap<InvInvoiceDetailModel, InvInvoiceDetailEntranceFeeModel>().ReverseMap();
            CreateMap<InvInvoiceDetailModel, InvInvoiceDetailUniformFeeModel>().ReverseMap();
            CreateMap<InvInvoiceDetailModel, InvInvoiceDetailTuitionFeeModel>().ReverseMap();
			CreateMap<InvInvoiceDetailModel, InvInvoiceDetailTuitionNewFeeModel>().ReverseMap();

			CreateMap<BaseInvoice, InvInvoiceDetail>().ReverseMap();
			CreateMap<InvInvoiceSummaryRefundModel, InvInvoiceSummary>().ReverseMap();
            CreateMap<InvInvoiceDetailyRefundModel, InvInvoiceDetail>().ReverseMap();
            CreateMap<InvInvoicePaymentyRefundModel, InvInvoicePayment>().ReverseMap();

            CreateMap<InvoiceSummary, InvInvoiceSummary>().ReverseMap();
            CreateMap<InvoiceDetail, InvInvoiceDetail>().ReverseMap();
            CreateMap<UniformDetail, InvInvoiceDetail>().ReverseMap();
            CreateMap<InvoicePayment, InvInvoicePayment>().ReverseMap();
		}
    }
}