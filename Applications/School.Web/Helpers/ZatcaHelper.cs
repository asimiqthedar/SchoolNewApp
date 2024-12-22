using System;
using System.Collections.Generic;
using System.Configuration;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using ZatcaIntegrationSDK;
using ZatcaIntegrationSDK.BLL;
using ZatcaIntegrationSDK.HelperContracts;
using School.Services.ALSManager;
using School.Services.Entities;
using School.Models;
using ZXing;
using ZXing.Common;
using School.Web.Models;
using School.Models.ZatcaModels;
using Microsoft.Extensions.Options;
using School.Models.WebModels;
using AutoMapper;

namespace School.Web.Helpers
{
	public class ZatcaHelper
	{
		private readonly InvoiceDataManager _InvoiceDataManager;

		private readonly ISellerMasterManager _ISellerMasterManager;
		private readonly ISellerDeviceConfigurationManager _ISellerDeviceConfigurationManager;
		private readonly IDeviceZatcaDetailManager _IDeviceZatcaDetailManager;
		
        private readonly EmailManager _EmailManager;
        private readonly ALSContext _ALSContextDB;
        private readonly IMapper _Mapper;
        AppSettingConfig _AppSettingConfig;
        private readonly ILogger<ZatcaHelper> logger;
        private readonly IWebHostEnvironment _env;
        public ZatcaHelper(IOptions<AppSettingConfig> appSettingConfig,
			ALSContext ALSContextDB, IMapper Mapper, ILogger<ZatcaHelper> _logger
			, IWebHostEnvironment env)
		{
			logger = _logger;
			_env = env;
            _AppSettingConfig = appSettingConfig.Value;
			_ALSContextDB = ALSContextDB;
			_Mapper = Mapper;
            _InvoiceDataManager = new InvoiceDataManager(_ALSContextDB, Mapper);
			_EmailManager = new EmailManager(ALSContextDB);
            _ISellerMasterManager = new SellerMasterManager(_ALSContextDB);
			_ISellerDeviceConfigurationManager = new SellerDeviceConfigurationManager(_ALSContextDB);
			_IDeviceZatcaDetailManager = new DeviceZatcaDetailManager(_ALSContextDB);

			//AutoMapper.Mapper.CreateMap<Invoice, InvoiceModel>();
			//AutoMapper.Mapper.CreateMap<InvoiceModel, Invoice>();

			//AutoMapper.Mapper.CreateMap<Invoice, ZATCAInvoice.ZatcaModel.Invoice>().ReverseMap();
		}

		#region Process Zatca Method		
		//public async Task<ZatcaResponseModel> ZatcaProcessInvoiceToZatca(string invoiceNos, string machineName, bool isGeneratePdfOnPostedOnly)
		//{

  //          ZatcaResponseModel zatcaResponse = new ZatcaResponseModel() { IsSuccess = false, Result = -1, ErrorMessage = "Unable to process" };
		//	try
		//	{
		//		SellerMaster sellerMasterRef = new SellerMaster();
		//		SellerDeviceConfiguration sellerDeviceConfigurationRef = new SellerDeviceConfiguration();
		//		DeviceZatcaDetail deviceZatcaDetailRef = new DeviceZatcaDetail();
		//		sellerMasterRef = await GetSellerInfo();
		//		if (sellerMasterRef == null)
		//		{
		//			zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "Seller information not available");
		//			return zatcaResponse;
		//		}

		//		sellerDeviceConfigurationRef = await GetSellerDeviceConfiguration(machineName);
		//		if (sellerDeviceConfigurationRef == null)
		//		{
		//			zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "Device is not registered");
		//			return zatcaResponse;
		//		}

		//		deviceZatcaDetailRef = await GetDeviceZatcaDetail(sellerDeviceConfigurationRef);
		//		if (deviceZatcaDetailRef == null)
		//		{
		//			zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "No CSR available for user");
		//			return zatcaResponse;
		//		}

		//		var invoiceList = invoiceNos.Split('|').ToList().Where(s => !string.IsNullOrEmpty(s)).ToList();

		//		if (invoiceList.Count > 10)
		//		{
		//			zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "Please select 10 records or less to process for ZATCA");
		//			return zatcaResponse;
		//		}
  //              List<long> invoiceListlong = invoiceList.Select(s => Int64.Parse(s)).ToList();
  //              var invoiceResultList = await _InvoiceDataManager.GetByList(invoiceListlong);
		//		if (!invoiceResultList.Any())
		//		{
		//			zatcaResponse = UpdateZatcaResponseMessgae(true, 0, "All invoices are already processed to ZATCA");
		//			return zatcaResponse;
		//		}

		//		//If any record does not have iqama number
		//		List<string> parentIds = invoiceResultList.Select(s => s.InvoiceSummaryModel.ParentID).Distinct().ToList();
		//		var invoiceListInt = invoiceList.Select(s => Convert.ToInt64(s)).ToList();
		//		var parentIqama = await _InvoiceDataManager.GetInvoices(invoiceListInt);
		//		if (!parentIqama.Any())
		//		{
		//			zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "Parent Iqama numbers are not available");
		//			return zatcaResponse;
		//		}
		//		else if (parentIqama.Any(s => string.IsNullOrEmpty(s.FatherIQAMA) && s.InvoiceType == "Fee"))
		//		{
		//			var listWithNoIqama = parentIqama.Where(s => string.IsNullOrEmpty(s.FatherIQAMA)).Select(s => new
		//			{
		//				ErrorMessage = "Invoice no " + s.InvoiceNo + " does not have father iqama"
		//			});

		//			zatcaResponse = UpdateZatcaResponseMessgae(false, -1, string.Join("<br>", listWithNoIqama.Select(s => s.ErrorMessage)));
		//			return zatcaResponse;
		//		}

		//		var fatherIQamaLess10Character = parentIqama.Where(s => s.FatherIQAMA.Count() > 0 && s.FatherIQAMA.Count() < 10).ToList();

		//		if (fatherIQamaLess10Character.Any())
		//		{
		//			zatcaResponse = UpdateZatcaResponseMessgae(false, -1, string.Join("<br>", fatherIQamaLess10Character.Select(s => "Invoice No-" + s.InvoiceNo + " has Invalid Iqama.")));
		//		}

		//		var firstZatcaInvoice = await _InvoiceDataManager.GetFirstZatcaInvoice();
		//		if (firstZatcaInvoice != null
		//			&& invoiceResultList.Any(s => Convert.ToInt32(s.InvoiceSummaryModel.InvoiceNo) <= Convert.ToInt32(firstZatcaInvoice.InvoiceNo)))
		//		{
		//			zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "Unable to Process Invoice to ZATCA as Sequential Invoice is Not Processing with ZATCA");

		//			return zatcaResponse;
		//		}
		//		var listFirstRecord = invoiceResultList.OrderBy(s => Convert.ToInt32(s.InvoiceSummaryModel.InvoiceNo)).FirstOrDefault();

			
		//		List<ZatcaResponseModel> zatcaResponseList = new List<ZatcaResponseModel>();
		//		foreach (var item in invoiceResultList.OrderBy(s => Convert.ToInt32(s.InvoiceSummaryModel.InvoiceNo)))
		//		{
		//			InvoiceModel previousInvoiceModel = new InvoiceModel();
		//			previousInvoiceModel = await _InvoiceDataManager.GetPreviousInvoice(item.InvoiceSummaryModel);

		//			if (previousInvoiceModel != null
		//				&& previousInvoiceModel.InvoiceSummaryModel.InvoiceNo<=0
		//				&& item.InvoiceSummaryModel.InvoiceNo<=0
		//				&&
		//				(Convert.ToInt32(item.InvoiceSummaryModel.InvoiceNo) - Convert.ToInt32(previousInvoiceModel.InvoiceSummaryModel.InvoiceNo)) != 1
		//				)
		//			{
		//				zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "The Invoices MUST be selected in serial order from the last ZATCA processed Invoice");
		//				return zatcaResponse;
		//			}

		//			if (previousInvoiceModel != null
		//			   &&
		//			   previousInvoiceModel.InvoiceSummaryModel.InvoiceId > item.InvoiceSummaryModel.InvoiceId
		//			   &&
		//				(
		//					string.IsNullOrEmpty(previousInvoiceModel.InvoiceSummaryModel.UUID)
		//					|| string.IsNullOrEmpty(previousInvoiceModel.InvoiceSummaryModel.EncodedInvoice)
		//					|| string.IsNullOrEmpty(previousInvoiceModel.InvoiceSummaryModel.InvoiceHash)
		//				))
		//			{
		//				zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "Please process the previous invoice first, (Hash/UUID) is not available");
		//				return zatcaResponse;
		//			}

		//			VWInvoiceModel vWInvoiceModel = parentIqama.FirstOrDefault(s => s.InvoiceNo.Value == item.InvoiceSummaryModel.InvoiceNo);

		//			//Here: Process zatca is executing
		//			zatcaResponse = await ProcessZatcaInvoice(item, machineName, sellerMasterRef, sellerDeviceConfigurationRef,
		//				previousInvoiceModel, vWInvoiceModel, false, false);

		//			zatcaResponse.InvoiceNo = item.InvoiceSummaryModel.InvoiceNo;
		//			if (!zatcaResponse.IsSuccess)
		//			{
		//				zatcaResponseList.Add(zatcaResponse);
		//				break;
		//			}
		//			zatcaResponseList.Add(zatcaResponse);
		//			await SaveInvoicePDFA3InFolder(item.InvoiceSummaryModel.InvoiceNo);
		//		}

  //              ZatcaResponseModel finelResponse = new ZatcaResponseModel
  //              {
		//			IsSuccess = zatcaResponseList.Any(s => s.ReportingStatus == "REPORTED"),

		//			ErrorMessage = string.Join("<br>", zatcaResponseList.Where(s => !string.IsNullOrEmpty(s.ErrorMessage)).Select(s => s.ErrorMessage)),
		//			WarningMessage = string.Join("<br>", zatcaResponseList.Where(s => !string.IsNullOrEmpty(s.WarningMessage)).Select(s => s.WarningMessage)),
		//			ReportingStatus = string.Join("<br>", zatcaResponseList.Select(s => s.InvoiceNo + "-" + s.ReportingStatus))
		//		};

		//		return finelResponse;
		//	}
		//	catch (Exception ex)
		//	{
		//		zatcaResponse.IsSuccess = false;
		//		zatcaResponse.ErrorMessage = ex.Message;
		//	}
		//	return zatcaResponse;
		//}

		public async Task<ZatcaResponseModel> ProcessZatcaPostedInvoiceAndGeneratePdf(long invoiceNo, string machineName, bool isGeneratePdfOnPostedOnly)
		{
            //List<string> invoiceList = new List<string>() { invoiceNo.ToString() };
            //List<int> invoiceintList = new List<int>() { invoiceNo };
            ZatcaResponseModel zatcaResponse = new ZatcaResponseModel() { IsSuccess = false, Result = -1, ErrorMessage = "Unable to process" };

            var invoiceResult = await _InvoiceDataManager.Get(invoiceNo);
			if (invoiceResult != null)
			{
				if (invoiceResult.InvoiceSummaryModel.IsSentToZatca == true || invoiceResult.InvoiceSummaryModel.ReportingStatus== "REPORTED"
					|| invoiceResult.InvoiceSummaryModel.ReportingStatus == "CLEARED")
				{
					zatcaResponse.IsSuccess = true;
                    zatcaResponse.InvoiceNo = invoiceResult.InvoiceSummaryModel.InvoiceNo;
                    var pdfPath = await SaveInvoicePDFA3InFolder(invoiceResult.InvoiceSummaryModel.InvoiceNo);
                    zatcaResponse.PdfPath = pdfPath;

                }
				else
				{
                    SellerMaster sellerMasterRef = new SellerMaster();
                    SellerDeviceConfiguration sellerDeviceConfigurationRef = new SellerDeviceConfiguration();
                    DeviceZatcaDetail deviceZatcaDetailRef = new DeviceZatcaDetail();
                    sellerMasterRef = await GetSellerInfo();
                    if (sellerMasterRef == null)
                    {
                        zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "Seller information not available");

                        return zatcaResponse;
                    }
                    sellerDeviceConfigurationRef = await GetSellerDeviceConfiguration(machineName);
                    if (sellerDeviceConfigurationRef == null)
                    {
                        zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "Device is not registered");


                        return zatcaResponse;
                    }

                    deviceZatcaDetailRef = await GetDeviceZatcaDetail(sellerDeviceConfigurationRef);
                    if (deviceZatcaDetailRef == null)
                    {
                        zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "No CSR available for user");

                        return zatcaResponse;
                    }

                    InvoiceModel previousInvoiceModel = null;
                    previousInvoiceModel = await _InvoiceDataManager.GetPreviousInvoice(invoiceResult.InvoiceSummaryModel);
                    //var vWInvoiceModel = await _InvoiceDataManager.GetInvoice(invoiceNo);

                    //zatcaResponse = await ProcessZatcaInvoice(invoiceResult, machineName, sellerMasterRef, sellerDeviceConfigurationRef,
                    //         previousInvoiceModel, vWInvoiceModel, isGeneratePdfOnPostedOnly, false);
                    zatcaResponse = await ProcessZatcaInvoice(invoiceResult, machineName, sellerMasterRef, sellerDeviceConfigurationRef,
                             previousInvoiceModel, isGeneratePdfOnPostedOnly, false);
                    if (zatcaResponse.IsSuccess)
					{
						zatcaResponse.InvoiceNo = invoiceResult.InvoiceSummaryModel.InvoiceNo;
						//this code for generate pdf file
						var pdfPath = await SaveInvoicePDFA3InFolder(invoiceResult.InvoiceSummaryModel.InvoiceNo);
						zatcaResponse.PdfPath = pdfPath;
					}
					else
					{
                        zatcaResponse = UpdateZatcaResponseMessgae(false, -1, zatcaResponse.ErrorMessage);

                        return zatcaResponse;
                    }
                   
                }
            }
		
			
			
			return zatcaResponse;
		}

		//public async Task<ZatcaResponseModel> ProcessZatcaSavedInvoiceAndGeneratePdf(long invoiceNo, string machineName, bool isGeneratePdfOnPostedOnly, bool isGeneratePdfOnSavedOnly)
		//{
		//	List<string> invoiceList = new List<string>() { invoiceNo.ToString() };
		//	List<long> invoiceintList = new List<long>() { invoiceNo };

		//	var invoiceResultList = await _InvoiceDataManager.GetByList(invoiceintList);
		//	var item = invoiceResultList.FirstOrDefault();

		//	ZatcaResponseModel zatcaResponse = new ZatcaResponseModel() { IsSuccess = false, Result = -1, ErrorMessage = "Unable to process" };

		//	SellerMaster sellerMasterRef = new SellerMaster();
		//	SellerDeviceConfiguration sellerDeviceConfigurationRef = new SellerDeviceConfiguration();
		//	DeviceZatcaDetail deviceZatcaDetailRef = new DeviceZatcaDetail();
		//	sellerMasterRef = await GetSellerInfo();
		//	if (sellerMasterRef == null)
		//	{
		//		zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "Seller information not available");
		//		return zatcaResponse;
		//	}

		//	sellerDeviceConfigurationRef = await GetSellerDeviceConfiguration(machineName);
		//	if (sellerDeviceConfigurationRef == null)
		//	{
		//		zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "Device is not registered");

		//		return zatcaResponse;
		//	}

		//	deviceZatcaDetailRef = await GetDeviceZatcaDetail(sellerDeviceConfigurationRef);
		//	if (deviceZatcaDetailRef == null)
		//	{
		//		zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "No CSR available for user");
		//		return zatcaResponse;
		//	}

		//	InvoiceModel previousInvoiceModel = null;
		//	previousInvoiceModel = await _InvoiceDataManager.GetPreviousInvoice(item.InvoiceSummaryModel);
		//	var parentIqama = await _InvoiceDataManager.GetInvoices(invoiceintList);
		//	VWInvoiceModel vWInvoiceModel = parentIqama.FirstOrDefault(s => s.InvoiceNo == item.InvoiceSummaryModel.InvoiceNo);

		//	zatcaResponse = await ProcessZatcaInvoice(item, machineName, sellerMasterRef, sellerDeviceConfigurationRef,
		//			 previousInvoiceModel, vWInvoiceModel, isGeneratePdfOnPostedOnly, isGeneratePdfOnSavedOnly);
		//	zatcaResponse.InvoiceNo = item.InvoiceSummaryModel.InvoiceNo;

		//	var pdfPath = await SaveInvoicePDFA3InFolder(item.InvoiceSummaryModel.InvoiceNo);
		//	zatcaResponse.PdfPath = pdfPath;
		//	return zatcaResponse;
		//}

		#endregion Process Zatca Method

		#region Private Method      

		private async Task<ZatcaResponseModel> ProcessZatcaInvoice(InvoiceModel invoiceModel, string machineName,
		 SellerMaster sellerMaster, SellerDeviceConfiguration sellerDeviceConfiguration,
		 InvoiceModel previousInvoiceModel,
		  bool isGeneratePdfOnPostedOnly, bool isGeneratePdfOnSavedOnly)
		{
            ZatcaResponseModel zatcaResponse = new ZatcaResponseModel();
			try
			{
				bool isException = false;

				try
				{
					Invoice inv = new Invoice();// _Mapper.Map<Invoice>(invoiceModel);

					ZatcaIntegrationSDK.Result res = new ZatcaIntegrationSDK.Result();

					inv.ID = invoiceModel.InvoiceSummaryModel.InvoiceNo.ToString();

					inv.IssueDate = invoiceModel.InvoiceSummaryModel.InvoiceDate.ToString("yyyy-MM-dd");
					inv.IssueTime = DateTime.Now.ToString("HH:mm:ss");

					inv.DocumentCurrencyCode = "SAR"; // Document Currency Code (invoice currency example SAR or USD) 
					inv.TaxCurrencyCode = "SAR";// Tax Currency Code it must be with SAR

					SetCalculateDisocunt(inv, invoiceModel);

					SetCalculateLineItems(inv, invoiceModel);

					//Update invoice type id and invoice type name
					SetInvoiceType(inv, invoiceModel);

					//Now set Invoice Hash for newly Invice
					SetInvoiceHash(inv, invoiceModel, previousInvoiceModel);

					//Now Set Payment method
					SetPaymentMethod(inv, invoiceModel);

					//Now invoice Type id is already set then validate SalesNot OR debit note
					SetInvoiceDocumentReference(inv, invoiceModel);

					//Set Supplier data
					SetSupplierParty(inv, invoiceModel, sellerMaster);

                    //Set Customer party data
                    //SetCustomerParty(inv, invoiceModel, vWInvoiceModel);
                    SetCustomerParty(inv, invoiceModel);

                    ZatcaIntegrationSDK.APIHelper.Mode mode = ZatcaIntegrationSDK.APIHelper.Mode.Simulation;
					if (_AppSettingConfig.InvoiceProcessMode != null
						&& Convert.ToString(_AppSettingConfig.InvoiceProcessMode).ToLower() == "production")
					{
						mode = ZatcaIntegrationSDK.APIHelper.Mode.Production;
					}

					//Now you need to set pass CSID data
					//CSIDInfo info = await GetCertificate(inv, invoiceModel, mode);
					CommonHelper commonHelper = new CommonHelper(_env);
					var keyFileSavePath = commonHelper.KeyFilePath("cert", "Device_" + sellerDeviceConfiguration.SellerDeviceConfigurationId.ToString());
					var CsrPath = System.IO.Path.Combine(keyFileSavePath, "csr.csr");
					var PrivateKeyPath = System.IO.Path.Combine(keyFileSavePath, "key.pem");
					var PublickeyPath = System.IO.Path.Combine(keyFileSavePath, "cert.pem");
					var SecretKeyPath = System.IO.Path.Combine(keyFileSavePath, "secret.txt");
					string secretkey = "";
					try
					{
						var CsrString = System.IO.File.ReadAllText(CsrPath);
						var PrivateKeyString = System.IO.File.ReadAllText(PrivateKeyPath);
						var PublickeyString = System.IO.File.ReadAllText(PublickeyPath);
						var SecretKeyString = System.IO.File.ReadAllText(SecretKeyPath);

						if (string.IsNullOrEmpty(CsrString) || string.IsNullOrEmpty(PrivateKeyString) || string.IsNullOrEmpty(PublickeyString) || string.IsNullOrEmpty(SecretKeyString))
						{
							zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "CSR OR CSID does not exists");
							return zatcaResponse;
						}

						//CSR- Private key-replaced
						inv.cSIDInfo.PrivateKey = PrivateKeyString;

						//CSID- Binary token
						inv.cSIDInfo.CertPem = PublickeyString;

						secretkey = SecretKeyString;
					}
					catch
					{
						zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "No certificate available in machine");
						return zatcaResponse;
					}
                    var xmlFilePathSave = commonHelper.KeyFilePath("xmlFiles"); 
					try
					{
						UBLXML ubl = new UBLXML();

						//if you need to save xml file true if not false;
						bool savexmlfile = true;

						// this method is used to generate xml file with invoice data 

						
                       res = ubl.GenerateInvoiceXML(inv, xmlFilePathSave, savexmlfile);

						
					}
					catch (Exception ex)
					{
						//Raise exception
					}
					if (!res.IsValid)
					{
                        //Raise Message
                        zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "Error while Generating XML : "+res.ErrorMessage);
                        return zatcaResponse;
                    }
					//else
					//{
                       
     //               }
                   
                    ApiRequestLogic apireqlogic = new ApiRequestLogic(mode, xmlFilePathSave, true);

					InvoiceReportingRequest invrequestbody = new InvoiceReportingRequest
					{
						invoice = res.EncodedInvoice,
						invoiceHash = res.InvoiceHash,
						uuid = res.UUID
					};

					//Now save to database table for given invoice

					if (mode == ZatcaIntegrationSDK.APIHelper.Mode.developer)
					{
						var mobileOtp = "127884";
						ComplianceCsrResponse tokenresponse = new ComplianceCsrResponse();
						string csr = inv.cSIDInfo.CSR;

						tokenresponse = apireqlogic.GetComplianceCSIDAPI(mobileOtp, csr);
						if (String.IsNullOrEmpty(tokenresponse.ErrorMessage))
						{
							InvoiceReportingResponse responsemodel = apireqlogic.CallComplianceInvoiceAPI(tokenresponse.BinarySecurityToken, tokenresponse.Secret, invrequestbody);
							if (responsemodel.IsSuccess)
							{
								if (responsemodel.StatusCode == 202)
								{
									//save warning message in database to solve for next invoices
									//responsemodel.WarningMessage
								}
								//MessageBox.Show(responsemodel.ReportingStatus + responsemodel.ClearanceStatus); //REPORTED
								//PictureBox1.Image = QrCodeImage(res.QRCode, 200, 200);

								var tupleResult = QrCodeImage(res.QRCode, 200, 200);
								zatcaResponse.QRImg = tupleResult.Item1;
							}
							else
							{
								//TODO: Show Message
								//MessageBox.Show(responsemodel.ErrorMessage);
							}
						}
						else
						{
							//TODO: Show Message
							// MessageBox.Show(tokenresponse.ErrorMessage);
						}
					}
					else
					{
                        //Production OR Simulation
                        //this code is for simulation and production mode
                        
                        //Standard invoice strat with 01
                        if (inv.invoiceTypeCode.Name.Substring(0, 2) == "01")
						{
                            
                            // to send standard invoices for clearing
                            //this this the calling of api 
                            zatcaResponse = await ProcessProduction_Simulation_StandardInvoice(apireqlogic, inv, invrequestbody, invoiceModel, res, secretkey);
							return zatcaResponse;
						}
						else
						{
                           
                            //to send simplified invoices for reporting
                            //this this the calling of api 
                            zatcaResponse = await ProcessProduction_Simulation_SimplifiedInvoice(apireqlogic, inv, invrequestbody, invoiceModel, res, secretkey, isGeneratePdfOnPostedOnly, isGeneratePdfOnSavedOnly);
							return zatcaResponse;
						}
					}
				}
				catch (Exception ex)
				{
					
					isException = true;
				}
				

				zatcaResponse.IsSuccess = !isException;
				zatcaResponse.Result = isException ? -1 : 0;
				zatcaResponse.ErrorMessage = "";
			}
			catch (Exception ex)
			{
				logger.LogInformation("End Exception: ZatcaHelper ProcessZatcaInvoice  " + ex.Message);
				throw ex;
			}

			logger.LogInformation("End: ProcessZatcaInvoice Invoice no: " + invoiceModel.InvoiceSummaryModel.InvoiceNo);

			return zatcaResponse;
		}
        //private async Task<ZatcaResponseModel> ProcessZatcaInvoice(InvoiceModel invoiceModel, string machineName,
        // SellerMaster sellerMaster, SellerDeviceConfiguration sellerDeviceConfiguration,
        // InvoiceModel previousInvoiceModel,
        // VWInvoiceModel vWInvoiceModel, bool isGeneratePdfOnPostedOnly, bool isGeneratePdfOnSavedOnly)
        //{
        //    ZatcaResponseModel zatcaResponse = new ZatcaResponseModel();
        //    try
        //    {
        //        bool isException = false;

        //        try
        //        {
        //            Invoice inv = new Invoice();// _Mapper.Map<Invoice>(invoiceModel);

        //            ZatcaIntegrationSDK.Result res = new ZatcaIntegrationSDK.Result();

        //            inv.ID = invoiceModel.InvoiceSummaryModel.InvoiceNo.ToString();

        //            inv.IssueDate = invoiceModel.InvoiceSummaryModel.InvoiceDate.ToString("yyyy-MM-dd");
        //            inv.IssueTime = DateTime.Now.ToString("HH:mm:ss");

        //            inv.DocumentCurrencyCode = "SAR"; // Document Currency Code (invoice currency example SAR or USD) 
        //            inv.TaxCurrencyCode = "SAR";// Tax Currency Code it must be with SAR

        //            SetCalculateDisocunt(inv, invoiceModel);

        //            SetCalculateLineItems(inv, invoiceModel);

        //            //Update invoice type id and invoice type name
        //            SetInvoiceType(inv, invoiceModel);

        //            //Now set Invoice Hash for newly Invice
        //            SetInvoiceHash(inv, invoiceModel, previousInvoiceModel);

        //            //Now Set Payment method
        //            SetPaymentMethod(inv, invoiceModel);

        //            //Now invoice Type id is already set then validate SalesNot OR debit note
        //            SetInvoiceDocumentReference(inv, invoiceModel);

        //            //Set Supplier data
        //            SetSupplierParty(inv, invoiceModel, sellerMaster);

        //            //Set Customer party data
        //            SetCustomerParty(inv, invoiceModel, vWInvoiceModel);

        //            ZatcaIntegrationSDK.APIHelper.Mode mode = ZatcaIntegrationSDK.APIHelper.Mode.Simulation;
        //            if (_AppSettingConfig.InvoiceProcessMode != null
        //                && Convert.ToString(_AppSettingConfig.InvoiceProcessMode).ToLower() == "production")
        //            {
        //                mode = ZatcaIntegrationSDK.APIHelper.Mode.Production;
        //            }

        //            //Now you need to set pass CSID data
        //            //CSIDInfo info = await GetCertificate(inv, invoiceModel, mode);
        //            CommonHelper commonHelper = new CommonHelper(_env);
        //            var keyFileSavePath = commonHelper.KeyFilePath("cert", "Device_" + sellerDeviceConfiguration.SellerDeviceConfigurationId.ToString());
        //            var CsrPath = System.IO.Path.Combine(keyFileSavePath, "csr.csr");
        //            var PrivateKeyPath = System.IO.Path.Combine(keyFileSavePath, "key.pem");
        //            var PublickeyPath = System.IO.Path.Combine(keyFileSavePath, "cert.pem");
        //            var SecretKeyPath = System.IO.Path.Combine(keyFileSavePath, "secret.txt");
        //            string secretkey = "";
        //            try
        //            {
        //                var CsrString = System.IO.File.ReadAllText(CsrPath);
        //                var PrivateKeyString = System.IO.File.ReadAllText(PrivateKeyPath);
        //                var PublickeyString = System.IO.File.ReadAllText(PublickeyPath);
        //                var SecretKeyString = System.IO.File.ReadAllText(SecretKeyPath);

        //                if (string.IsNullOrEmpty(CsrString) || string.IsNullOrEmpty(PrivateKeyString) || string.IsNullOrEmpty(PublickeyString) || string.IsNullOrEmpty(SecretKeyString))
        //                {
        //                    zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "CSR OR CSID does not exists");
        //                    return zatcaResponse;
        //                }

        //                //CSR- Private key-replaced
        //                inv.cSIDInfo.PrivateKey = PrivateKeyString;

        //                //CSID- Binary token
        //                inv.cSIDInfo.CertPem = PublickeyString;

        //                secretkey = SecretKeyString;
        //            }
        //            catch
        //            {
        //                zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "No certificate available in machine");
        //                return zatcaResponse;
        //            }
        //            try
        //            {
        //                UBLXML ubl = new UBLXML();

        //                //if you need to save xml file true if not false;
        //                bool savexmlfile = true;

        //                // this method is used to generate xml file with invoice data 

        //                var xmlFilePathSave = commonHelper.KeyFilePath("xmlFiles");
        //                res = ubl.GenerateInvoiceXML(inv, xmlFilePathSave, savexmlfile);


        //            }
        //            catch (Exception ex)
        //            {
        //                //Raise exception
        //            }
        //            if (!res.IsValid)
        //            {
        //                //Raise Message
        //                zatcaResponse = UpdateZatcaResponseMessgae(false, -1, "Error while Generating XML : " + res.ErrorMessage);
        //                return zatcaResponse;
        //            }
        //            //else
        //            //{

        //            //               }

        //            ApiRequestLogic apireqlogic = new ApiRequestLogic(mode, keyFileSavePath, true);

        //            InvoiceReportingRequest invrequestbody = new InvoiceReportingRequest
        //            {
        //                invoice = res.EncodedInvoice,
        //                invoiceHash = res.InvoiceHash,
        //                uuid = res.UUID
        //            };

        //            //Now save to database table for given invoice

        //            if (mode == ZatcaIntegrationSDK.APIHelper.Mode.developer)
        //            {
        //                var mobileOtp = "127884";
        //                ComplianceCsrResponse tokenresponse = new ComplianceCsrResponse();
        //                string csr = inv.cSIDInfo.CSR;

        //                //                string csr = @"-----BEGIN CERTIFICATE REQUEST-----
        //                //MIIB5DCCAYoCAQAwVTELMAkGA1UEBhMCU0ExFjAUBgNVBAsMDUVuZ2F6YXRCcmFu
        //                //Y2gxEDAOBgNVBAoMB0VuZ2F6YXQxHDAaBgNVBAMME1RTVC0zMDAzMDA4Njg2MDAw
        //                //MDMwVjAQBgcqhkjOPQIBBgUrgQQACgNCAARYvqwxwBzinhARQZYQnWBoSr8wMmmw
        //                //CdfTSleD+rZoh/NeJMF8reXaBFrMCrlPK0hTRXmCyXuc6nFUfjSvZU/goIHVMIHS
        //                //BgkqhkiG9w0BCQ4xgcQwgcEwIgYJKwYBBAGCNxQCBBUTE1RTVFpBVENBQ29kZVNp
        //                //Z25pbmcwgZoGA1UdEQSBkjCBj6SBjDCBiTE7MDkGA1UEBAwyMS1UU1R8Mi1UU1R8
        //                //My1lZDIyZjFkOC1lNmEyLTExMTgtOWI1OC1kOWE4ZjExZTQ0NWYxHzAdBgoJkiaJ
        //                //k/IsZAEBDA8zMDAzMDA4Njg2MDAwMDMxDTALBgNVBAwMBDExMDAxDDAKBgNVBBoM
        //                //A1RTVDEMMAoGA1UEDwwDVFNUMAoGCCqGSM49BAMCA0gAMEUCIQDRroaukEGwwRXW
        //                //RhOudGrd/OGrcUnnn2ftb6Jk4dDGFgIgaV+sXmaZlKbxR7k/lMhnf/2j95XHDkso
        //                //hup1ROPc+cc=
        //                //-----END CERTIFICATE REQUEST-----
        //                //";
        //                tokenresponse = apireqlogic.GetComplianceCSIDAPI(mobileOtp, csr);
        //                if (String.IsNullOrEmpty(tokenresponse.ErrorMessage))
        //                {
        //                    InvoiceReportingResponse responsemodel = apireqlogic.CallComplianceInvoiceAPI(tokenresponse.BinarySecurityToken, tokenresponse.Secret, invrequestbody);
        //                    if (responsemodel.IsSuccess)
        //                    {
        //                        if (responsemodel.StatusCode == 202)
        //                        {
        //                            //save warning message in database to solve for next invoices
        //                            //responsemodel.WarningMessage
        //                        }
        //                        //MessageBox.Show(responsemodel.ReportingStatus + responsemodel.ClearanceStatus); //REPORTED
        //                        //PictureBox1.Image = QrCodeImage(res.QRCode, 200, 200);

        //                        var tupleResult = QrCodeImage(res.QRCode, 200, 200);
        //                        zatcaResponse.QRImg = tupleResult.Item1;
        //                    }
        //                    else
        //                    {
        //                        //TODO: Show Message
        //                        //MessageBox.Show(responsemodel.ErrorMessage);
        //                    }
        //                }
        //                else
        //                {
        //                    //TODO: Show Message
        //                    // MessageBox.Show(tokenresponse.ErrorMessage);
        //                }
        //            }
        //            else
        //            {
        //                //Production OR Simulation
        //                //this code is for simulation and production mode

        //                //Standard invoice strat with 01
        //                if (inv.invoiceTypeCode.Name.Substring(0, 2) == "01")
        //                {

        //                    // to send standard invoices for clearing
        //                    //this this the calling of api 
        //                    zatcaResponse = await ProcessProduction_Simulation_StandardInvoice(apireqlogic, inv, invrequestbody, invoiceModel, res, secretkey);
        //                    return zatcaResponse;
        //                }
        //                else
        //                {

        //                    //to send simplified invoices for reporting
        //                    //this this the calling of api 
        //                    zatcaResponse = await ProcessProduction_Simulation_SimplifiedInvoice(apireqlogic, inv, invrequestbody, invoiceModel, res, secretkey, isGeneratePdfOnPostedOnly, isGeneratePdfOnSavedOnly);
        //                    return zatcaResponse;
        //                }
        //            }
        //        }
        //        catch (Exception ex)
        //        {

        //            isException = true;
        //        }


        //        zatcaResponse.IsSuccess = !isException;
        //        zatcaResponse.Result = isException ? -1 : 0;
        //        zatcaResponse.ErrorMessage = "";
        //    }
        //    catch (Exception ex)
        //    {
        //        logger.LogInformation("End Exception: ZatcaHelper ProcessZatcaInvoice  " + ex.Message);
        //        throw ex;
        //    }

        //    logger.LogInformation("End: ProcessZatcaInvoice Invoice no: " + invoiceModel.InvoiceSummaryModel.InvoiceNo);

        //    return zatcaResponse;
        //}

        private async Task<ZatcaResponseModel> ProcessProduction_Simulation_StandardInvoice(ApiRequestLogic apireqlogic, Invoice inv, InvoiceReportingRequest invrequestbody, InvoiceModel invoiceModel, ZatcaIntegrationSDK.Result res, string secretkey)
		{
			try
			{
                ZatcaResponseModel zatcaResponse = new ZatcaResponseModel()
				{
					IsSuccess = false,
					Result = -1,
					ErrorMessage = "Unable to process data on Zatca"
				};
                
                InvoiceClearanceResponse responsemodel = apireqlogic.CallClearanceAPI(Utility.ToBase64Encode(inv.cSIDInfo.CertPem), secretkey, invrequestbody);
                //if responsemodel.IsSuccess = true this means that your xml is successfully sent to zatca 
                if (responsemodel.IsSuccess)
				{

					///////////
					//if status code =202 it means that xml accepted but with warning 
					//no need to sent xml again but you must solve that warning messages for the next invoices
					string WarningMessage = "";

                    if (responsemodel.StatusCode == 202)
					{
						//save warning message in database to solve for next invoices
						WarningMessage = responsemodel.WarningMessage;
					}
					var tupleResult = QrCodeImage(responsemodel.QRCode, 200, 200);
					zatcaResponse.QRImg = tupleResult.Item1;

					//invrequestbody.invoice = res.EncodedInvoice;
					//invrequestbody.invoiceHash = res.InvoiceHash;
					//invrequestbody.uuid = res.UUID;
                    
                    bool isSaveZATCAResponse = await _InvoiceDataManager.SaveZatcaResponse(invoiceModel.InvoiceSummaryModel.InvoiceNo, invrequestbody.invoice, invrequestbody.invoiceHash
						, invrequestbody.uuid, responsemodel.ClearanceStatus, zatcaResponse.QRImg, res.SingedXMLFileNameFullPath,responsemodel.ClearedInvoice,"", WarningMessage,responsemodel.IsSuccess,responsemodel.StatusCode, "Posted");
                   
                    zatcaResponse.IsSuccess = isSaveZATCAResponse;
					zatcaResponse.Result = isSaveZATCAResponse ? 0 : -1;
					zatcaResponse.ErrorMessage = isSaveZATCAResponse ? "invoice is processed" : "Unable to process data on Zatca";
					return zatcaResponse;
				}
				else
				{
					zatcaResponse.IsSuccess = false;
					zatcaResponse.Result = -1;
					zatcaResponse.ErrorMessage = "Unable to process data on Zatca";
					return zatcaResponse;
				}
			}
			catch (Exception ex)
			{
				logger.LogInformation("End Exception: ZatcaHelper ProcessProduction_Simulation_StandardInvoice  " + ex.Message);
				throw ex;
			}
		}

        //private async Task<ZatcaResponseModel> ProcessProduction_Simulation_SimplifiedInvoice(ApiRequestLogic apireqlogic, Invoice inv, InvoiceReportingRequest invrequestbody,
        //	InvoiceModel invoiceModel, ZatcaIntegrationSDK.Result res, string secretkey, bool isGeneratePdfOnPostedOnly, bool isGeneratePdfOnSavedOnly)
        //{
        //	try
        //	{
        //		logger.LogInformation("Start: GenerateInvoiceXML: isGeneratePdfOnSavedOnly: " + isGeneratePdfOnSavedOnly + ", isGeneratePdfOnPostedOnly: " + isGeneratePdfOnPostedOnly);
        //              ZatcaResponseModel zatcaResponse = new ZatcaResponseModel()
        //		{
        //			IsSuccess = res.IsValid,
        //			Result = res.IsValid ? 1 : -1,
        //			ErrorMessage = "Unable to process data on Zatca"
        //		};

        //		zatcaResponse.IsSuccess = res.IsValid;
        //		zatcaResponse.ErrorMessage = res.ErrorMessage;

        //		if (isGeneratePdfOnSavedOnly)
        //		{
        //			logger.LogInformation("Start: GenerateInvoiceXML with Save only for saved invoice");

        //			try
        //			{
        //				//Get drafted image
        //				var tupleResult = GetDraftedCodeImage();
        //				zatcaResponse.QRImg = tupleResult.Item1;

        //				bool isSaveZATCAResponse = await _InvoiceDataManager.SaveZatcaResponse(invoiceModel.InvoiceSummaryModel.InvoiceNo,
        //					invrequestbody.invoice, invrequestbody.invoiceHash
        //					   , invrequestbody.uuid, "Not Reported", zatcaResponse.QRImg, res.SingedXMLFileNameFullPath,"",res.WarningMessage, false, "Saved");

        //				zatcaResponse.XMLFilePath = res.SingedXMLFileNameFullPath;

        //				zatcaResponse = UpdateZatcaResponseMessgae(true, 1, "QR code generated successfully");

        //				logger.LogInformation("Process: GenerateInvoiceXML- Saved Status: " + isSaveZATCAResponse + ", XMLFilePath" + zatcaResponse.XMLFilePath);
        //			}
        //			catch (Exception ex)
        //			{
        //				zatcaResponse = UpdateZatcaResponseMessgae(false, 1, "Unable to process QR code generate");
        //				logger.LogInformation("End Exception: GenerateInvoiceXML with Save only- Error" + ex.Message);
        //				throw ex;
        //			}
        //			logger.LogInformation("End: GenerateInvoiceXML with Save only for saved invoice");
        //		}
        //		else if (isGeneratePdfOnPostedOnly)
        //		{
        //			logger.LogInformation("Start: GenerateInvoiceXML with Save only for posted invoice");

        //			try
        //			{
        //				var tupleResult = QrCodeImage(res.QRCode, 200, 200);
        //				zatcaResponse.QRImg = tupleResult.Item1;

        //				bool isSaveZATCAResponse = await _InvoiceDataManager.SaveZatcaResponse(invoiceModel.InvoiceSummaryModel.InvoiceNo,
        //					invrequestbody.invoice, invrequestbody.invoiceHash
        //					   , invrequestbody.uuid, "Not Reported", zatcaResponse.QRImg, res.SingedXMLFileNameFullPath,"",res.WarningMessage,false, "Saved");

        //				zatcaResponse.XMLFilePath = res.SingedXMLFileNameFullPath;

        //				zatcaResponse = UpdateZatcaResponseMessgae(true, 1, "XML file generated");
        //				logger.LogInformation("Process: GenerateInvoiceXML- Saved Status: " + isSaveZATCAResponse + ", XMLFilePath" + zatcaResponse.XMLFilePath);
        //			}
        //			catch (Exception ex)
        //			{
        //				zatcaResponse = UpdateZatcaResponseMessgae(false, 1, "Unable to process XML file generate");
        //				logger.LogInformation("End Exception: GenerateInvoiceXML with Save only- Error" + ex.Message);
        //				throw ex;
        //			}
        //			logger.LogInformation("End: GenerateInvoiceXML with Save only for posted invoice");
        //		}
        //		else
        //		{
        //			var tupleResult = QrCodeImage(res.QRCode, 200, 200);
        //			zatcaResponse.QRImg = tupleResult.Item1;
        //                  logger.LogInformation("before CallReportingAPI");

        //                  InvoiceReportingResponse responsemodel = apireqlogic.CallReportingAPI(Utility.ToBase64Encode(inv.cSIDInfo.CertPem), secretkey, invrequestbody);
        //                  logger.LogInformation("CallReportingAPI:"+responsemodel.ReportingStatus);
        //                  if (responsemodel.IsSuccess)
        //			{
        //				//if status code =202 it means that xml accespted but with warning 
        //				//no need to sent xml again but you must solve that warning messages for the next invoices
        //				string WarningMessage = "";

        //                      if (responsemodel.StatusCode == 202)
        //				{
        //					//save warning message in database to solve for next invoices
        //					WarningMessage = responsemodel.WarningMessage;
        //				}
        //				zatcaResponse.ReportingStatus = responsemodel.ReportingStatus;
        //				zatcaResponse.ErrorMessage = responsemodel.ErrorMessage;
        //				zatcaResponse.WarningMessage = responsemodel.WarningMessage;

        //				invrequestbody.invoice = res.EncodedInvoice;
        //				invrequestbody.invoiceHash = res.InvoiceHash;
        //				invrequestbody.uuid = res.UUID;
        //                      logger.LogInformation("before SaveZatcaResponse CallReportingAPI ");
        //                      bool isSaveZATCAResponse = await _InvoiceDataManager.SaveZatcaResponse(invoiceModel.InvoiceSummaryModel.InvoiceNo, invrequestbody.invoice, invrequestbody.invoiceHash
        //					, invrequestbody.uuid, responsemodel.ReportingStatus, zatcaResponse.QRImg, res.SingedXMLFileNameFullPath,"", WarningMessage,responsemodel.IsSuccess, "Posted");
        //                      logger.LogInformation("before SaveZatcaResponse CallReportingAPI");
        //                      zatcaResponse.XMLFilePath = res.SingedXMLFileNameFullPath;

        //				zatcaResponse = UpdateZatcaResponseMessgae(true, 1, "XML file generated");
        //				logger.LogInformation("Process: GenerateInvoiceXML- Saved Status: " + isSaveZATCAResponse + ", XMLFilePath" + zatcaResponse.XMLFilePath);

        //				return zatcaResponse;
        //			}
        //			else
        //			{
        //				zatcaResponse = UpdateZatcaResponseMessgae(false, 1, "Unable to process XML file generate");

        //				zatcaResponse.ErrorMessage = responsemodel.ErrorMessage;
        //				zatcaResponse.WarningMessage = responsemodel.WarningMessage;
        //				zatcaResponse.ReportingStatus = responsemodel.WarningMessage;
        //			}

        //			zatcaResponse.IsSuccess = responsemodel.IsSuccess;
        //		}
        //		logger.LogInformation("End: GenerateInvoiceXML");
        //		return zatcaResponse;
        //	}
        //	catch (Exception ex)
        //	{
        //		logger.LogInformation("End Exception: ZatcaHelper ProcessProduction_Simulation_SimplifiedInvoice  " + ex.Message);
        //		throw ex;
        //	}
        //}
        private async Task<ZatcaResponseModel> ProcessProduction_Simulation_SimplifiedInvoice(ApiRequestLogic apireqlogic, Invoice inv, InvoiceReportingRequest invrequestbody,
            InvoiceModel invoiceModel, ZatcaIntegrationSDK.Result res, string secretkey, bool isGeneratePdfOnPostedOnly, bool isGeneratePdfOnSavedOnly)
        {
            try
            {
                logger.LogInformation("Start: GenerateInvoiceXML: isGeneratePdfOnSavedOnly: " + isGeneratePdfOnSavedOnly + ", isGeneratePdfOnPostedOnly: " + isGeneratePdfOnPostedOnly);
                ZatcaResponseModel zatcaResponse = new ZatcaResponseModel()
                {
                    IsSuccess = res.IsValid,
                    Result = res.IsValid ? 1 : -1,
                    ErrorMessage = "Unable to process data on Zatca"
                };

                zatcaResponse.IsSuccess = false;
                zatcaResponse.ErrorMessage = res.ErrorMessage;

               var tupleResult = QrCodeImage(res.QRCode, 200, 200);
                    zatcaResponse.QRImg = tupleResult.Item1;
                   
                    InvoiceReportingResponse responsemodel = apireqlogic.CallReportingAPI(Utility.ToBase64Encode(inv.cSIDInfo.CertPem), secretkey, invrequestbody);
                    logger.LogInformation("CallReportingAPI:" + responsemodel.ReportingStatus);
                zatcaResponse.ReportingStatus = responsemodel.ReportingStatus;
                zatcaResponse.IsSuccess = responsemodel.IsSuccess;
                zatcaResponse.StatusCode = responsemodel.StatusCode;
                zatcaResponse.XMLFilePath = res.SingedXMLFileNameFullPath;
                if (responsemodel.IsSuccess)
                    {
                        //if status code =202 it means that xml accespted but with warning 
                        //no need to sent xml again but you must solve that warning messages for the next invoices
                        string WarningMessage = "";

                        if (responsemodel.StatusCode == 202)
                        {
                            //save warning message in database to solve for next invoices
                            WarningMessage = responsemodel.WarningMessage;
                        }
                        
                        zatcaResponse.ErrorMessage = "";
                        zatcaResponse.WarningMessage = WarningMessage;
                       
                        bool isSaveZATCAResponse = await _InvoiceDataManager.SaveZatcaResponse(invoiceModel.InvoiceSummaryModel.InvoiceNo, res.EncodedInvoice, res.InvoiceHash
                            , res.UUID, responsemodel.ReportingStatus, zatcaResponse.QRImg, res.SingedXMLFileNameFullPath, "","", WarningMessage, responsemodel.IsSuccess,responsemodel.StatusCode, "Posted");
                    
                        //zatcaResponse = UpdateZatcaResponseMessgae(true, 1, "XML file generated");
                        logger.LogInformation("Process: GenerateInvoiceXML- Saved Status: " + isSaveZATCAResponse + ", XMLFilePath" + zatcaResponse.XMLFilePath);

                        return zatcaResponse;
                    }
                    else
                    {
                    bool isSaveZATCAResponse = await _InvoiceDataManager.SaveZatcaResponse(invoiceModel.InvoiceSummaryModel.InvoiceNo, res.EncodedInvoice, res.InvoiceHash
                           , res.UUID, responsemodel.ReportingStatus, zatcaResponse.QRImg, res.SingedXMLFileNameFullPath, "", responsemodel.ErrorMessage,"", responsemodel.IsSuccess,responsemodel.StatusCode, "Saved");

                    zatcaResponse = UpdateZatcaResponseMessgae(false, 1, "Unable to process XML file generate");

                        zatcaResponse.ErrorMessage = responsemodel.ErrorMessage;
                        
                    }

                logger.LogInformation("End: GenerateInvoiceXML");
                return zatcaResponse;
            }
            catch (Exception ex)
            {
                logger.LogInformation("End Exception: ZatcaHelper ProcessProduction_Simulation_SimplifiedInvoice  " + ex.Message);
                throw ex;
            }
        }

        #endregion Private Method

        #region Invoice Pdf Save method
        private async Task<string> SaveInvoicePDFA3InFolder(long invoiceNo)
		{
            string logmessage = "";
            try
			{
                logger.LogInformation("begin generate pdf a3");

               
				InvInvoiceSummary InvoiceSummaryModel = _ALSContextDB.InvInvoiceSummaries.FirstOrDefault(f => f.InvoiceNo == invoiceNo);
                
                CommonHelper commonHelper = new CommonHelper(_env);
				var directoryPath = commonHelper.KeyFilePath("invoicepdfa3");
               
                //Shared file path
                string invoiceSavePath = _AppSettingConfig.InvoicePdfPath;
                
                if (!Directory.Exists(invoiceSavePath))
					Directory.CreateDirectory(invoiceSavePath);
               
                string newSavepdfPath = Path.Combine(directoryPath, "Invoice_A3_" + invoiceNo + ".pdf");
				invoiceSavePath = Path.Combine(invoiceSavePath, "Invoice_A3_" + invoiceNo + ".pdf");
                string rootpath = _env.WebRootPath;
               
				//this method is the reason for slow
				//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                var generatedInvoicepdfPath = _EmailManager.GetEmail("invoice_pdf_simplifiedinvoice", invoiceNo,rootpath);
                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                //var invoiceRecord = await _InvoiceDataManager.Get(invoiceNo);
				

                if (!string.IsNullOrEmpty(InvoiceSummaryModel.SignedXMLPath) && !string.IsNullOrEmpty(generatedInvoicepdfPath))
				{
					try
					{
                        string clearedinvoice = "";
						if (!string.IsNullOrEmpty(InvoiceSummaryModel.ClearedInvoice))
						{
							clearedinvoice = InvoiceSummaryModel.ClearedInvoice;

						}
						else
						{
                            clearedinvoice = InvoiceSummaryModel.EncodedInvoice;
                        }
						string tempdir = directoryPath;
                        PdfHelper pdfHelper = new PdfHelper();
                      
                        var result = pdfHelper.ConvertEncodedXMLToPDFA3ByteArray(clearedinvoice, generatedInvoicepdfPath, newSavepdfPath,tempdir);
                       
                        if (result.IsValid)
						{
							byte[] a3fileBytes = result.PDFA3ContentFile;

							try
							{
								//Process file to server path
								System.IO.File.WriteAllBytes(invoiceSavePath, a3fileBytes);

								//Delete file from here 
								DeletePreviousGeneratedFile(InvoiceSummaryModel);
							}
							catch (Exception ex)
							{
                                logger.LogInformation("exception with Process pdf a3 file to server path:" + ex.Message);
                            }

							InvoiceSummaryModel.InvoicePdfPath = newSavepdfPath;
							await _ALSContextDB.SaveChangesAsync();

							return InvoiceSummaryModel.InvoicePdfPath;
						}
					}
					catch
					{
					}
				}
                logger.LogInformation("byte[] fileBytes = System.IO.File.ReadAllBytes(generatedInvoicepdfPath);:");

                byte[] fileBytes = System.IO.File.ReadAllBytes(generatedInvoicepdfPath);
				System.IO.File.WriteAllBytes(newSavepdfPath, fileBytes);
				InvoiceSummaryModel.InvoicePdfPath = newSavepdfPath;
                logger.LogInformation("after byte[] fileBytes = System.IO.File.ReadAllBytes(generatedInvoicepdfPath);:");

                await _ALSContextDB.SaveChangesAsync();
				return InvoiceSummaryModel.InvoicePdfPath;
			}
			catch (Exception ex)
			{
               
				throw ex;
			}
		}
		#endregion Invoice Pdf Save method

		#region Set Seller Info and Device info
		private async Task<SellerMaster> GetSellerInfo()
		{
			
			try
			{
				var sellerMasterList = await _ISellerMasterManager.GetAll();
				return sellerMasterList.FirstOrDefault();
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		private async Task<SellerDeviceConfiguration> GetSellerDeviceConfiguration(string machineName)
		{
			
			try
			{
                ZatcaResponseModel zatcaResponse = new ZatcaResponseModel();

				return await _ISellerDeviceConfigurationManager.GetByMachineName(machineName);
			}
			catch (Exception ex)
			{
				
				throw ex;
			}
		}

		private async Task<DeviceZatcaDetail> GetDeviceZatcaDetail(SellerDeviceConfiguration sellerDeviceConfiguration)
		{
			logger.LogInformation("Get: ZatcaHelper GetDeviceZatcaDetail");
			try
			{
				return await _IDeviceZatcaDetailManager.GetByDeviceCOnfiguration(sellerDeviceConfiguration.SellerDeviceConfigurationId);
			}
			catch (Exception ex)
			{
				logger.LogError("ZatcaHelper GetDeviceZatcaDetail- Error: " + ex.Message);
				throw ex;
			}
		}

		#endregion

		#region Zatca property Set Property
		private void SetSupplierParty(Invoice inv, InvoiceModel model, SellerMaster sellerMaster)
		{
			logger.LogInformation("Start: ZatcaHelper SetSupplierParty");
			try
			{
				// بيانات البائع 
				//seller date
				//other identifier for seller like commercial registration number
				inv.SupplierParty.partyIdentification.ID = sellerMaster.SchemaNo.ToString(); // رقم السجل التجارى الخاض بالبائع
				//other identifier scheme id example CRN for commercial registration number
				inv.SupplierParty.partyIdentification.schemeID = !String.IsNullOrEmpty(sellerMaster.SchemeType)? sellerMaster.SchemeType.ToUpper() : "CRN" ; // رقم السجل التجارى
				 //seller street name mandatory
				inv.SupplierParty.postalAddress.StreetName = sellerMaster.StreetName; // اجبارى
				//inv.SupplierParty.postalAddress.AdditionalStreetName = ""; // اختيارى
				 //seller buliding number mandatory must be 4 digits
				inv.SupplierParty.postalAddress.BuildingNumber = sellerMaster.BuildingNumber; // اجبارى رقم المبنى
				// inv.SupplierParty.postalAddress.PlotIdentification = "9833"; //اختيارى
				//seller city name 
				inv.SupplierParty.postalAddress.CityName = sellerMaster.CityName; // اسم المدينة
				//seller postal zone must be 5 digits 
				inv.SupplierParty.postalAddress.PostalZone = sellerMaster.PostalZone; // الرقم البريدي
																					  //inv.SupplierParty.postalAddress.CountrySubentity = "Riyadh Region"; // اسم المحافظة او المدينة مثال (مكة) اختيارى
																					  //seller City Subdivision Name
				inv.SupplierParty.postalAddress.CitySubdivisionName = sellerMaster.CitySubdivisionName; // اسم المنطقة او الحى 
																										//SA for Saudi it must be SA with seller data
				inv.SupplierParty.postalAddress.country.IdentificationCode = sellerMaster.CountyIdentificationCode.ToUpper();
				// seller company name
				inv.SupplierParty.partyLegalEntity.RegistrationName = sellerMaster.OrganizationName; // اسم الشركة المسجل فى الهيئة
																									 //seller vat registration number must be 15 digits and start with 3 and end with 3
				inv.SupplierParty.partyTaxScheme.CompanyID = sellerMaster.OrganizationIdentifier;  // رقم التسجيل الضريبي
			}
			catch (Exception ex)
			{
				logger.LogError("ZatcaHelper SetSupplierParty- Error: " + ex.Message);
				throw ex;
			}
			logger.LogInformation("End: ZatcaHelper SetSupplierParty");
		}
        private void SetCustomerParty(Invoice inv, InvoiceModel model)
        {
            logger.LogInformation("Start: ZatcaHelper SetCustomerParty");
            try
            {
                //NAT = for Saudi National
                //IQA for Non Saudi
                var fatherIQAMA = "";
				string parentname = "";
                
                 if (model.InvoiceSummaryModel != null)
                {
                    fatherIQAMA = model.InvoiceSummaryModel.IqamaNumber;
                }

                var isVatAvailable = model.InvoiceDetailModelLst.Where(x=>!x.InvoiceType.ToLower().Contains("uniform")).Any(s => s.TaxRate > 0);

                //if (!isVatAvailable)
                //{
                //    isVatAvailable = model.UniformDetailModelLst.Any(s => !string.IsNullOrEmpty(s.TaxRate) && Convert.ToDecimal(s.TaxRate) > 0);
                //}

                if (isVatAvailable && !string.IsNullOrEmpty(fatherIQAMA))
                {
                    //inv.CustomerParty.partyIdentification.ID = "IQA"; // رقم السجل التجارى الخاص بالمشترى  // iqama number id
                    //inv.CustomerParty.partyIdentification.schemeID = studentParentInfo.FatherIQAMA; //رقم السجل التجارى //iqaman number
                    inv.CustomerParty.partyIdentification.ID = fatherIQAMA;
                    inv.CustomerParty.partyIdentification.schemeID = "IQA"; //رقم السجل التجارى //iqaman number
                    inv.CustomerParty.partyLegalEntity.RegistrationName = !string.IsNullOrEmpty(model.InvoiceSummaryModel.ParentName)
                        ? model.InvoiceSummaryModel.ParentName : !string.IsNullOrEmpty(model.InvoiceSummaryModel.CustomerName)
                        ? model.InvoiceSummaryModel.CustomerName : "";
                }
                else
                {
                    if (!string.IsNullOrEmpty(fatherIQAMA))
                    {
                        inv.CustomerParty.partyLegalEntity.RegistrationName = !string.IsNullOrEmpty(model.InvoiceSummaryModel.ParentName)
                        ? model.InvoiceSummaryModel.ParentName : !string.IsNullOrEmpty(model.InvoiceSummaryModel.CustomerName)
                        ? model.InvoiceSummaryModel.CustomerName : "";
                        inv.CustomerParty.partyIdentification.ID = fatherIQAMA;
                        inv.CustomerParty.partyIdentification.schemeID = "NAT"; //رقم السجل التجارى //iqaman number
                        //inv.CustomerParty.partyIdentification.ID = "NAT"; // رقم السجل التجارى الخاص بالمشترى  // iqama number id
                       //inv.CustomerParty.partyIdentification.schemeID = studentParentInfo.FatherIQAMA; //رقم السجل التجارى //iqaman number
                    }
                }

                logger.LogInformation("ZatcaHelper SetCustomerParty- : ID" + inv.CustomerParty.partyIdentification.ID + ", schemeID: " + inv.CustomerParty.partyIdentification.schemeID + ", isVatAvailable: " + isVatAvailable);

				inv.CustomerParty.postalAddress.StreetName = "";// اجبارى
                    //inv.CustomerParty.postalAddress.AdditionalStreetName = "street name"; // اختيارى
                inv.CustomerParty.postalAddress.CityName = "RIYADH"; // اسم المدينة
                

                inv.CustomerParty.postalAddress.BuildingNumber = ""; // اجبارى رقم المبنى
                inv.CustomerParty.postalAddress.PlotIdentification = ""; // اختيارى رقم القطعة

                inv.CustomerParty.postalAddress.PostalZone = "";
                // الرقم البريدي
                //inv.CustomerParty.postalAddress.CountrySubentity = "Makkah"; // اسم المحافظة او المدينة مثال (مكة) اختيارى
                inv.CustomerParty.postalAddress.CitySubdivisionName = ""; // اسم المنطقة او الحى 
                inv.CustomerParty.postalAddress.country.IdentificationCode = "SA";

                //inv.CustomerParty.partyLegalEntity.RegistrationName = ""; // اسم الشركة المسجل فى الهيئة
                inv.CustomerParty.partyTaxScheme.CompanyID = "";// studentParentInfo.FatherIQAMA; // رقم التسجيل الضريبي

            }
            catch (Exception ex)
            {
                logger.LogError("ZatcaHelper SetCustomerParty- Error: " + ex.Message);
                throw ex;
            }
            logger.LogInformation("End: ZatcaHelper SetCustomerParty");
        }
        //private void SetCustomerParty(Invoice inv, InvoiceModel model, VWInvoiceModel vWInvoiceModel)
        //{
        //	logger.LogInformation("Start: ZatcaHelper SetCustomerParty");
        //	try
        //	{
        //		//NAT = for Saudi National
        //		//IQA for Non Saudi
        //		var fatherIQAMA = "";
        //		string parentname = "";
        //		if (vWInvoiceModel == null && model.InvoiceSummaryModel == null)
        //		{
        //			//no father iqama available;
        //			fatherIQAMA = "";
        //		}
        //		else if (vWInvoiceModel != null && !string.IsNullOrEmpty(vWInvoiceModel.FatherIQAMA))
        //		{
        //			fatherIQAMA = vWInvoiceModel.FatherIQAMA;
        //		}
        //		else if (model != null && model.InvoiceSummaryModel != null)
        //		{
        //			fatherIQAMA = model.InvoiceSummaryModel.IqamaNumber;
        //		}

        //		var isVatAvailable = model.InvoiceDetailModelLst.Any(s => s.TaxRate > 0);

        //		if (!isVatAvailable)
        //		{
        //			isVatAvailable = model.UniformDetailModelLst.Any(s => !string.IsNullOrEmpty(s.TaxRate) && Convert.ToDecimal(s.TaxRate) > 0);
        //		}

        //		if (model.UniformDetailModelLst.Any() && !string.IsNullOrEmpty(fatherIQAMA))
        //		{
        //			//inv.CustomerParty.partyIdentification.ID = "IQA"; // رقم السجل التجارى الخاص بالمشترى  // iqama number id
        //			//inv.CustomerParty.partyIdentification.schemeID = studentParentInfo.FatherIQAMA; //رقم السجل التجارى //iqaman number
        //			inv.CustomerParty.partyIdentification.ID = fatherIQAMA;
        //			inv.CustomerParty.partyIdentification.schemeID = "IQA"; //رقم السجل التجارى //iqaman number
        //                  inv.CustomerParty.partyLegalEntity.RegistrationName =!string.IsNullOrEmpty(model.InvoiceSummaryModel.ParentName) 
        //				? model.InvoiceSummaryModel.ParentName : !string.IsNullOrEmpty(model.InvoiceSummaryModel.CustomerName)
        //				? model.InvoiceSummaryModel.CustomerName :"";
        //              }
        //		else if (isVatAvailable)// when VAT amount is already paid then no need of iqama number
        //		{
        //			if (vWInvoiceModel != null)
        //			{
        //				//inv.CustomerParty.partyIdentification.ID = "IQA"; // رقم السجل التجارى الخاص بالمشترى  // iqama number id
        //				//inv.CustomerParty.partyIdentification.schemeID = studentParentInfo.FatherIQAMA; //رقم السجل التجارى //iqaman number
        //				inv.CustomerParty.partyIdentification.ID = fatherIQAMA;
        //				inv.CustomerParty.partyIdentification.schemeID = "IQA"; //رقم السجل التجارى //iqaman number
        //                      inv.CustomerParty.partyLegalEntity.RegistrationName = !string.IsNullOrEmpty(model.InvoiceSummaryModel.ParentName)
        //                      ? model.InvoiceSummaryModel.ParentName : !string.IsNullOrEmpty(model.InvoiceSummaryModel.CustomerName)
        //                      ? model.InvoiceSummaryModel.CustomerName : "";
        //                  }
        //		}
        //		else
        //		{
        //			if (!string.IsNullOrWhiteSpace(fatherIQAMA))
        //			{
        //                      inv.CustomerParty.partyLegalEntity.RegistrationName = !string.IsNullOrEmpty(model.InvoiceSummaryModel.ParentName)
        //                      ? model.InvoiceSummaryModel.ParentName : !string.IsNullOrEmpty(model.InvoiceSummaryModel.CustomerName)
        //                      ? model.InvoiceSummaryModel.CustomerName : ""; 
        //				inv.CustomerParty.partyIdentification.ID = fatherIQAMA;
        //				inv.CustomerParty.partyIdentification.schemeID = "NAT"; //رقم السجل التجارى //iqaman number
        //																		//inv.CustomerParty.partyIdentification.ID = "NAT"; // رقم السجل التجارى الخاص بالمشترى  // iqama number id
        //																		//inv.CustomerParty.partyIdentification.schemeID = studentParentInfo.FatherIQAMA; //رقم السجل التجارى //iqaman number
        //			}
        //		}

        //		logger.LogInformation("ZatcaHelper SetCustomerParty- : ID" + inv.CustomerParty.partyIdentification.ID + ", schemeID: " + inv.CustomerParty.partyIdentification.schemeID + ", isVatAvailable: " + isVatAvailable);

        //		if (vWInvoiceModel != null && vWInvoiceModel?.Address != vWInvoiceModel.FatherIQAMA)
        //		{
        //			inv.CustomerParty.postalAddress.StreetName = string.IsNullOrEmpty(vWInvoiceModel?.Address) ? string.Empty : vWInvoiceModel?.Address;
        //			// اجبارى
        //			//inv.CustomerParty.postalAddress.AdditionalStreetName = "street name"; // اختيارى
        //			inv.CustomerParty.postalAddress.CityName = " RIYADH, SAUDI ARABIA"; // اسم المدينة
        //		}
        //		else
        //		{
        //			inv.CustomerParty.postalAddress.StreetName = string.Empty;
        //			inv.CustomerParty.postalAddress.CityName = " RIYADH, SAUDI ARABIA"; // اسم المدينة
        //		}

        //		inv.CustomerParty.postalAddress.BuildingNumber = ""; // اجبارى رقم المبنى
        //		inv.CustomerParty.postalAddress.PlotIdentification = ""; // اختيارى رقم القطعة

        //		inv.CustomerParty.postalAddress.PostalZone = "";
        //		// الرقم البريدي
        //		//inv.CustomerParty.postalAddress.CountrySubentity = "Makkah"; // اسم المحافظة او المدينة مثال (مكة) اختيارى
        //		inv.CustomerParty.postalAddress.CitySubdivisionName = ""; // اسم المنطقة او الحى 
        //		inv.CustomerParty.postalAddress.country.IdentificationCode = "SA";

        //              //inv.CustomerParty.partyLegalEntity.RegistrationName = ""; // اسم الشركة المسجل فى الهيئة
        //              inv.CustomerParty.partyTaxScheme.CompanyID = "";// studentParentInfo.FatherIQAMA; // رقم التسجيل الضريبي

        //		inv.CustomerParty.contact = new Contact()
        //		{
        //			Name = (model != null && model.InvoiceSummaryModel != null && !string.IsNullOrEmpty(model.InvoiceSummaryModel.ParentName))
        //			? model.InvoiceSummaryModel.ParentName : ((vWInvoiceModel != null && !string.IsNullOrEmpty(vWInvoiceModel.ParentName)) ? vWInvoiceModel.ParentName : string.Empty),
        //			//ElectronicMail = (model != null && model.InvoiceSummaryModel != null && !string.IsNullOrEmpty(model.InvoiceSummaryModel.EmailID))
        //			//? model.InvoiceSummaryModel.EmailID : ((vWInvoiceModel != null && !string.IsNullOrEmpty(vWInvoiceModel.EmailID)) ? vWInvoiceModel.EmailID : string.Empty),
        //			Telephone = (model != null && model.InvoiceSummaryModel != null && !string.IsNullOrEmpty(model.InvoiceSummaryModel.MobileNo))
        //			? model.InvoiceSummaryModel.MobileNo : ((vWInvoiceModel != null && !string.IsNullOrEmpty(vWInvoiceModel.MobileNo)) ? vWInvoiceModel.MobileNo : string.Empty),
        //		};

        //		inv.CustomerParty.contact.Telephone = inv.CustomerParty.contact.Telephone.Replace(" ", "");

        //	}
        //	catch (Exception ex)
        //	{
        //		logger.LogError("ZatcaHelper SetCustomerParty- Error: " + ex.Message);
        //		throw ex;
        //	}
        //	logger.LogInformation("End: ZatcaHelper SetCustomerParty");
        //}
        private void SetPaymentMethod(Invoice inv, InvoiceModel model)
        {
            logger.LogInformation("Start: ZatcaHelper SetPaymentMethod");
            try
            {
                //PaymentMeansCode payment method codes
                //10 In cash
                //30 Credit
                //42 Payment to bank account
                //48 Bank card
                //1 Instrument Not defined(Free text)
                string PaymentCode = "";

				string paymentname = !string.IsNullOrEmpty(model.InvoiceSummaryModel.PaymentMethod) ?
					model.InvoiceSummaryModel.PaymentMethod.ToLower().ToLower()
					: "cash";

                if (paymentname == "cash")
                    PaymentCode = "10";
                else if (paymentname=="cheque no")
                    PaymentCode = "30";
                else if (paymentname=="wire transfer")
                    PaymentCode = "42";
                else if (paymentname== "card")
                    PaymentCode = "48";
                else
                    PaymentCode = "10";

                PaymentMeans paymentMeans = new PaymentMeans
                    {
                        PaymentMeansCode = PaymentCode // optional for invoices - mandatory for return invoice - debit notes
                    };
                    if (inv.invoiceTypeCode.id == 383 || inv.invoiceTypeCode.id == 381)
                    {
                        paymentMeans.InstructionNote =!String.IsNullOrEmpty(model.InvoiceSummaryModel.CreditReason)? model.InvoiceSummaryModel.CreditReason .Trim(): "Return Invoice"; //the reason of return invoice - debit notes // manatory only for return invoice - debit notes 
                    }
                    inv.paymentmeans.Add(paymentMeans);
                
                
            }
            catch (Exception ex)
            {
                logger.LogError("ZatcaHelper SetPaymentMethod- Error: " + ex.Message);
                throw ex;
            }
            logger.LogInformation("End: ZatcaHelper SetPaymentMethod");
        }
        //private void SetPaymentMethod(Invoice inv, InvoiceModel model)
        //{
        //	logger.LogInformation("Start: ZatcaHelper SetPaymentMethod");
        //	try
        //	{
        //		//PaymentMeansCode payment method codes
        //		//10 In cash
        //		//30 Credit
        //		//42 Payment to bank account
        //		//48 Bank card
        //		//1 Instrument Not defined(Free text)
        //		string PaymentCode = "";



        //		var paymentMethodList = (from pay in _ALSContextDB.TblPaymentMethods.AsQueryable()
        //								 join payCat in _ALSContextDB.TblPaymentMethodCategories.AsQueryable()
        //								 on pay.PaymentMethodCategoryId equals payCat.PaymentMethodCategoryId
        //								 select new
        //								 {
        //									 pay.PaymentMethodCategoryId,
        //									 pay.PaymentMethodId,
        //									 pay.PaymentMethodName,
        //									 payCat.CategoryName
        //								 })
        //								 .ToList();

        //		if (paymentMethodList.Any(s => s.PaymentMethodName.ToLower() == model.InvoiceSummaryModel.PaymentMethod.ToLower() && s.CategoryName.ToLower() == "cash"))
        //			PaymentCode = "10";
        //		//else if (model.InvoiceSummaryModel.PaymentMethod.ToLower() == "credit")
        //		else if (paymentMethodList.Any(s => s.PaymentMethodName.ToLower() == model.InvoiceSummaryModel.PaymentMethod.ToLower() && s.CategoryName.ToLower() == "cheque no"))
        //			PaymentCode = "30";
        //		//else if (model.InvoiceSummaryModel.PaymentMethod.ToLower() == "bank transfer" || model.InvoiceSummaryModel.PaymentMethod == "Check")
        //		else if (paymentMethodList.Any(s => s.PaymentMethodName.ToLower() == model.InvoiceSummaryModel.PaymentMethod.ToLower() && s.CategoryName.ToLower() == "wire transfer"))
        //			PaymentCode = "42";
        //		//else if (model.InvoiceSummaryModel.PaymentMethod == "Visa" || model.InvoiceSummaryModel.PaymentMethod == "Mada" || model.InvoiceSummaryModel.PaymentMethod == "Master")
        //		else if (paymentMethodList.Any(s => s.PaymentMethodName.ToLower() == model.InvoiceSummaryModel.PaymentMethod.ToLower() && s.CategoryName.ToLower() == "card"))
        //			PaymentCode = "48";
        //		else
        //			PaymentCode = "";

        //		if (!string.IsNullOrEmpty(PaymentCode))
        //		{
        //			PaymentMeans paymentMeans = new PaymentMeans
        //			{
        //				PaymentMeansCode = PaymentCode // optional for invoices - mandatory for return invoice - debit notes
        //			};
        //			if (inv.invoiceTypeCode.id == 383 || inv.invoiceTypeCode.id == 381)
        //			{
        //				paymentMeans.InstructionNote = "dameged items"; //the reason of return invoice - debit notes // manatory only for return invoice - debit notes 
        //			}
        //			inv.paymentmeans.Add(paymentMeans);
        //		}
        //		else
        //		{
        //			var paymentMethodListNew = (from pay in _ALSContextDB.TblPaymentMethods.AsQueryable()
        //										join payCat in _ALSContextDB.TblPaymentMethodCategories.AsQueryable()
        //										on pay.PaymentMethodCategoryId equals payCat.PaymentMethodCategoryId
        //										select new
        //										{
        //											pay.PaymentMethodCategoryId,
        //											pay.PaymentMethodId,
        //											pay.PaymentMethodName,
        //											payCat.CategoryName
        //										})
        //									 .ToList();

        //			//new invoice school db
        //			foreach (var item in model.InvoicePaymentModelLst)
        //			{
        //				if (paymentMethodListNew.Any(s => (s.PaymentMethodName == item.PaymentMethod.ToLower() || item.PaymentMethodId == s.PaymentMethodId) && s.CategoryName.ToLower() == "cash"))
        //					PaymentCode = "10";
        //				//else if (model.InvoiceSummaryModel.PaymentMethod.ToLower() == "credit")
        //				else if (paymentMethodListNew.Any(s => (s.PaymentMethodName == item.PaymentMethod.ToLower() || item.PaymentMethodId == s.PaymentMethodId) && s.CategoryName.ToLower() == "cheque no"))
        //					PaymentCode = "30";
        //				//else if (model.InvoiceSummaryModel.PaymentMethod.ToLower() == "bank transfer" || model.InvoiceSummaryModel.PaymentMethod == "Check")
        //				else if (paymentMethodListNew.Any(s => (s.PaymentMethodName == item.PaymentMethod.ToLower() || item.PaymentMethodId == s.PaymentMethodId) && s.CategoryName.ToLower() == "wire transfer"))
        //					PaymentCode = "42";
        //				//else if (model.InvoiceSummaryModel.PaymentMethod == "Visa" || model.InvoiceSummaryModel.PaymentMethod == "Mada" || model.InvoiceSummaryModel.PaymentMethod == "Master")
        //				else if (paymentMethodListNew.Any(s => (s.PaymentMethodName == item.PaymentMethod.ToLower() || item.PaymentMethodId == s.PaymentMethodId) && s.CategoryName.ToLower() == "card"))
        //					PaymentCode = "48";
        //				else
        //					PaymentCode = "";

        //				if (!string.IsNullOrEmpty(PaymentCode))
        //				{
        //					PaymentMeans paymentMeans = new PaymentMeans
        //					{
        //						PaymentMeansCode = PaymentCode // optional for invoices - mandatory for return invoice - debit notes
        //					};
        //					if (inv.invoiceTypeCode.id == 383 || inv.invoiceTypeCode.id == 381)
        //					{
        //						paymentMeans.InstructionNote = "dameged items"; //the reason of return invoice - debit notes // manatory only for return invoice - debit notes 
        //					}
        //					inv.paymentmeans.Add(paymentMeans);
        //				}
        //			}
        //		}
        //	}
        //	catch (Exception ex)
        //	{
        //		logger.LogError("ZatcaHelper SetPaymentMethod- Error: " + ex.Message);
        //		throw ex;
        //	}
        //	logger.LogInformation("End: ZatcaHelper SetPaymentMethod");
        //}

        private void SetInvoiceHash(Invoice inv, InvoiceModel model, InvoiceModel previousInvoiceModel)
		{
			logger.LogInformation("Start: ZatcaHelper SetInvoiceHash");
			try
			{
				if (previousInvoiceModel != null && previousInvoiceModel.InvoiceSummaryModel != null && !string.IsNullOrEmpty(previousInvoiceModel.InvoiceSummaryModel.InvoiceHash))//&& !previousInvoiceModel.isFirstZatcaInvoice
				{
					//TODO: Add new field in table
					//inv.AdditionalDocumentReferencePIH.EmbeddedDocumentBinaryObject = previousInvoiceModel.EmbeddedDocumentBinaryObject;
					inv.AdditionalDocumentReferencePIH.EmbeddedDocumentBinaryObject = previousInvoiceModel.InvoiceSummaryModel.InvoiceHash;
					inv.AdditionalDocumentReferenceICV.UUID = Convert.ToInt32(previousInvoiceModel.InvoiceSummaryModel.InvoiceNo);
					//inv.AdditionalDocumentReferencePIH.ID = previousInvoiceModel.InvoiceSummaryModel.UUID;
				}
				else
				{
					// هنا ممكن اضيف ال pih من قاعدة البيانات  
					//this is previous invoice hash (the invoice hash of last invoice ) res.InvoiceHash
					// for the first invoice and because there is no previous hash we must write this code "NWZlY2ViNjZmZmM4NmYzOGQ5NTI3ODZjNmQ2OTZjNzljMmRiYzIzOWRkNGU5MWI0NjcyOWQ3M2EyN2ZiNTdlOQ=="
					inv.AdditionalDocumentReferencePIH.EmbeddedDocumentBinaryObject = "NWZlY2ViNjZmZmM4NmYzOGQ5NTI3ODZjNmQ2OTZjNzljMmRiYzIzOWRkNGU5MWI0NjcyOWQ3M2EyN2ZiNTdlOQ==";
					// قيمة عداد الفاتورة
					// Invoice counter (1,2,3,4) this counter must start from 1 for each CSID
					//inv.AdditionalDocumentReferenceICV.UUID = (model.InvoiceId); // لابد ان يكون ارقام فقط must be numbers only
					inv.AdditionalDocumentReferenceICV.UUID = Convert.ToInt32(model.InvoiceSummaryModel.InvoiceNo); // لابد ان يكون ارقام فقط must be numbers only
				}
			}
			catch (Exception ex)
			{
				logger.LogError("ZatcaHelper SetInvoiceHash- Error: " + ex.Message);
				throw ex;
			}
			logger.LogInformation("End: ZatcaHelper SetInvoiceHash");
		}

		private void SetInvoiceDocumentReference(Invoice inv, InvoiceModel model)
		{
			logger.LogInformation("Start: ZatcaHelper SetInvoiceDocumentReference");
			try
			{
				//inv.CurrencyRate = 3.75m; // incase of DocumentCurrencyCode equal any currency code not SAR we must mention CurrencyRate value
				if (inv.invoiceTypeCode.id == 383 || inv.invoiceTypeCode.id == 381)
				{
					// فى حالة ان اشعار دائن او مدين فقط هانكتب رقم الفاتورة اللى اصدرنا الاشعار ليها
					// in case of return sales invoice or debit notes we must mention the original sales invoice number
					string ref_no = (model.InvoiceSummaryModel.InvoiceRefNo.HasValue && model.InvoiceSummaryModel.InvoiceRefNo.Value > 0)
						? model.InvoiceSummaryModel.InvoiceRefNo.ToString() : "";


                    InvoiceDocumentReference invoiceDocumentReference = new InvoiceDocumentReference
					{
						ID = $"Invoice Number: {ref_no}" // mandatory in case of return sales invoice or debit notes
					};
					inv.billingReference.invoiceDocumentReferences.Add(invoiceDocumentReference);
				}
			}
			catch (Exception ex)
			{
				logger.LogError("ZatcaHelper SetInvoiceDocumentReference- Error: " + ex.Message);
				throw ex;
			}
			logger.LogInformation("End: ZatcaHelper SetInvoiceDocumentReference");
		}

		private void SetInvoiceType(Invoice inv, InvoiceModel model)
		{
			logger.LogInformation("Start: ZatcaHelper SetInvoiceType");
			try
			{
				//all needed codes for invoiceTypeCode id
				// 388 sales invoice  
				// 383 debit note
				// 381 credit note
				// get invoice type 

				// inv.invoiceTypeCode.Name based on format NNPNESB
				// NN 01 standard invoice 
				// NN 02 simplified invoice
				// P فى حالة فاتورة لطرف ثالث نكتب 1 فى الحالة الاخرى نكتب 0
				// N فى حالة فاتورة اسمية نكتب 1 وفى الحالة الاخرى نكتب 0
				// E فى حالة فاتورة للصادرات نكتب 1 وفى الحالة الاخرى نكتب 0
				// S فى حالة فاتورة ملخصة نكتب 1 وفى الحالة الاخرى نكتب 0
				// B فى حالة فاتورة ذاتية نكتب 1
				// B فى حالة ان الفاتورة صادرات=1 لايمكن ان تكون الفاتورة ذاتية =1

				//if (model.InvoiceType == (int)enumInvoiceType.SimplifiedInvoice)
				//{
				//    inv.invoiceTypeCode.id = 388;
				//    inv.invoiceTypeCode.Name = "0200000";
				//}
				//else if (model.InvoiceType == (int)enumInvoiceType.StandardInvoice)
				//{
				//    inv.invoiceTypeCode.id = 388;
				//    inv.invoiceTypeCode.Name = "0100000";
				//}

				//else if (model.InvoiceType == (int)enumInvoiceType.SimplifiedDebitNote)
				//{
				//    inv.invoiceTypeCode.id = 383;
				//    inv.invoiceTypeCode.Name = "0200000";
				//}
				//else if (model.InvoiceType == (int)enumInvoiceType.StandardDebitNote)
				//{
				//    inv.invoiceTypeCode.id = 383;
				//    inv.invoiceTypeCode.Name = "0100000";
				//}

				//else if (model.InvoiceType == (int)enumInvoiceType.SimplifiedCreditNote)
				//{
				//    inv.invoiceTypeCode.id = 381;
				//    inv.invoiceTypeCode.Name = "0200000";
				//}
				//else if (model.InvoiceType == (int)enumInvoiceType.StandardCreditNote)
				//{
				//    inv.invoiceTypeCode.id = 381;
				//    inv.invoiceTypeCode.Name = "0100000";
				//}
				//else
				//{
				//    inv.invoiceTypeCode.id = 388;
				//    inv.invoiceTypeCode.Name = "0100000";
				//}


				//else if (model.InvoiceType == (int)enumInvoiceType.StandardInvoice)
				//{
				//    inv.invoiceTypeCode.id = 388;
				//    inv.invoiceTypeCode.Name = "0100000";
				//}

				//else if (model.InvoiceType == (int)enumInvoiceType.SimplifiedDebitNote)
				//{
				//    inv.invoiceTypeCode.id = 383;
				//    inv.invoiceTypeCode.Name = "0200000";
				//}
				//else if (model.InvoiceType == (int)enumInvoiceType.StandardDebitNote)
				//{
				//    inv.invoiceTypeCode.id = 383;
				//    inv.invoiceTypeCode.Name = "0100000";
				//}


				//else if (model.InvoiceType == (int)enumInvoiceType.StandardCreditNote)
				//{
				//    inv.invoiceTypeCode.id = 381;
				//    inv.invoiceTypeCode.Name = "0100000";
				//}

				if (model.InvoiceSummaryModel.InvoiceType != "Return" && 
					 model.InvoiceDetailModelLst.Any(s => s.InvoiceType.ToString().ToLower().Contains("fee"))
                )
				{
					inv.invoiceTypeCode.id = 388;
					inv.invoiceTypeCode.Name = "0200000";
				}
				else if (model.InvoiceSummaryModel.InvoiceType == "Return")
				{
					inv.invoiceTypeCode.id = 381;
					inv.invoiceTypeCode.Name = "0200000";
				}
				else
				{
					inv.invoiceTypeCode.id = 388;
					inv.invoiceTypeCode.Name = "0200000";
				}

				if (inv.invoiceTypeCode.Name.Substring(0, 2) == "01")
				{
					//supply date mandatory only for standard invoices
					// فى حالة فاتورة مبسطة وفاتورة ملخصة هانكتب تاريخ التسليم واخر تاريخ التسليم
					inv.delivery.ActualDeliveryDate = DateTime.Now.ToString("yyyy-MM-dd");// "2022-10-22"; //TODO
					inv.delivery.LatestDeliveryDate = DateTime.Now.ToString("yyyy-MM-dd");//"2022-10-23"; //TODO
				}
				if (inv.invoiceTypeCode.id == 381 || inv.invoiceTypeCode.id == 383)
				{

				}
			}
			catch (Exception ex)
			{
				logger.LogError("ZatcaHelper SetInvoiceType- Error: " + ex.Message);
				throw ex;
			}
			logger.LogInformation("End: ZatcaHelper SetInvoiceType");
		}

		private void SetCalculateLineItems(Invoice inv, InvoiceModel model)
		{
			logger.LogInformation("Start: ZatcaHelper SetCalculateLineItems");
			try
			{
				//this is the invoice total amount (invoice total with vat) and you can set its value with Zero and i will calculate it from sdk
				//inv.legalMonetaryTotal.PayableAmount = model.InvoiceDetailModelLst.Sum(s => s.TaxableAmount);
				//inv.legalMonetaryTotal.PayableAmount = 0;
				//inv.legalMonetaryTotal.PayableAmount = model.InvoiceDetailModelLst.Sum(s => s.ItemSubtotal);
				inv.legalMonetaryTotal.PayableAmount = model.InvoiceDetailModelLst.Sum(s => s.ItemSubtotal);

				var isVatAvailable = model.InvoiceDetailModelLst.Any(s => s.TaxRate > 0);

				//if (model.UniformDetailModelLst.Any())
				//{
				//	foreach (UniformDetailModel item in model.UniformDetailModelLst)
				//	{
				//		var quanitty = string.IsNullOrEmpty(item.Quantity) ? 1 : Convert.ToDecimal(item.Quantity);
				//		InvoiceLine invline = new InvoiceLine
				//		{
				//			//invline.InvoiceQuantity = item.ProductQuantity;
				//			InvoiceQuantity = quanitty
				//		};
				//		invline.item.Name = item.Description;

				//		//TODO: Uniform/Fee/Return
				//		if (Convert.ToDecimal(item.TaxRate) == 0)
				//		{
				//			//TODO
				//			invline.item.classifiedTaxCategory.ID = "Z"; // كود الضريبة
				//														 //TODO
				//			invline.taxTotal.TaxSubtotal.taxCategory.ID = "Z"; // كود الضريبة
				//			invline.taxTotal.TaxSubtotal.taxCategory.TaxExemptionReasonCode = "VATEX-SA-EDU"; // كود الضريبة    

				//			//TO: Make sellerinfo for Industry
				//			invline.taxTotal.TaxSubtotal.taxCategory.TaxExemptionReason = "Private education to citizen"; // كود الضريبة   
				//		}
				//		else
				//		{
				//			//TODO
				//			invline.item.classifiedTaxCategory.ID = "S"; // كود الضريبة

				//			//TODO6
				//			invline.taxTotal.TaxSubtotal.taxCategory.ID = "S"; // كود الضريبة
				//		}

				//		invline.item.classifiedTaxCategory.Percent = Convert.ToDecimal(item.TaxRate); // نسبة الضريبة
				//		invline.taxTotal.TaxSubtotal.taxCategory.Percent = Convert.ToDecimal(item.TaxRate); // نسبة الضريبة

				//		invline.price.EncludingVat = false;
				//		invline.price.PriceAmount = Convert.ToDecimal(item.TaxableAmount);  // Make it TaxableAmount

				//		//invline.price.BaseQuantity = item.ProductQuantity;
				//		invline.price.BaseQuantity = quanitty;

				//		decimal invoicediscount = string.IsNullOrEmpty(item.Discount) ? 0 : Convert.ToDecimal(item.Discount);

				//		if (invoicediscount > 0)
				//		{
				//			AllowanceCharge allowanceCharge = new AllowanceCharge
				//			{
				//				// فى حالة الرسوم
				//				// allowanceCharge.ChargeIndicator = true;
				//				// فى حالة الخصم
				//				ChargeIndicator = false,

				//				AllowanceChargeReason = "discount", // سبب الخصم على مستوى المنتج
				//													// allowanceCharge.AllowanceChargeReasonCode = "90"; // سبب الخصم على مستوى المنتج
				//				Amount = invoicediscount, // قيم الخصم

				//				MultiplierFactorNumeric = 0,
				//				BaseAmount = 0
				//			};
				//			invline.allowanceCharges.Add(allowanceCharge);
				//		}
				//		inv.InvoiceLines.Add(invline);
				//	}
				//}

				foreach (InvoiceDetailModel item in model.InvoiceDetailModelLst)
				{
                    var quanitty = item.Quantity <=0 ?1 : item.Quantity;

                    InvoiceLine invline = new InvoiceLine
					{
						InvoiceQuantity = quanitty
                    };
					invline.item.Name = string.IsNullOrEmpty(item.Description)? item.InvoiceType : item.Description;

					//TODO: Uniform/Fee/Return
					if (item.TaxRate == 0 )
					{
						//TODO
						invline.item.classifiedTaxCategory.ID = "Z"; // كود الضريبة
																	 //TODO
						invline.taxTotal.TaxSubtotal.taxCategory.ID = "Z"; // كود الضريبة
						invline.taxTotal.TaxSubtotal.taxCategory.TaxExemptionReasonCode = "VATEX-SA-EDU"; // كود الضريبة    

						//TO: Make sellerinfo for Industry
						invline.taxTotal.TaxSubtotal.taxCategory.TaxExemptionReason = "Private education to citizen"; // كود الضريبة   
					}
					else
					{
						//TODO
						invline.item.classifiedTaxCategory.ID = "S"; // كود الضريبة
																	 //TODO
						invline.taxTotal.TaxSubtotal.taxCategory.ID = "S"; // كود الضريبة

                    }

					invline.item.classifiedTaxCategory.Percent = item.TaxRate; // نسبة الضريبة
					invline.taxTotal.TaxSubtotal.taxCategory.Percent = item.TaxRate; // نسبة الضريبة
					//invline.taxTotal.TaxSubtotal.TaxAmount = item.TaxAmount;
					invline.price.EncludingVat = false;
					invline.price.PriceAmount = item.UnitPrice;  // Make it TaxableAmount

					//invline.price.BaseQuantity = item.ProductQuantity;
					invline.price.BaseQuantity = 1;

					//decimal invoicediscount = model.InvoiceDetailModelLst.Where(s => !s.Description.ToLower().Contains("uniform")).Sum(s => s.Discount);
					decimal invoicediscount = item.Discount;

					if (invoicediscount > 0)
					{
						AllowanceCharge allowanceCharge = new AllowanceCharge
						{
							// فى حالة الرسوم
							// allowanceCharge.ChargeIndicator = true;
							// فى حالة الخصم
							ChargeIndicator = false,

							AllowanceChargeReason = "discount", // سبب الخصم على مستوى المنتج
																// allowanceCharge.AllowanceChargeReasonCode = "90"; // سبب الخصم على مستوى المنتج
							Amount = invoicediscount, // قيم الخصم

							MultiplierFactorNumeric = 0,
							BaseAmount = 0
						};
						invline.allowanceCharges.Add(allowanceCharge);
					}
					inv.InvoiceLines.Add(invline);
				}
			}
			catch (Exception ex)
			{
				logger.LogError("ZatcaHelper SetCalculateLineItems- Error: " + ex.Message);
				throw ex;
			}
			logger.LogInformation("End: ZatcaHelper SetCalculateLineItems");
		}

		private void SetCalculateDisocunt(Invoice inv, InvoiceModel model)
		{
			logger.LogInformation("Start: ZatcaHelper SetCalculateDisocunt");
			//decimal invoicediscount = model != null && model.InvoiceDetailModelLst != null && model.InvoiceDetailModelLst.Any() ? model.InvoiceDetailModelLst.Where(s => s.Discount != null).Sum(s => s.Discount) : 0;
			//if (invoicediscount > 0)
			//{
			//    AllowanceCharge allowance = new AllowanceCharge
			//    {
			//        ChargeIndicator = false,
			//        //write this lines in case you will make discount as percentage
			//        MultiplierFactorNumeric = 0, //dscount percentage like 10
			//        BaseAmount = 0, // the amount we will apply percentage on example (MultiplierFactorNumeric=10 ,BaseAmount=1000 then AllowanceAmount will be 100 SAR)

			//        // in case we will make discount as Amount 
			//        Amount = invoicediscount, // 
			//        AllowanceChargeReasonCode = "", //سبب الخصم
			//        AllowanceChargeReason = "discount" //سبب الخصم
			//    };
			//    allowance.taxCategory.ID = "S";// كود الضريبة

			//    //TODO
			//    //var taxRate = model.InvoiceDetailModelLst.FirstOrDefault(s => s.TaxRate > 0);
			//    //allowance.taxCategory.Percent = taxRate == null ? 0 : taxRate.TaxRate;
			//    // نسبة الضريبة
			//    //فى حالة عندى اكثر من خصم بعمل loop على الاسطر السابقة
			//    inv.allowanceCharges.Add(allowance);
			//}
			logger.LogInformation("End: ZatcaHelper SetCalculateDisocunt");
		}

		#endregion Zatca property Set Property

		#region QR Code
		//public Bitmap QrCodeImage(string Qrcode, int width = 250, int height = 250)
		//{

		//    BarcodeWriter barcodeWriter = new BarcodeWriter
		//    {
		//        Format = BarcodeFormat.QR_CODE,
		//        Options = new EncodingOptions
		//        {
		//            Width = width,
		//            Height = height
		//        }
		//    };
		//    Bitmap QrCode = barcodeWriter.Write(Qrcode);

		//    return QrCode;
		//}
		private Tuple<string, byte[]> QrCodeImage(string Qrcode, int width = 200, int height = 200)
		{
			string qrImg;
			BarcodeWriter barcodeWriter = new BarcodeWriter
			{
				Format = BarcodeFormat.QR_CODE,
				Options = new EncodingOptions
				{
					Width = width,
					Height = height
				}
			};
			Bitmap QrCode = barcodeWriter.Write(Qrcode);
            //Convert bitmap to base64-encoded string
            //using (MemoryStream ms = new MemoryStream())
            //{
            //    QrCode.Save(ms, ImageFormat.Png);
            //    byte[] qrBytes = ms.ToArray();
            //    string base64String = Convert.ToBase64String(qrBytes);
            //    qrImg = $"data:image/png;base64,{base64String}";
            //}
           
            string qrPath = $"{Path.Combine(_env.WebRootPath, "CertificateFolder", "QRImages")}";

			// Ensure the folder exists, create it if it doesn't
			if (!System.IO.Directory.Exists(qrPath))
				System.IO.Directory.CreateDirectory(qrPath);
			string qrFileName = $"QRCode_{DateTime.Now:yyyyMMddHHmmss}.png";
			string qrfilePath = Path.Combine(qrPath, qrFileName);
			byte[] qrBytes;
			using (MemoryStream ms = new MemoryStream())
			{
				QrCode.Save(ms, ImageFormat.Png);
				qrBytes = ms.ToArray();
				System.IO.File.WriteAllBytes(qrfilePath, qrBytes);
			}
			////ImageConverter converter = new ImageConverter();
			////byte[] qrBytes = (byte[])converter.ConvertTo(QrCode, typeof(byte[]));
			//return qrImg;
			Tuple<string, byte[]> tuple = new Tuple<string, byte[]>(qrfilePath, qrBytes);
			return tuple;
		}

		private Tuple<string, byte[]> GetDraftedCodeImage()
		{
			string qrImg;

			string qrPath = $"{Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Configurations", "Images")}";

			// Ensure the folder exists, create it if it doesn't
			if (!System.IO.Directory.Exists(qrPath))
				System.IO.Directory.CreateDirectory(qrPath);
			string qrFileName = $"Draft_image.jpg";
			string qrfilePath = Path.Combine(qrPath, qrFileName);
			byte[] qrBytes = null;


			Tuple<string, byte[]> tuple = new Tuple<string, byte[]>(qrfilePath, qrBytes);
			return tuple;
		}

		private ZatcaResponseModel UpdateZatcaResponseMessgae(bool isSuccess = false, int result = -1, string errorMessage = "Unable to process")
		{
            ZatcaResponseModel zatcaResponse = new ZatcaResponseModel() { IsSuccess = isSuccess, Result = result, ErrorMessage = errorMessage };
			return zatcaResponse;
		}
		#endregion

		public void DeletePreviousGeneratedFile(InvInvoiceSummary item)
		{
			try
			{
				//_logger.LogInformation("Start: Delete file- SignedXMLPath: " + item.SignedXMLPath + ", InvoicePdfPath: " + item.InvoicePdfPath + ", QRCodePath" + item.QRCodePath);
				if (File.Exists(item.SignedXMLPath))
				{
					File.Delete(item.SignedXMLPath);
					logger.LogInformation("File deleted SignedXMLPath: " + item.SignedXMLPath);
				}

				if (File.Exists(item.InvoicePdfPath))
				{
					File.Delete(item.InvoicePdfPath);
					logger.LogInformation("File deleted InvoicePdfPath: " + item.InvoicePdfPath);
				}

				if (File.Exists(item.QRCodePath))
				{
					File.Delete(item.QRCodePath);
					logger.LogInformation("File deleted QRCodePath: " + item.QRCodePath);
				}
			}
			catch (Exception ex)
			{
			}
		}
	}
}